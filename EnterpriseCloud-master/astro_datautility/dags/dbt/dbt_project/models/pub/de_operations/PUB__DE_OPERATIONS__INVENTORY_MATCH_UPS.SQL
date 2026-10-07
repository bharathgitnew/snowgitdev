{{ config(
        materialized='view',
        alias='INVENTORY_MATCH_UPS',
        transient=false,
        enabled=True    
) }}

with source_data as 
(

    select
        MATERIAL
        , STORAGE_LOCATION
        , SAP_ON_HAND
        , UPS_ON_HAND
        , ON_HAND_DIFFERENCE
        , REASON
    from {{ ref('COMMON__DE_THREEPL__INVENTORY_MATCH_UPS') }} 
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data