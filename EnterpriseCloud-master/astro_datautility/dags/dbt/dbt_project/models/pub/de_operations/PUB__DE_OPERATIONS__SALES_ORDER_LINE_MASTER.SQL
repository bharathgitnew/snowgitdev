{{ config(
        materialized='view',
        alias='SALES_ORDER_LINE_MASTER',
        transient=false    
) }}

with source_data as (
    select 
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__SAPH__SALES_ORDER_LINE_MASTER') }} 
),
transform_data AS
(
    select * from source_data
)
select * from transform_data