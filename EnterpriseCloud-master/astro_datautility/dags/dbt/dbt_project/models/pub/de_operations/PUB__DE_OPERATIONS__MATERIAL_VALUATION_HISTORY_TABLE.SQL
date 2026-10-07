{{ config(
        alias = 'MATERIAL_VALUATION_HISTORY_TABLE',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__REPORTS__MATERIAL_VALUATION_HISTORY_TABLE') }} 
)

select * from source_data