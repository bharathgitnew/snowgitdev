{{ config(
    alias = 'NCDR_SAPH',
    materialized = 'view'
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__SAPH__NCDR_SAPH') }} 
)

select * from source_data
