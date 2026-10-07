{{ config(
        alias = 'PRICE_MATRIX',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__SAPH__PRICE_MATRIX') }} 
)

select * from source_data