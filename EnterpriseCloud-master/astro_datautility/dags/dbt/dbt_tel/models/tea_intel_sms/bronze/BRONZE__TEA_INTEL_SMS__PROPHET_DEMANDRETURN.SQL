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
    alias='PROPHET_DEMANDRETURN',
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
         LZ._FileName
        FROM {{ source("PROPHET", "DEMANDRETURN") }} LZ
        {% if is_tel_incremental() %} 
         LEFT JOIN {{ this }} ODS ON LZ._FileName = ODS._FileName 
         WHERE ODS._FileName IS NULL
        {% endif %}
)
,	transform_data as
(
    SELECT
		source_data._FileName AS _FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		source_data.FIELD0 AS ItemId,
		source_data.FIELD1 AS WarehouseRegionId,
		source_data.FIELD2 AS WarehouseId,
		source_data.FIELD3 AS TransactionType,
		TRY_TO_NUMBER(source_data.FIELD4,38, 0) AS OrderMonthDate,
		TRY_TO_NUMBER(source_data.FIELD5,38,10) AS Quantity 
        FROM source_data
        )
,	type_data as
(
    select
		CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		CAST(_ROW_HASH as varchar(128)) as _ROW_HASH,
		CAST(ItemId AS VARCHAR(16777216)) AS ItemId,
		CAST(WarehouseRegionId AS VARCHAR(16777216)) AS WarehouseRegionId,
		CAST(WarehouseId AS VARCHAR(16777216)) AS WarehouseId,
		CAST(TransactionType AS VARCHAR(16777216)) AS TransactionType,
		CAST(OrderMonthDate AS NUMBER(38,0)) AS OrderMonthDate,
		CAST(Quantity AS NUMBER(38,10)) AS Quantity
    from transform_data
    )
select * from type_data