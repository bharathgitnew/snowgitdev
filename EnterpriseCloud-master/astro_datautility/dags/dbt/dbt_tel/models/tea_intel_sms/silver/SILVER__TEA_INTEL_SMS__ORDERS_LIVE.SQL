{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='ORDERS_Live',
    unique_key = []
) }}

with source_data as
(
    SELECT
         Orders.ITEMID
        ,Orders.REGIONID
        ,Orders.WAREHOUSEID
        ,Orders.SUPPLIERID
        ,Orders.SUPPLIERTYPE
        ,Orders.ORDERDATEKEY
        ,Orders.DUEDATEKEY
        ,Orders.QUANTITY
        ,Orders.SUGGESTEDDUEDATEKEY
        ,Orders.SUGGESTEDQUANTITY
        ,Orders.RECEIVEDQUANTITY
        ,Orders.ALLOWCHANGES
        ,Orders.PONUMBER
        ,Orders.POLINEITEM
        ,Orders.STATUS
        ,Orders.SUPPLIERPARTNUMBER
        ,Orders.ORDERAPPROVALID
        ,Orders.ORDERAPPROVALSEQUENCE
        ,Orders.ORDERUNITCOST
        ,Orders.SCRAPPEDQUANTITY
        ,Orders.REFERENCEA
        ,Orders.REFERENCEB
      ,_FileName
      ,try_to_timestamp(replace(split_part(_filename,'_',2)||split_part(_filename,'_',3),'.feed.gz',''),'yyyymmddHH24MISS') AS FileDate
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__PROPHET_ORDERS') }} Orders
)
,	transform_data as
(
    SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
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
		REPLACE(LEFT(_FILENAME,CHARINDEX('_',_FILENAME)-1),'ORDERS/ORDERS','') AS OriginatingSubsidiary,
		LEFT(RegionId,CHARINDEX('-',RegionId)-1) AS WarehouseSubsidiary,
		SUBSTRING(RegionId,CHARINDEX('-',RegionId)+1) AS WarehouseType,
		FileDate 
    FROM source_data
)
,Orders_Max as
(
    SELECT
        OriginatingSubsidiary,
        MAX(FileDate) AS FileDate
    FROM transform_data
    GROUP BY OriginatingSubsidiary
)
,transform_data_max as
(
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
        transform_data.OriginatingSubsidiary,
        WarehouseSubsidiary,
        WarehouseType,
        transform_data.FileDate,
        _AUDIT_LOG_ID,
        _ROW_HASH 
    FROM transform_data
    INNER JOIN Orders_Max
    ON transform_data.OriginatingSubsidiary = Orders_Max.OriginatingSubsidiary AND transform_data.FileDate = Orders_Max.FileDate
)
,	type_data as
(
    select
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
		CAST(ItemId AS VARCHAR(16777216)) AS ItemId,
		CAST(RegionId AS VARCHAR(16777216)) AS RegionId,
		CAST(WarehouseId AS VARCHAR(16777216)) AS WarehouseId,
		CAST(SupplierId AS VARCHAR(16777216)) AS SupplierId,
		CAST(SupplierType AS VARCHAR(16777216)) AS SupplierType,
		CAST(OrderDateKey AS NUMBER(38,0)) AS OrderDateKey,
		CAST(DueDateKey AS NUMBER(38,0)) AS DueDateKey,
		CAST(Quantity AS NUMBER(38,0)) AS Quantity,
		CAST(SuggestedDueDateKey AS NUMBER(38,0)) AS SuggestedDueDateKey,
		CAST(SuggestedQuantity AS NUMBER(38,0)) AS SuggestedQuantity,
		CAST(ReceivedQuantity AS NUMBER(38,0)) AS ReceivedQuantity,
		CAST(AllowChanges AS VARCHAR(16777216)) AS AllowChanges,
		CAST(PONumber AS VARCHAR(16777216)) AS PONumber,
		CAST(POLineItem AS VARCHAR(16777216)) AS POLineItem,
		CAST(Status AS VARCHAR(16777216)) AS Status,
		CAST(SupplierPartNumber AS VARCHAR(16777216)) AS SupplierPartNumber,
		CAST(OrderApprovalID AS NUMBER(38,0)) AS OrderApprovalID,
		CAST(OrderApprovalSequence AS NUMBER(38,0)) AS OrderApprovalSequence,
		CAST(OrderUnitCost AS NUMBER(11,2)) AS OrderUnitCost,
		CAST(ScrappedQuantity AS NUMBER(38,0)) AS ScrappedQuantity,
		CAST(ReferenceA AS VARCHAR(16777216)) AS ReferenceA,
		CAST(ReferenceB AS VARCHAR(16777216)) AS ReferenceB,
		CAST(OriginatingSubsidiary AS VARCHAR(16777216)) AS OriginatingSubsidiary,
		CAST(WarehouseSubsidiary AS VARCHAR(16777216)) AS WarehouseSubsidiary,
		CAST(WarehouseType AS VARCHAR(16777216)) AS WarehouseType,
		CAST(FILEDATE AS TIMESTAMP_NTZ(9)) AS FILEDATE
    from transform_data_max
    )
select * from type_data