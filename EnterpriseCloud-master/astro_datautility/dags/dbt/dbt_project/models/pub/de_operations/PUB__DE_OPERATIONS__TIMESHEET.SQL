{{ config(
        alias = 'TIMESHEET',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__TIMESHEET') }} 
)

select * from source_data