/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Warehouse.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Warehouse.SQL
-materialized incremental
-alias Warehouse
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 7:25:01 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='Warehouse',
    unique_key = ['WAREHOUSEID']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS WarehouseId
         ,JSonField:WarehouseRelationship::STRING AS WarehouseRelationship
         ,JSonField:WarehouseClassification::STRING AS WarehouseClassification
         ,JSonField:ActiveFlag::STRING AS ActiveFlag
         ,JSonField:IntelFlag::STRING AS IntelFlag
        FROM {{ source("MDM", "WAREHOUSE") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "WAREHOUSE") }})
        )
,transform_data as
(
    SELECT
        source_data.WAREHOUSEID AS WAREHOUSEID,
        source_data.WAREHOUSERELATIONSHIP AS WAREHOUSERELATIONSHIP,
        source_data.WAREHOUSECLASSIFICATION AS WAREHOUSECLASSIFICATION,
        source_data.ACTIVEFLAG AS ACTIVEFLAG,
        source_data.INTELFLAG AS INTELFLAG,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(WAREHOUSEID as VARCHAR(16777216)) as WAREHOUSEID,
        cast(WAREHOUSERELATIONSHIP as VARCHAR(16777216)) as WAREHOUSERELATIONSHIP,
        cast(WAREHOUSECLASSIFICATION as VARCHAR(16777216)) as WAREHOUSECLASSIFICATION,
        cast(ACTIVEFLAG as VARCHAR(16777216)) as ACTIVEFLAG,
        cast(INTELFLAG as VARCHAR(16777216)) as INTELFLAG,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data