/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Customer_Group__CustomerGroup.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\CustomerGroup.SQL
-materialized tel_incremental
-alias CustomerGroup
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='CUSTOMERGROUP',
    unique_key = ['CustomerCode']
) }}

with source_data as
( SELECT
    Customer_Group_Mapping.CustomerCode AS CustomerCode,
    Customer_Group_Mapping.FSTCustomerGroup AS FSTCustomerGroup,
    Customer_Group_Mapping.BaanCustomerName AS BaanCustomerName,
    Customer_Group_Mapping.SalesCustomerGroup AS SalesCustomerGroup,
    Customer_Group_Mapping.CustomerShortName AS CustomerShortName
FROM {{ ref('BRONZE__TEH_REVENUE_COGS__MDM_CUSTOMER_GROUP_MAPPING') }} Customer_Group_Mapping
    )
,transform_data as
(
    SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
    CustomerCode,
    FSTCustomerGroup,
    BaanCustomerName,
    SalesCustomerGroup,
    CustomerShortName
    FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(CUSTOMERCODE as VARCHAR(16777216)) as CUSTOMERCODE,
        cast(FSTCUSTOMERGROUP as VARCHAR(16777216)) as FSTCUSTOMERGROUP,
        cast(BAANCUSTOMERNAME as VARCHAR(16777216)) as BAANCUSTOMERNAME,
        cast(SALESCUSTOMERGROUP as VARCHAR(16777216)) as SALESCUSTOMERGROUP,
        cast(CUSTOMERSHORTNAME as VARCHAR(16777216)) as CUSTOMERSHORTNAME
    from transform_data
    )
select * from type_data