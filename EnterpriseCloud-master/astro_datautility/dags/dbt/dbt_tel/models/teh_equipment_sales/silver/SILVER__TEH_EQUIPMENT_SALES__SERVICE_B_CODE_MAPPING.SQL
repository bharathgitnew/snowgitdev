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
    FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SHAREPOINT_SERVICE_B_CODE_MAPPING') }}


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
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(B_CODE AS VARCHAR(16777216)) AS B_CODE,
        CAST(LEGACY_OFFICE AS VARCHAR(16777216)) AS LEGACY_OFFICE,
        CAST(LEGACY_OFFICE_CODE AS VARCHAR(16777216)) AS LEGACY_OFFICE_CODE,
        CAST(SAP_DESCRIPTION AS VARCHAR(16777216)) AS SAP_DESCRIPTION,
        CAST(SAP_CODE AS VARCHAR(16777216)) AS SAP_CODE,
        CAST(B_CODE_LOCATION AS VARCHAR(16777216)) AS B_CODE_LOCATION,
        CAST(SAP_TECHNICAL_ID AS VARCHAR(16777216)) AS SAP_TECHNICAL_ID
from transform_data
    )
select * from type_data