{{ config(
        alias = 'TIMESHEET_SERVICE_TEMPORARY_WORKER_HOURS',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__TIMESHEET_SERVICE_TEMPORARY_WORKER_HOURS') }} 
)

select * from source_data