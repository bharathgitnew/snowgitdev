{{ config(
        materialized='view',
        alias='SAP_DELIVERY_DOC_TYPE',
        transient=false    
) }}

with source_data as (
    select 
        * exclude(AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__SAPH__SAP_DELIVERY_DOC_TYPE') }} 
),
transform_data AS
(
    select * from source_data
)
select * from transform_data