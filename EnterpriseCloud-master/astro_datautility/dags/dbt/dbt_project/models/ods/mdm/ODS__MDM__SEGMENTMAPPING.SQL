/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\SegmentMapping__MDM_SegmentMapping.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\SegmentMapping.SQL 
-materialized incremental
-alias SegmentMapping 
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
    alias='SegmentMapping',
    unique_key = ['SegmentCode']
) }}


with source_data as 
(
    SELECT 
            jsonfield:"Segment Code"::VARCHAR AS SegmentCode, 
        	jsonfield:"Segment Description"::VARCHAR AS SegmentDescription, 
        	jsonfield:"Segment Short Name"::VARCHAR AS SegmentShortName, 
        	jsonfield:"Segment Group"::VARCHAR AS SegmentGroup, 
        	jsonfield:"Standard Machine BU"::VARCHAR AS StandardMachineBU, 
        	jsonfield:"Group Machine BU"::VARCHAR AS GroupMachineBU, 
        	jsonfield:"Paid Service Forecast Machine BU"::VARCHAR AS PaidServiceForecastMachineBU, 
        	jsonfield:"Sales_Forecast_BU_Name"::VARCHAR AS SalesForecastBUName, 
        	jsonfield:"Sales_Forecast_BU_Group"::VARCHAR AS SalesForecastBUGroup, 
        	jsonfield:"FS Flag"::VARCHAR AS FSFlag, 
        	jsonfield:"FS_BU_Group"::VARCHAR AS FSBUGroup 
        FROM {{ source("MDM", "SEGMENTMAPPING") }} 
        )
,transform_data as
(
    SELECT 
        source_data.SEGMENTCODE AS SegmentCode, 
        source_data.SEGMENTDESCRIPTION AS SegmentDescription, 
        source_data.SEGMENTSHORTNAME AS SegmentShortName, 
        source_data.SEGMENTGROUP AS SegmentGroup, 
        source_data.STANDARDMACHINEBU AS StandardMachineBU, 
        source_data.GROUPMACHINEBU AS GroupMachineBU, 
        source_data.PAIDSERVICEFORECASTMACHINEBU AS PaidServiceForecastMachineBU, 
        source_data.SALESFORECASTBUNAME AS SalesForecastBUName, 
        source_data.SALESFORECASTBUGROUP AS SalesForecastBUGroup, 
        source_data.FSFLAG AS FSFlag, 
        source_data.FSBUGROUP AS FSBUGroup, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(SEGMENTCODE as VARCHAR(16777216)) as SEGMENTCODE,
        cast(SEGMENTDESCRIPTION as VARCHAR(16777216)) as SEGMENTDESCRIPTION,
        cast(SEGMENTSHORTNAME as VARCHAR(16777216)) as SEGMENTSHORTNAME,
        cast(SEGMENTGROUP as VARCHAR(16777216)) as SEGMENTGROUP,
        cast(STANDARDMACHINEBU as VARCHAR(16777216)) as STANDARDMACHINEBU,
        cast(GROUPMACHINEBU as VARCHAR(16777216)) as GROUPMACHINEBU,
        cast(PAIDSERVICEFORECASTMACHINEBU as VARCHAR(16777216)) as PAIDSERVICEFORECASTMACHINEBU,
        cast(SALESFORECASTBUNAME as VARCHAR(16777216)) as SALESFORECASTBUNAME,
        cast(SALESFORECASTBUGROUP as VARCHAR(16777216)) as SALESFORECASTBUGROUP,
        cast(FSFLAG as VARCHAR(16777216)) as FSFLAG,
        cast(FSBUGROUP as VARCHAR(16777216)) as FSBUGROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data