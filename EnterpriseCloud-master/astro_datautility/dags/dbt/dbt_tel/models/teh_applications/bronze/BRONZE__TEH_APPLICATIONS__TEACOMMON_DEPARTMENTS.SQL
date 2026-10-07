{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEACOMMON_DEPARTMENTS'
) }}


with source_data as
(
    SELECT      
        _Filename as _Filename,
        _Filedate as _Filedate,
        JSonField:companyid::STRING AS companyid,
        JSonField:deptcode::STRING AS deptcode,
        JSonField:description::STRING AS description,
        JSonField:abbreviation::STRING AS abbreviation
    FROM {{ source("TEACOMMON", "DEPARTMENTS") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TEACOMMON", "DEPARTMENTS") }})
            )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _Filename,
        _Filedate,
        companyid,
        deptcode,
        description,
        abbreviation
    FROM source_data
          )
,type_data as
(
    SELECT 
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _Filename,
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _Filedate,
        companyid,
        deptcode,
        description,
        abbreviation
    FROM transform_data
        )
select * from type_data