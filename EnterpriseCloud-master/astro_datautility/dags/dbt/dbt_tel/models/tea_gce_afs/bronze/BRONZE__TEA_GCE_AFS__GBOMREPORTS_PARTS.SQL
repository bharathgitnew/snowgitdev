    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='GBOMREPORTS_PARTS',
            unique_key=[],
            transient=false
) }}

    with source_data as (
        SELECT
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE,
            CP,
            CURRENT_PART_NUMBER,
            CURRENT_PN_DESCRIPTION,
            NEW_PART_NUMBER,
            NEW_PN_DESCRIPTION,
            PART_NUMBER_CHANGE_DIVISION,
            "UNNAMED: 6" as STATUS
        FROM {{ source('ADS', 'GBOMREPORTS_PARTS') }}
        WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('ADS', 'GBOMREPORTS_PARTS') }})
    ),
    transform_data as (
        SELECT
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE,
            '{{ invocation_id }}' AS _AUDIT_LOG_ID,
            SHA2('hash_me') as _ROW_HASH,
            CP,
            CURRENT_PART_NUMBER,
            CURRENT_PN_DESCRIPTION,
            NEW_PART_NUMBER,
            NEW_PN_DESCRIPTION,
            PART_NUMBER_CHANGE_DIVISION,
            STATUS
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
            CURRENT_PART_NUMBER,
            CURRENT_PN_DESCRIPTION,
            NEW_PART_NUMBER,
            NEW_PN_DESCRIPTION,
            PART_NUMBER_CHANGE_DIVISION,
            STATUS
        FROM transform_data
    )
    SELECT * FROM type_data