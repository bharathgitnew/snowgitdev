/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_ASSETS__Lansweeper_tblAssets.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_ASSETS.SQL 
-materialized incremental
-alias TBL_ASSETS 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema LANSWEEPER
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 9:15:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TBL_ASSETS',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"AssetID"::NUMBER AS Asset_ID 
        ,JSONFIELD:"AssetUnique"::STRING AS Asset_Unique 
        ,JSONFIELD:"Domain"::STRING AS Domain 
        ,JSONFIELD:"Username"::STRING AS User_name 
        ,JSONFIELD:"Userdomain"::STRING AS User_domain 
        ,JSONFIELD:"FQDN"::STRING AS FQDN 
        ,JSONFIELD:"IPAddress"::STRING AS IP_Address 
        ,JSONFIELD:"IPNumeric"::NUMBER AS IP_Numeric 
        ,JSONFIELD:"SiteID"::NUMBER AS Site_ID 
        ,JSONFIELD:"Scanserver"::STRING AS Scan_server 
        ,JSONFIELD:"OScode"::STRING AS OS_code 
        ,JSONFIELD:"SP"::NUMBER AS SP 
        ,JSONFIELD:"Description"::STRING AS Description 
        ,JSONFIELD:"DescriptionLock"::NUMBER AS Description_Lock 
        ,JSONFIELD:"Assettype"::NUMBER AS Asset_type 
        ,JSONFIELD:"AssetTypeLock"::NUMBER AS Asset_Type_Lock 
        ,JSONFIELD:"AssetName"::STRING AS Asset_Name 
        ,JSONFIELD:"AssetNameLock"::NUMBER AS Asset_Name_Lock 
        ,JSONFIELD:"Mac"::STRING AS Mac 
        ,REGEXP_REPLACE(JSONFIELD:"Firstseen", '\/Date\\(|\\)\/', '')::TIMESTAMP AS First_seen 
        ,REGEXP_REPLACE(JSONFIELD:"Lastseen", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_seen 
        ,REGEXP_REPLACE(JSONFIELD:"Lasttried", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_tried 
        ,REGEXP_REPLACE(JSONFIELD:"Lasttriggered", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_triggered 
        ,REGEXP_REPLACE(JSONFIELD:"LastScheduled", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Scheduled 
        ,REGEXP_REPLACE(JSONFIELD:"LastActiveScan", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Active_Scan 
        ,REGEXP_REPLACE(JSONFIELD:"LastIPScan", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_IP_Scan 
        ,REGEXP_REPLACE(JSONFIELD:"LastLsPush", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Ls_Push 
        ,REGEXP_REPLACE(JSONFIELD:"LastSaved", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Saved 
        ,JSONFIELD:"Uptime"::NUMBER AS Uptime 
        ,JSONFIELD:"Memory"::NUMBER AS Memory 
        ,JSONFIELD:"NrProcessors"::NUMBER AS Nr_Processors 
        ,JSONFIELD:"Processor"::STRING AS Processor 
        ,JSONFIELD:"ServiceVersion"::STRING AS Service_Version 
        ,JSONFIELD:"LsPushVersion"::STRING AS Ls_Push_Version 
        ,REGEXP_REPLACE(JSONFIELD:"lastWorkgroupScan", '\/Date\\(|\\)\/', '')::TIMESTAMP AS last_Work_group_Scan 
        ,JSONFIELD:"LocationID"::NUMBER AS Location_ID 
        ,JSONFIELD:"ManualMAC"::NUMBER AS Manual_MAC 
        ,REGEXP_REPLACE(JSONFIELD:"LastChanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Changed 
        ,REGEXP_REPLACE(JSONFIELD:"LastLsFallBack", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Ls_FallBack 
        ,JSONFIELD:"BuildNumber"::STRING AS Build_Number 
        ,JSONFIELD:"Version"::STRING AS Version 
        ,JSONFIELD:"LsAgentVersion"::STRING AS Ls_Agent_Version 
        ,REGEXP_REPLACE(JSONFIELD:"LastLsAgent", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Ls_Agent 
        ,JSONFIELD:"HostTypeId"::NUMBER AS Host_Type_Id 
        ,REGEXP_REPLACE(JSONFIELD:"LastPerformanceScan", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Performance_Scan 
        ,JSONFIELD:"ScannedBy"::NUMBER AS Scanned_By 
        ,REGEXP_REPLACE(JSONFIELD:"LastSccmScan", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Sccm_Scan 
        FROM {{ source("LANSWEEPER", "TBLASSETS") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLASSETS") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.ASSET_ID, 
        source_data.ASSET_NAME, 
        source_data.ASSET_NAME_LOCK, 
        source_data.ASSET_TYPE, 
        source_data.ASSET_TYPE_LOCK, 
        source_data.ASSET_UNIQUE, 
        source_data.BUILD_NUMBER, 
        source_data.DESCRIPTION, 
        source_data.DESCRIPTION_LOCK, 
        source_data.DOMAIN, 
        source_data.FIRST_SEEN, 
        source_data.FQDN, 
        source_data.HOST_TYPE_ID, 
        source_data.IP_ADDRESS, 
        source_data.IP_NUMERIC, 
        source_data.LAST_ACTIVE_SCAN, 
        source_data.LAST_CHANGED, 
        source_data.LAST_IP_SCAN, 
        source_data.LAST_LS_AGENT, 
        source_data.LAST_LS_FALLBACK, 
        source_data.LAST_LS_PUSH, 
        source_data.LAST_PERFORMANCE_SCAN, 
        source_data.LAST_SAVED, 
        source_data.LAST_SCCM_SCAN, 
        source_data.LAST_SCHEDULED, 
        source_data.LAST_SEEN, 
        source_data.LAST_TRIED, 
        source_data.LAST_TRIGGERED, 
        source_data.LAST_WORK_GROUP_SCAN, 
        source_data.LOCATION_ID, 
        source_data.LS_AGENT_VERSION, 
        source_data.LS_PUSH_VERSION, 
        source_data.MAC, 
        source_data.MANUAL_MAC, 
        source_data.MEMORY, 
        source_data.NR_PROCESSORS, 
        source_data.OS_CODE, 
        source_data.PROCESSOR, 
        source_data.SCANNED_BY, 
        source_data.SCAN_SERVER, 
        source_data.SERVICE_VERSION, 
        source_data.SITE_ID, 
        source_data.SP, 
        source_data.UPTIME, 
        source_data.USER_DOMAIN, 
        source_data.USER_NAME, 
        source_data.VERSION, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(ASSET_ID as NUMBER(38,0)) as ASSET_ID,
        cast(ASSET_UNIQUE as VARCHAR(16777216)) as ASSET_UNIQUE,
        cast(DOMAIN as VARCHAR(16777216)) as DOMAIN,
        cast(USER_NAME as VARCHAR(16777216)) as USER_NAME,
        cast(USER_DOMAIN as VARCHAR(16777216)) as USER_DOMAIN,
        cast(FQDN as VARCHAR(16777216)) as FQDN,
        cast(IP_ADDRESS as VARCHAR(16777216)) as IP_ADDRESS,
        cast(IP_NUMERIC as NUMBER(38,0)) as IP_NUMERIC,
        cast(SITE_ID as NUMBER(38,0)) as SITE_ID,
        cast(SCAN_SERVER as VARCHAR(16777216)) as SCAN_SERVER,
        cast(OS_CODE as VARCHAR(16777216)) as OS_CODE,
        cast(SP as NUMBER(38,0)) as SP,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(DESCRIPTION_LOCK as NUMBER(38,0)) as DESCRIPTION_LOCK,
        cast(ASSET_TYPE as NUMBER(38,0)) as ASSET_TYPE,
        cast(ASSET_TYPE_LOCK as NUMBER(38,0)) as ASSET_TYPE_LOCK,
        cast(ASSET_NAME as VARCHAR(16777216)) as ASSET_NAME,
        cast(ASSET_NAME_LOCK as NUMBER(38,0)) as ASSET_NAME_LOCK,
        cast(MAC as VARCHAR(16777216)) as MAC,
        cast(FIRST_SEEN as TIMESTAMP_NTZ(9)) as FIRST_SEEN,
        cast(LAST_SEEN as TIMESTAMP_NTZ(9)) as LAST_SEEN,
        cast(LAST_TRIED as TIMESTAMP_NTZ(9)) as LAST_TRIED,
        cast(LAST_TRIGGERED as TIMESTAMP_NTZ(9)) as LAST_TRIGGERED,
        cast(LAST_SCHEDULED as TIMESTAMP_NTZ(9)) as LAST_SCHEDULED,
        cast(LAST_ACTIVE_SCAN as TIMESTAMP_NTZ(9)) as LAST_ACTIVE_SCAN,
        cast(LAST_IP_SCAN as TIMESTAMP_NTZ(9)) as LAST_IP_SCAN,
        cast(LAST_LS_PUSH as TIMESTAMP_NTZ(9)) as LAST_LS_PUSH,
        cast(LAST_SAVED as TIMESTAMP_NTZ(9)) as LAST_SAVED,
        cast(UPTIME as NUMBER(38,0)) as UPTIME,
        cast(MEMORY as NUMBER(38,0)) as MEMORY,
        cast(NR_PROCESSORS as NUMBER(38,0)) as NR_PROCESSORS,
        cast(PROCESSOR as VARCHAR(16777216)) as PROCESSOR,
        cast(SERVICE_VERSION as VARCHAR(16777216)) as SERVICE_VERSION,
        cast(LAST_WORK_GROUP_SCAN as TIMESTAMP_NTZ(9)) as LAST_WORK_GROUP_SCAN,
        cast(LOCATION_ID as NUMBER(38,0)) as LOCATION_ID,
        cast(MANUAL_MAC as NUMBER(38,0)) as MANUAL_MAC,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(LAST_LS_FALLBACK as TIMESTAMP_NTZ(9)) as LAST_LS_FALLBACK,
        cast(BUILD_NUMBER as VARCHAR(16777216)) as BUILD_NUMBER,
        cast(VERSION as VARCHAR(16777216)) as VERSION,
        cast(LS_AGENT_VERSION as VARCHAR(16777216)) as LS_AGENT_VERSION,
        cast(LAST_LS_AGENT as TIMESTAMP_NTZ(9)) as LAST_LS_AGENT,
        cast(HOST_TYPE_ID as NUMBER(38,0)) as HOST_TYPE_ID,
        cast(LAST_PERFORMANCE_SCAN as TIMESTAMP_NTZ(9)) as LAST_PERFORMANCE_SCAN,
        cast(SCANNED_BY as NUMBER(38,0)) as SCANNED_BY,
        cast(LAST_SCCM_SCAN as TIMESTAMP_NTZ(9)) as LAST_SCCM_SCAN,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(LS_PUSH_VERSION as VARCHAR(16777216)) as LS_PUSH_VERSION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data