/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.28"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYTRANSACTIONSBYITEMANDWAREHOUSE',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        BUSINESSPARTNER,
        CHANNEL,
        CONSIGNMENTDESCRIPTION,
        CONSIGNMENTID,
        INVENTORYAFTERTRANSACTION,
        INVENTORYTRANSACTIONPRINTEDDESCRIPTION,
        INVENTORYTRANSACTIONPRINTEDID,
        ITEM,
        LOGINNAME,
        ORDER_,
        ORDER_TYPEDESCRIPTION,
        ORDER_TYPEID,
        POSITIONNUMBER,
        PROJECT,
        QUANTITYINVENTORYUNIT,
        SEQUENCENUMBER,
        TRANSACTIONDATE,
        TRANSACTIONTYPEDESCRIPTION,
        TRANSACTIONTYPEID,
        WAREHOUSE
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYTRANSACTIONSBYITEMANDWAREHOUSE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data