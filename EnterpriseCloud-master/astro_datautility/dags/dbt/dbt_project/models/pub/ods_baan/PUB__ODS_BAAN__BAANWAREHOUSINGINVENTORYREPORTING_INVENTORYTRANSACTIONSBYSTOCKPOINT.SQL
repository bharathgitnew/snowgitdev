/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.28"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYTRANSACTIONSBYSTOCKPOINT',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        BUSINESSPARTNER,
        INVENTORYDATE,
        INVENTORYTRANSACTIONPRINTEDDESCRIPTION,
        INVENTORYTRANSACTIONPRINTEDID,
        ITEM,
        LOCATION,
        LOGINNAME,
        LOT,
        ORDER_NUMBER,
        ORDER_TYPEDESCRIPTION,
        ORDER_TYPEID,
        POSITIONNUMBER,
        QUANTITYINVENTORYUNIT,
        SEQUENCENUMBER,
        TRANSACTIONDATE,
        TRANSACTIONTYPEDESCRIPTION,
        TRANSACTIONTYPEID,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYTRANSACTIONSBYSTOCKPOINT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data