{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_BUSINESS_UNIT',
    transient=false    
) }}

with source_data as (
    SELECT 
        JSONFIELD:fields:"Title"::STRING AS "BU_ID", 
        JSONFIELD:fields:"COST_CENTER_GROUP_CODE"::STRING AS "COST_CENTER_GROUP_CODE",
        JSONFIELD:fields:"_BU"::STRING AS "_BU",
        JSONFIELD:fields:"_BU_GROUP"::STRING AS "_BU_GROUP",
        JSONFIELD:fields:"_BU_TYPE"::STRING AS "_BU_TYPE",
        JSONFIELD:fields:"_SUB_BU"::STRING AS "_SUB_BU",
        JSONFIELD:fields:"BU"::STRING AS "BU",
        JSONFIELD:fields:"BU_GROUP"::STRING AS "BU_GROUP",
        JSONFIELD:fields:"BU_TYPE"::STRING AS "BU_TYPE",
        JSONFIELD:fields:"SUB_BU"::STRING AS "SUB_BU",
        JSONFIELD:fields:"STATECODE"::STRING AS "STATE_CODE",
        JSONFIELD:fields:"STATUSCODE"::STRING AS "STATUS_CODE",
        JSONFIELD:fields:"PRODUCT_CODE"::STRING AS "PRODUCT_CODE",
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE
    FROM {{ source('SHAREPOINT', 'COMMON_BUSINESS_UNIT') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_BUSINESS_UNIT') }})
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
       _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        BU_ID,
        COST_CENTER_GROUP_CODE,
        _BU,
        _BU_GROUP,
        _BU_TYPE,
        _SUB_BU,
        BU,
        BU_GROUP,
        BU_TYPE,
        SUB_BU,
        STATE_CODE,
        STATUS_CODE,
        PRODUCT_CODE
    FROM source_data
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _FILENAME,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        BU_ID,
        COST_CENTER_GROUP_CODE,
        _BU,
        _BU_GROUP,
        _BU_TYPE,
        _SUB_BU,
        BU,
        BU_GROUP,
        BU_TYPE,
        SUB_BU,
        STATE_CODE,
        STATUS_CODE,
        PRODUCT_CODE
    FROM transform_data
)
SELECT * FROM type_data