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
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_TIMECARDPAYCODE',
    unique_key = ['ID']
) }}


with source_data as 
(
    SELECT 
        _Filename,
        _Filedate,
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
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        source_data.ID AS ID,
        source_data.NAME AS Name,
        source_data.CODE AS Code,
        source_data.DESCRIPTION AS Description
FROM source_data
        )
,type_data as 
(
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(ID as NUMBER(38,0)) as ID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(CODE as VARCHAR(16777216)) as CODE,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION
from transform_data
    )
select * from type_data