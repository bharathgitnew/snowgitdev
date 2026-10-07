{{ config(
        materialized='view',
        alias='PART_STOCK_OVERVIEW_REPORT',
        transient=false    
) }}

with source_data as (
    select 
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__PART_STOCK_OVERVIEW_REPORT') }} 
),
transform_data AS
(
    select * from source_data
)
select * from transform_data