/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\OracleEPBCSAccount.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\OracleEPBCSAccount.SQL
-materialized incremental
-alias OracleEPBCSAccount
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
    alias='OracleEPBCSAccount',
    unique_key = ['OracleAccountId']
) }}


with source_data as
(
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS OracleAccountId
         ,JSonField:Name::STRING AS OracleAccountName
         ,JSonField:"Oracle EPBCS Account Name in DW"::STRING AS OracleEPBCSAccountNumberInDW
         ,JSonField:"Oracle EPBCS Account Name in DW"::STRING AS OracleEPBCSAccountNameInDW
         ,JSonField:"Financial Account Group"::STRING AS FinancialAccountGroup
         ,JSonField:"Baan Account for Budget"::STRING AS BaanAccountForBudget
        FROM {{ source("MDM", "ORACLEEPBCSACCOUNT") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "ORACLEEPBCSACCOUNT") }})
        )
,transform_data as
(
    SELECT
        source_data.ORACLEACCOUNTID AS OracleAccountId,
        source_data.ORACLEACCOUNTNAME AS OracleAccountName,
        source_data.ORACLEEPBCSACCOUNTNUMBERINDW AS OracleEPBCSAccountNumberInDW,
        source_data.ORACLEEPBCSACCOUNTNAMEINDW AS OracleEPBCSAccountNameInDW,
        source_data.FINANCIALACCOUNTGROUP AS FinancialAccountGroup,
        source_data.BAANACCOUNTFORBUDGET AS BaanAccountForBudget,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(ORACLEACCOUNTID as VARCHAR(16777216)) as ORACLEACCOUNTID,
        cast(ORACLEACCOUNTNAME as VARCHAR(16777216)) as ORACLEACCOUNTNAME,
        cast(ORACLEEPBCSACCOUNTNUMBERINDW as VARCHAR(16777216)) as ORACLEEPBCSACCOUNTNUMBERINDW,
        cast(ORACLEEPBCSACCOUNTNAMEINDW as VARCHAR(16777216)) as ORACLEEPBCSACCOUNTNAMEINDW,
        cast(FINANCIALACCOUNTGROUP as VARCHAR(16777216)) as FINANCIALACCOUNTGROUP,
        cast(BAANACCOUNTFORBUDGET as VARCHAR(16777216)) as BAANACCOUNTFORBUDGET,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data