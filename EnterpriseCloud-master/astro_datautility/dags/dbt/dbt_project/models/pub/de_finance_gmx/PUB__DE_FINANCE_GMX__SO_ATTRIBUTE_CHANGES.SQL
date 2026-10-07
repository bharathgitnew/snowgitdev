{{ config(
        alias = 'SO_ATTRIBUTE_CHANGES',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS_GMX__SO_ATTRIBUTE_CHANGES') }} 
)

select * from source_data