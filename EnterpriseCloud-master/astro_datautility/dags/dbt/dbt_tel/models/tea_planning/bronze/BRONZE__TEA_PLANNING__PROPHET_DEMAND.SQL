{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='PROPHET_DEMAND',
    unique_key = []
) }}


with source_data as
(
    SELECT
         FIELD0,
         FIELD1,
         FIELD2,
         FIELD3,
         FIELD4,
         FIELD5,
         FIELD6,
         FIELD7,
         FIELD8,
         FIELD9,
         FIELD10,
         FIELD11,
         FIELD12,
         FIELD13,
         FIELD14,
         FIELD15,
         FIELD16,
         FIELD17,
         FIELD18,
         FIELD19,
         FIELD20,
         FIELD21,
         FIELD22,
         FIELD23,
         FIELD24,
         FIELD25,
         FIELD26,
         FIELD27,
         FIELD28,
         FIELD29,
         LZ.FIELD30,
         LZ.FIELD31,
         LZ.FIELD32,
         LZ.FIELD33,
         LZ.FIELD34,
         LZ.FIELD35,
         LZ._FileName
        FROM {{ source("PROPHET", "DEMAND") }} LZ
        {% if is_tel_incremental() %}
        LEFT JOIN {{ this }} ODS ON LZ._FileName = ODS._FileName
        WHERE ODS._FileName IS NULL 
        {% endif %}

        /*FROM {{ source("PROPHET", "DEMAND") }}
        {% if is_tel_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}*/
)
,transform_data as
(
    SELECT
        source_data.FIELD0 AS ItemId,
        source_data.FIELD1 AS RegionId,
        source_data.FIELD2 AS InventorySourceSystem,
        TRY_TO_NUMBER(source_data.FIELD3,38,0) AS OrderQuantity,
        source_data.FIELD4 AS OrderDate,
        source_data.FIELD5 AS OrderTime,
        TRY_TO_NUMBER(source_data.FIELD6,38,0) AS DeliveredQuantity,
        source_data.FIELD7 AS DeliveryDate,
        source_data.FIELD8 AS DeliveredTime,
        source_data.FIELD9 AS RequiredDate,
        source_data.FIELD10 AS RequiredTime,
        source_data.FIELD11 AS ReceivedDate,
        source_data.FIELD12 AS ReceivedTime,
        source_data.FIELD13 AS SourceSystemTransactionID,
        source_data.FIELD14 AS CustomerOrderID,
        source_data.FIELD15 AS SerialNumber,
        source_data.FIELD16 AS DeliveryPostalCode,
        source_data.FIELD17 AS DeliveryCountryCode,
        source_data.FIELD18 AS DeliveryCity,
        source_data.FIELD19 AS DeliveryStateProvince,
        source_data.FIELD20 AS DeliveryName,
        source_data.FIELD21 AS OrderType,
        TRY_TO_NUMBER(source_data.FIELD22,38,0) AS OrderPriority,
        TRY_TO_NUMBER(source_data.FIELD23,38,0) AS CoverageDays,
        source_data.FIELD24 AS CoverageHours,
        TRY_TO_NUMBER(source_data.FIELD25,38,0) AS CustomerID,
        source_data.FIELD26 AS CustomerPriority,
        TRY_TO_NUMBER(source_data.FIELD27,38,0) AS ProductCode,
        source_data.FIELD28 AS WarehouseRegion,
        source_data.FIELD29 AS WarehouseId,
        source_data.FIELD30 AS FIELD30,
        source_data.FIELD31 AS FIELD31,
        source_data.FIELD32 AS FIELD32,
        source_data.FIELD33 AS FIELD33,
        source_data.FIELD34 AS FIELD34,
        source_data.FIELD35 AS FIELD35,
        source_data._FileName AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
         --CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
         CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
         CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
         CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
         CAST(ItemId AS VARCHAR(16777216)) AS ItemId,
         CAST(RegionId AS VARCHAR(16777216)) AS RegionId,
         CAST(InventorySourceSystem AS VARCHAR(16777216)) AS InventorySourceSystem,
         CAST(OrderQuantity AS NUMBER(38,0)) AS OrderQuantity,
         CAST(OrderDate AS VARCHAR(16777216)) AS OrderDate,
         CAST(OrderTime AS VARCHAR(16777216)) AS OrderTime,
         CAST(DeliveredQuantity AS NUMBER(38,0)) AS DeliveredQuantity,
         CAST(DeliveryDate AS VARCHAR(16777216)) AS DeliveryDate,
         CAST(DeliveredTime AS VARCHAR(16777216)) AS DeliveredTime,
         CAST(RequiredDate AS VARCHAR(16777216)) AS RequiredDate,
         CAST(RequiredTime AS VARCHAR(16777216)) AS RequiredTime,
         CAST(ReceivedDate AS VARCHAR(16777216)) AS ReceivedDate,
         CAST(ReceivedTime AS VARCHAR(16777216)) AS ReceivedTime,
         CAST(SourceSystemTransactionID AS VARCHAR(16777216)) AS SourceSystemTransactionID,
         CAST(CustomerOrderID AS VARCHAR(16777216)) AS CustomerOrderID,
         CAST(SerialNumber AS VARCHAR(16777216)) AS SerialNumber,
         CAST(DeliveryPostalCode AS VARCHAR(16777216)) AS DeliveryPostalCode,
         CAST(DeliveryCountryCode AS VARCHAR(16777216)) AS DeliveryCountryCode,
         CAST(DeliveryCity AS VARCHAR(16777216)) AS DeliveryCity,
         CAST(DeliveryStateProvince AS VARCHAR(16777216)) AS DeliveryStateProvince,
         CAST(DeliveryName AS VARCHAR(16777216)) AS DeliveryName,
         CAST(OrderType AS VARCHAR(16777216)) AS OrderType,
         CAST(OrderPriority AS NUMBER(38,0)) AS OrderPriority,
         CAST(CoverageDays AS NUMBER(38,0)) AS CoverageDays,
         CAST(CoverageHours AS VARCHAR(16777216)) AS CoverageHours,
         CAST(CustomerID AS NUMBER(38,0)) AS CustomerID,
         CAST(CustomerPriority AS VARCHAR(16777216)) AS CustomerPriority,
         CAST(ProductCode AS NUMBER(38,0)) AS ProductCode,
         CAST(WarehouseRegion AS VARCHAR(16777216)) AS WarehouseRegion,
         CAST(WarehouseId AS VARCHAR(16777216)) AS WarehouseId,
         CAST(Field30 AS VARCHAR(16777216)) AS Field30,
         CAST(Field31 AS VARCHAR(16777216)) AS Field31,
         CAST(Field32 AS VARCHAR(16777216)) AS Field32,
         CAST(Field33 AS VARCHAR(16777216)) AS Field33,
         CAST(Field34 AS VARCHAR(16777216)) AS Field34,
         CAST(Field35 AS VARCHAR(16777216)) AS Field35
    from transform_data
    )
select * from type_data