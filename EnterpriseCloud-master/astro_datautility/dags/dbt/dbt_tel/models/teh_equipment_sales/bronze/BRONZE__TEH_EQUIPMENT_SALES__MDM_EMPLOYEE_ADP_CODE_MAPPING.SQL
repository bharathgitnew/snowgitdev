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
        _Filename,
        _Filedate,
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
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        source_data.ADP_CODE,
        source_data.COMPANY_CODE,
        source_data.COMPANY_EMP_TYPE,
        source_data.COMPANY_NAME,
        source_data.COMPANY_TYPE,
        source_data.EMP_CATEGORY,
        source_data.EXPAT_FLAG,
        source_data.FIELDGLASS_NAME
FROM source_data
        )
,type_data as 
(
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(ADP_CODE as VARCHAR(16777216)) as ADP_CODE,
        cast(COMPANY_NAME as VARCHAR(16777216)) as COMPANY_NAME,
        cast(COMPANY_CODE as VARCHAR(16777216)) as COMPANY_CODE,
        cast(COMPANY_TYPE as VARCHAR(16777216)) as COMPANY_TYPE,
        cast(COMPANY_EMP_TYPE as VARCHAR(16777216)) as COMPANY_EMP_TYPE,
        cast(FIELDGLASS_NAME as VARCHAR(16777216)) as FIELDGLASS_NAME,
        cast(EXPAT_FLAG as VARCHAR(16777216)) as EXPAT_FLAG,
        cast(EMP_CATEGORY as VARCHAR(16777216)) as EMP_CATEGORY
from transform_data
    )
select * from type_data