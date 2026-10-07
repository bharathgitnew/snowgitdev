/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Customer_Group_Mapping__MDM_Customer_Group.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Customer_Group_Mapping.SQL 
-materialized incremental
-alias Customer_Group_Mapping 
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
    alias='MDM_CUSTOMER_GROUP_MAPPING',
    unique_key = ['CustomerCode']
) }}


with source_data as 
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        jsonfield:"Customer Code"::VARCHAR AS CustomerCode, 
        jsonfield:"FST Customer Group"::VARCHAR AS FSTCustomerGroup, 
        jsonfield:"Baan Customer Name"::VARCHAR AS BaanCustomerName, 
        jsonfield:"Sales Customer Group"::VARCHAR AS SalesCustomerGroup, 
        jsonfield:"Customer Short Name"::VARCHAR AS CustomerShortName 
        FROM {{ source("MDM", "CUSTOMER_GROUP_MAPPING") }} 
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source("MDM", "CUSTOMER_GROUP_MAPPING") }}) 
        )
,transform_data as
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.CUSTOMERCODE AS CustomerCode, 
        source_data.FSTCUSTOMERGROUP AS FSTCustomerGroup, 
        source_data.BAANCUSTOMERNAME AS BaanCustomerName, 
        source_data.SALESCUSTOMERGROUP AS SalesCustomerGroup, 
        source_data.CUSTOMERSHORTNAME AS CustomerShortName
        FROM source_data
        )
,type_data as 
(
    select
        CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(CUSTOMERCODE as VARCHAR(16777216)) as CUSTOMERCODE,
        cast(FSTCUSTOMERGROUP as VARCHAR(16777216)) as FSTCUSTOMERGROUP,
        cast(BAANCUSTOMERNAME as VARCHAR(16777216)) as BAANCUSTOMERNAME,
        cast(SALESCUSTOMERGROUP as VARCHAR(16777216)) as SALESCUSTOMERGROUP,
        cast(CUSTOMERSHORTNAME as VARCHAR(16777216)) as CUSTOMERSHORTNAME
      
    from transform_data
    )
select * from type_data