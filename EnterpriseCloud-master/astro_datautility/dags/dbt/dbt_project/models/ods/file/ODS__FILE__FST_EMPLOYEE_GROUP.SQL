{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='FST_EMPLOYEE_GROUP'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        FSTSupervisorID	,
        FSTSupervisorName,
        FSTEmployeeGroup,
        RegionalServiceManagerID,
        RSMFlag,
        RegionalServiceManager,
        FileDate	

    FROM {{ source("FILE", "FST_EMPLOYEE_GROUP") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "FST_EMPLOYEE_GROUP") }})

)

,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        FSTSupervisorID,
        FSTSupervisorName,
        FSTEmployeeGroup,
        RegionalServiceManagerID,
        RSMFlag	,
        RegionalServiceManager,
        FileDate,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
)

 ,type_data as
 (
     select
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(FSTSUPERVISORID AS VARCHAR(16777216)) AS FSTSUPERVISORID,
        CAST(FSTSUPERVISORNAME AS VARCHAR(16777216)) AS FSTSUPERVISORNAME,
        CAST(FSTEMPLOYEEGROUP AS VARCHAR(16777216)) AS FSTEMPLOYEEGROUP,
        CAST(REGIONALSERVICEMANAGERID AS VARCHAR(16777216)) AS REGIONALSERVICEMANAGERID,
        CAST(RSMFLAG AS VARCHAR(16777216)) AS RSMFLAG,
        CAST(REGIONALSERVICEMANAGER AS VARCHAR(16777216)) AS REGIONALSERVICEMANAGER,
        CAST(FILEDATE AS VARCHAR(16777216)) AS FILEDATE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
     from transform_data
     )
select * from transform_data