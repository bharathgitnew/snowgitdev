/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Machine_Model_Group__MDM_Machine_Model_Group.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Machine_Model_Group.SQL 
-materialized incremental
-alias Machine_Model_Group 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Machine_Model_Group',
    unique_key = []
) }}


with source_data as 
(
    SELECT  
        jsonfield:"BU"::VARCHAR AS BU, 
        jsonfield:"SWLH Model"::VARCHAR AS SWLH_Model, 
        jsonfield:"Model Category"::VARCHAR AS Model_Category, 
        jsonfield:"Model Sub-Category"::VARCHAR AS Model_Sub_Category 
        FROM {{ source("MDM", "MACHINE_MODEL_GROUP") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "MACHINE_MODEL_GROUP") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.BU AS BU, 
        source_data.SWLH_MODEL AS SWLH_Model, 
        source_data.MODEL_CATEGORY AS Model_Category, 
        source_data.MODEL_SUB_CATEGORY AS Model_Sub_Category, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID  
        FROM source_data
        )
,type_data as 
(
    select
        cast(BU as VARCHAR(16777216)) as BU,
        cast(SWLH_MODEL as VARCHAR(16777216)) as SWLH_MODEL,
        cast(MODEL_CATEGORY as VARCHAR(16777216)) as MODEL_CATEGORY,
        cast(MODEL_SUB_CATEGORY as VARCHAR(16777216)) as MODEL_SUB_CATEGORY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data