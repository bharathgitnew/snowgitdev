{{ config(
      materialized='view',
      alias='Orders_History',
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
                OriginatingSubsidiary,
                WarehouseSubsidiary,
                WarehouseType,
                FILEDATE

    from {{ ref('COMMON__PROPHET__ORDERS_HISTORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data