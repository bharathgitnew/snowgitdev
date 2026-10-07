/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Employee_Group_Mapping__MDM_Employee_Group_Mapping.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Employee_Group_Mapping.SQL 
-materialized incremental
-alias Employee_Group_Mapping 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Employee_Group_Mapping',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        jsonfield:"FST Emp Group"::VARCHAR AS FST_Emp_Group, 
        jsonfield:"Regional Service Manager"::VARCHAR AS Regional_Service_Manager, 
        jsonfield:"Service Manager ID"::VARCHAR AS Service_Manager_ID, 
        jsonfield:"Regional Sales Manager"::VARCHAR AS Regional_Sales_Manager, 
        jsonfield:"Sales Manager ID"::VARCHAR AS Sales_Manager_ID 
        FROM {{ source("MDM", "EMPLOYEE_GROUP_MAPPING") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "EMPLOYEE_GROUP_MAPPING") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.FST_EMP_GROUP AS FST_Emp_Group, 
        source_data.REGIONAL_SERVICE_MANAGER AS Regional_Service_Manager, 
        source_data.SERVICE_MANAGER_ID AS Service_Manager_ID, 
        source_data.REGIONAL_SALES_MANAGER AS Regional_Sales_Manager, 
        source_data.SALES_MANAGER_ID AS Sales_Manager_ID, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID 
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