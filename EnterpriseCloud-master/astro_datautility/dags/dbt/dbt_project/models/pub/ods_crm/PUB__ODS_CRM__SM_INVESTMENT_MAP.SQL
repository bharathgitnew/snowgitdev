{{ config(
        alias = 'SM_INVESTMENT_MAP',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__SM_INVESTMENT_MAP') }} 
)

select * from source_data