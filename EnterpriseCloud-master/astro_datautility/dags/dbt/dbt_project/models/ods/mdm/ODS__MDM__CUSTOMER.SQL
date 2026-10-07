/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Customer.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Customer.SQL
-materialized incremental
-alias Customer
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
    alias='Customer',
    unique_key = ['CustomerID']
) }}


with source_data as
(
    SELECT
          _Filename AS _Filename
         ,_Filedate AS _Filedate
         ,JSonField:Code::STRING AS CustomerId
         ,JSonField:CustomerShortName::STRING AS CustomerShortName
         ,JSonField:CustomerGroup_Name::STRING AS CustomerGroup
         ,JSonField:CustomerGroupTEL_Name::STRING AS CustomerGroupTEL
         ,JSonField:CustomerFinanceGroupName::STRING AS GroupFinancialName
         ,JSonField:SalesCustomerGroup::STRING AS SalesCustomerGroup
        FROM {{ source("MDM", "CUSTOMER") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "CUSTOMER") }})
        )
,transform_data as
(
    SELECT
        source_data.CUSTOMERID AS CustomerID,
        source_data.CUSTOMERSHORTNAME AS CustomerShortName,
        source_data.CUSTOMERGROUP AS CustomerGroup,
        source_data.CUSTOMERGROUPTEL AS CustomerGroupTel,
        source_data.GROUPFINANCIALNAME AS GroupFinancialName,
        source_data.SALESCUSTOMERGROUP AS SalesCustomerGroup,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(CUSTOMERID as VARCHAR(16777216)) as CUSTOMERID,
        cast(CUSTOMERSHORTNAME as VARCHAR(16777216)) as CUSTOMERSHORTNAME,
        cast(CUSTOMERGROUP as VARCHAR(16777216)) as CUSTOMERGROUP,
        cast(CUSTOMERGROUPTEL as VARCHAR(16777216)) as CUSTOMERGROUPTEL,
        cast(GROUPFINANCIALNAME as VARCHAR(16777216)) as GROUPFINANCIALNAME,
        cast(SALESCUSTOMERGROUP as VARCHAR(16777216)) as SALESCUSTOMERGROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data