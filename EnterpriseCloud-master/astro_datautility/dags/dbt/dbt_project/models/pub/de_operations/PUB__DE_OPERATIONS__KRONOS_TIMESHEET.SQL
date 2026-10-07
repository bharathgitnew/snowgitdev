{{ config(
        alias = 'KRONOS_TIMESHEET',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__KRONOS__TIMESHEET') }} 
)

select * from source_data