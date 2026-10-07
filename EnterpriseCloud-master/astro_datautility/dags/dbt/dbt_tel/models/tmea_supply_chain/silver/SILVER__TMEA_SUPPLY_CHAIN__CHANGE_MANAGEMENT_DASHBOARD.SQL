{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='CHANGE_MANAGEMENT_DASHBOARD',
) }}

with source_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        ECN,
        OWNER,
        TARGET_SAP_DATE,
        TIME,
        TASK,
        TASK_SUBMITTAL,
        TASK_OWNER_REVIEW,
        PENDING_APPROVERS,
        COMPLETED_APPROVERS,
        FINAL_AUDIT
    FROM {{ ref('BRONZE__TMEA_SUPPLY_CHAIN__WINDCHILL_CHANGE_MANAGEMENT_DASHBOARD') }}
),
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
        _FILENAME,
        ECN,
        OWNER,
        TARGET_SAP_DATE,
        TIME,
        TASK,
        TASK_SUBMITTAL,
        TASK_OWNER_REVIEW,
        PENDING_APPROVERS,
        COMPLETED_APPROVERS,
        FINAL_AUDIT
    FROM source_data
),
type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        ECN,
        OWNER,
        TARGET_SAP_DATE,
        TIME,
        TASK,
        TASK_SUBMITTAL,
        TASK_OWNER_REVIEW,
        PENDING_APPROVERS,
        COMPLETED_APPROVERS,
        FINAL_AUDIT
    FROM transform_data
)
SELECT * FROM type_data