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
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.TAS_TASK, 
        source_data.TAS_WRENCH_TYPE, 
        source_data.TASK_NAME         
        FROM source_data
        )
,type_data as 
(
    select
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(TASK_NAME as VARCHAR(16777216)) as TASK_NAME,
        cast(TAS_WRENCH_TYPE as VARCHAR(16777216)) as TAS_WRENCH_TYPE,
        cast(TAS_TASK as VARCHAR(16777216)) as TAS_TASK
    from transform_data
    )
select * from type_data