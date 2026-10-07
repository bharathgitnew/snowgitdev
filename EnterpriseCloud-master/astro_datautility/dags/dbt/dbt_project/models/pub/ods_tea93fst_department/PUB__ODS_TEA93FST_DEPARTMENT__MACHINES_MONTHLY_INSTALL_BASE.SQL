{{ config(
        alias = 'MACHINES_MONTHLY_INSTALL_BASE',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__TEA93FST_DEPARTMENT__MACHINES_MONTHLY_INSTALL_BASE') }} 
)

select * from source_data