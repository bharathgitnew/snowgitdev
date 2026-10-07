{{ config(
        alias = 'UG_EXPLAIN_TI_US',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__WISDOM__UG_EXPLAIN_TI_US') }} 
)

select * from source_data