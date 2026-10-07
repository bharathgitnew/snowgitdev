{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='WORKSPACE',
    unique_key = []
) }}

with source_data as
(
    SELECT
        WORKSPACE_ID,
        WORKSPACE_NAME,
        WORKSPACE_CREATED_AT,
        BOARD_NAME,
        BOARD_ID,
        BOARD_DESCRIPTION,
        BOARD_UPDATED_AT,
        _FILENAME,
        _FILEDATE
        FROM {{ source("MONDAY", "WORKSPACE") }}
        WHERE (_FileDate) = IFNULL((SELECT MAX((_FileDate)) FROM {{ source("MONDAY", "WORKSPACE") }}),'1970-01-01')
        )
,transform_data as
(
    SELECT
        WORKSPACE_ID,
        WORKSPACE_NAME,
        WORKSPACE_CREATED_AT,
        BOARD_NAME,
        BOARD_ID,
        BOARD_DESCRIPTION,
        BOARD_UPDATED_AT,
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)
,type_data as
(
    select
        CAST(WORKSPACE_ID AS VARCHAR(16777216)) AS WORKSPACE_ID,
        CAST(WORKSPACE_NAME AS VARCHAR(16777216)) AS WORKSPACE_NAME,
        CAST(WORKSPACE_CREATED_AT AS TIMESTAMP_LTZ(9)) AS WORKSPACE_CREATED_AT,
        CAST(BOARD_NAME AS VARCHAR(16777216)) AS BOARD_NAME,
        CAST(BOARD_ID AS VARCHAR(16777216)) AS BOARD_ID,
        CAST(BOARD_DESCRIPTION AS VARCHAR(16777216)) AS BOARD_DESCRIPTION,
        CAST(BOARD_UPDATED_AT AS TIMESTAMP_LTZ(9)) AS BOARD_UPDATED_AT,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128))  AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128))  AS _ROW_HASH
    from transform_data
    )
select * from type_data