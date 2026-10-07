{{ config(
        alias = 'CONTRACT_AND_PAID_SERVICE_SAP_REV_COGS',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__CONTRACT_AND_PAID_SERVICE_SAP_REV_COGS') }} 
)

select * from source_data