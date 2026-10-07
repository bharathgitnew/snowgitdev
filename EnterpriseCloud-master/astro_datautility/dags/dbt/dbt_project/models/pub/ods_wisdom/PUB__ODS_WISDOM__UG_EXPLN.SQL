{{ config(
        alias = 'UG_EXPLN',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__WISDOM__UG_EXPLN') }} 
)

select * from source_data