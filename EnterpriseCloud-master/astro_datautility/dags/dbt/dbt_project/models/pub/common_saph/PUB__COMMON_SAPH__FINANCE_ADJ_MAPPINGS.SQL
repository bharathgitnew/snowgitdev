{{ config(
        alias = 'FINANCE_ADJ_MAPPINGS',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        *
    from {{ ref('COMMON__SAPH__FINANCE_ADJ_MAPPINGS') }} 
)

select * from source_data