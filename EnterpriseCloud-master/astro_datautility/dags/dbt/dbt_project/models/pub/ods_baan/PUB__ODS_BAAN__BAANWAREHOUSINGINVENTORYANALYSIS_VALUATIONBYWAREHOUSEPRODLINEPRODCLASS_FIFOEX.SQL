/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.26"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYANALYSIS_VALUATIONBYWAREHOUSEPRODLINEPRODCLASS_FIFOEX',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        INTRANSITAMOUNT,
        INVAMOUNT,
        INVENTORY_PERCENT_ONHAND,
        INVENTORY,
        ITEM,
        LASTUPDATED,
        ONHANDAMOUNT,
        PRODUCTLINE,
        QUANTITYINTRANSIT,
        SEQUENCE,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYANALYSIS_VALUATIONBYWAREHOUSEPRODLINEPRODCLASS_FIFOEX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data