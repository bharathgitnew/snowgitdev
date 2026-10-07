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
        RegionalServiceManager

    FROM {{ source("FILE", "FST_EMPLOYEE_GROUP") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "FST_EMPLOYEE_GROUP") }})

)

,transform_data as
(
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        FSTSupervisorID,
        FSTSupervisorName,
        FSTEmployeeGroup,
        RegionalServiceManagerID,
        RSMFlag	,
        RegionalServiceManager
FROM source_data
)

 ,type_data as
 (
     select
        CAST(_Filename AS VARCHAR(16777216)) AS _Filename,
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(FSTSUPERVISORID AS VARCHAR(16777216)) AS FSTSUPERVISORID,
        CAST(FSTSUPERVISORNAME AS VARCHAR(16777216)) AS FSTSUPERVISORNAME,
        CAST(FSTEMPLOYEEGROUP AS VARCHAR(16777216)) AS FSTEMPLOYEEGROUP,
        CAST(REGIONALSERVICEMANAGERID AS VARCHAR(16777216)) AS REGIONALSERVICEMANAGERID,
        CAST(RSMFLAG AS VARCHAR(16777216)) AS RSMFLAG,
        CAST(REGIONALSERVICEMANAGER AS VARCHAR(16777216)) AS REGIONALSERVICEMANAGER
from transform_data
     )
select * from transform_data