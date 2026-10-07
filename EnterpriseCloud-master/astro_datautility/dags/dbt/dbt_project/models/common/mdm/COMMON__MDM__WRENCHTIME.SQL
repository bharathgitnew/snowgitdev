/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Wrench_Time_Mapping__WrenchTime.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\WrenchTime.SQL
-materialized incremental
-alias WrenchTime
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
    alias='WrenchTime',
    unique_key = []
) }}

with source_data as
(
    SELECT
    FST_Kronos_Wrench_Time_Mapping.Org_Map_Type,
    FST_Kronos_Wrench_Time_Mapping.Paycode_Name,
    FST_Kronos_Wrench_Time_Mapping.Task,
    FST_Kronos_Wrench_Time_Mapping.Task_Wrench_Type
    FROM {{ ref('ODS__MDM__FST_KRONOS_WRENCH_TIME_MAPPING') }} FST_Kronos_Wrench_Time_Mapping 
    )
,transform_data as
(
    SELECT
        Org_Map_Type,
        Paycode_Name,
        Task,
        Task_Wrench_Type
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(PAYCODE_NAME as VARCHAR(16777216)) as PAYCODE_NAME,
        cast(ORG_MAP_TYPE as VARCHAR(16777216)) as ORG_MAP_TYPE,
        cast(TASK as VARCHAR(16777216)) as TASK,
        cast(TASK_WRENCH_TYPE as VARCHAR(16777216)) as TASK_WRENCH_TYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data