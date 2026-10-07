{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_DOCUMENT_TYPE_DESCRIPTION'
) }}

with source_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
		DOC_TYPE,
		DOC_TYPE_DESCRIPTION
    FROM {{ source("FILE", "SAP_DOCUMENT_TYPE_DESCRIPTION") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "SAP_DOCUMENT_TYPE_DESCRIPTION") }})

)

,transform_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
		DOC_TYPE,
		DOC_TYPE_DESCRIPTION,
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
        CAST(DOC_TYPE AS VARCHAR(16777216)) AS DOC_TYPE,
        CAST(DOC_TYPE_DESCRIPTION AS VARCHAR(16777216)) AS DOC_TYPE_DESCRIPTION,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    from transform_data
    )
select * from type_data