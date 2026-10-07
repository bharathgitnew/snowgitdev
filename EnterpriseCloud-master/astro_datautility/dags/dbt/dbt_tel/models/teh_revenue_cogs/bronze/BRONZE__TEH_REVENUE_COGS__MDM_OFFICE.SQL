/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Office.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Office.SQL
-materialized incremental
-alias Office
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_OFFICE',
    unique_key = ['OFFICECODE']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS OfficeCode
         ,JSonField:OfficeRegion::STRING AS OfficeRegion
         ,JSonField:OfficeKey::INTEGER AS OfficeKey
         ,JSonField:OracleOfficeCode::STRING AS OracleOfficeCode
        FROM {{ source("MDM", "OFFICE") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "OFFICE") }})
        )
,transform_data as
(
    SELECT
        _Filedate as _Filedate,
        _Filename as _Filename,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.OFFICECODE AS OFFICECODE,
        source_data.OFFICEREGION AS REGION,
        source_data.OFFICEKEY AS OFFICEKEY,
        source_data.ORACLEOFFICECODE AS ORACLEOFFICECODE        
        FROM source_data
        )
,type_data as
(
    select
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(OFFICECODE as VARCHAR(16777216)) as OFFICECODE,
        cast(REGION as VARCHAR(16777216)) as REGION,
        cast(OFFICEKEY as NUMBER(38,0)) as OFFICEKEY,
        cast(ORACLEOFFICECODE as VARCHAR(16777216)) as ORACLEOFFICECODE
    from transform_data
    )
select * from type_data