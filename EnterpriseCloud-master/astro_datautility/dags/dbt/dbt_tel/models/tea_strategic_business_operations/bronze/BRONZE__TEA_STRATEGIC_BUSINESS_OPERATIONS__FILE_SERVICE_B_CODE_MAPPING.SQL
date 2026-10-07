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
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
)

,type_data as
(
    select
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        B_CODE AS B_CODE,
        LEGACY_OFFICE AS LEGACY_OFFICE,
        LEGACY_OFFICE_CODE AS LEGACY_OFFICE_CODE,
        SAP_DESCRIPTION AS SAP_DESCRIPTION,
        SAP_CODE AS SAP_CODE,
        B_CODE_LOCATION AS B_CODE_LOCATION,
        SAP_TECHNICAL_ID AS SAP_TECHNICAL_ID
    from transform_data
    )
select * from type_data