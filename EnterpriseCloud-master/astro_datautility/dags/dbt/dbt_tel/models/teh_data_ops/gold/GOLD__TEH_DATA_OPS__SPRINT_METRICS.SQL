
{{ config(
    alias = 'SPRINT_METRICS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['SPRINT'],
    meta = {
        'owners': ['Jay Spiers']
    },
) }}

with source_data as (
    select 
        SPRINT,
        sum(AVG_SPRINT_VELOCITY) as AVG_SPRINT_VELOCITY,
        sum(POINTS_START) as POINTS_START,
        sum(POINTS_END) as POINTS_END,
        sum(POINTS_DELTA) as POINTS_DELTA,
        sum(POINTS_START) / nullifzero(sum(AVG_SPRINT_VELOCITY)) as COMMIT_OVER_CAPACITY_START,
        sum(POINTS_END) / nullifzero(sum(AVG_SPRINT_VELOCITY)) as COMMIT_OVER_CAPACITY_END,
        sum(POINTS_DELIVERED) as POINTS_DELIVERED,
        sum(POINTS_MISSED) as POINTS_MISSED,
        sum(POINTS_DELIVERED) / nullifzero(sum(POINTS_END)) as COMMITTED_DELIVERED,
    from {{ ref('GOLD__TEH_DATA_OPS__SPRINT_USER_METRICS')}}
    group by SPRINT
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
        AVG_SPRINT_VELOCITY,
        POINTS_START,
        POINTS_END,
        POINTS_DELTA,
        COMMIT_OVER_CAPACITY_START,
        COMMIT_OVER_CAPACITY_END,
        POINTS_DELIVERED,
        POINTS_MISSED,
        COMMITTED_DELIVERED,
    from transform_data
)

select * from type_data
