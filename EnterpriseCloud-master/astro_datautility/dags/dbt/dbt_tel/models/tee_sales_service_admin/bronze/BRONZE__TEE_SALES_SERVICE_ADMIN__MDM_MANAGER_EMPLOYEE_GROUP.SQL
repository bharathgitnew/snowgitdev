/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Manager_Employee_Group__MDM_Manager_Employee_Group.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Manager_Employee_Group.SQL 
-materialized incremental
-alias Manager_Employee_Group 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='MDM_MANAGER_EMPLOYEE_GROUP',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
          jsonfield:"Employee_Code"::VARCHAR AS SupervisorEmployeeId,  
          jsonfield:"Department_Code"::VARCHAR AS DepartmentId,  
          jsonfield:"Segment_Code"::VARCHAR AS SegmentId,  
          jsonfield:"Employee Group_Code"::VARCHAR AS GroupName 
        FROM {{ source("MDM", "MANAGER_EMPLOYEE_GROUP") }} 
        WHERE _Filedate = (SELECT MAX(_Filedate) FROM {{ source("MDM", "MANAGER_EMPLOYEE_GROUP") }}) 
        )
,transform_data as
(
    SELECT 
         
        source_data.SupervisorEmployeeId AS SUPERVISORID,
        source_data.GroupName AS GROUPNAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh. 
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(SUPERVISORID as VARCHAR(16777216)) as SUPERVISORID,
        cast(GROUPNAME as VARCHAR(16777216)) as GROUPNAME
    from transform_data
    )
select * from type_data