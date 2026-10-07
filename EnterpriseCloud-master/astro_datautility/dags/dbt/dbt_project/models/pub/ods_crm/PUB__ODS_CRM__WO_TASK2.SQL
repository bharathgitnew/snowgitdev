{{ config(
        alias = 'WO_TASK2',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__WO_TASK2') }} 
)

select * from source_data