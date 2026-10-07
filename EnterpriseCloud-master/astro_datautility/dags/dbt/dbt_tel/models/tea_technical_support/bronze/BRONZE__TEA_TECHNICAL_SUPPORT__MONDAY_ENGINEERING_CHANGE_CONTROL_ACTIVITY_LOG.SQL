{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MONDAY_ENGINEERING_CHANGE_CONTROL_ACTIVITY_LOG',
    unique_key=['activity_log_id'],
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD
    from {{ source('MONDAY', 'ENGINEERING_CHANGE_CONTROL_ACTIVITY_LOG') }}
    {% if is_tel_incremental() %} where _FILEDATE > (select ifnull(max(_FILEDATE), to_date('1900-01-01')) from {{ this }}) {% endif %}
    qualify row_number() over (partition by JSONFIELD:id::string order by _FILEDATE desc) = 1

),

-- JSONFIELD is VARIANT → access fields directly. Inner `data` is still a JSON string.
extracted_data as (
    select
        _FILENAME, _FILEDATE, _UPLOADDATE,
        JSONFIELD:id::string                    as activity_log_id,
        JSONFIELD:account_id::string            as account_id,
        JSONFIELD:board_id::string              as board_id,
        JSONFIELD:board_name::string            as board_name,
        JSONFIELD:entity::string                as entity,
        JSONFIELD:event::string                 as event_name,
        JSONFIELD:user_id::string               as user_id,
        JSONFIELD:created_at::string            as created_at_raw,
        try_parse_json(JSONFIELD:data::string)  as data_json
    from source_data
    where JSONFIELD is not null
),

enriched_data as (
    select
        e.*,
        to_timestamp_ntz(round(created_at_raw::number / 10000), 3) as created_at,
        case when user_id::number <= 0 then true else false end    as is_system_user,
        case when event_name like 'batch\\_%' escape '\\' then true else false end as is_batch,
        coalesce(
            data_json:pulse_id::string,
            data_json:item_id::string,
            data_json:pulse:id::string
        ) as item_id,
        coalesce(
            data_json:pulse_name::string,
            data_json:item_name::string,
            data_json:pulse:name::string
        ) as item_name,
        data_json:action_record_uuid::string  as action_record_uuid,
        data_json:column_id::string           as column_id,
        data_json:column_title::string        as column_title,
        data_json:column_type::string         as column_type,
        data_json:group_id::string            as group_id,
        coalesce(
            data_json:group_title::string,
            data_json:group_name::string
        ) as group_name
    from extracted_data e
),

-- Step 1 of array handling: flatten every array into a tagged stream of (id, which, value, idx).
-- Each branch uses LATERAL FLATTEN at the top FROM level — Snowflake handles this natively.
flat_unioned as (
    select e.activity_log_id, 'v_chosen'   as which, f.value:name::string         as item_value, f.index as item_idx
    from enriched_data e, lateral flatten(input => e.data_json:value:chosenValues) f
    union all
    select e.activity_log_id, 'pv_chosen',         f.value:name::string,          f.index
    from enriched_data e, lateral flatten(input => e.data_json:previous_value:chosenValues) f
    union all
    select e.activity_log_id, 'v_persons',         f.value:id::string,            f.index
    from enriched_data e, lateral flatten(input => e.data_json:value:personsAndTeams) f
    union all
    select e.activity_log_id, 'pv_persons',        f.value:id::string,            f.index
    from enriched_data e, lateral flatten(input => e.data_json:previous_value:personsAndTeams) f
    union all
    select e.activity_log_id, 'v_linked',          f.value:linkedPulseId::string, f.index
    from enriched_data e, lateral flatten(input => e.data_json:value:linkedPulseIds) f
    union all
    select e.activity_log_id, 'pv_linked',         f.value:linkedPulseId::string, f.index
    from enriched_data e, lateral flatten(input => e.data_json:previous_value:linkedPulseIds) f
),

-- Step 2: pivot-aggregate. Each LISTAGG ignores rows where the CASE returns NULL.
flat_pivoted as (
    select
        activity_log_id,
        listagg(case when which = 'v_chosen'   then item_value end, ', ') within group (order by item_idx) as v_chosen_str,
        listagg(case when which = 'pv_chosen'  then item_value end, ', ') within group (order by item_idx) as pv_chosen_str,
        listagg(case when which = 'v_persons'  then item_value end, ', ') within group (order by item_idx) as v_persons_str,
        listagg(case when which = 'pv_persons' then item_value end, ', ') within group (order by item_idx) as pv_persons_str,
        listagg(case when which = 'v_linked'   then item_value end, ', ') within group (order by item_idx) as v_linked_str,
        listagg(case when which = 'pv_linked'  then item_value end, ', ') within group (order by item_idx) as pv_linked_str
    from flat_unioned
    group by activity_log_id
),

