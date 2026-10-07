{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='ITEMS',
    unique_key = []
) }}

with source_data as
(
    SELECT
        TITLE,
        TYPE,
        TEXT,
        ACCOUNT_ID,
        BOARDS_ID,
        BOARDS_NAME,
        ITEMS_ID,
        ITEMS_NAME,
        ITEMS_UPDATED_AT,
        ITEMS_GROUP_TITLE,
        _FILENAME,
        _FILEDATE
        FROM {{ source("MONDAY", "ITEMS") }}
        WHERE (_FileDate) = IFNULL((SELECT MAX((_FileDate)) FROM {{ source("MONDAY", "ITEMS") }}),'1970-01-01')
        )
,transform_data as
(
    SELECT
        TITLE,
        TYPE,
        TEXT,
        ACCOUNT_ID,
        BOARDS_ID,
        BOARDS_NAME,
        ITEMS_ID,
        ITEMS_NAME,
        ITEMS_UPDATED_AT,
        ITEMS_GROUP_TITLE,
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)
,type_data as
(
    select
        CAST(TITLE AS VARCHAR(16777216)) AS TITLE,
        CAST(TYPE AS VARCHAR(16777216)) AS TYPE,
        CAST(TEXT AS VARCHAR(16777216)) AS TEXT,
        CAST(ACCOUNT_ID AS VARCHAR(16777216)) AS ACCOUNT_ID,
        CAST(BOARDS_ID AS VARCHAR(16777216)) AS BOARDS_ID,
        CAST(BOARDS_NAME AS VARCHAR(16777216)) AS BOARDS_NAME,
        CAST(ITEMS_ID AS VARCHAR(16777216)) AS ITEMS_ID,
        CAST(ITEMS_NAME AS VARCHAR(16777216)) AS ITEMS_NAME,
        CAST(ITEMS_UPDATED_AT AS TIMESTAMP_LTZ(9)) AS ITEMS_UPDATED_AT,
        CAST(ITEMS_GROUP_TITLE AS VARCHAR(16777216)) AS ITEMS_GROUP_TITLE,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128))  AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128))  AS _ROW_HASH
    from transform_data
    )
select * from type_data