/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Employee_Type.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Employee_Type.SQL 
-materialized incremental
-alias Employee_Type 
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
    alias='MDM_EMPLOYEE_TYPE',
    unique_key = ['EmployeeTypeId']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Code"::VARCHAR AS EmployeeTypeId, 
        jsonfield:"Employee Type Name"::VARCHAR AS Name, 
        jsonfield:"EmployeeTypeFST"::VARCHAR AS FSTName 
        FROM {{ source("MDM", "EMPLOYEE_TYPE") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "EMPLOYEE_TYPE") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.EMPLOYEETYPEID AS EmployeeTypeId, 
        source_data.NAME AS Name, 
        source_data.FSTNAME AS NameFST, 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(EMPLOYEETYPEID as VARCHAR(16777216)) as EMPLOYEETYPEID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(NAMEFST as VARCHAR(16777216)) as NAMEFST
    from transform_data
    )
select * from type_data