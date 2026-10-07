/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Kronos_Type_Of_Work__MDM_Type_Of_Work.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Kronos_Type_Of_Work_Group.SQL
-materialized incremental
-alias Kronos_Type_Of_Work_Group
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
    alias='Kronos_Type_Of_Work_Group',
    unique_key = ['Type_Of_Work']
) }}


with source_data as
(
    SELECT
        jsonfield:"Type of Work"::VARCHAR AS Type_Of_Work,
        jsonfield:"Type of Work Group"::VARCHAR AS Type_Of_Work_Group,
        jsonfield:"Billable Category"::VARCHAR AS Billable_Category,
        jsonfield:"General Category"::VARCHAR AS General_Category,
        jsonfield:"Labor Type"::VARCHAR AS Labor_Type,
        jsonfield:"Product Type Code"::VARCHAR AS Product_Type_Code,
        jsonfield:"Revenue Per Tool Category"::VARCHAR AS Revenue_Per_Tool_Category,
        jsonfield:"Product Sub-Category"::VARCHAR AS Product_Sub_Category,
        jsonfield:"KPI Type of Work"::VARCHAR AS KPI_Type_Of_Work,
        jsonfield:"Revenue Source"::VARCHAR AS Revenue_Source
        FROM {{ source("MDM", "KRONOS_TYPE_OF_WORK_GROUP") }}
)
,source_data_additional AS
(
    SELECT
        Type_Of_Work,
        Type_Of_Work_Group,
        Billable_Category,
        General_Category,
        Labor_Type,
        Product_Type_Code,
        Revenue_Per_Tool_Category,
        Product_Sub_Category,
        KPI_Type_Of_Work,
        Revenue_Source
        FROM {{ source("MDM", "KRONOS_TYPE_OF_WORK_GROUP_ADDITIONAL") }}
)
,source_data_combined AS
(
    SELECT
        Type_Of_Work,
        Type_Of_Work_Group,
        Billable_Category,
        General_Category,
        Labor_Type,
        Product_Type_Code,
        Revenue_Per_Tool_Category,
        Product_Sub_Category,
        KPI_Type_Of_Work,
        Revenue_Source
    FROM source_data
UNION
    SELECT
        Type_Of_Work,
        Type_Of_Work_Group,
        Billable_Category,
        General_Category,
        Labor_Type,
        Product_Type_Code,
        Revenue_Per_Tool_Category,
        Product_Sub_Category,
        KPI_Type_Of_Work,
        Revenue_Source
    FROM source_data_additional
)
,transform_data as
(
    SELECT
        TYPE_OF_WORK AS Type_Of_Work,
        TYPE_OF_WORK_GROUP AS Type_Of_Work_Group,
        BILLABLE_CATEGORY AS Billable_Category,
        GENERAL_CATEGORY AS General_Category,
        LABOR_TYPE AS Labor_Type,
        PRODUCT_TYPE_CODE AS Product_Type_Code,
        REVENUE_PER_TOOL_CATEGORY AS Revenue_Per_Tool_Category,
        PRODUCT_SUB_CATEGORY AS Product_Sub_Category,
        KPI_TYPE_OF_WORK AS KPI_Type_Of_Work,
        REVENUE_SOURCE AS Revenue_Source,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data_combined
        )
,type_data as
(
    select
        cast(TYPE_OF_WORK as VARCHAR(16777216)) as TYPE_OF_WORK,
        cast(TYPE_OF_WORK_GROUP as VARCHAR(16777216)) as TYPE_OF_WORK_GROUP,
        cast(BILLABLE_CATEGORY as VARCHAR(16777216)) as BILLABLE_CATEGORY,
        cast(GENERAL_CATEGORY as VARCHAR(16777216)) as GENERAL_CATEGORY,
        cast(LABOR_TYPE as VARCHAR(16777216)) as LABOR_TYPE,
        cast(PRODUCT_TYPE_CODE as VARCHAR(16777216)) as PRODUCT_TYPE_CODE,
        cast(REVENUE_PER_TOOL_CATEGORY as VARCHAR(16777216)) as REVENUE_PER_TOOL_CATEGORY,
        cast(PRODUCT_SUB_CATEGORY as VARCHAR(16777216)) as PRODUCT_SUB_CATEGORY,
        cast(KPI_TYPE_OF_WORK as VARCHAR(16777216)) as KPI_TYPE_OF_WORK,
        cast(REVENUE_SOURCE as VARCHAR(16777216)) as REVENUE_SOURCE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data