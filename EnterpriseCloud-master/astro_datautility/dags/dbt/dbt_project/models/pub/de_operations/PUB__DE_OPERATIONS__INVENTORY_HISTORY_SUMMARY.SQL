{{ config(
      materialized='view',
        alias='INVENTORY_HISTORY_SUMMARY',
      transient=false,
      enabled=true
) }}


with source_data as (
    select
        MATERIAL
        , PLANT
        , STORAGE_LOCATION
        , SLOC_TYPE
        , YEAR_MONTH_TEXT
        , ON_HAND
        , STOCK_VALUE
        , BU
        , Consumable
        , Intel

    FROM {{ ref('COMMON__SAPH__INVENTORY_HISTORY_SUMMARY') }}  

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data