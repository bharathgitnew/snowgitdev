{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_FST_EMPLOYEE_GROUP'
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
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        FSTSupervisorID,
        FSTSupervisorName,
        FSTEmployeeGroup,
        RegionalServiceManagerID,
        RSMFlag	,
        RegionalServiceManager,
        FileDate
        FROM source_data
)

 ,type_data as
 (
     select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        FSTSUPERVISORID,
        FSTSUPERVISORNAME,
        FSTEMPLOYEEGROUP,
        REGIONALSERVICEMANAGERID,
        RSMFLAG,
        REGIONALSERVICEMANAGER,
        FILEDATE
     from transform_data
     )
select * from transform_data