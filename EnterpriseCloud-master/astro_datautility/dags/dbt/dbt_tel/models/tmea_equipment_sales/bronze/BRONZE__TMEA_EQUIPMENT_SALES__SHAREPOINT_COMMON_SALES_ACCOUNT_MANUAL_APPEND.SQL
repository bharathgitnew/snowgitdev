{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_SALES_ACCOUNT_MANUAL_APPEND',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"END_USER"::STRING AS "END_USER", 
        JSONFIELD:fields:"LinkTitle"::STRING AS "END_USER_ADDRESS",
        JSONFIELD:fields:"SALES_ACCOUNT"::STRING AS "SALES_ACCOUNT",
        JSONFIELD:fields:"SALES_REGION"::STRING AS "SALES_REGION",
        JSONFIELD:fields:"ZIP_CODE"::STRING AS "ZIP_CODE",
        JSONFIELD:fields:"COUNTRY"::STRING AS "COUNTRY",
        JSONFIELD:fields:"NEW_NAME"::STRING AS "NEW_NAME"
    FROM {{ source('SHAREPOINT', 'COMMON_SALES_ACCOUNT_MANUAL_APPEND') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_SALES_ACCOUNT_MANUAL_APPEND') }})
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        "ID",
        "END_USER",
        "END_USER_ADDRESS",
        "SALES_ACCOUNT",
        "SALES_REGION",
        "ZIP_CODE",
        "COUNTRY",
        "NEW_NAME"
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
        "END_USER",
        "END_USER_ADDRESS",
        "SALES_ACCOUNT",
        "SALES_REGION",
        "ZIP_CODE",
        "COUNTRY",
        "NEW_NAME"
    FROM transform_data
)

SELECT * FROM type_data