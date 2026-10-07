{{ config(
        alias = 'WISDOM_MACHINE_FCNS',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__WISDOM__WISDOM_MACHINE_FCNS') }} 
)

select * from source_data