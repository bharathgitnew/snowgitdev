{{ config(
      materialized='view',
      alias='INVENTORY_TRANSACTION_HISTORY',
      transient=false,
      enabled=true
) }}

-- This view is being deprecated. Please use INVENTORY_HISTORY_FULL instead.

with source_data as (
    select
        DOCUMENT_NUMBER
        , MOVEMENT_TYPE
        , MOVEMENT_TYPE_DESC
        , DOCUMENT_ITEM
        , MATERIAL
        , PLANT
        , STORAGE_LOCATION
        , CONSIGNMENT_CUSTOMER
        , CUSTOMER_NAME
        , SLOC_CUSTOMER_COMBINED
        , ENTRY_DATE
        , ENTRY_TIME         
        , CST_TIME_STAMP
        , CST_ENTRY_DATE
        , CST_ENTRY_TIME
        , UTC_ENTRY_DATE
        , UTC_ENTRY_TIME
        , UTC_TIMESTAMP
        , TRANSACTION_QTY
        , TRANSACTION_VALUE
        , PRODUCT_CODE
        , LOCAL_ABC
        , INTEL_ABC
        , CONSUMABLE
        , INTEL
    FROM {{ ref('COMMON__REPORTS__INVENTORY_HISTORY_FULL') }} 

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data