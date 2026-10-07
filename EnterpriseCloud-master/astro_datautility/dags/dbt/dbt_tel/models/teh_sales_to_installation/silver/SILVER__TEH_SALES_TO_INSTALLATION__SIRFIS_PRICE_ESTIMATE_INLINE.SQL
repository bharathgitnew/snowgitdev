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
    FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__SHAREPOINT_SIRFIS_PRICE_ESTIMATE_INLINE') }} 
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
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        PRICE_KEY,
        CAST(PRICE_ESTIMATE AS NUMBER(38,0)) AS PRICE_ESTIMATE
    FROM transform_data
)

SELECT * from type_data