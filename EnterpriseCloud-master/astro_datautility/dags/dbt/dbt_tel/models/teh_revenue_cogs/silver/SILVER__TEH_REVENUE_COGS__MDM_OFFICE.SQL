/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Office.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\Office.SQL
-materialized tel_incremental
-alias Office
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_OFFICE',
    unique_key = ['OfficeCode']
) }}

with source_data as
(
    SELECT
    Office.OFFICECODE AS OfficeCode,
    Office.REGION AS Region,
    Office.OFFICEKEY AS OfficeKey,
    Office.ORACLEOFFICECODE AS OracleOfficeCode
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__MDM_OFFICE') }} Office
    )
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        OfficeCode,
        Region,
        OfficeKey,
        OracleOfficeCode
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(OFFICECODE as VARCHAR(16777216)) as OFFICECODE,
        cast(REGION as VARCHAR(16777216)) as REGION,
        cast(OFFICEKEY as NUMBER(38,0)) as OFFICEKEY,
        cast(ORACLEOFFICECODE as VARCHAR(16777216)) as ORACLEOFFICECODE
    from transform_data
    )
select * from type_data