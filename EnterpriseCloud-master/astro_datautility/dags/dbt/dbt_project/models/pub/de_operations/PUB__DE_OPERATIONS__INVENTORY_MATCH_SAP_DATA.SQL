{{ config(
      materialized='view',
      alias='INVENTORY_MATCH_SAP_DATA',
      transient=false,
      enabled=true
) }}

with source_data as
(   
    select 
         MATERIAL 
        , PLANT
        , STORAGE_LOCATION 
        , SAP_BATCH_NUMBER 
        , CHARACTERISTIC_VALUE
        , WMS_BATCH_NO
        , SERIAL_NO
        , BATCH_COUNT
        , SERIAL_COUNT                
        , ON_HAND_QTY
    from {{ ref('COMMON__DE_THREEPL__INVENTORY_MATCH_SAP_DATA') }}     
),

transform_data as
(
      select * from source_data
)

select * from transform_data