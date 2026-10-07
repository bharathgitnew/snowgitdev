{{ config(
      materialized='incremental',
      incremental_strategy='insert_overwrite',
      alias='BaanV_TEA_Warehouse_Orders_Inbound',
      transient=false
) }}

with source_data as 
(
SELECT 
DISTINCT a.ORDER_ORIGINDESCRIPTION AS WHS_Order_Origin,
a.ORDER_ AS WHS_Order_No,
a._SET AS WHS_Set,
c.POSITIONNUMBER AS IB_Pos_No,
c.SEQUENCENUMBER AS IB_Seq_No,
a.WAREHOUSINRDERTYPE AS WHS_Order_Type,
a.INVENTORYTRANSACTIONTYPEDESCRIPTION AS Inv_Transaction_Type,
a.SHIPTOTYPEDESCRIPTION AS Ship_To_Type,
a.SHIPTOCODE AS Ship_To,
a.SHIPFROMTYPEDESCRIPTION AS Ship_From_Type,
a.SHIPFROMTYPEID AS Ship_From_Type_ID,
a.SHIPFROMCODE AS Ship_From,
a.ORDER_DATE AS Order_Date,
c.PLANNEDSTORAGEUNIT AS UOM,
c.ITEM AS Item,
d.DESCRIPTION AS Item_Description,
c.LINESTATUSDESCRIPTION AS IB_Line_Status,
c.ACTUALRECEIPTDATE AS Act_Receipt_Date,
c.RECEIPTQUANTITY AS Received_Qty,
c.RECEIPTNUMBER AS Receipt_No,
c.PACKINGSLIPNUMBER AS Packing_Slip_No,
a.REFERENCE AS Reference,
a.INFORMATION AS Information,
a.CARRIER AS Carrier,
a.ROUTE AS Route,
a.OFFICE AS Office,
CASE WHEN a.RETURNORDERID = 1 THEN 'No'
     WHEN a.RETURNORDERID = 2 THEN 'Yes'
     ELSE Null 
END  AS RETURN
FROM {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYHANDLING_WAREHOUSEORDERSRECEIPTISSUEANDTRANSFER') }} a
INNER JOIN {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYHANDLING_INBOUNDORDERLINES') }} c ON a.ORDER_ORIGINID = c.ORDER_ORIGINID AND a.ORDER_ = c.ORDER_ AND  a._SET = c._SET
INNER JOIN {{ ref('ODS__BAAN__BAANCOMMONITEMBASEDATA_GENERALITEMDATA') }} d ON c.ITEM = d.ITEM
WHERE trim(c.RECEIPTNUMBER) IS NOT NULL
ORDER BY
a.ORDER_ORIGINDESCRIPTION,
a.ORDER_, a._SET,
a.ORDER_DATE, c.POSITIONNUMBER
)

,transform_data as
(
    select
    WHS_Order_Origin,
    WHS_Order_No,
    WHS_Set,
    IB_Pos_No,
    IB_Seq_No,
    WHS_Order_Type,
    Inv_Transaction_Type,
    Ship_To_Type,
    Ship_To,
    Ship_From_Type,
    Ship_From_Type_ID,
    Ship_From,
    Order_Date,
    UOM,
    Item,
    Item_Description,
    IB_Line_Status,
    Act_Receipt_Date,
    Received_Qty,
    Receipt_No,
    Packing_Slip_No,
    Reference,
    Information,
    Carrier,
    Route,
    Office,
    RETURN
    from source_data
)

select * from transform_data