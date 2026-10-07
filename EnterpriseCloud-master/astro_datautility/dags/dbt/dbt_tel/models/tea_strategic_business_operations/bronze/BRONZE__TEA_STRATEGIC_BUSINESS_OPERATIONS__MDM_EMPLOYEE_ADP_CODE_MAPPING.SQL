/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Employee_ADP_Code__MDM_Employee_ADP_Code.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Employee_ADP_Code_Mapping.SQL 
-materialized incremental
-alias Employee_ADP_Code_Mapping 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='MDM_EMPLOYEE_ADP_CODE_MAPPING',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILEDATE,
        _FILENAME,
        jsonfield:"ADP Code"::VARCHAR AS ADP_Code, 
        jsonfield:"Company Name"::VARCHAR AS Company_Name, 
        jsonfield:"Company Code"::VARCHAR AS Company_Code, 
        jsonfield:"Company Type"::VARCHAR AS Company_Type, 
        jsonfield:"Company Emp Type"::VARCHAR AS Company_Emp_Type, 
        jsonfield:"FieldGlass Name"::VARCHAR AS FieldGlass_Name, 
        jsonfield:"Expat Flag"::VARCHAR AS Expat_Flag, 
        jsonfield:"Emp Category"::VARCHAR AS Emp_Category 
        FROM {{ source("MDM", "EMPLOYEE_ADP_CODE_MAPPING") }} 
        )
,transform_data as
(
    SELECT 
        source_data._FILEDATE,
        source_data._FILENAME,
        source_data.ADP_CODE, 
        source_data.COMPANY_CODE, 
        source_data.COMPANY_EMP_TYPE, 
        source_data.COMPANY_NAME, 
        source_data.COMPANY_TYPE, 
        source_data.EMP_CATEGORY, 
        source_data.EXPAT_FLAG, 
        source_data.FIELDGLASS_NAME 
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH 
        FROM source_data
        )
,type_data as 
(
    select
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH,
        ADP_CODE as ADP_CODE,
        COMPANY_NAME as COMPANY_NAME,
        COMPANY_CODE as COMPANY_CODE,
        COMPANY_TYPE as COMPANY_TYPE,
        COMPANY_EMP_TYPE as COMPANY_EMP_TYPE,
        FIELDGLASS_NAME as FIELDGLASS_NAME,
        EXPAT_FLAG as EXPAT_FLAG,
        EMP_CATEGORY as EMP_CATEGORY,
    from transform_data
    )
select * from type_data