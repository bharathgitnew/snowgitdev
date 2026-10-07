{{ config(
        alias = 'SO_ATTRIBUTE_CHANGES',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__SO_ATTRIBUTE_CHANGES_FIN01') }} 
)

select * from source_data