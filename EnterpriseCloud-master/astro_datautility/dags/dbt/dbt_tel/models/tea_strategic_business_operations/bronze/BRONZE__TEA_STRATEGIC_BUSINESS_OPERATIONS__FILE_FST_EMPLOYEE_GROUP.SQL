{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_FST_EMPLOYEE_GROUP'
) }}

with source_data as
(
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
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
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
)

 ,type_data as
 (
     select
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _FILENAME AS _FILENAME,
        _AUDIT_LOG_ID AS _AUDIT_LOG_ID,
        _ROW_HASH AS _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        FSTSUPERVISORID AS FSTSUPERVISORID,
        FSTSUPERVISORNAME AS FSTSUPERVISORNAME,
        FSTEMPLOYEEGROUP AS FSTEMPLOYEEGROUP,
        REGIONALSERVICEMANAGERID AS REGIONALSERVICEMANAGERID,
        RSMFLAG AS RSMFLAG,
        REGIONALSERVICEMANAGER AS REGIONALSERVICEMANAGER,
        FileDate AS FileDate
     from transform_data
     )
select * from type_data