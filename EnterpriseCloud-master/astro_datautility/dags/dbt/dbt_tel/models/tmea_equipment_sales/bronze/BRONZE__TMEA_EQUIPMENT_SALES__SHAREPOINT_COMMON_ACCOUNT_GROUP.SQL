{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_ACCOUNT_GROUP',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"Title"::STRING AS "ACCOUNT_ID", 
        JSONFIELD:fields:"ACCOUNT_NAME"::STRING AS "ACCOUNT_NAME",
        JSONFIELD:fields:"ACCOUNT_CODE"::STRING AS "ACCOUNT_CODE",
        JSONFIELD:fields:"SALES_ACCOUNT"::STRING AS "SALES_ACCOUNT",
        JSONFIELD:fields:"_SALES_ACCOUNT"::STRING AS "_SALES_ACCOUNT",
        JSONFIELD:fields:"STATUSCODE"::STRING AS "STATUS_CODE",
        JSONFIELD:fields:"STATECODE"::STRING AS "STATE_CODE"
    FROM {{ source('SHAREPOINT', 'COMMON_ACCOUNT_GROUP') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_ACCOUNT_GROUP') }})
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        "ID",
        "ACCOUNT_ID",
        "ACCOUNT_NAME",
        "ACCOUNT_CODE",
        "SALES_ACCOUNT",
        "_SALES_ACCOUNT",
        "STATUS_CODE",
        "STATE_CODE"
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
        "ACCOUNT_ID",
        "ACCOUNT_NAME",
        "ACCOUNT_CODE",
        "SALES_ACCOUNT",
        "_SALES_ACCOUNT",
        "STATUS_CODE",
        "STATE_CODE"
    FROM transform_data
)

SELECT * FROM type_data