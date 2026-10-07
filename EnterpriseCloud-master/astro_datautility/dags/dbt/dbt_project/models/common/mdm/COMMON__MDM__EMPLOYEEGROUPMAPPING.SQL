/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Employee_Group_Mapping__EmployeeGroupMapping.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\EmployeeGroupMapping.SQL
-materialized incremental
-alias EmployeeGroupMapping
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='EmployeeGroupMapping',
    unique_key = []
) }}

with source_data as
( SELECT
    Employee_Group_Mapping.FST_Emp_Group AS FST_Emp_Group,
    Employee_Group_Mapping.Regional_Service_Manager AS Regional_Service_Manager,
    Employee_Group_Mapping.Service_Manager_ID AS Service_Manager_ID,
    Employee_Group_Mapping.Regional_Sales_Manager AS Regional_Sales_Manager,
    Employee_Group_Mapping.Sales_Manager_ID AS Sales_Manager_ID
FROM {{ ref('ODS__MDM__EMPLOYEE_GROUP_MAPPING') }} Employee_Group_Mapping
    )
,transform_data as
(
    SELECT
        FST_Emp_Group,
        Regional_Service_Manager,
        Service_Manager_ID,
        Regional_Sales_Manager,
        Sales_Manager_ID,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        -- ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(FST_EMP_GROUP as VARCHAR(16777216)) as FST_EMP_GROUP,
        cast(REGIONAL_SERVICE_MANAGER as VARCHAR(16777216)) as REGIONAL_SERVICE_MANAGER,
        cast(SERVICE_MANAGER_ID as VARCHAR(16777216)) as SERVICE_MANAGER_ID,
        cast(REGIONAL_SALES_MANAGER as VARCHAR(16777216)) as REGIONAL_SALES_MANAGER,
        cast(SALES_MANAGER_ID as VARCHAR(16777216)) as SALES_MANAGER_ID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data