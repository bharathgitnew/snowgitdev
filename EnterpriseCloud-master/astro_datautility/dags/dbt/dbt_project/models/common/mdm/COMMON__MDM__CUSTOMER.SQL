/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Customer.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\Customer.SQL
-materialized incremental
-alias Customer
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='Customer',
    unique_key = ['CustomerId']
) }}

with source_data as
( SELECT
        Customer.CustomerID AS CustomerId,
        Customer.CustomerShortName AS CustomerShortName,
        Customer.CustomerGroup AS CustomerGroup,
        Customer.CustomerGroupTel AS CustomerGroupTel,
        Customer.GroupFinancialName AS GroupFinancialName,
        Customer.SalesCustomerGroup AS SalesCustomerGroup
        FROM {{ ref('ODS__MDM__CUSTOMER') }} Customer

    )
,transform_data as
(
    SELECT
        CustomerId,
        CustomerShortName,
        CustomerGroup,
        CustomerGroupTel,
        GroupFinancialName,
        SalesCustomerGroup,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
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