{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='SIRFIS_AREA',
      transient=false
) }}

with source_data as 
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        SITE,
        AREA
    FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__FILE_SIRFIS_AREA') }} 
),

transform_data as 
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
),

type_data as (
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(SITE AS VARCHAR(16777216)) AS SITE,
        CAST(AREA AS VARCHAR(16777216)) AS AREA
FROM transform_data
)

SELECT * from type_data