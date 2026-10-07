/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\TASTypeOfWork_MDS_TASTypeOfWork.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\TASTypeOfWork.SQL 
-materialized incremental
-alias TASTypeOfWork 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:01 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TASTypeOfWork',
    unique_key = []
) }}


with source_data as 
(
    SELECT  
        jsonfield:"Type of Work"::VARCHAR AS Type_of_Work, 
        jsonfield:"TAS Type of Work"::VARCHAR AS TAS_Type_of_Work, 
        jsonfield:"TAS Type of Work Group"::VARCHAR AS TAS_Type_of_Work_Group, 
        jsonfield:"Source"::VARCHAR AS Source, 
        jsonfield:"Service Utilization Group"::VARCHAR AS Service_Utilization_Group, 
        jsonfield:"SO Expected in CRM"::VARCHAR AS SO_Expected_in_CRM, 
        jsonfield:"Revenue Source"::VARCHAR AS Revenue_Source, 
        jsonfield:"Expected SO Series"::VARCHAR AS Expected_SO_Series, 
        jsonfield:"Legacy Type of Work"::VARCHAR AS Legacy_Type_of_Work, 
        jsonfield:"Service Costing Product Type Code"::VARCHAR AS Service_Costing_Product_Type_Code, 
        jsonfield:"Billable Category Group"::VARCHAR AS Billable_Category_Group 
        FROM {{ source("MDM", "TASTYPEOFWORK") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "TASTYPEOFWORK") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.BILLABLE_CATEGORY_GROUP, 
        source_data.EXPECTED_SO_SERIES, 
        source_data.LEGACY_TYPE_OF_WORK, 
        source_data.REVENUE_SOURCE, 
        source_data.SO_EXPECTED_IN_CRM, 
        source_data.SERVICE_COSTING_PRODUCT_TYPE_CODE, 
        source_data.SERVICE_UTILIZATION_GROUP, 
        source_data.SOURCE, 
        source_data.TAS_TYPE_OF_WORK, 
        source_data.TAS_TYPE_OF_WORK_GROUP, 
        source_data.TYPE_OF_WORK 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(TYPE_OF_WORK as VARCHAR(16777216)) as TYPE_OF_WORK,
        cast(TAS_TYPE_OF_WORK as VARCHAR(16777216)) as TAS_TYPE_OF_WORK,
        cast(TAS_TYPE_OF_WORK_GROUP as VARCHAR(16777216)) as TAS_TYPE_OF_WORK_GROUP,
        cast(SOURCE as VARCHAR(16777216)) as SOURCE,
        cast(SERVICE_UTILIZATION_GROUP as VARCHAR(16777216)) as SERVICE_UTILIZATION_GROUP,
        cast(SO_EXPECTED_IN_CRM as VARCHAR(16777216)) as SO_EXPECTED_IN_CRM,
        cast(REVENUE_SOURCE as VARCHAR(16777216)) as REVENUE_SOURCE,
        cast(EXPECTED_SO_SERIES as VARCHAR(16777216)) as EXPECTED_SO_SERIES,
        cast(LEGACY_TYPE_OF_WORK as VARCHAR(16777216)) as LEGACY_TYPE_OF_WORK,
        cast(SERVICE_COSTING_PRODUCT_TYPE_CODE as VARCHAR(16777216)) as SERVICE_COSTING_PRODUCT_TYPE_CODE,
        cast(BILLABLE_CATEGORY_GROUP as VARCHAR(16777216)) as BILLABLE_CATEGORY_GROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data