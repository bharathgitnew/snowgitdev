/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\FinancialProductType.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\FinancialProductType.SQL
-materialized incremental
-alias FinancialProductType
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='FinancialProductType',
    unique_key = ['ProductTypeCode']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS ProductTypeCode
         ,JSonField:FinancialProductTypeFinancialStatementType::STRING AS FinancialStatementType
         ,JSonField:FinancialProductTypeActiveFlag::STRING AS ActiveFlag
         ,JSonField:FinancialProductTypeRevenueSource::STRING AS RevenueSource
         ,JSonField:FinancialProductTypeOwner::STRING AS OWNER
         ,JSonField:FinancialProductTypeCategory::STRING AS Category
         ,JsonField:FinancialProductTypeGroup::STRING AS GroupName
         ,JSonField:FinancialProductTypeTELGrouping::STRING AS TELGrouping
         ,JSonField:FinancialProductTypeTEAOperationsGrouping::STRING AS GROUPTEAOperationsGrouping
         ,JSonField:FinancialProductTypeGlobalKPI::STRING AS GlobalKPI
         ,JSonField:FinancialProductTypeBAANIncomeStatement::STRING AS BaanIncomeStatement
        FROM {{ source("MDM", "FINANCIALPRODUCTTYPE") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "FINANCIALPRODUCTTYPE") }})
        )
,transform_data as
(
    SELECT
        source_data.PRODUCTTYPECODE AS ProductTypeCode,
        source_data.FINANCIALSTATEMENTTYPE AS FinancialStatementType,
        source_data.ACTIVEFLAG AS ActiveFlag,
        source_data.REVENUESOURCE AS RevenueSource,
        source_data.OWNER AS Owner,
        source_data.CATEGORY AS Category,
        source_data.GROUPNAME AS GroupName,
        source_data.TELGROUPING AS TELGrouping,
        source_data.GROUPTEAOPERATIONSGROUPING AS GROUPTEAOperationsGrouping,
        source_data.GLOBALKPI AS GlobalKPI,
        source_data.BAANINCOMESTATEMENT AS BaanIncomeStatement,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(PRODUCTTYPECODE as VARCHAR(16777216)) as PRODUCTTYPECODE,
        cast(FINANCIALSTATEMENTTYPE as VARCHAR(16777216)) as FINANCIALSTATEMENTTYPE,
        cast(ACTIVEFLAG as VARCHAR(16777216)) as ACTIVEFLAG,
        cast(REVENUESOURCE as VARCHAR(16777216)) as REVENUESOURCE,
        cast(OWNER as VARCHAR(16777216)) as OWNER,
        cast(CATEGORY as VARCHAR(16777216)) as CATEGORY,
        cast(GROUPNAME as VARCHAR(16777216)) as GROUPNAME,
        cast(TELGROUPING as VARCHAR(16777216)) as TELGROUPING,
        cast(GROUPTEAOPERATIONSGROUPING as VARCHAR(16777216)) as GROUPTEAOPERATIONSGROUPING,
        cast(GLOBALKPI as VARCHAR(16777216)) as GLOBALKPI,
        cast(BAANINCOMESTATEMENT as VARCHAR(16777216)) as BAANINCOMESTATEMENT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data