-- Step 3: stitch the aggregated strings back onto every enriched row.
flat_arrays as (
    select
        e.*,
        fp.v_chosen_str,
        fp.pv_chosen_str,
        fp.v_persons_str,
        fp.pv_persons_str,
        fp.v_linked_str,
        fp.pv_linked_str
    from enriched_data e
    left join flat_pivoted fp on e.activity_log_id = fp.activity_log_id
),

value_extraction as (
    select
        *,
        case
            when column_type = 'color' then data_json:value:label:text::string
            when column_type in ('dropdown', 'tag', 'tags') then v_chosen_str
            when column_type in ('multiple-person', 'people', 'person') then
                coalesce(data_json:textual_value::string, v_persons_str)
            when column_type = 'date' then
                trim(coalesce(data_json:value:date::string, '') || ' ' ||
                     coalesce(data_json:value:time::string, ''))
            when column_type = 'timeline' then
                case when data_json:value:from is null and data_json:value:to is null then null
                     else coalesce(data_json:value:from::string, 'open') || ' → ' ||
                          coalesce(data_json:value:to::string, 'open')
                end
            when column_type = 'link' then
                coalesce(data_json:value:text::string, data_json:value:url::string)
            when column_type in ('numeric', 'numbers') then
                coalesce(data_json:value:value::string, data_json:value::string)
            when column_type = 'checkbox' then
                case when data_json:value:checked = true then 'Checked' else 'Unchecked' end
            when column_type = 'rating' then data_json:value:rating::string
            when column_type = 'email' then
                coalesce(data_json:value:email::string, data_json:value:text::string)
            when column_type = 'phone' then
                coalesce(data_json:value:phone::string, data_json:value:text::string)
            when column_type in ('board-relation', 'mirror') then v_linked_str
            else coalesce(
                data_json:textual_value::string,
                data_json:value:text::string,
                data_json:value:name::string,
                data_json:value::string
            )
        end as to_value_typed,

        case
            when column_type = 'color' then data_json:previous_value:label:text::string
            when column_type in ('dropdown', 'tag', 'tags') then pv_chosen_str
            when column_type in ('multiple-person', 'people', 'person') then
                coalesce(data_json:previous_textual_value::string, pv_persons_str)
            when column_type = 'date' then
                trim(coalesce(data_json:previous_value:date::string, '') || ' ' ||
                     coalesce(data_json:previous_value:time::string, ''))
            when column_type = 'timeline' then
                case when data_json:previous_value:from is null and data_json:previous_value:to is null then null
                     else coalesce(data_json:previous_value:from::string, 'open') || ' → ' ||
                          coalesce(data_json:previous_value:to::string, 'open')
                end
            when column_type = 'link' then
                coalesce(data_json:previous_value:text::string, data_json:previous_value:url::string)
            when column_type in ('numeric', 'numbers') then
                coalesce(data_json:previous_value:value::string, data_json:previous_value::string)
            when column_type = 'checkbox' then
                case when data_json:previous_value:checked = true then 'Checked' else 'Unchecked' end
            when column_type = 'rating' then data_json:previous_value:rating::string
            when column_type = 'email' then
                coalesce(data_json:previous_value:email::string, data_json:previous_value:text::string)
            when column_type = 'phone' then
                coalesce(data_json:previous_value:phone::string, data_json:previous_value:text::string)
            when column_type in ('board-relation', 'mirror') then pv_linked_str
            else coalesce(
                data_json:previous_textual_value::string,
                data_json:previous_value:text::string,
                data_json:previous_value:name::string,
                data_json:previous_value::string
            )
        end as from_value_typed
    from flat_arrays
),

