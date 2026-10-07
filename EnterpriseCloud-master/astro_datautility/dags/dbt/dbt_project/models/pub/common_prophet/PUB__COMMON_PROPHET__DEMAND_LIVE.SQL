{{ config(
    materialized='view',
    alias='Demand_Live'
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
		OriginatingSubsidiary,
        WarehouseSubsidiary,
		WarehouseType,
        FileDate
    FROM {{ ref('COMMON__PROPHET__DEMAND_LIVE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data