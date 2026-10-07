/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.28"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CONSIGNMENTDESCRIPTION,
        CONSIGNMENTID,
        INVENTORYVARIANCEASSIGNEDDESCRIPTION,
        INVENTORYVARIANCEASSIGNEDID,
        ITEM,
        ORDER_,
        ORDER_ORIGINDESCRIPTION,
        ORDER_ORIGINID,
        POSITIONNUMBER,
        QUANTITYTOBECONSUMED,
        RECEIVEDQUANTITY,
        REVALUEDDESCRIPTION,
        REVALUEDID,
        REVALUEDON,
        SEQUENCENUMBER_SEQN,
        SEQUENCENUMBER_SRNB,
        TRANSACTIONDATE,
        TRANSITIONEDDESCRIPTION,
        TRANSITIONEDID,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data