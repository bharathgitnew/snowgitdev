{{ config(
        materialized='view',
        alias='SAP_CUSTOMER_COORDINATE_LKUP',
        transient=false    
) }}

with source_data as (
    select 
        *
    from {{ ref('COMMON__REPORTS__SAP_CUSTOMER_COORDINATE_LKUP') }} 
),
transform_data AS
(
    select * from source_data
)
select * from transform_data