final_data as (
    select
        _FILEDATE, _FILENAME, _UPLOADDATE,
        '{{ invocation_id }}' as _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        activity_log_id, account_id, board_id, board_name,
        created_at, event_name, entity, user_id, is_system_user, is_batch,
        action_record_uuid, item_id, item_name,
        column_id, column_title, column_type,
        group_id, group_name,

        case
            when event_name = 'create_pulse'                            then 'Item Created'
            when event_name in ('delete_pulse', 'batch_delete_pulses')  then 'Item Deleted'
            when event_name = 'archive_pulse'                           then 'Item Archived'
            when event_name = 'restore_pulse'                           then 'Item Restored'
            when event_name = 'update_name'                             then 'Item Name'
            when event_name in (
                'move_pulse_into_group', 'move_pulse_from_group',
                'batch_move_pulses_into_group', 'batch_move_pulses_from_group'
            ) then 'Group'
            when event_name in ('update_column_value', 'batch_change_pulses_column_value')
                then coalesce(column_title, 'Column Value')
            when event_name = 'subscribe'    then 'Subscriber Added'
            when event_name = 'unsubscribe'  then 'Subscriber Removed'
            when event_name = 'add_owner'    then 'Owner Added'
            when event_name = 'remove_owner' then 'Owner Removed'
            when event_name = 'create_column'           then 'Column Created'
            when event_name = 'delete_column'           then 'Column Deleted'
            when event_name = 'update_column_name'      then 'Column Renamed'
            when event_name = 'change_column_settings'  then 'Column Settings'
            when event_name = 'create_group'        then 'Group Created'
            when event_name = 'delete_group'        then 'Group Deleted'
            when event_name = 'update_group_name'   then 'Group Renamed'
            when event_name = 'update_group_color'  then 'Group Color'
            when event_name = 'update_board_name'                  then 'Board Renamed'
            when event_name = 'update_board_nickname'              then 'Board Nickname'
            when event_name = 'update_board_permissions'           then 'Board Permissions'
            when event_name = 'update_board_granular_permissions'  then 'Board Permissions'
            when event_name = 'set_entity_board_role'              then 'Board Role'
            when event_name = 'board_disconnect'                   then 'Board Disconnected'
            when event_name = 'board_view_added'      then 'View Added'
            when event_name = 'board_view_changed'    then 'View Changed'
            when event_name = 'board_view_deleted'    then 'View Deleted'
            when event_name = 'board_view_duplicated' then 'View Duplicated'
            when event_name = 'board_view_locked'     then 'View Locked'
            else initcap(replace(event_name, '_', ' '))
        end as category,

        case
            when event_name in (
                'move_pulse_into_group', 'move_pulse_from_group',
                'batch_move_pulses_into_group', 'batch_move_pulses_from_group'
            ) then coalesce(
                data_json:source_group:title::string,
                data_json:source_group:name::string,
                data_json:source_group:id::string
            )
            when event_name in (
                'create_pulse', 'subscribe', 'add_owner',
                'create_column', 'create_group', 'board_view_added'
            ) then null
            when event_name = 'archive_pulse' then 'Active'
            when event_name = 'restore_pulse' then 'Archived'
            when event_name in ('unsubscribe', 'remove_owner') then data_json:subscribed_id::string
            when event_name = 'delete_pulse'        then item_name
            when event_name = 'batch_delete_pulses' then item_name
            when event_name = 'delete_column'       then column_title
            when event_name = 'delete_group'        then group_name
            when event_name = 'board_view_deleted'  then
                coalesce(data_json:view_name::string, data_json:name::string,
                         data_json:previous_value:name::string)
            when event_name = 'update_name' then data_json:previous_value:name::string
            when event_name = 'update_column_name' then
                coalesce(data_json:previous_value:name::string,
                         data_json:previous_value:title::string,
                         data_json:previous_column_title::string)
            when event_name = 'update_group_name' then
                coalesce(data_json:previous_value:title::string,
                         data_json:previous_value:name::string)
            when event_name = 'update_group_color' then
                coalesce(data_json:previous_value:color::string, data_json:previous_color::string)
            when event_name = 'update_board_name' then
                coalesce(data_json:previous_value:name::string, data_json:previous_name::string)
            when event_name = 'update_board_nickname' then
                coalesce(data_json:previous_value:nickname::string, data_json:previous_value:name::string)
            when event_name in ('update_column_value', 'batch_change_pulses_column_value')
                then from_value_typed
            else coalesce(
                data_json:previous_value:name::string,
                data_json:previous_value:title::string,
                data_json:previous_value::string
            )
        end as from_value,

        case
            when event_name in (
                'move_pulse_into_group', 'move_pulse_from_group',
                'batch_move_pulses_into_group', 'batch_move_pulses_from_group'
            ) then coalesce(
                data_json:dest_group:title::string,
                data_json:dest_group:name::string,
                data_json:dest_group:id::string
            )
            when event_name = 'create_pulse' then group_name
            when event_name = 'archive_pulse' then 'Archived'
            when event_name = 'restore_pulse' then 'Active'
            when event_name in (
                'delete_pulse', 'batch_delete_pulses',
                'unsubscribe', 'remove_owner',
                'delete_column', 'delete_group', 'board_view_deleted'
            ) then null
            when event_name in ('subscribe', 'add_owner') then data_json:subscribed_id::string
            when event_name = 'create_column'        then column_title
            when event_name = 'create_group'         then group_name
            when event_name = 'board_view_added'     then
                coalesce(data_json:view_name::string, data_json:name::string,
                         data_json:value:name::string)
            when event_name = 'update_name' then data_json:value:name::string
            when event_name = 'update_column_name' then
                coalesce(data_json:value:name::string, data_json:value:title::string, column_title)
            when event_name = 'update_group_name' then
                coalesce(data_json:value:title::string, data_json:value:name::string, group_name)
            when event_name = 'update_group_color' then
                coalesce(data_json:value:color::string, data_json:new_color::string)
            when event_name = 'update_board_name' then
                coalesce(data_json:value:name::string, data_json:new_name::string, board_name)
            when event_name = 'update_board_nickname' then
                coalesce(data_json:value:nickname::string, data_json:value:name::string)
            when event_name in ('update_column_value', 'batch_change_pulses_column_value')
                then to_value_typed
            else coalesce(
                data_json:value:name::string,
                data_json:value:title::string,
                data_json:value::string
            )
        end as to_value,

        data_json as raw_data
    from value_extraction
),

