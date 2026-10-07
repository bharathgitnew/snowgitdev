/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\FST_Startup_Supervisors__MDM_FSTStartupSupervisors.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\FST_Startup_Supervisors.SQL 
-materialized incremental
-alias FST_Startup_Supervisors 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='FST_Startup_Supervisors',
    unique_key = ['BU',
    'Machine_History_Reason']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"BU"::VARCHAR AS BU, 
        jsonfield:"Machine History Reason"::VARCHAR AS Machine_History_Reason, 
        jsonfield:"Startup Supervisor"::VARCHAR AS Startup_Supervisor, 
        jsonfield:"Startup Supervisor ID"::NUMBER AS Startup_Supervisor_ID 
        FROM {{ source("MDM", "FST_STARTUP_SUPERVISORS") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "FST_STARTUP_SUPERVISORS") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.BU AS BU, 
        source_data.MACHINE_HISTORY_REASON AS Machine_History_Reason, 
        source_data.STARTUP_SUPERVISOR AS Startup_Supervisor, 
        source_data.STARTUP_SUPERVISOR_ID AS Startup_Supervisor_ID, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(BU as VARCHAR(16777216)) as BU,
        cast(MACHINE_HISTORY_REASON as VARCHAR(16777216)) as MACHINE_HISTORY_REASON,
        cast(STARTUP_SUPERVISOR as VARCHAR(16777216)) as STARTUP_SUPERVISOR,
        cast(STARTUP_SUPERVISOR_ID as NUMBER(38,0)) as STARTUP_SUPERVISOR_ID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data