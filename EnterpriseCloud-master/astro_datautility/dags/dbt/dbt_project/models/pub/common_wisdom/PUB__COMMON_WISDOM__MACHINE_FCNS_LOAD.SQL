{{ config(
        alias = 'MACHINE_FCNS_LOAD',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__WISDOM__MACHINE_FCNS_LOAD') }} 
)

select * from source_data