/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\REQUESTSERVICE__CARMA_REQUESTSERVICE.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\REQUEST_SERVICE.SQL
-materialized incremental
-alias REQUEST_SERVICE
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema CARMA
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/10/2022 2:23:24 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='PROPHET_INVENTORY',
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
         LZ._FileName,
         _FileDate
        FROM {{ source("PROPHET", "INVENTORY") }} LZ

        {% if is_tel_incremental() %}

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
        source_data.FIELD3 AS BinShelfId,
        source_data.FIELD4 AS Condition,
        source_data.FIELD5 AS InventoryStatus,
        --source_data.FIELD6 AS InventoryQuantity,
        TRY_TO_NUMBER(source_data.FIELD6,38, 0) AS InventoryQuantity,
        source_data.FIELD7 AS SerialNumber,
        source_data.FIELD8 AS BarCode,
        source_data.FIELD9 AS InventorySourceSystem,
        source_data._FileName AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
         CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
         CAST(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
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
         CAST(InventorySourceSystem AS VARCHAR(16777216)) AS InventorySourceSystem
    from transform_data
    )
select * from type_data