/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\TASTask__TASTask.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\TASTask.SQL
-materialized incremental
-alias TASTask
-incremental_strategy insert_overwrite
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:05 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TASTask',
    unique_key = []
) }}

with source_data as
( 
    SELECT
    TASTask.TAS_Task,
    TASTask.TAS_Wrench_Type,
    TASTask.Task_Name
    FROM {{ ref('ODS__MDM__TASTASK') }} TASTask
    )
,transform_data as
(
    SELECT
        TAS_Task,
        TAS_Wrench_Type,
        Task_Name
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(TASK_NAME as VARCHAR(16777216)) as TASK_NAME,
        cast(TAS_WRENCH_TYPE as VARCHAR(16777216)) as TAS_WRENCH_TYPE,
        cast(TAS_TASK as VARCHAR(16777216)) as TAS_TASK,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data