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
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        SITE,
        AREA
FROM source_data
)
,type_data as
(
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(SITE AS VARCHAR(16777216)) AS SITE,
        CAST(AREA AS VARCHAR(16777216)) AS AREA
from transform_data
    )
select * from type_data