{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SUBITEMSID',
    unique_key = []
) }}

with source_data as
(
    SELECT
        ACCOUNT_ID,
        BOARDS_ID,
        ITEMS_ID,
        SUBITEMS_ID,
        SUBITEMS_UPDATED_AT,
        _FILENAME,
        _FILEDATE
        FROM {{ source("MONDAY", "SUBITEMSID") }}
        WHERE (_FileDate) = IFNULL((SELECT MAX((_FileDate)) FROM {{ source("MONDAY", "SUBITEMSID") }}),'1970-01-01')
        )
,transform_data as
(
    SELECT
        ACCOUNT_ID,
        BOARDS_ID,
        ITEMS_ID,
        SUBITEMS_ID,
        SUBITEMS_UPDATED_AT,
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)
,type_data as
(
    select
        CAST(ACCOUNT_ID AS VARCHAR(16777216)) AS ACCOUNT_ID,
        CAST(BOARDS_ID AS VARCHAR(16777216)) AS BOARDS_ID,
        CAST(ITEMS_ID AS VARCHAR(16777216)) AS ITEMS_ID,
        CAST(SUBITEMS_ID AS VARCHAR(16777216)) AS SUBITEMS_ID,
        CAST(SUBITEMS_UPDATED_AT AS TIMESTAMP_NTZ(9)) AS SUBITEMS_UPDATED_AT,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128))  AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128))  AS _ROW_HASH
    from transform_data
    )
select * from type_data