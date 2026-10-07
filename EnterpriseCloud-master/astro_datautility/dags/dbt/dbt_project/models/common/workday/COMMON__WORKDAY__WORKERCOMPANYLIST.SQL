{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='WORKERCOMPANYLIST',
    unique_key = []
) }}

with source_data as 
( 
    SELECT
    EmployeeId,
    HomeCompanyID,
    HomeDepartmentID,
    HostCompanyID,
    HostDepartmentID
    FROM {{ ref('ODS__WORKDAY__WORKERCOMPANYLIST') }} 
),
transform_data as 
(
SELECT
    '{{ invocation_id }}' AS AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    EmployeeId as EMPLOYEEID,
    HomeCompanyID::NUMBER as HOMECOMPANYID,
    HomeDepartmentID::NUMBER as HOMEDEPARTMENTID,
    HostCompanyID::NUMBER as HOSTCOMPANYID,
    HostDepartmentID::NUMBER as HOSTDEPARTMENTID,
    0 AS ERROR_FLAG,
    CAST('' AS VARCHAR(200)) AS ERROR_REASON,
    CAST('' AS VARCHAR(100)) AS ERROR_CODE,
    CAST(LOCALTIMESTAMP AS TIMESTAMP) AS RECORD_INSERT_TIMESTAMP,
    CAST('INSERT' AS VARCHAR(100)) AS OPERATION_TYPE,
    ROW_NUMBER() OVER (ORDER BY 3) AS SRC_ROW_NUMBER
FROM source_data 
),
type_data as
(
    SELECT
        AUDIT_LOG_ID,
        _ROW_HASH,
        EMPLOYEEID,
        HOMECOMPANYID,
        HOMEDEPARTMENTID,
        HOSTCOMPANYID,
        HOSTDEPARTMENTID
    FROM transform_data 
)
select * from type_data