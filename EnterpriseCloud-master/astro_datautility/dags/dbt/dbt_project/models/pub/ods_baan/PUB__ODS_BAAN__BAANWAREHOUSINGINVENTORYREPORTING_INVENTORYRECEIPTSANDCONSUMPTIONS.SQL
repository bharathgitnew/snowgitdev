/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.27"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTSANDCONSUMPTIONS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACTUALRECEIPTDATE,
        ACTUALWAREHOUSE,
        ORDER_NUMBER,
        ORDER_ORIGINDESCRIPTION,
        ORDER_ORIGINID,
        PARTNUMBER,
        POSITIONNUMBER,
        QUANTITYTOBECONSUMED,
        SEQUENCE,
        TOTALAMOUNT,
        TRANSACTIONDATE,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTSANDCONSUMPTIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data