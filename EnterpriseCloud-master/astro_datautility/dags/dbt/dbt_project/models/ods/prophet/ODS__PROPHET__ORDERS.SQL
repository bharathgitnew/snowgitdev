{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ORDERS',
    unique_key = []
) }}


with source_data as
(
    SELECT
            LZ.FIELD0,
            LZ.FIELD1,
            LZ.FIELD2,
            LZ.FIELD3,
            LZ.FIELD4,
            LZ.FIELD5,
            LZ.FIELD6,
            LZ.FIELD7,
            LZ.FIELD8,
            LZ.FIELD9,
            LZ.FIELD10,
            LZ.FIELD11,
            LZ.FIELD12,
            LZ.FIELD13,
            LZ.FIELD14,
            LZ.FIELD15,
            LZ.FIELD16,
            LZ.FIELD17,
            LZ.FIELD18,
            LZ.FIELD19,
            LZ.FIELD20,
            LZ.FIELD21,
            LZ._FileName
       -- FROM {{ source("PROPHET", "DEMAND") }}
        --{% if is_incremental() %} WHERE _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01') {% endif %}
    FROM {{ source("PROPHET", "ORDERS") }} LZ
        {% if is_incremental() %}
        LEFT JOIN {{ this }} ODS ON LZ._FileName = ODS._FileName
        WHERE ODS._FileName IS NULL
        {% endif %}
)
,transform_data as
(
    SELECT
        source_data.FIELD0 AS ItemId,
        source_data.FIELD1 AS RegionId,
        source_data.FIELD2 AS WarehouseId,
        source_data.FIELD3 AS SupplierId,
        source_data.FIELD4 AS SupplierType,
        TRY_TO_NUMBER(source_data.FIELD5,38,0) AS OrderDateKey,
        TRY_TO_NUMBER(source_data.FIELD6,38,0) AS DueDateKey,
        TRY_TO_NUMBER(source_data.FIELD7,38,0) AS Quantity,
        TRY_TO_NUMBER(source_data.FIELD8,38,0) AS SuggestedDueDateKey,
        TRY_TO_NUMBER(source_data.FIELD9,38,0) AS SuggestedQuantity,
        TRY_TO_NUMBER(source_data.FIELD10,38,0) AS ReceivedQuantity,
        source_data.FIELD11 AS AllowChanges,
        source_data.FIELD12 AS PONumber,
        source_data.FIELD13 AS POLineItem,
        source_data.FIELD14 AS Status,
        source_data.FIELD15 AS SupplierPartNumber,
        TRY_TO_NUMBER(source_data.FIELD16,38,0) AS OrderApprovalID,
        TRY_TO_NUMBER(source_data.FIELD17,38,0) AS OrderApprovalSequence,
        TRY_TO_NUMBER(source_data.FIELD18,11,2) AS OrderUnitCost,
        TRY_TO_NUMBER(source_data.FIELD19,38,0) AS ScrappedQuantity,
        source_data.FIELD20 AS ReferenceA,
        source_data.FIELD21 AS ReferenceB,
        source_data._FileName AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
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
      --  CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data