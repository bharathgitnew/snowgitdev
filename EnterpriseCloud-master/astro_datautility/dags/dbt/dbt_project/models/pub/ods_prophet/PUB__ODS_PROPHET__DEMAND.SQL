{{ config(
    materialized='view',
    alias='DEMAND'
) }}


with source_data as (
    SELECT ItemId,
        RegionId,
        InventorySourceSystem,
        OrderQuantity,
        OrderDate,
        OrderTime,
        DeliveredQuantity,
        DeliveryDate,
        DeliveredTime,
        RequiredDate,
        RequiredTime,
        ReceivedDate,
        ReceivedTime,
        SourceSystemTransactionID,
        CustomerOrderID,
        SerialNumber,
        DeliveryPostalCode,
        DeliveryCountryCode,
        DeliveryCity,
        DeliveryStateProvince,
        DeliveryName,
        OrderType,
        OrderPriority,
        CoverageDays,
        CoverageHours,
        CustomerID,
        CustomerPriority,
        ProductCode,
        WarehouseRegion,
        WarehouseId,
        FIELD30,
        FIELD31,
        FIELD32,
        FIELD33,
        FIELD34,
        FIELD35,
        _FILENAME
    FROM {{ ref('ODS__PROPHET__DEMAND') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data