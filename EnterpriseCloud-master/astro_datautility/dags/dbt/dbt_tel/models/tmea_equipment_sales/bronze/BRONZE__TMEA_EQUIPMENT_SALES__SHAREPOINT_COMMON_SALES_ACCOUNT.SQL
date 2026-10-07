{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_SALES_ACCOUNT',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"Title"::STRING AS "ACCOUNT_ID", 
        JSONFIELD:fields:"ACCOUNT_CODE"::STRING AS "ACCOUNT_CODE",
        JSONFIELD:fields:"ACCOUNT_NAME"::STRING AS "ACCOUNT_NAME",
        JSONFIELD:fields:"_5_DIGIT_OLD_CUSTOMER_CODE"::STRING AS "_5_DIGIT_OLD_CUSTOMER_CODE",
        JSONFIELD:fields:"SALES_ACCOUNT"::STRING AS "SALES_ACCOUNT",
        JSONFIELD:fields:"_SALES_ACCOUNT"::STRING AS "_SALES_ACCOUNT",
        JSONFIELD:fields:"STATUSCODE"::STRING AS "STATUS_CODE",
        JSONFIELD:fields:"STATECODE"::STRING AS "STATE_CODE",
        JSONFIELD:fields:"SALES_REGION"::STRING AS "SALES_REGION",
        JSONFIELD:fields:"SALES_ACCOUNT_REGION"::STRING AS "SALES_ACCOUNT_REGION",
        JSONFIELD:fields:"_SALES_ACCOUNT_REGION"::STRING AS "_SALES_ACCOUNT_REGION",
        JSONFIELD:fields:"CITY"::STRING AS "CITY",
        JSONFIELD:fields:"STATE_OR_PROVINCE"::STRING AS "STATE_OR_PROVINCE",
        JSONFIELD:fields:"COUNTRY"::STRING AS "COUNTRY",
        JSONFIELD:fields:"ADDRESS"::STRING AS "ADDRESS",
        JSONFIELD:fields:"ZIP_CODE"::STRING AS "ZIP_CODE"
    FROM {{ source('SHAREPOINT', 'COMMON_SALES_ACCOUNT') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_SALES_ACCOUNT') }})
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
        "ACCOUNT_CODE",
        "ACCOUNT_NAME",
        "_5_DIGIT_OLD_CUSTOMER_CODE",
        "SALES_ACCOUNT",
        "_SALES_ACCOUNT",
        "STATUS_CODE",
        "STATE_CODE",
        "SALES_REGION",
        "SALES_ACCOUNT_REGION",
        "_SALES_ACCOUNT_REGION",
        "CITY",
        "STATE_OR_PROVINCE",
        "COUNTRY",
        "ADDRESS",
        "ZIP_CODE"
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
        "ACCOUNT_CODE",
        "ACCOUNT_NAME",
        "_5_DIGIT_OLD_CUSTOMER_CODE",
        "SALES_ACCOUNT",
        "_SALES_ACCOUNT",
        "STATUS_CODE",
        "STATE_CODE",
        "SALES_REGION",
        "SALES_ACCOUNT_REGION",
        "_SALES_ACCOUNT_REGION",
        "CITY",
        "STATE_OR_PROVINCE",
        "COUNTRY",
        "ADDRESS",
        "ZIP_CODE"
    FROM transform_data
)

SELECT * FROM type_data