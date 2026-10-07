{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='REPLENISHMENTORDER'
) }}

with source_data as
(       
    SELECT  
        a.ORDER_ AS Warehouse_Order_No,
        c.POSITIONNUMBER AS Position_No,
        c.SEQUENCENUMBER AS Sequence_No,
        c.ITEM AS Item,
        d.DESCRIPTION AS Item_Description,
        a.SHIPTOCODE AS Ship_To,
        a.SHIPFROMCODE AS Ship_From,
        a.ORDER_DATE AS Order_Date,
        c.PLANNEDDELIVERYDATETIME AS Planned_Delivery_Date,
        c.PLANNEDRECEIPTDATE AS Planned_Receipt_Date,
        c.ACTUALDELIVERYDATE AS Act_Delivery_Date,
        b.ACTUALRECEIPTDATE AS Act_Receipt_Date,
        c.PLANNEDSTORAGEUNIT AS Unit_of_Measure,
        c.ORDER_EDQUANTITYINSTORAGEUNIT AS Ordered_Qty,
        b.RECEIPTQUANTITY AS Received_Qty,
        b.RECEIPTNUMBER AS Receipt_No,
        a.REFERENCE AS Reference,
        c.LINESTATUSDESCRIPTION AS OB_Line_Status,
        b.LINESTATUSDESCRIPTION AS IB_Line_Status,
        '' AS Logon_Code,
        a.INFORMATION AS Information
        FROM {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANWAREHOUSINGINVENTORYHANDLING_WAREHOUSEORDERSRECEIPTISSUEANDTRANSFER') }} a /* Warehouse Orders */
        INNER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDORDERLINES') }} c  /* Outbound Order Lines */
        ON    a.ORDER_ORIGINID = c.ORDER_ORIGINID
        AND   a.ORDER_ = c.ORDER_
        AND   a._SET = c._SET
        LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANWAREHOUSINGINVENTORYHANDLING_INBOUNDORDERLINES') }} b  /* Inbound Order Lines */
        ON    c.ORDER_ORIGINID = b.ORDER_ORIGINID
        AND   c.ORDER_ = b.ORDER_
        AND   c._SET = b._SET
        AND   c.POSITIONNUMBER = b.POSITIONNUMBER
        AND   trim(b.RECEIPTNUMBER) IS NOT NULL
        LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONITEMBASEDATA_GENERALITEMDATA') }} d /* General Item */
        ON    c.ITEM = d.ITEM
        WHERE   a.ORDER_ORIGINID IN (5, 22)
        ORDER BY a.ORDER_,c.POSITIONNUMBER, c.SEQUENCENUMBER, b.ACTUALRECEIPTDATE
    )

,transform_data as(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        WAREHOUSE_ORDER_NO,
        POSITION_NO,
        SEQUENCE_NO,
        ITEM,
        ITEM_DESCRIPTION,
        SHIP_TO,
        SHIP_FROM,
        ORDER_DATE,
        PLANNED_DELIVERY_DATE,
        PLANNED_RECEIPT_DATE,
        ACT_DELIVERY_DATE,
        ACT_RECEIPT_DATE,
        UNIT_OF_MEASURE,
        ORDERED_QTY,
        RECEIVED_QTY,
        RECEIPT_NO,
        REFERENCE,
        OB_LINE_STATUS,
        IB_LINE_STATUS,
        LOGON_CODE,
        INFORMATION   
    FROM source_data
)
,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        WAREHOUSE_ORDER_NO,
        cast(POSITION_NO as NUMBER(38,0)) as POSITION_NO,
        cast(SEQUENCE_NO as NUMBER(38,0)) as SEQUENCE_NO,
        ITEM,
        ITEM_DESCRIPTION,
        SHIP_TO,
        SHIP_FROM,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(PLANNED_DELIVERY_DATE as TIMESTAMP_NTZ(9)) as PLANNED_DELIVERY_DATE,
        cast(PLANNED_RECEIPT_DATE as TIMESTAMP_NTZ(9)) as PLANNED_RECEIPT_DATE,
        cast(ACT_DELIVERY_DATE as TIMESTAMP_NTZ(9)) as ACT_DELIVERY_DATE,
        cast(ACT_RECEIPT_DATE as TIMESTAMP_NTZ(9)) as ACT_RECEIPT_DATE,
        UNIT_OF_MEASURE,
        cast(ORDERED_QTY as NUMBER(15,2)) as ORDERED_QTY,
        cast(RECEIVED_QTY as NUMBER(15,2)) as RECEIVED_QTY,
        RECEIPT_NO,
        REFERENCE,
        OB_LINE_STATUS,
        IB_LINE_STATUS,
        LOGON_CODE,
        INFORMATION
    from transform_data
    )
select * from type_data