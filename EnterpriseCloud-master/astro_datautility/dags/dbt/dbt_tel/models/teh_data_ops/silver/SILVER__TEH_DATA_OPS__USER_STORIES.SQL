
{{ config(
    alias = 'USER_STORIES',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['CARD_ID'],
    meta = {
        'owners': ['Jay Spiers']
    },
) }}

with card_tags as (
    -- need to split array of tag ids before joining and regrouping into labeled array
    select 
        cards.CARD_ID as CARD_ID,
        array_agg(tag_details.LABEL) as TAG_LABELS,
    from {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_CARDS') }} as cards
    inner join lateral flatten (input => parse_json(cards.TAG_IDS)) as flattened_tags
    left join {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_TAGS') }} as tag_details
        on flattened_tags.VALUE = tag_details.TAG_ID
    group by all
),

card_fields as (
    -- need to split object of field/value ids before joining and regrouping into labeled object
    select 
        cards.CARD_ID as CARD_ID,
        object_agg(field_details.NAME::VARIANT, fields_values.VALUE::VARIANT) as FIELDS_LABELS
    from {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_CARDS') }} as cards
    left join lateral flatten (input => parse_json(cards.CUSTOM_FIELDS)) as flattened_fields -- acts as inner join even if specified otherwise
    left join {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_CUSTOMFIELDS') }} as field_details
        on flattened_fields.VALUE:field_id = field_details.FIELD_ID
    left join {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_CUSTOMFIELDS_VALUES') }} as fields_values
        on flattened_fields.VALUE:field_id = fields_values.FIELD_ID
        and get(flattened_fields.VALUE:values, 0):value_id = fields_values.VALUE_ID
        and field_details.IS_ENABLED = '1'
    group by all
),
card_case_fields as (
    select 
        cards.CARD_ID as CARD_ID,
        CASE WHEN flattened_fields.value:field_id ='98' then flattened_fields.value:"display_value" ELSE NULL END AS CASE_NUMBER
    from {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_CARDS') }} as cards
    left join lateral flatten (input => parse_json(cards.CUSTOM_FIELDS)) as flattened_fields
    where  flattened_fields.value:field_id ='98'
),
card_comments as (
    select 
        cards.CARD_ID as CARD_ID,
        array_agg(object_construct('text', comment.value:"text"::STRING, 'last_modified',comment.value:"last_modified"::STRING)) 
        within group (order by comment.value:"last_modified" desc ) as COMMENTS
    from {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_CARDS') }} as cards
    left join lateral flatten (input => parse_json(cards.COMMENTS)) as comment
    GROUP BY CARD_ID
),
max_filedate as (
    select 
        max(cards._FILEDATE)::TIMESTAMP_TZ as SNAPSHOT_DT
    from {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_CARDS') }} as cards
),
    
source_data as (
    select 
        cards.CARD_ID,
        owners.USERNAME as ASSIGNEE,
        card_fields.FIELDS_LABELS:"Work Category" as WORK_CATEGORY,
        card_fields.FIELDS_LABELS:"Domain" as DOMAIN,
        cards.TITLE,
        case 
            when cards.PRIORITY = '1' then 'Critical'
            when cards.PRIORITY = '2' then 'High'
            when cards.PRIORITY = '3' then 'Average'
            when cards.PRIORITY = '4' then 'Low'
        end as PRIORITY,
        cards.IS_BLOCKED,
        parse_json(cards.BLOCK_REASON):comment as BLOCK_REASON,
        datediff('seconds', dateadd('seconds', -cards.CURRENT_BLOCK_TIME, cards._FILEDATE), current_timestamp())/60/60/24 as CURRENT_BLOCK_TIME,
        -- cards.CURRENT_BLOCK_TIME/60/60/24 as CURRENT_BLOCK_TIME,
        case 
            when cards.COLUMN_ID = '1428' then 'Product Backlog'
            when cards.COLUMN_ID = '1429' then 'Sprint Backlog'
            when cards.COLUMN_ID = '1430' then 'In Progress'
            when cards.COLUMN_ID = '1676' then 'Test and Verification'
            when cards.COLUMN_ID = '1431' then 'Done'
            when cards.COLUMN_ID = '1432' then 'Ready to archive'
        end as COLUMN_NAME,
        case COLUMN_NAME
            when 'Product Backlog' then 0
            when 'Sprint Backlog' then 1
            when 'In Progress' then 2
            when 'Test and Verification' then 3
            when 'Done' then 4
            when 'Ready to archive' then 5
            else -1
        end as COLUMN_NUM,
        cards.SIZE,
        datediff('seconds', dateadd('seconds', -cards.CURRENT_CYCLE_TIME, cards._FILEDATE), current_timestamp())/60/60/24 as CYCLE_TIME,
        -- cards.CURRENT_CYCLE_TIME/60/60/24 as CYCLE_TIME,
        cards.CREATED_AT,
        cards.IN_CURRENT_POSITION_SINCE,
        cards.COLOR as KCARD_COLOR,
        card_tags.TAG_LABELS,
        array_to_string(card_tags.TAG_LABELS, ',') as TAG_LABELS_CSV,
        card_fields.FIELDS_LABELS:"Sprint" as SPRINT,
        card_fields.FIELDS_LABELS:"Data Product" as DATA_PRODUCT,
        card_fields.FIELDS_LABELS:"Business Contact" as BUSINESS_CONTACT,
        card_case_fields.CASE_NUMBER,
        cards.DESCRIPTION,
        cards.LANE_ID,
        cards.LAST_MODIFIED,
        cards.STATE,
        card_comments.COMMENTS,
        max_filedate.SNAPSHOT_DT,
    from {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_CARDS') }} as cards
    left join {{ ref('BRONZE__TEH_DATA_OPS__KANBANIZE_USERS') }} as owners
        on cards.OWNER_USER_ID = owners.USER_ID
    left join card_tags
        on cards.CARD_ID = card_tags.CARD_ID
    left join card_fields
        on cards.CARD_ID = card_fields.CARD_ID
    left join card_case_fields
        on cards.CARD_ID = card_case_fields.CARD_ID
    left join card_comments
        on cards.CARD_ID = card_comments.CARD_ID
    left join max_filedate
        on 1=1
    where 
        cards.BOARD_ID = '66' and -- BI-Modernization board
        cards.LANE_ID = '981' -- User Stories lane
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        *,
        -- Sprints begin and end every other Wednesday at 10 am CT. 
        -- Any sprint can be used as the base sprint timestamp as long as it is at the starting hour.
        '2024-07-17 10:00:00 -0500'::TIMESTAMP_NTZ as BASE_SPRINT,
        datediff('hours', BASE_SPRINT, SNAPSHOT_DT) / 24 as DAYS_SINCE_BASE,
        floor(DAYS_SINCE_BASE / 14) as SPRINTS_SINCE_BASE,
        to_varchar(dateadd('days', SPRINTS_SINCE_BASE * 14, BASE_SPRINT::date), 'YYYYMMDD') as ACTIVE_SPRINT,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        CARD_ID,
        ASSIGNEE,
        WORK_CATEGORY::VARCHAR as WORK_CATEGORY,
        DOMAIN::VARCHAR as DOMAIN,
        TITLE,
        PRIORITY,
        IS_BLOCKED::BOOLEAN as IS_BLOCKED,
        BLOCK_REASON::VARCHAR as BLOCK_REASON,
        CURRENT_BLOCK_TIME::NUMBER(38,2) as CURRENT_BLOCK_TIME,
        COLUMN_NAME,
        SIZE::NUMBER(38,0) as SIZE,
        CYCLE_TIME::NUMBER(38,2) as CYCLE_TIME,
        CREATED_AT::TIMESTAMP_TZ as CREATED_AT,
        IN_CURRENT_POSITION_SINCE::TIMESTAMP_TZ as IN_CURRENT_POSITION_SINCE,
        KCARD_COLOR::VARCHAR as KCARD_COLOR,
        TAG_LABELS,
        SPRINT::VARCHAR as SPRINT,
        DATA_PRODUCT::VARCHAR as DATA_PRODUCT,
        BUSINESS_CONTACT::VARCHAR as BUSINESS_CONTACT,
        CASE_NUMBER::VARCHAR as CASE_NUMBER,
        DESCRIPTION,
        LANE_ID,
        LAST_MODIFIED::TIMESTAMP_TZ as LAST_MODIFIED,
        STATE,
        COMMENTS,
        ACTIVE_SPRINT,
        SNAPSHOT_DT,
        COLUMN_NUM,
        TAG_LABELS_CSV,
    from transform_data
)

select * from type_data
