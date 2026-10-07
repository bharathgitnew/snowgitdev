{{ config(
        alias = 'CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FAB',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__CNT_CNT_CONTRACTSUMMARY_ACCOUNT_FAB') }} 
)

select * from source_data