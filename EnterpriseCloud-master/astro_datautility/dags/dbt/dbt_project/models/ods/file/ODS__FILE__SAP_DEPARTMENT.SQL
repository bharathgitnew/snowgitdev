{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_DEPARTMENT'
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
		BAAN_CODE
    FROM {{ source("FILE", "SAP_DEPARTMENT") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "SAP_DEPARTMENT") }})

)

,transform_data as
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
        CAST(ORACLE_CODE AS VARCHAR(16777216)) AS ORACLE_CODE,
        CAST(ORACLE_DESCRIPTION AS VARCHAR(16777216)) AS ORACLE_DESCRIPTION,
        CAST(SAP_CODE AS VARCHAR(16777216)) AS SAP_CODE,
        CAST(SAP_DESCRIPTION AS VARCHAR(16777216)) AS SAP_DESCRIPTION,
        CAST(BAAN_CODE AS VARCHAR(16777216)) AS BAAN_CODE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    from transform_data
    )
select * from type_data