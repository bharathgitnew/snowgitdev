/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Wrench_Time_Mapping__MDM_Wrench_Time_Mapping.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\FST_Kronos_Wrench_Time_Mapping.SQL 
-materialized incremental
-alias FST_Kronos_Wrench_Time_Mapping 
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
    alias='MDM_FST_KRONOS_WRENCH_TIME_MAPPING',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _Filename,
        _Filedate,
        jsonfield:"Paycode Name"::VARCHAR AS Paycode_Name, 
        jsonfield:"Org Map Type"::VARCHAR AS Org_Map_Type, 
        jsonfield:"Task"::VARCHAR AS Task, 
        jsonfield:"Task Wrench Type"::VARCHAR AS Task_Wrench_Type 
        FROM {{ source("MDM", "FST_KRONOS_WRENCH_TIME_MAPPING") }} 
        )
,transform_data as
(
    SELECT 
        _Filedate as _FILEDATE,
        _Filename as _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.ORG_MAP_TYPE, 
        source_data.PAYCODE_NAME, 
        source_data.TASK, 
        REPLACE(source_data.TASK_WRENCH_TYPE,'Wrench Time','Wrench') AS TASK_WRENCH_TYPE
        FROM source_data
        )
,type_data as 
(
    select
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(PAYCODE_NAME as VARCHAR(16777216)) as PAYCODE_NAME,
        cast(ORG_MAP_TYPE as VARCHAR(16777216)) as ORG_MAP_TYPE,
        cast(TASK as VARCHAR(16777216)) as TASK,
        cast(TASK_WRENCH_TYPE as VARCHAR(16777216)) as TASK_WRENCH_TYPE
    from transform_data
    )
select * from type_data