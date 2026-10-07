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
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
        B_CODE,
        LEGACY_OFFICE,
        LEGACY_OFFICE_CODE,
        SAP_DESCRIPTION,
        SAP_CODE,
        B_CODE_LOCATION,
        SAP_TECHNICAL_ID,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
)

,type_data as
(
    select
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(B_CODE AS VARCHAR(16777216)) AS B_CODE,
        CAST(LEGACY_OFFICE AS VARCHAR(16777216)) AS LEGACY_OFFICE,
        CAST(LEGACY_OFFICE_CODE AS VARCHAR(16777216)) AS LEGACY_OFFICE_CODE,
        CAST(SAP_DESCRIPTION AS VARCHAR(16777216)) AS SAP_DESCRIPTION,
        CAST(SAP_CODE AS VARCHAR(16777216)) AS SAP_CODE,
        CAST(B_CODE_LOCATION AS VARCHAR(16777216)) AS B_CODE_LOCATION,
        CAST(SAP_TECHNICAL_ID AS VARCHAR(16777216)) AS SAP_TECHNICAL_ID,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    from transform_data
    )
select * from type_data