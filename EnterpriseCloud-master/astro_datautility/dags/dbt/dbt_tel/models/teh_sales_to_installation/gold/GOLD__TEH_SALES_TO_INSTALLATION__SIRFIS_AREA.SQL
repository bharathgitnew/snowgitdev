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
    FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__SHAREPOINT_SIRFIS_AREA') }} 
),

transform_data as 
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        SITE,
        AREA
    FROM source_data
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _FILENAME,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        SITE,
        AREA

    FROM transform_data
)

SELECT * from type_data