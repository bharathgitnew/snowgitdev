{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Inventory_Active',
    unique_key = []
) }}


with ph_inv as 
(
    Select
        ItemId
        ,RegionId
        ,WarehouseId
        ,BinShelfId
        ,Condition
        ,InventoryStatus
        ,InventoryQuantity
        ,SerialNumber
        ,BarCode
        ,InventorySourceSystem
        ,OriginatingSubsidiary
        ,WarehouseSubsidiary
        ,WarehouseType
        ,FILEDATE
        ,row_number() over (partition by itemid,regionid,warehouseid order by filedate desc) as rownumber
    from PUB.COMMON_PROPHET.INVENTORY_LIVE
    where
        inventorystatus = 'OH'
        and regionid in ('TEL-GDC','TEL-DC','TEL-FLD','TEA-FLD','TEA-DC','TEE-FLD','TEE-DC')
),

source_data as 
(
    select 
        ItemId
        ,RegionId
        ,WarehouseId
        ,BinShelfId
        ,Condition
        ,InventoryStatus
        ,InventoryQuantity
        ,SerialNumber
        ,BarCode
        ,InventorySourceSystem
        ,OriginatingSubsidiary
        ,WarehouseSubsidiary
        ,WarehouseType
        ,FILEDATE
        ,rownumber
        from ph_inv
        where rownumber = 1
),

transform_data as 
(
        select 
        ItemId
        ,RegionId
        ,WarehouseId
        ,BinShelfId
        ,Condition
        ,InventoryStatus
        ,InventoryQuantity
        ,SerialNumber
        ,BarCode
        ,InventorySourceSystem
        ,OriginatingSubsidiary
        ,WarehouseSubsidiary
        ,WarehouseType
        ,FILEDATE
        ,rownumber
        from source_data
),

type_data as
(
    select * from transform_data
)

select * from type_data