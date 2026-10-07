{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Inventory_Live',
    unique_key = []
) }}


with source_data as
(
    SELECT
          ItemId,
            RegionId,
            WarehouseId,
            BinShelfId,
            Condition,
            InventoryStatus,
            InventoryQuantity,
            SerialNumber,
            BarCode,
            InventorySourceSystem,
            _FILENAME,
            try_to_timestamp(replace(split_part(_filename,'_',2)||split_part(_filename,'_',3),'.feed.gz',''),'yyyymmddHH24MIss')  AS FILEDATE


        FROM {{ ref('ODS__PROPHET__INVENTORY') }} ODS

)
,transform_data_a as
(
    SELECT
       ItemId,
            RegionId,
            WarehouseId,
            BinShelfId,
            Condition,
            InventoryStatus,
            InventoryQuantity,
            SerialNumber,
            BarCode,
            InventorySourceSystem,
            REPLACE(LEFT(_FILENAME,CHARINDEX('_',_FILENAME)-1),'INVENTORY/INVENTORY','') AS OriginatingSubsidiary,
            LEFT(RegionId,CHARINDEX('-',RegionId)-1) AS WarehouseSubsidiary,
            SUBSTRING(RegionId,CHARINDEX('-',RegionId)+1) AS WarehouseType,
            FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM
        source_data
        ),

InventoryMax as
    (   SELECT OriginatingSubsidiary, MAX(FILEDATE) FILEDATE
         FROM transform_data_a GROUP BY OriginatingSubsidiary

),

transform_data as
    (
        SELECT  t1.ItemId,
                t1.RegionId,
                t1.WarehouseId,
                t1.BinShelfId,
                t1.Condition,
                t1.InventoryStatus,
                t1.InventoryQuantity,
                t1.SerialNumber,
                t1.BarCode,
                t1.InventorySourceSystem,
                t1.OriginatingSubsidiary,
                t1.WarehouseSubsidiary,
                t1.WarehouseType,
                t1.FILEDATE,
                AUDIT_LOG_ID,
                _ROW_HASH
        FROM transform_data_a t1
                 JOIN InventoryMax
            ON t1.OriginatingSubsidiary = InventoryMax.OriginatingSubsidiary AND t1.FILEDATE = InventoryMax.FILEDATE

                      )
,type_data as
(
    select
         CAST(ItemId AS VARCHAR(16777216)) AS ItemId,
         CAST(RegionId AS VARCHAR(16777216)) AS RegionId,
         CAST(WarehouseId AS VARCHAR(16777216)) AS WarehouseId,
         CAST(BinShelfId AS VARCHAR(16777216)) AS BinShelfId,
         CAST(Condition AS VARCHAR(16777216)) AS Condition,
         CAST(InventoryStatus AS VARCHAR(16777216)) AS InventoryStatus,
         CAST(InventoryQuantity AS Number(38,0)) AS InventoryQuantity,
         CAST(SerialNumber AS VARCHAR(16777216)) AS SerialNumber,
         CAST(BarCode AS VARCHAR(16777216)) AS BarCode,
         CAST(InventorySourceSystem AS VARCHAR(16777216)) AS InventorySourceSystem,
         CAST(FILEDATE AS TIMESTAMP_NTZ(9)) AS FILEDATE,
         CAST(OriginatingSubsidiary AS VARCHAR(16777216)) AS OriginatingSubsidiary,
         CAST(WarehouseType AS VARCHAR(16777216)) AS WarehouseType,
         CAST(WarehouseSubsidiary AS VARCHAR(16777216)) AS WarehouseSubsidiary,
         CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
         CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data