{{ config(
        alias = 'PURCHASE_ORDER_MASTER',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__SAPH__PURCHASE_ORDER_MASTER') }} 
)

select * from source_data