/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\FST_Startup_Supervisors__FSTStartupSupervisors.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\FSTStartupSupervisors.SQL
-materialized incremental
-alias FSTStartupSupervisors
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='FSTStartupSupervisors',
    unique_key = ['BU',
    'Machine_History_Reason']
) }}

with source_data as
(
    SELECT
    FST_Startup_Supervisors.BU AS BU,
    FST_Startup_Supervisors.Machine_History_Reason AS Machine_History_Reason,
    FST_Startup_Supervisors.Startup_Supervisor AS Startup_Supervisor,
    FST_Startup_Supervisors.Startup_Supervisor_ID AS Startup_Supervisor_ID
    FROM  {{ ref('ODS__MDM__FST_STARTUP_SUPERVISORS') }} FST_Startup_Supervisors 
    )
,transform_data as
(
    SELECT
        BU,
        Machine_History_Reason,
        Startup_Supervisor,
        Startup_Supervisor_ID,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
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