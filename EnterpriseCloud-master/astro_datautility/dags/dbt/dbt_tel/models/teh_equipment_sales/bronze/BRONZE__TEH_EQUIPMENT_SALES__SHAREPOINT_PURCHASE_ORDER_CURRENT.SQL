{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_PURCHASE_ORDER_CURRENT',
    transient=false    
) }}

with source_data as (
    SELECT 
        JSONFIELD:fields:"id"::STRING AS "ID", 
        JSONFIELD:fields:"Title"::STRING AS "FILE_NAME_OPPORTUNITY_ID", 
        JSONFIELD:fields:"FILE_TYPE"::STRING AS "FILE_TYPE",
        JSONFIELD:fields:"SALES_ACCOUNT"::STRING AS "SALES_ACCOUNT",
        JSONFIELD:fields:"OPPORTUNITY_ID"::STRING AS "OPPORTUNITY_ID",
        JSONFIELD:fields:"FILE_NAME"::STRING AS "FILE_NAME",
        JSONFIELD:fields:"CREATED_DATE"::STRING AS "CREATED_DATE",
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE
    FROM {{ source('SHAREPOINT', 'SHAREPOINT_PURCHASE_ORDER_CURRENT') }}
    WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('SHAREPOINT', 'SHAREPOINT_PURCHASE_ORDER_CURRENT') }})
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
        ID,
        FILE_NAME_OPPORTUNITY_ID,
        FILE_TYPE,
        SALES_ACCOUNT,
        OPPORTUNITY_ID,
        FILE_NAME,
        CAST(CREATED_DATE AS TIMESTAMP_NTZ(9)) AS CREATED_DATE
    FROM transform_data
)

SELECT * FROM type_data