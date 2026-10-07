{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_SIRFIS_AREA'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        SITE,
        AREA
    FROM {{ source("FILE", "SIRFIS_AREA") }}
    {% if is_tel_incremental() %}
    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "SIRFIS_AREA") }})
    {% endif %}

)
,transform_data as
(
    SELECT        
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        SITE,
        AREA
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
        SITE,
        AREA
    from transform_data
    )
select * from type_data