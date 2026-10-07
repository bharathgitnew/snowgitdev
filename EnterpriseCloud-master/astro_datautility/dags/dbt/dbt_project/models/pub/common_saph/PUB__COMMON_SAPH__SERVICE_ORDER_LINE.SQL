{{ config(
        alias = 'SERVICE_ORDER_LINE',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__SAPH__SERVICE_ORDER_LINE') }} 
)

select * from source_data