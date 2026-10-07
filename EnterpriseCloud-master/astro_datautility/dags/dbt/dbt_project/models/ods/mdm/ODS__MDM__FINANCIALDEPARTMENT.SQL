/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\FinancialDepartment.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\FinancialDepartment.SQL
-materialized incremental
-alias FinancialDepartment
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='FinancialDepartment',
    unique_key = ['DEPARTMENTCODE']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS DepartmentId
         ,JSonField:FinancialDepartmentBillbackType::STRING AS DepartmentType
         ,JSonField:FinancialDepartmentFunctionalGroup::STRING AS BillBackType
         ,JSonField:FinancialDepartmentType::STRING AS FunctionalGroup
        FROM {{ source("MDM", "FINANCIALDEPARTMENT") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "FINANCIALDEPARTMENT") }})
        )
,transform_data as
(
    SELECT
        source_data.DEPARTMENTID AS DEPARTMENTCODE,
        source_data.DEPARTMENTTYPE AS DEPARTMENTTYPE,
        source_data.BILLBACKTYPE AS BILLBACKTYPE,
        source_data.FUNCTIONALGROUP AS FUNCTIONALGROUP,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(DEPARTMENTCODE as VARCHAR(16777216)) as DEPARTMENTCODE,
        cast(DEPARTMENTTYPE as VARCHAR(16777216)) as DEPARTMENTTYPE,
        cast(BILLBACKTYPE as VARCHAR(16777216)) as BILLBACKTYPE,
        cast(FUNCTIONALGROUP as VARCHAR(16777216)) as FUNCTIONALGROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data