/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TSYS_IP_LOCATIONS__Lansweeper_tsysIPLocations.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TSYS_IP_LOCATIONS.SQL 
-materialized incremental
-alias TSYS_IP_LOCATIONS 
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
    alias='TSYS_IP_LOCATIONS',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"StartIP"::NUMBER AS Start_IP 
        ,JSONFIELD:"EndIP"::NUMBER AS End_IP 
        ,JSONFIELD:"IPLocation"::STRING AS IP_Location 
        ,JSONFIELD:"Realstart"::STRING AS Real_start 
        ,JSONFIELD:"Realend"::STRING AS Real_end 
        ,JSONFIELD:"PackageShare"::STRING AS Package_Share 
        ,JSONFIELD:"ShareUsername"::STRING AS Share_Username 
        ,JSONFIELD:"SharePassword"::STRING AS Share_Password 
        ,JSONFIELD:"ShareKeyHash"::NUMBER AS Share_Key_Hash 
        ,JSONFIELD:"LocationID"::NUMBER AS Location_ID 
        FROM {{ source("LANSWEEPER", "TSYSIPLOCATIONS") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TSYSIPLOCATIONS") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.END_IP, 
        source_data.IP_LOCATION, 
        source_data.LOCATION_ID, 
        source_data.PACKAGE_SHARE, 
        source_data.REAL_END, 
        source_data.REAL_START, 
        source_data.SHARE_KEY_HASH, 
        source_data.SHARE_PASSWORD, 
        source_data.SHARE_USERNAME, 
        source_data.START_IP, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(START_IP as NUMBER(38,0)) as START_IP,
        cast(END_IP as NUMBER(38,0)) as END_IP,
        cast(IP_LOCATION as VARCHAR(16777216)) as IP_LOCATION,
        cast(REAL_START as VARCHAR(16777216)) as REAL_START,
        cast(REAL_END as VARCHAR(16777216)) as REAL_END,
        cast(PACKAGE_SHARE as VARCHAR(16777216)) as PACKAGE_SHARE,
        cast(SHARE_USERNAME as VARCHAR(16777216)) as SHARE_USERNAME,
        cast(SHARE_PASSWORD as VARCHAR(16777216)) as SHARE_PASSWORD,
        cast(SHARE_KEY_HASH as NUMBER(38,0)) as SHARE_KEY_HASH,
        cast(LOCATION_ID as NUMBER(38,0)) as LOCATION_ID,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data