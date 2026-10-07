{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ORACLE_FUNCTIONAL_DEPT_HIERARCHY'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        FUNCTIONAL_DEPARTMENT,
        DEPARTMENT,
        DEPARTMENT_ALIAS
    FROM {{ source("FILE", "ORACLE_FUNCTIONAL_DEPT_HIERARCHY") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "ORACLE_FUNCTIONAL_DEPT_HIERARCHY") }})

)

,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        FUNCTIONAL_DEPARTMENT,
        DEPARTMENT,
        DEPARTMENT_ALIAS,
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
        CAST(FUNCTIONAL_DEPARTMENT AS VARCHAR(16777216)) AS FUNCTIONAL_DEPARTMENT,
        CAST(DEPARTMENT AS VARCHAR(16777216)) AS DEPARTMENT,
        CAST(DEPARTMENT_ALIAS AS VARCHAR(16777216)) AS DEPARTMENT_ALIAS,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    from transform_data
    )
select * from type_data