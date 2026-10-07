/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Employees_Job_Title_Mapping__MDM_EmployeesJobTitle.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Employees_Job_Title_Mapping.SQL 
-materialized incremental
-alias Employees_Job_Title_Mapping 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_EMPLOYEES_JOB_TITLE_MAPPING',
    unique_key = ['TEA_Common_Job_Title']
) }}


with source_data as 
(
    SELECT 
        _Filename,
        _Filedate,
        jsonfield:"TEA Common Job Title"::VARCHAR AS TEA_Common_Job_Title, 
        jsonfield:"Job Title Group"::VARCHAR AS Job_Title_Group, 
        jsonfield:"Manager Flag"::VARCHAR AS Manager_Flag, 
        jsonfield:"Job Category"::VARCHAR AS Job_Category, 
        jsonfield:"FE Group"::VARCHAR AS FE_Group 
        FROM {{ source("MDM", "EMPLOYEES_JOB_TITLE_MAPPING") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "EMPLOYEES_JOB_TITLE_MAPPING") }}) 
        )
,transform_data as
(
    SELECT 
        _Filedate as _FILEDATE,
        _Filename as _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.TEA_COMMON_JOB_TITLE AS TEA_Common_Job_Title, 
        source_data.JOB_TITLE_GROUP AS Job_Title_Group, 
        source_data.MANAGER_FLAG AS Manager_Flag, 
        source_data.JOB_CATEGORY AS Job_Category, 
        source_data.FE_GROUP AS FE_Group
        FROM source_data
        )
,type_data as 
(
    select
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(TEA_COMMON_JOB_TITLE as VARCHAR(16777216)) as TEA_COMMON_JOB_TITLE,
        cast(JOB_TITLE_GROUP as VARCHAR(16777216)) as JOB_TITLE_GROUP,
        cast(MANAGER_FLAG as VARCHAR(16777216)) as MANAGER_FLAG,
        cast(JOB_CATEGORY as VARCHAR(16777216)) as JOB_CATEGORY,
        cast(FE_GROUP as VARCHAR(16777216)) as FE_GROUP
    from transform_data
    )
select * from type_data