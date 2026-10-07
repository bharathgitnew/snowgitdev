{{ config(
        alias = 'FINANCE_ADJ_MAPPINGS',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        *
    from {{ ref('ODS__FILE__FINANCE_ADJ_MAPPINGS') }} 
)

select * from source_data