
{{ config(
    alias = 'NCDR_RETURNS',
    materialized = 'view'
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS_GMX__NCDR_RETURNS') }} 
)

select * from source_data
