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
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH 
    FROM source_data
          )
,type_data as
(
    SELECT 
        CAST(_Filename AS VARCHAR(16777216)) AS _Filename,
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _Filedate,
        CAST(companyid AS VARCHAR(16777216)) AS companyid,
        CAST(deptcode AS VARCHAR(16777216)) AS deptcode,
        CAST(description AS VARCHAR(16777216)) AS description,
        CAST(abbreviation AS VARCHAR(16777216)) AS abbreviation,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    FROM transform_data
        )
select * from type_data