transform_data as (
    select
        *,
        case
            when event_name = 'create_pulse' then
                coalesce('Created in: ' || to_value, 'Item created')
            when event_name in ('delete_pulse', 'batch_delete_pulses') then 'Item deleted'
            when event_name = 'archive_pulse' then 'Archived'
            when event_name = 'restore_pulse' then 'Restored'
            when event_name in (
                'move_pulse_into_group', 'move_pulse_from_group',
                'batch_move_pulses_into_group', 'batch_move_pulses_from_group'
            ) then coalesce(from_value, '?') || ' → ' || coalesce(to_value, '?')
            when event_name in ('subscribe', 'add_owner') then
                category || ': user ' || coalesce(to_value, '?')
            when event_name in ('unsubscribe', 'remove_owner') then
                category || ': user ' || coalesce(from_value, '?')
            when event_name in ('create_column', 'create_group', 'board_view_added') then
                'Created: ' || coalesce(to_value, '?')
            when event_name in ('delete_column', 'delete_group', 'board_view_deleted') then
                'Deleted: ' || coalesce(from_value, '?')
            when from_value is null and to_value is null then null
            when from_value is null then '(empty) → ' || to_value
            when to_value is null   then from_value || ' → (empty)'
            when from_value = to_value then from_value
            else from_value || ' → ' || to_value
        end as change_summary
    from final_data
),

type_data as (
    select
        cast(_FILEDATE as timestamp_ntz(9)) as _FILEDATE,
        cast(_FILENAME as varchar(16777216)) as _FILENAME,
        cast(_UPLOADDATE as timestamp_ntz(9)) as _UPLOADDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(activity_log_id as varchar(16777216)) as activity_log_id,
        cast(account_id as varchar(16777216)) as account_id,
        cast(board_id as varchar(16777216)) as board_id,
        cast(board_name as varchar(16777216)) as board_name,
        cast(created_at as timestamp_ntz(9)) as created_at,
        cast(event_name as varchar(16777216)) as event_name,
        cast(entity as varchar(16777216)) as entity,
        cast(user_id as varchar(16777216)) as user_id,
        cast(is_system_user as boolean) as is_system_user,
        cast(is_batch as boolean) as is_batch,
        cast(action_record_uuid as varchar(16777216)) as action_record_uuid,
        cast(item_id as varchar(16777216)) as item_id,
        cast(item_name as varchar(16777216)) as item_name,
        cast(column_id as varchar(16777216)) as column_id,
        cast(column_title as varchar(16777216)) as column_title,
        cast(column_type as varchar(16777216)) as column_type,
        cast(group_id as varchar(16777216)) as group_id,
        cast(group_name as varchar(16777216)) as group_name,
        cast(category as varchar(16777216)) as category,
        cast(from_value as varchar(16777216)) as from_value,
        cast(to_value as varchar(16777216)) as to_value,
        cast(change_summary as varchar(16777216)) as change_summary,
        cast(raw_data as variant) as raw_data
    from transform_data
)

select * from type_data