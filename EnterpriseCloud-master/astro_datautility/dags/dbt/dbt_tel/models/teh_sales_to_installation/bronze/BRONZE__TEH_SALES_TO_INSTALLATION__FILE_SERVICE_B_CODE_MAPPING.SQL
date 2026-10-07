{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_SERVICE_B_CODE_MAPPING'
) }}

with source_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
        B_CODE,
        LEGACY_OFFICE,
        LEGACY_OFFICE_CODE,
        SAP_DESCRIPTION,
        SAP_CODE,
        B_CODE_LOCATION,
        SAP_TECHNICAL_ID
    FROM {{ source("FILE", "SERVICE_B_CODE_MAPPING") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "SERVICE_B_CODE_MAPPING") }})
        and B_CODE is not null

)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
        B_CODE,
        LEGACY_OFFICE,
        LEGACY_OFFICE_CODE,
        SAP_DESCRIPTION,
        SAP_CODE,
        B_CODE_LOCATION,
        SAP_TECHNICAL_ID
        FROM source_data
)

,type_data as
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        B_CODE,
        LEGACY_OFFICE,
        LEGACY_OFFICE_CODE,
        SAP_DESCRIPTION,
        SAP_CODE,
        B_CODE_LOCATION,
        SAP_TECHNICAL_ID
    from transform_data
    )
select * from type_data