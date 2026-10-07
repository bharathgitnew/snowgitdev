{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_COMMON_ORDER_TYPE',
    transient=false    
) }}

with source_data as (
    SELECT 
        JSONFIELD:fields:"Title"::STRING AS "ORDER_TYPE_ID", 
        JSONFIELD:fields:"ORDER_TYPE_CODE"::STRING AS "ORDER_TYPE_CODE",
        JSONFIELD:fields:"ORDER_TYPE"::STRING AS "ORDER_TYPE",
        JSONFIELD:fields:"ORDER_TYPE_GROUP"::STRING AS "ORDER_TYPE_GROUP",
        JSONFIELD:fields:"STATECODE"::STRING AS "STATE_CODE",
        JSONFIELD:fields:"STATUSCODE"::STRING AS "STATUS_CODE",
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE
    FROM {{ source('SHAREPOINT', 'COMMON_ORDER_TYPE') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'COMMON_ORDER_TYPE') }})
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        *
    FROM source_data
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _FILENAME,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        ORDER_TYPE_ID,
        ORDER_TYPE_CODE,
        ORDER_TYPE,
        ORDER_TYPE_GROUP,
        STATE_CODE,
        STATUS_CODE
    FROM transform_data
)
select * from type_data
