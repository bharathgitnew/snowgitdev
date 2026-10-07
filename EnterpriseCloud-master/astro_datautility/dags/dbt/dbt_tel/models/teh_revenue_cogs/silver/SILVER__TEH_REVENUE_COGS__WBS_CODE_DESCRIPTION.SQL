{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='WBS_CODE_DESCRIPTION',
    tags=["finance"]
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        WBS_CODE,
        WBS_1,
        WBS_13,
        WBS_CODE_DESC
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__FILE_WBS_CODE_DESCRIPTION') }}

)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        WBS_CODE,
        WBS_1,
        WBS_13,
        WBS_CODE_DESC
        FROM source_data
)

,type_data as
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(WBS_CODE AS VARCHAR(16777216)) AS WBS_CODE,
        CAST(WBS_1 AS VARCHAR(16777216)) AS WBS_1,
        CAST(WBS_13 AS VARCHAR(16777216)) AS WBS_13,
        CAST(WBS_CODE_DESC AS VARCHAR(16777216)) AS WBS_CODE_DESC
    from transform_data
    )
select * from type_data