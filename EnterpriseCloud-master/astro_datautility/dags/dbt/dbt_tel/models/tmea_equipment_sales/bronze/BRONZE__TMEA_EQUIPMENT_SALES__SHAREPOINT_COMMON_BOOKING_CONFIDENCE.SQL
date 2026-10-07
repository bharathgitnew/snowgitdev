{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_BOOKING_CONFIDENCE',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"LinkTitle"::STRING AS "OPTION_CODE", 
        JSONFIELD:fields:"CONFIDENCE_ORDER"::STRING AS "CONFIDENCE_ORDER",
        JSONFIELD:fields:"BOOKING_CONFIDENCE"::STRING AS "BOOKING_CONFIDENCE",
        JSONFIELD:fields:"CONFIDENCE_SHORT"::STRING AS "CONFIDENCE_SHORT"
    FROM {{ source('SHAREPOINT', 'COMMON_BOOKING_CONFIDENCE') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_BOOKING_CONFIDENCE') }})
),

transform_data as (
    SELECT
       _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        ID,
        OPTION_CODE,
        CONFIDENCE_ORDER,
        BOOKING_CONFIDENCE,
        CONFIDENCE_SHORT
    FROM source_data
),

type_data as (
    SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _FILENAME,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        ID,
        OPTION_CODE,
        CONFIDENCE_ORDER,
        BOOKING_CONFIDENCE,
        CONFIDENCE_SHORT
    FROM transform_data
)
SELECT * FROM type_data