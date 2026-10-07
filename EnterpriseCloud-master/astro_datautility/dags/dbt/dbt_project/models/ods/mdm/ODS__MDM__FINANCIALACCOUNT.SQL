/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\FinancialAccount.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\FinancialAccount.SQL 
-materialized incremental
-alias FinancialAccount 
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
    alias='FinancialAccount',
    unique_key = ['ACCOUNTID']
) }}


with source_data as 
(
    SELECT  
          _Filename as _Filename 
         ,_Filedate as _Filedate 
         ,JSonField:Code::STRING AS AccountId 
         ,JSonField:AccountParentNumber_Code::STRING AS ParentAccountId 
         ,JSonField:AccountType_Name::STRING AS AccountIdType 
         ,JSonField:AccountOperator_Name::STRING AS Operator 
         ,JSonField:AccountValueType_Name::STRING AS ValueType 
         ,JSonField:AccountDebitCreditIndicator_Name::STRING AS DebitCreditIndicator 
         ,JSonField:SensitiveIndicator_Name::STRING AS SensitiveIndicator 
         ,JSonField:FinancialAccountCategory_Name::STRING AS CategoryName 
         ,JSonField:FinancialAccountGroup_Name::STRING AS GroupName 
         ,JSonField:FinancialAccountStatementType_Name::STRING AS StatementType 
         ,JSonField:FinancialAccountDataType_Name::STRING AS AccountType 
         ,JSonField:BAANIndicator_Name::STRING AS ERPIndicator 
         ,JSonField:"Statutory Mapping for Income Statement"::STRING AS StatutoryReportingGroup 
         ,'INSERT' METADATA$ACTION 
        FROM {{ source("MDM", "FINANCIALACCOUNT") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "FINANCIALACCOUNT") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.ACCOUNTID AS ACCOUNTID, 
        source_data.PARENTACCOUNTID AS PARENTACCOUNTID, 
        source_data.ACCOUNTIDTYPE AS ACCOUNTIDTYPE, 
        source_data.OPERATOR AS OPERATOR, 
        source_data.VALUETYPE AS VALUETYPE, 
        source_data.DEBITCREDITINDICATOR AS DEBITCREDITINDICATOR, 
        source_data.SENSITIVEINDICATOR AS SENSITIVEINDICATOR, 
        source_data.CATEGORYNAME AS CATEGORYNAME, 
        source_data.GROUPNAME AS GROUPNAME, 
        source_data.STATEMENTTYPE AS STATEMENTTYPE, 
        source_data.ACCOUNTTYPE AS ACCOUNTTYPE, 
        source_data.ERPINDICATOR AS ERPINDICATOR, 
        source_data.STATUTORYREPORTINGGROUP AS STATUTORYREPORTINGGROUP, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(ACCOUNTID as VARCHAR(16777216)) as ACCOUNTID,
        cast(PARENTACCOUNTID as VARCHAR(16777216)) as PARENTACCOUNTID,
        cast(ACCOUNTIDTYPE as VARCHAR(16777216)) as ACCOUNTIDTYPE,
        cast(OPERATOR as VARCHAR(16777216)) as OPERATOR,
        cast(VALUETYPE as VARCHAR(16777216)) as VALUETYPE,
        cast(DEBITCREDITINDICATOR as VARCHAR(16777216)) as DEBITCREDITINDICATOR,
        cast(SENSITIVEINDICATOR as VARCHAR(16777216)) as SENSITIVEINDICATOR,
        cast(CATEGORYNAME as VARCHAR(16777216)) as CATEGORYNAME,
        cast(GROUPNAME as VARCHAR(16777216)) as GROUPNAME,
        cast(STATEMENTTYPE as VARCHAR(16777216)) as STATEMENTTYPE,
        cast(ACCOUNTTYPE as VARCHAR(16777216)) as ACCOUNTTYPE,
        cast(ERPINDICATOR as VARCHAR(16777216)) as ERPINDICATOR,
        cast(STATUTORYREPORTINGGROUP as VARCHAR(16777216)) as STATUTORYREPORTINGGROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data