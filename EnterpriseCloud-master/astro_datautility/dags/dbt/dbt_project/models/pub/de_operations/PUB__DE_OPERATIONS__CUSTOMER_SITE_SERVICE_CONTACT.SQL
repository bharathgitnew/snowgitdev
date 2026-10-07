{{ config(
        alias = 'CUSTOMER_SITE_SERVICE_CONTACT',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__CUSTOMER_SITE_SERVICE_CONTACT') }} 
)

select * from source_data