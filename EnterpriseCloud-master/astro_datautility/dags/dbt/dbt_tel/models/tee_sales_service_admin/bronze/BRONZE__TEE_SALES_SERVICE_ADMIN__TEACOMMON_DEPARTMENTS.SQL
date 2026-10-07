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
        SHA2('hash_me') as _ROW_HASH,
        _Filedate,
        _Filename,
        companyid,
        deptcode,
        description,
        abbreviation
    FROM source_data
          )
,type_data as
(
    SELECT 
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _Filedate,
        CAST(_Filename AS VARCHAR(16777216)) AS _Filename,
        CAST(companyid AS VARCHAR(16777216)) AS companyid,
        CAST(deptcode AS VARCHAR(16777216)) AS deptcode,
        CAST(description AS VARCHAR(16777216)) AS description,
        CAST(abbreviation AS VARCHAR(16777216)) AS abbreviation
    FROM transform_data
        )
select * from type_data