{{ config(
        materialized='view',
        alias='SAP_SALES_DOC_TYPE',
        transient=false    
) }}

with source_data as (
    select 
        *
    from {{ ref('COMMON__SAPH__SAP_SALES_DOC_TYPE') }} 
),
transform_data AS
(
    select * from source_data
)
select * from transform_data