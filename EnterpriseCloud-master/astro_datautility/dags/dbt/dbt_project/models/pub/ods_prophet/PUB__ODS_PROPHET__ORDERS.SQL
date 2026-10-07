/************
Model file generated from dbtGeneratePubViews: 05.09.2022.16.29.44"
*************/

{{ config(
      materialized='view',
      alias='ORDERS',
      transient=false
) }}

with source_data as (
    SELECT
      	    ITEMID,
            REGIONID,
            WAREHOUSEID,
            SUPPLIERID,
            SUPPLIERTYPE,
            ORDERDATEKEY,
            DUEDATEKEY,
            QUANTITY,
            SUGGESTEDDUEDATEKEY,
            SUGGESTEDQUANTITY,
            RECEIVEDQUANTITY,
            ALLOWCHANGES,
            PONUMBER,
            POLINEITEM,
            STATUS,
            SUPPLIERPARTNUMBER,
            ORDERAPPROVALID,
            ORDERAPPROVALSEQUENCE,
            ORDERUNITCOST,
            SCRAPPEDQUANTITY,
            REFERENCEA,
            REFERENCEB,
            _FILENAME
    from {{ ref('ODS__PROPHET__ORDERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data