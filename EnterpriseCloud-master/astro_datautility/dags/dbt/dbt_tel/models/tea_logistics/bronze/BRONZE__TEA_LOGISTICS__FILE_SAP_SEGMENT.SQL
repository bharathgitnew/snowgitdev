{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
    alias='FILE_SAP_SEGMENT'
) }}

with source_data as
(
    SELECT
	    _FILENAME,
	    _FILEDATE,
	    _UPLOADDATE,
	    ORACLE_CODE,
	    ORACLE_DESCRIPTION,
	    SAP_CODE,
	    SAP_DESCRIPTION,
	    BAAN_CODE,
	    BAAN_DESCRIPTION
    FROM {{ source("FILE", "SAP_SEGMENT") }}
    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "SAP_SEGMENT") }})
 
)

,transform_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		_UPLOADDATE,
		ORACLE_CODE,
		ORACLE_DESCRIPTION,
		SAP_CODE,
		SAP_DESCRIPTION,
		BAAN_CODE,
		BAAN_DESCRIPTION
        FROM source_data
)

,type_data as
(
    select
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(ORACLE_CODE AS VARCHAR(16777216)) AS ORACLE_CODE,
        CAST(ORACLE_DESCRIPTION AS VARCHAR(16777216)) AS ORACLE_DESCRIPTION,
        CAST(SAP_CODE AS VARCHAR(16777216)) AS SAP_CODE,
        CAST(SAP_DESCRIPTION AS VARCHAR(16777216)) AS SAP_DESCRIPTION,
        CAST(BAAN_CODE AS VARCHAR(16777216)) AS BAAN_CODE,
        CAST(BAAN_DESCRIPTION AS VARCHAR(16777216)) AS BAAN_DESCRIPTION
    from transform_data
    )
select * from type_data