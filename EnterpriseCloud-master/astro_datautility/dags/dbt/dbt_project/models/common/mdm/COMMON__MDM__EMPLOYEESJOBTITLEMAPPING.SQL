/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Employee_Job_Title__EmployeeJobTitleMapping.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\EmployeeJobTitleMapping.SQL
-materialized incremental
-alias EmployeeJobTitleMapping
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
    alias='EmployeesJobTitleMapping',
    unique_key = ['TEA_Common_Job_Title']
) }}

with source_data as
(
    SELECT
    Employees_Job_Title_Mapping.TEA_Common_Job_Title AS TEA_Common_Job_Title,
    Employees_Job_Title_Mapping.Job_Title_Group AS Job_Title_Group,
    Employees_Job_Title_Mapping.Manager_Flag AS Manager_Flag,
    Employees_Job_Title_Mapping.Job_Category AS Job_Category,
    Employees_Job_Title_Mapping.FE_Group AS FE_Group
    FROM {{ ref('ODS__MDM__EMPLOYEES_JOB_TITLE_MAPPING') }} Employees_Job_Title_Mapping
    )
,transform_data as
(
    SELECT
        TEA_Common_Job_Title,
        Job_Title_Group,
        Manager_Flag,
        Job_Category,
        FE_Group,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(TEA_COMMON_JOB_TITLE as VARCHAR(16777216)) as TEA_COMMON_JOB_TITLE,
        cast(JOB_TITLE_GROUP as VARCHAR(16777216)) as JOB_TITLE_GROUP,
        cast(MANAGER_FLAG as VARCHAR(16777216)) as MANAGER_FLAG,
        cast(JOB_CATEGORY as VARCHAR(16777216)) as JOB_CATEGORY,
        cast(FE_GROUP as VARCHAR(16777216)) as FE_GROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data