/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Workday\WorkerCompanyList.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\workday\WORKERCOMPANYLIST.SQL
-materialized incremental
-alias WORKERCOMPANYLIST
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema WORKDAY
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/13/2022 11:34:15 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='WORKDAY_WORKERCOMPANYLIST',
    unique_key = ['EmployeeId']
) }}


with source_data as
(
    SELECT
      EmployeeId,
      HomeCompanyID,
      HomeDepartmentID,
      HostCompanyID,
      HostDepartmentID
    FROM {{ source("WORKDAY", "WORKERCOMPANYLIST") }}
    {%- if is_tel_incremental() %}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("WORKDAY", "WORKERCOMPANYLIST") }} )
    {%- else %}
        QUALIFY ( ROW_NUMBER() OVER ( PARTITION BY EmployeeId ORDER BY _Filedate DESC ) ) = 1
    {%- endif %}
    )

,transform_data as 
(
    SELECT
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        EmployeeId as EmployeeId,
        HomeCompanyID::NUMBER as HomeCompanyID,
        HomeDepartmentID::NUMBER as HomeDepartmentID,
        HostCompanyID::NUMBER as HostCompanyID,
        HostDepartmentID::NUMBER as HostDepartmentID
    FROM source_data 
),
type_data as 
(
    SELECT
        AUDIT_LOG_ID,
        _ROW_HASH,
        EmployeeId,
        HomeCompanyID,
        HomeDepartmentID,
        HostCompanyID,
        HostDepartmentID
    FROM transform_data 
)
select * from type_data

