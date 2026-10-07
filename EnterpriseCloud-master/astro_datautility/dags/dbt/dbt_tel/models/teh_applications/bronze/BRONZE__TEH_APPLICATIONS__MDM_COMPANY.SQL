/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Company.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Company.SQL
-materialized incremental
-alias Company
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized = 'tel_incremental',
    incremental_strategy='merge',
    alias='MDM_COMPANY',
    unique_key = ['COMPANYCODE']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS CompanyCode
         ,JSonField:Name::STRING AS CompanyName
         ,JSonField:CompanyLongName::STRING AS LongName
         ,JSonField:CompanyActiveIndicator::STRING AS ActiveIndicator
        FROM {{ source("MDM", "COMPANY") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "COMPANY") }})
        )
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        source_data.COMPANYCODE AS COMPANYCODE,
        source_data.COMPANYNAME AS COMPANYNAME,
        source_data.LONGNAME AS LONGNAME,
        source_data.ACTIVEINDICATOR AS ACTIVEINDICATOR-- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        COMPANYCODE,
        COMPANYNAME,
        LONGNAME,
        ACTIVEINDICATOR
    from transform_data
    )
select * from type_data