{{ config(
      materialized='view',
      alias='INVENTORY_MATCH_3PL_DATA',
      transient=false,
      enabled=true
) }}

with source_data as
(   
    select 
      PART_NUMBER 
    , STORAGE_LOCATION 
    , WMS_BATCH_NUMBER 
    , SERIAL_NUMBER 
    , EXTRACT_DATE 
    , ON_HAND_QTY 
    , BATCH_COUNT 
    , SERIAL_COUNT
    from {{ ref('COMMON__DE_THREEPL__INVENTORY_MATCH_3PL_DATA') }}     
),

transform_data as
(
      select * from source_data
)

select * from transform_data