/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\TASTypeOfWork__TASTypeOfWork.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\TASTypeOfWork.SQL
-materialized incremental
-alias TASTypeOfWork
-incremental_strategy insert_overwrite
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:05 PM
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
    TASTypeOfWork.Billable_Category_Group,
    TASTypeOfWork.Expected_SO_Series,
    TASTypeOfWork.Legacy_Type_of_Work,
    TASTypeOfWork.Revenue_Source,
    TASTypeOfWork.SO_Expected_in_CRM,
    TASTypeOfWork.Service_Costing_Product_Type_Code,
    TASTypeOfWork.Service_Utilization_Group,
    TASTypeOfWork.Source,
    TASTypeOfWork.TAS_Type_of_Work,
    TASTypeOfWork.TAS_Type_of_Work_Group,
    TASTypeOfWork.Type_of_Work
    FROM {{ ref('ODS__MDM__TASTYPEOFWORK') }} TASTypeOfWork
    )
,transform_data as
(
    SELECT
        Billable_Category_Group,
        Expected_SO_Series,
        Legacy_Type_of_Work,
        Revenue_Source,
        SO_Expected_in_CRM,
        Service_Costing_Product_Type_Code,
        Service_Utilization_Group,
        Source,
        TAS_Type_of_Work,
        TAS_Type_of_Work_Group,
        Type_of_Work
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