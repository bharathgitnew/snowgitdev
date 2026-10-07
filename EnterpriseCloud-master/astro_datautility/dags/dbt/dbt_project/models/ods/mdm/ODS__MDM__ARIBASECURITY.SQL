/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\AribaSecurity__MDM_AribaSecurity.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\AribaSecurity.SQL 
-materialized incremental
-alias AribaSecurity 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:24:58 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='AribaSecurity',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
            JSONFIELD:"Employee ID_Code"::STRING(16777216) AS Employee_ID_Code, 
            JSONFIELD:Department_Code::STRING(16777216) AS Department_Code, 
            JSONFIELD:Segment_Code::STRING(16777216) AS Segment_Code 
        FROM {{ source("MDM", "ARIBASECURITY") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "ARIBASECURITY") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.DEPARTMENT_CODE, 
        source_data.EMPLOYEE_ID_CODE, 
        source_data.SEGMENT_CODE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(EMPLOYEE_ID_CODE as VARCHAR(16777216)) as EMPLOYEE_ID_CODE,
        cast(DEPARTMENT_CODE as VARCHAR(16777216)) as DEPARTMENT_CODE,
        cast(SEGMENT_CODE as VARCHAR(16777216)) as SEGMENT_CODE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data