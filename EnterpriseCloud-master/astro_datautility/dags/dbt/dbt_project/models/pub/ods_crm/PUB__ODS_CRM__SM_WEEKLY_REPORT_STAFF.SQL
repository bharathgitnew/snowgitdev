{{ config(
        alias = 'SM_WEEKLY_REPORT_STAFF',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__SM_WEEKLY_REPORT_STAFF') }} 
)

select * from source_data