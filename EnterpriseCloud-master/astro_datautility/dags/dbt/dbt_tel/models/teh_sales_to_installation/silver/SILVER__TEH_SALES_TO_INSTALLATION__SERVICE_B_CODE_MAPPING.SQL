{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SERVICE_B_CODE_MAPPING',
    tags=["finance"]
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
    FROM {{ ref('BRONZE__TEH_SALES_TO_INSTALLATION__SHAREPOINT_SERVICE_B_CODE_MAPPING') }}


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