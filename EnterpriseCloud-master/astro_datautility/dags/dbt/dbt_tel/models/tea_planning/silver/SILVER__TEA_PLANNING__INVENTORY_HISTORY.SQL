{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='PROPHET_Inventory_History',
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


        FROM {{ ref('BRONZE__TEA_PLANNING__PROPHET_INVENTORY') }} ODS

        {% if is_tel_incremental() %}

        WHERE FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01')

        {% endif %}
)
,transform_data as
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
        )
,type_data as
(
    select
         CAST(FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
         CAST(AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
         CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
         CAST(ItemId AS VARCHAR(16777216)) AS ItemId,
         CAST(RegionId AS VARCHAR(16777216)) AS RegionId,
         CAST(WarehouseId AS VARCHAR(16777216)) AS WarehouseId,
         CAST(BinShelfId AS VARCHAR(16777216)) AS BinShelfId,
         CAST(Condition AS VARCHAR(16777216)) AS Condition,
         CAST(InventoryStatus AS VARCHAR(16777216)) AS InventoryStatus,
         CAST(InventoryQuantity AS NUMBER(38,0)) AS InventoryQuantity,
         CAST(SerialNumber AS VARCHAR(16777216)) AS SerialNumber,
         CAST(BarCode AS VARCHAR(16777216)) AS BarCode,
         CAST(InventorySourceSystem AS VARCHAR(16777216)) AS InventorySourceSystem,
         CAST(OriginatingSubsidiary AS VARCHAR(16777216)) AS OriginatingSubsidiary,
         CAST(WarehouseType AS VARCHAR(16777216)) AS WarehouseType,
         CAST(WarehouseSubsidiary AS VARCHAR(16777216)) AS WarehouseSubsidiary
    from transform_data
    )
select * from type_data