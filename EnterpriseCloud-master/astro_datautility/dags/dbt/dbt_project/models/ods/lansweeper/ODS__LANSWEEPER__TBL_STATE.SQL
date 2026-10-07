/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_STATE__Lansweeper_tblState.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_STATE.SQL 
-materialized incremental
-alias TBL_STATE 
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
    alias='TBL_STATE',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"State"::NUMBER AS State 
        ,JSONFIELD:"Statename"::STRING AS State_name 
        ,REGEXP_REPLACE(JSONFIELD:"LastChanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Changed 
        FROM {{ source("LANSWEEPER", "TBLSTATE") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLSTATE") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.LAST_CHANGED, 
        source_data.STATE, 
        source_data.STATE_NAME, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(STATE_NAME as VARCHAR(16777216)) as STATE_NAME,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data