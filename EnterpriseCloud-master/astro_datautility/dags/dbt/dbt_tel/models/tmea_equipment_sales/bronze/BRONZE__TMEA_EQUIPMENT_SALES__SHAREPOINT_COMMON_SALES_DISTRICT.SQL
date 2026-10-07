{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_SALES_DISTRICT',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"LinkTitle"::STRING AS "SALES_DISTRICT_ID", 
        JSONFIELD:fields:"ORGANIZATION_ID"::STRING AS "ORGANIZATION_ID",
        JSONFIELD:fields:"SALES_DISTRICT"::STRING AS "SALES_DISTRICT",
        JSONFIELD:fields:"SALES_DISTRICT_CODE"::STRING AS "SALES_DISTRICT_CODE"
    FROM {{ source('SHAREPOINT', 'COMMON_SALES_DISTRICT') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_SALES_DISTRICT') }})
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        "ID",
        "SALES_DISTRICT_ID",
        "ORGANIZATION_ID",
        "SALES_DISTRICT",
        "SALES_DISTRICT_CODE"
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
        "SALES_DISTRICT_ID",
        "ORGANIZATION_ID",
        "SALES_DISTRICT",
        "SALES_DISTRICT_CODE"
    FROM transform_data
)

SELECT * FROM type_data