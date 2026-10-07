{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_MODEL',
    transient=false    
) }}

with source_data as (
    SELECT 
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"LinkTitle"::STRING AS "MODEL_ID", 
        JSONFIELD:fields:"PRODUCT_CODE"::STRING AS "PRODUCT_CODE",
        JSONFIELD:fields:"MODEL_TYPE_CODE"::STRING AS "MODEL_TYPE_CODE",
        JSONFIELD:fields:"MODEL"::STRING AS "MODEL"
    FROM {{ source('SHAREPOINT', 'COMMON_MODEL') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_MODEL') }})
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        "ID",
        "MODEL_ID",
        "PRODUCT_CODE",
        "MODEL_TYPE_CODE",
        "MODEL"
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
        "MODEL_ID",
        "PRODUCT_CODE",
        "MODEL_TYPE_CODE",
        "MODEL"
    FROM transform_data
)

SELECT * FROM type_data