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
        _Filename,
        _Filedate,
        companyid,
        deptcode,
        description,
        abbreviation,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH 
    FROM source_data
          )
,type_data as
(
    SELECT 
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _Filedate,
        _Filename AS _Filename,
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH as _ROW_HASH,
        companyid AS companyid,
        deptcode AS deptcode,
        description AS description,
        abbreviation AS abbreviation
    FROM transform_data
        )
select * from type_data