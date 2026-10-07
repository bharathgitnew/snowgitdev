/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\TASTask_MDS_TASTask.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\TASTask.SQL 
-materialized incremental
-alias TASTask 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:01 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='MDM_TASTASK',
    unique_key = []
) }}


with source_data as 
(
    SELECT  
         _FILEDATE,
         _FILENAME,
         jsonfield:"Task Name"::VARCHAR AS Task_Name, 
         jsonfield:"TAS Wrench Type"::VARCHAR AS TAS_Wrench_Type, 
         jsonfield:"TAS Task"::VARCHAR AS TAS_Task 
        FROM {{ source("MDM", "TASTASK") }} 
        WHERE _FileDate = ( SELECT MAX(_FileDate) FROM {{ source("MDM", "TASTASK") }}) 
        )
,transform_data as
(
    SELECT 
        source_data._FILEDATE,
        source_data._FILENAME,
        source_data.TAS_TASK, 
        source_data.TAS_WRENCH_TYPE, 
        source_data.TASK_NAME 
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH,
        TASK_NAME as TASK_NAME,
        TAS_WRENCH_TYPE as TAS_WRENCH_TYPE,
        TAS_TASK as TAS_TASK
    from transform_data
    )
select * from type_data