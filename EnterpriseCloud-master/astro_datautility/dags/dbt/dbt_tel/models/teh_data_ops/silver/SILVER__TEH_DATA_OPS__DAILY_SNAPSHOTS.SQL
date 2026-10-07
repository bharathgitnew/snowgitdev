
{{ config(
    alias = 'DAILY_SNAPSHOTS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['SPRINT', 'SNAPSHOT_DATE', 'CARD_ID'],
    meta = {
        'owners': ['Jay Spiers']
    },
) }}

with source_data as (
    select 
        SPRINT,
        SNAPSHOT_DT::DATE as SNAPSHOT_DATE,
        CARD_ID,
        ASSIGNEE,
        WORK_CATEGORY,
        DOMAIN,
        TITLE,
        PRIORITY,
        IS_BLOCKED,
        BLOCK_REASON,
        CURRENT_BLOCK_TIME,
        COLUMN_NAME,
        SIZE,
        CYCLE_TIME,
        CREATED_AT,
        IN_CURRENT_POSITION_SINCE,
        TAG_LABELS,
        TAG_LABELS_CSV,
        DATA_PRODUCT,
        BUSINESS_CONTACT,
        DESCRIPTION,
        LANE_ID,
        LAST_MODIFIED,
        STATE,
        SNAPSHOT_DT as SNAPSHOT_TIMESTAMP,
    from {{ ref('SILVER__TEH_DATA_OPS__USER_STORIES') }}
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        *,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        SPRINT,
        SNAPSHOT_DATE,
        CARD_ID,
        ASSIGNEE,
        WORK_CATEGORY,
        DOMAIN,
        TITLE,
        PRIORITY,
        IS_BLOCKED,
        BLOCK_REASON,
        CURRENT_BLOCK_TIME,
        COLUMN_NAME,
        SIZE,
        CYCLE_TIME,
        CREATED_AT,
        IN_CURRENT_POSITION_SINCE,
        TAG_LABELS,
        DATA_PRODUCT,
        BUSINESS_CONTACT,
        DESCRIPTION,
        LANE_ID,
        LAST_MODIFIED,
        STATE,
        SNAPSHOT_TIMESTAMP,
        TAG_LABELS_CSV,
    from transform_data
)

select * from type_data
