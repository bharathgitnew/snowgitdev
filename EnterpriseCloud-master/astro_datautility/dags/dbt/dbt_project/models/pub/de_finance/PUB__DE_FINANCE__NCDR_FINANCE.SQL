
{{ config(
    alias = 'NCDR_FINANCE',
    materialized = 'view'
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__NCDR_FINANCE') }} 
)

select * from source_data
