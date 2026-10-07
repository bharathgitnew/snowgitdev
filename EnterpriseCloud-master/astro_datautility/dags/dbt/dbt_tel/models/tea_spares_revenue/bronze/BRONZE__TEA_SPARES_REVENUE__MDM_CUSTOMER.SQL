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
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_CUSTOMER',
    unique_key = ['CustomerID']
) }}


with source_data as
(
    SELECT
         _Filedate AS _FILEDATE,
         _Filename AS _FILENAME
         ,JSonField:Code::STRING AS CustomerId
         ,JSonField:CustomerShortName::STRING AS CustomerShortName
         ,JSonField:CustomerGroup_Name::STRING AS CustomerGroup
         ,JSonField:CustomerGroupTEL_Name::STRING AS CustomerGroupTEL
         ,JSonField:CustomerFinanceGroupName::STRING AS GroupFinancialName
         ,JSonField:SalesCustomerGroup::STRING AS SalesCustomerGroup
        FROM {{ source("MDM", "CUSTOMER") }}
        WHERE _Filedate = (SELECT COALESCE(MAX(_FileDate),'1900-01-01') FROM {{ source("MDM", "CUSTOMER") }})
        )
,transform_data as
(
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        source_data.CUSTOMERID AS CustomerID,
        source_data.CUSTOMERSHORTNAME AS CustomerShortName,
        source_data.CUSTOMERGROUP AS CustomerGroup,
        source_data.CUSTOMERGROUPTEL AS CustomerGroupTel,
        source_data.GROUPFINANCIALNAME AS GroupFinancialName,
        source_data.SALESCUSTOMERGROUP AS SalesCustomerGroup
        FROM source_data
        )
,type_data as
(
    select
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        CUSTOMERID,
        CUSTOMERSHORTNAME,
        CUSTOMERGROUP,
        CUSTOMERGROUPTEL,
        GROUPFINANCIALNAME,
        SALESCUSTOMERGROUP
    from transform_data
    )
select * from type_data