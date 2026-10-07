/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-MySkills\GBMN_Table__MySkills_GBMNTable.SQL 
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\myskills\GBMNTable.SQL 
-materialized incremental
-alias GBMNTable 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MYSKILLS
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 6:09:18 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='GBMN_Table',
    unique_key = ['GBASHOCD']
) }}


with source_data as 
(
    SELECT  
         _Filename as _Filename 
        ,_Filedate as _Filedate 
        ,JSonField:GYOMUYMD::STRING AS GYOMUYMD 
        ,JSonField:GBASHOCD::STRING AS GBASHOCD 
        ,JSonField:YUKKYMD::STRING AS YUKKYMD 
        ,JSonField:YKEYMD::STRING AS YKEYMD 
        ,JSonField:BASHOCD::STRING AS BASHOCD 
        ,JSonField:KUNICD::STRING AS KUNICD 
        ,JSonField:TORIYMD::STRING AS TORIYMD 
        ,JSonField:GBASYSNJ::STRING AS GBASYSNJ 
        ,JSonField:GBASYSNE::STRING AS GBASYSNE 
        ,JSonField:GBASYONM::STRING AS GBASYONM 
        ,JSonField:GBASYONE::STRING AS GBASYONE 
        ,JSonField:TIMESP::STRING AS TIMESP 
        FROM {{ source("MYSKILLS", "GBMN_TABLE") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MYSKILLS", "GBMN_TABLE") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.GYOMUYMD AS GYOMUYMD, 
        source_data.GBASHOCD AS GBASHOCD, 
        source_data.YUKKYMD AS YUKKYMD, 
        source_data.YKEYMD AS YKEYMD, 
        source_data.BASHOCD AS BASHOCD, 
        source_data.KUNICD AS KUNICD, 
        source_data.TORIYMD AS TORIYMD, 
        source_data.GBASYSNJ AS GBASYSNJ, 
        source_data.GBASYSNE AS GBASYSNE, 
        source_data.GBASYONM AS GBASYONM, 
        source_data.GBASYONE AS GBASYONE, 
        source_data.TIMESP AS TIMESP, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(GYOMUYMD as VARCHAR(16777216)) as GYOMUYMD,
        cast(GBASHOCD as VARCHAR(16777216)) as GBASHOCD,
        cast(YUKKYMD as VARCHAR(16777216)) as YUKKYMD,
        cast(YKEYMD as VARCHAR(16777216)) as YKEYMD,
        cast(BASHOCD as VARCHAR(16777216)) as BASHOCD,
        cast(KUNICD as VARCHAR(16777216)) as KUNICD,
        cast(TORIYMD as VARCHAR(16777216)) as TORIYMD,
        cast(GBASYSNJ as VARCHAR(16777216)) as GBASYSNJ,
        cast(GBASYSNE as VARCHAR(16777216)) as GBASYSNE,
        cast(GBASYONM as VARCHAR(16777216)) as GBASYONM,
        cast(GBASYONE as VARCHAR(16777216)) as GBASYONE,
        cast(TIMESP as TIMESTAMP_NTZ(9)) as TIMESP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data