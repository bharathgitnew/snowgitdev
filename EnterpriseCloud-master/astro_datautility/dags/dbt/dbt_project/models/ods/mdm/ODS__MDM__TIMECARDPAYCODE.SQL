/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\TimecardPaycode__MDM_TimecardPaycode.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\TimecardPaycode.SQL 
-materialized incremental
-alias TimecardPaycode 
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
    alias='TimecardPaycode',
    unique_key = ['ID']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"ID"::NUMBER AS ID, 
        jsonfield:"Name"::VARCHAR AS Name, 
        jsonfield:"Code"::VARCHAR AS Code, 
        jsonfield:"Description"::VARCHAR AS Description 
        FROM {{ source("MDM", "TIMECARDPAYCODE") }} 
		WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "TIMECARDPAYCODE") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.ID AS ID, 
        source_data.NAME AS Name, 
        source_data.CODE AS Code, 
        source_data.DESCRIPTION AS Description, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(ID as NUMBER(38,0)) as ID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(CODE as VARCHAR(16777216)) as CODE,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data