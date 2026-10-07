{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_COUNTRY',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"LinkTitle"::STRING AS "COUNTRY_ID", 
        JSONFIELD:fields:"COUNTRY"::STRING AS "COUNTRY",
        JSONFIELD:fields:"COUNTRY_CODE"::STRING AS "COUNTRY_CODE"
    FROM {{ source('SHAREPOINT', 'COMMON_COUNTRY') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_COUNTRY') }})
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        "ID",
        "COUNTRY_ID",
        "COUNTRY",
        "COUNTRY_CODE"
    FROM source_data
),

type_data as (
    SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _FILENAME,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        "ID",
        "COUNTRY_ID",
        "COUNTRY",
        "COUNTRY_CODE"
    FROM transform_data
)

SELECT * FROM type_data