/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_PROCESSOR__Lansweeper_tblProcessor.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_PROCESSOR.SQL 
-materialized incremental
-alias TBL_PROCESSOR 
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
    alias='TBL_PROCESSOR',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"WIN32_PROCESSORid"::NUMBER AS WIN32_PROCESSORid 
        ,JSONFIELD:"AssetID"::NUMBER AS Asset_ID 
        ,JSONFIELD:"AddressWidth"::NUMBER AS Address_Width 
        ,JSONFIELD:"Architecture"::NUMBER AS Architecture 
        ,JSONFIELD:"Availability"::NUMBER AS Availability 
        ,JSONFIELD:"Caption"::STRING AS Caption 
        ,JSONFIELD:"CpuStatus"::NUMBER AS Cpu_Status 
        ,JSONFIELD:"DataWidth"::NUMBER AS Data_Width 
        ,JSONFIELD:"DeviceID"::STRING AS Device_ID 
        ,JSONFIELD:"ExtClock"::NUMBER AS Ext_Clock 
        ,JSONFIELD:"Family"::NUMBER AS Family 
        ,JSONFIELD:"L2CacheSize"::NUMBER AS L2_Cache_Size 
        ,JSONFIELD:"L2CacheSpeed"::NUMBER AS L2_Cache_Speed 
        ,JSONFIELD:"Level"::NUMBER AS Level 
        ,JSONFIELD:"Manufacturer"::STRING AS Manufacturer 
        ,JSONFIELD:"MaxClockSpeed"::NUMBER AS Max_Clock_Speed 
        ,JSONFIELD:"Name"::STRING AS Name 
        ,JSONFIELD:"NumberOfCores"::NUMBER AS Number_Of_Cores 
        ,JSONFIELD:"NumberOfLogicalProcessors"::NUMBER AS Number_Of_Logical_Processors 
        ,JSONFIELD:"ProcessorId"::STRING AS Processor_Id 
        ,JSONFIELD:"ProcessorType"::NUMBER AS Processor_Type 
        ,JSONFIELD:"Revision"::NUMBER AS Revision 
        ,JSONFIELD:"SocketDesignation"::STRING AS Socket_Designation 
        ,JSONFIELD:"Stepping"::STRING AS Stepping 
        ,JSONFIELD:"UniqueId"::STRING AS Unique_Id 
        ,JSONFIELD:"UpgradeMethod"::NUMBER AS Upgrade_Method 
        ,JSONFIELD:"Version"::STRING AS Version 
        ,JSONFIELD:"VoltageCaps"::NUMBER AS Voltage_Caps 
        ,REGEXP_REPLACE(JSONFIELD:"Lastchanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_changed 
        ,JSONFIELD:"TotalProcCapacity":NUMBER AS Total_Proc_Capacity 
        FROM {{ source("LANSWEEPER", "TBLPROCESSOR") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLPROCESSOR") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.ADDRESS_WIDTH, 
        source_data.ARCHITECTURE, 
        source_data.ASSET_ID, 
        source_data.AVAILABILITY, 
        source_data.CAPTION, 
        source_data.CPU_STATUS, 
        source_data.DATA_WIDTH, 
        source_data.DEVICE_ID, 
        source_data.EXT_CLOCK, 
        source_data.FAMILY, 
        source_data.L2_CACHE_SIZE, 
        source_data.L2_CACHE_SPEED, 
        source_data.LAST_CHANGED, 
        source_data.LEVEL, 
        source_data.MANUFACTURER, 
        source_data.MAX_CLOCK_SPEED, 
        source_data.NAME, 
        source_data.NUMBER_OF_CORES, 
        source_data.NUMBER_OF_LOGICAL_PROCESSORS, 
        source_data.PROCESSOR_ID, 
        source_data.PROCESSOR_TYPE, 
        source_data.REVISION, 
        source_data.SOCKET_DESIGNATION, 
        source_data.STEPPING, 
        source_data.UNIQUE_ID, 
        source_data.UPGRADE_METHOD, 
        source_data.VERSION, 
        source_data.VOLTAGE_CAPS, 
        source_data.WIN32_PROCESSORID, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(WIN32_PROCESSORID as NUMBER(38,0)) as WIN32_PROCESSORID,
        cast(ASSET_ID as NUMBER(38,0)) as ASSET_ID,
        cast(ADDRESS_WIDTH as NUMBER(38,0)) as ADDRESS_WIDTH,
        cast(ARCHITECTURE as NUMBER(38,0)) as ARCHITECTURE,
        cast(AVAILABILITY as NUMBER(38,0)) as AVAILABILITY,
        cast(CAPTION as VARCHAR(16777216)) as CAPTION,
        cast(CPU_STATUS as NUMBER(38,0)) as CPU_STATUS,
        cast(DATA_WIDTH as NUMBER(38,0)) as DATA_WIDTH,
        cast(DEVICE_ID as VARCHAR(16777216)) as DEVICE_ID,
        cast(EXT_CLOCK as NUMBER(38,0)) as EXT_CLOCK,
        cast(FAMILY as NUMBER(38,0)) as FAMILY,
        cast(L2_CACHE_SIZE as NUMBER(38,0)) as L2_CACHE_SIZE,
        cast(L2_CACHE_SPEED as NUMBER(38,0)) as L2_CACHE_SPEED,
        cast(LEVEL as NUMBER(38,0)) as LEVEL,
        cast(MANUFACTURER as VARCHAR(16777216)) as MANUFACTURER,
        cast(MAX_CLOCK_SPEED as NUMBER(38,0)) as MAX_CLOCK_SPEED,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(NUMBER_OF_CORES as NUMBER(38,0)) as NUMBER_OF_CORES,
        cast(NUMBER_OF_LOGICAL_PROCESSORS as NUMBER(38,0)) as NUMBER_OF_LOGICAL_PROCESSORS,
        cast(PROCESSOR_ID as VARCHAR(16777216)) as PROCESSOR_ID,
        cast(PROCESSOR_TYPE as NUMBER(38,0)) as PROCESSOR_TYPE,
        cast(REVISION as NUMBER(38,0)) as REVISION,
        cast(SOCKET_DESIGNATION as VARCHAR(16777216)) as SOCKET_DESIGNATION,
        cast(STEPPING as VARCHAR(16777216)) as STEPPING,
        cast(UNIQUE_ID as VARCHAR(16777216)) as UNIQUE_ID,
        cast(UPGRADE_METHOD as NUMBER(38,0)) as UPGRADE_METHOD,
        cast(VERSION as VARCHAR(16777216)) as VERSION,
        cast(VOLTAGE_CAPS as NUMBER(38,0)) as VOLTAGE_CAPS,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data