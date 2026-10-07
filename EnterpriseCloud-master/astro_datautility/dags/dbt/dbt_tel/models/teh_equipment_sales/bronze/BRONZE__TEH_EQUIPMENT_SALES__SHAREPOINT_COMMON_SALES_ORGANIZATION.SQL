{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_SALES_ORGANIZATION',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"Title"::STRING AS "SALES_ORGANIZATION_ID", 
        JSONFIELD:fields:"SALES_ORGANIZATION"::STRING AS "SALES_ORGANIZATION",
        JSONFIELD:fields:"SALES_ORGANIZATION_CODE"::STRING AS "SALES_ORGANIZATION_CODE",
        JSONFIELD:fields:"BUSINESS_ENTITY"::STRING AS "BUSINESS_ENTITY",
        JSONFIELD:fields:"STATECODE"::STRING AS "STATECODE",
        JSONFIELD:fields:"STATUSCODE"::STRING AS "STATUSCODE"
    FROM {{ source('SHAREPOINT', 'COMMON_SALES_ORGANIZATION') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_SALES_ORGANIZATION') }})
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        "ID",
        "SALES_ORGANIZATION_ID",
        "SALES_ORGANIZATION",
        "SALES_ORGANIZATION_CODE",
        "BUSINESS_ENTITY",
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
        "SALES_ORGANIZATION_ID",
        "SALES_ORGANIZATION",
        "SALES_ORGANIZATION_CODE",
        "BUSINESS_ENTITY",
        "STATECODE",
        "STATUSCODE"
    FROM transform_data
)

SELECT * FROM type_data