{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='SIRFIS_PRICE_ESTIMATE_INLINE',
      transient=false
) }}

with source_data as 
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        PRICE_KEY,
        PRICE_ESTIMATE
    FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SHAREPOINT_SIRFIS_PRICE_ESTIMATE_INLINE') }} 
),

transform_data as 
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        PRICE_KEY,
        PRICE_ESTIMATE
FROM source_data
),

type_data as (
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(PRICE_KEY AS VARCHAR(16777216)) AS PRICE_KEY,
        CAST(PRICE_ESTIMATE AS NUMBER(38,0)) AS PRICE_ESTIMATE
FROM transform_data
)

SELECT * from type_data