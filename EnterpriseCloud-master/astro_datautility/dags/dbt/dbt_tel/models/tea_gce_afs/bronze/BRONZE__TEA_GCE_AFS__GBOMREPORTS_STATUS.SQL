    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='GBOMREPORTS_STATUS',
            unique_key=[],
            transient=false
) }}

    with source_data as (
        SELECT
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE,
            CP,
            PLATFORM,
            TECHNOLOGY,
            MODULE,
            CEID,
            PROCESS,
            APPROVAL_STATUS,
            TEL_CHARGE,
            OPEN_DATE,
            CLOSE_DATE,
            CUSTOMER_APPROVER,
            COMMENT,
            OUTPUT_ORDER,
            "UPDATED_AT " as UPDATED_AT
        FROM {{ source('ADS', 'GBOMREPORTS_STATUS') }}
        WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('ADS', 'GBOMREPORTS_STATUS') }})
    ),
    transform_data as (
        SELECT
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE,
            '{{ invocation_id }}' AS _AUDIT_LOG_ID,
            SHA2('hash_me') as _ROW_HASH,
            CP,
            PLATFORM,
            TECHNOLOGY,
            MODULE,
            CEID,
            PROCESS,
            APPROVAL_STATUS,
            TEL_CHARGE,
            OPEN_DATE,
            CLOSE_DATE,
            CUSTOMER_APPROVER,
            COMMENT,
            OUTPUT_ORDER,
            UPDATED_AT
        FROM source_data
    ),
    type_data as (
        SELECT
            CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
            CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
            CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
            CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
            CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
            CP,
            PLATFORM,
            TECHNOLOGY,
            MODULE,
            CEID,
            PROCESS,
            APPROVAL_STATUS,
            TEL_CHARGE,
            OPEN_DATE,
            CLOSE_DATE,
            CUSTOMER_APPROVER,
            COMMENT,
            OUTPUT_ORDER,
            UPDATED_AT
        FROM transform_data
    )
    SELECT * FROM type_data