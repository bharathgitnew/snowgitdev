/************
Model file generated from dbtGeneratePubViews: 05.09.2022.16.29.44"
*************/

{{ config(
      materialized='view',
      alias='INVENTORY',
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
            _FILENAME
    from {{ ref('ODS__PROPHET__INVENTORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data