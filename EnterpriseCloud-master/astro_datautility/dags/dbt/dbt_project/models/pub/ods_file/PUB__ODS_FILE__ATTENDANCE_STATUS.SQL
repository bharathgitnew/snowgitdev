
{{ config(
    alias = 'ATTENDANCE_STATUS',
    materialized = 'view'
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH, _FILENAME, _FILEDATE, _UPLOADDATE)
    from {{ ref('ODS__FILE__ATTENDANCE_STATUS') }} 
)

select * from source_data
