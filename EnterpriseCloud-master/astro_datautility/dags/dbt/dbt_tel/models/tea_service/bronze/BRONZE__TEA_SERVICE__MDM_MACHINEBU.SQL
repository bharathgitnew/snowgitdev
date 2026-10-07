/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\MachineBU__MDM_MachineBU.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\MachineBU.SQL 
-materialized incremental
-alias MachineBU 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='MDM_MACHINEBU',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Code"::VARCHAR AS SourceMachineBU,  
        jsonfield:"Name"::VARCHAR AS StandardizedMachineBU 
        FROM {{ source("MDM", "MACHINEBU") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "MACHINEBU") }} ) 
        )
,transform_data as
(
    SELECT 
        source_data.SOURCEMACHINEBU, 
        source_data.STANDARDIZEDMACHINEBU 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(SOURCEMACHINEBU as VARCHAR(16777216)) as SOURCEMACHINEBU,
        cast(STANDARDIZEDMACHINEBU as VARCHAR(16777216)) as STANDARDIZEDMACHINEBU,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data