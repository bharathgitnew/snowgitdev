{{ config(
      materialized='view',
      alias='Inventory_Live',
      transient=false
) }}

with source_data as (
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
                OriginatingSubsidiary,
                WarehouseSubsidiary,
                WarehouseType,
                FILEDATE

    from {{ ref('COMMON__PROPHET__INVENTORY_HISTORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data