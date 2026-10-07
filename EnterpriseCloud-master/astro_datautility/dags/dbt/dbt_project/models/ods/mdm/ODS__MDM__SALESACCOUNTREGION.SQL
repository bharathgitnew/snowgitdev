/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\SalesAccountRegion__MDM_SalesAccount_Region.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\SalesAccountRegion.SQL 
-materialized incremental
-alias SalesAccountRegion 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SalesAccountRegion',
    unique_key = []
) }}


with source_data as 
(
    SELECT  
         jsonfield:"Code"::VARCHAR AS StateOrProvince, 
         jsonfield:"Name"::VARCHAR AS Region 
        FROM {{ source("MDM", "SALESACCOUNTREGION") }} 
        WHERE _FileDate = ( SELECT MAX(_FileDate) FROM {{ source("MDM", "SALESACCOUNTREGION") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.REGION, 
        source_data.STATEORPROVINCE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(STATEORPROVINCE as VARCHAR(16777216)) as STATEORPROVINCE,
        cast(REGION as VARCHAR(16777216)) as REGION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data