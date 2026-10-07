{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_FAB',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID",
        JSONFIELD:fields:"LinkTitle"::STRING AS "FAB_LINE_ID", 
        JSONFIELD:fields:"ACCOUNT_ID"::STRING AS "ACCOUNT_ID", 
        JSONFIELD:fields:"FAB_LINE_CODE"::STRING AS "FAB_LINE_CODE",
        JSONFIELD:fields:"ACCOUNT_CODE"::STRING AS "ACCOUNT_CODE",
        JSONFIELD:fields:"FAB_LINE"::STRING AS "FAB_LINE",
        JSONFIELD:fields:"FAB"::STRING AS "FAB",
        JSONFIELD:fields:"STATECODE"::STRING AS "STATECODE",
        JSONFIELD:fields:"STATUSCODE"::STRING AS "STATUSCODE"
    FROM {{ source('SHAREPOINT', 'COMMON_FAB') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_FAB') }})
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        "ID",
        "FAB_LINE_ID",
        "ACCOUNT_ID",
        "FAB_LINE_CODE",
        "ACCOUNT_CODE",
        "FAB_LINE",
        "FAB",
        "STATECODE",
        "STATUSCODE"
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
        "FAB_LINE_ID",
        "ACCOUNT_ID",
        "FAB_LINE_CODE",
        "ACCOUNT_CODE",
        "FAB_LINE",
        "FAB",
        "STATECODE",
        "STATUSCODE"
    FROM transform_data
)

SELECT * FROM type_data