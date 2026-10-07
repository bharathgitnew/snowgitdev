/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TSYS_OS__Lansweeper_tsysOS.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TSYS_OS.SQL 
-materialized incremental
-alias TSYS_OS 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema LANSWEEPER
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 9:15:50 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TSYS_OS',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"OScode"::STRING AS OS_code 
        ,JSONFIELD:"OSname"::STRING AS OS_name 
        ,JSONFIELD:"Image"::STRING AS Image 
        ,JSONFIELD:"Sortorder"::NUMBER AS Sort_order 
        ,JSONFIELD:"OSCodeNumeric"::NUMBER AS OS_Code_Numeric 
        FROM {{ source("LANSWEEPER", "TSYSOS") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TSYSOS") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.IMAGE, 
        source_data.OS_CODE, 
        source_data.OS_CODE_NUMERIC, 
        source_data.OS_NAME, 
        source_data.SORT_ORDER, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(OS_CODE as VARCHAR(16777216)) as OS_CODE,
        cast(OS_NAME as VARCHAR(16777216)) as OS_NAME,
        cast(IMAGE as VARCHAR(16777216)) as IMAGE,
        cast(SORT_ORDER as NUMBER(38,0)) as SORT_ORDER,
        cast(OS_CODE_NUMERIC as NUMBER(38,0)) as OS_CODE_NUMERIC,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data