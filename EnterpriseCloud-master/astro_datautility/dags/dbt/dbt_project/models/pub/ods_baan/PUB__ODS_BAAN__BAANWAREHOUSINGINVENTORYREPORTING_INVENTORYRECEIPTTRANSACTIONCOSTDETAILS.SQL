/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.28"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONCOSTDETAILS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AMOUNT1,
        AMOUNT2,
        AMOUNT3,
        COSTCOMPONENT,
        ITEM,
        MAUC1,
        MAUC2,
        MAUC3,
        SEQUENCENUMBER,
        TRANSACTIONDATE,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONCOSTDETAILS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data