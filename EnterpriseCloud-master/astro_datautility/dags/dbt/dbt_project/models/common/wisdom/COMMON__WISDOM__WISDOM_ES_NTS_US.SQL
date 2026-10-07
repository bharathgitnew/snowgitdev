{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='WISDOM_ES_NTS_US'
) }}

with source_data as
(
    SELECT 
    _FILEDATE,
    _FILENAME,
    DOC_NO,
    DOC_TITLE,
    ISSUE_DT,
    MODEL,
    CATEGORY,
    PRIORITY,
    EMP_NO,
    NAME,
    READ_DT
    FROM {{ ref('ODS__WISDOM__WISDOM_ES_NTS_US') }}
),


transform_data as 
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
        _FILENAME,
        DOC_NO,
        DOC_TITLE,
        ISSUE_DT,
        MODEL,
        CATEGORY,
        PRIORITY,
        EMP_NO,
        NAME,
        READ_DT
    FROM source_data 
),
type_data as 
(
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        DOC_NO,
        DOC_TITLE,
        ISSUE_DT,
        MODEL,
        CATEGORY,
        PRIORITY,
        EMP_NO,
        NAME,
        READ_DT
    FROM transform_data 
)
select * from type_data