/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Machine_Status__MachineStatusMapping.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\MachineStatusMapping.SQL
-materialized incremental
-alias MachineStatusMapping
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='MachineStatusMapping',
    unique_key = []
) }}

with source_data as
(   SELECT
    Machine_Status_Mapping.Status_Key AS Status_Key,
    Machine_Status_Mapping.Machine_Status AS Machine_Status,
    Machine_Status_Mapping.Expired_Flag AS Expired_Flag,
    Machine_Status_Mapping.Eval_Flag AS Eval_Flag,
    Machine_Status_Mapping.Install_Base_Status AS Install_Base_Status,
    Machine_Status_Mapping.Status_Sort AS Status_Sort
    FROM {{ ref('ODS__MDM__MACHINE_STATUS_MAPPING') }} Machine_Status_Mapping
    )
,transform_data as
(
    SELECT
        Status_Key,
        Machine_Status,
        Expired_Flag,
        Eval_Flag,
        Install_Base_Status,
        Status_Sort
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        -- ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(STATUS_KEY as NUMBER(38,0)) as STATUS_KEY,
        cast(MACHINE_STATUS as VARCHAR(16777216)) as MACHINE_STATUS,
        cast(EXPIRED_FLAG as VARCHAR(16777216)) as EXPIRED_FLAG,
        cast(EVAL_FLAG as VARCHAR(16777216)) as EVAL_FLAG,
        cast(INSTALL_BASE_STATUS as VARCHAR(16777216)) as INSTALL_BASE_STATUS,
        cast(STATUS_SORT as NUMBER(38,0)) as STATUS_SORT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data