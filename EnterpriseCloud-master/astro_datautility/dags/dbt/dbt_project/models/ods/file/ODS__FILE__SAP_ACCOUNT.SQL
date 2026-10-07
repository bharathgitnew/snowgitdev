{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_ACCOUNT'
) }}

with source_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
		BAAN_GL,
		BAAN_LEDGER_ACCOUNT_DESCRIPTION,
		SAP_GL_NO,
		SAP_GL_ACCOUNT_TEXT
    FROM {{ source("FILE", "SAP_ACCOUNT") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "SAP_ACCOUNT") }})

)

,transform_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
		BAAN_GL,
		BAAN_LEDGER_ACCOUNT_DESCRIPTION,
		SAP_GL_NO,
		SAP_GL_ACCOUNT_TEXT,
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
        CAST(BAAN_GL AS VARCHAR(16777216)) AS BAAN_GL,
        CAST(BAAN_LEDGER_ACCOUNT_DESCRIPTION AS VARCHAR(16777216)) AS BAAN_LEDGER_ACCOUNT_DESCRIPTION,
        CAST(SAP_GL_NO AS VARCHAR(16777216)) AS SAP_GL_NO,
        CAST(SAP_GL_ACCOUNT_TEXT AS VARCHAR(16777216)) AS SAP_GL_ACCOUNT_TEXT,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    from transform_data
    )
select * from type_data