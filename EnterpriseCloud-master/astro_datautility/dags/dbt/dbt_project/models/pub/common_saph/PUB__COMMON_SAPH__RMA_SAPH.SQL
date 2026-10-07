{{ config(
        alias = 'RMA_SAPH',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        *
    from {{ ref('COMMON__SAPH__RMA_SAPH') }} 
)

select * from source_data