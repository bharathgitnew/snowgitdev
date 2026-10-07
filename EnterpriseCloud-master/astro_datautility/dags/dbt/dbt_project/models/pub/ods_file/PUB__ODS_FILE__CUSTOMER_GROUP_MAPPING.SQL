{{ config(
        alias = 'CUSTOMER_GROUP_MAPPING',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__SHAREPOINT__CUSTOMER_GROUP_MAPPING') }}
)

select * from source_data