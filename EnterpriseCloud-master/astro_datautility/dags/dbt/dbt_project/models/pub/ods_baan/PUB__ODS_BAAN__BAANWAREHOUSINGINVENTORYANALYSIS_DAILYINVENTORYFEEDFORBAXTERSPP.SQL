/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.26"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYANALYSIS_DAILYINVENTORYFEEDFORBAXTERSPP',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        INVENTORYONHAND,
        ITEM,
        QUANTITYINTRANSIT,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYANALYSIS_DAILYINVENTORYFEEDFORBAXTERSPP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data