{{ config(
        alias = 'UG_EXPLAIN_US',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__WISDOM__UG_EXPLAIN_US') }} 
)

select * from source_data