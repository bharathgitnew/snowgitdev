{{ config(
        alias = 'UG_EXPLN_RCD',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD:ID::STRING as ID,
        JSONFIELD:WISDOM_UG_EXPLN_ID::STRING as WISDOM_UG_EXPLN_ID,
        JSONFIELD:EXPLAINED_NAME::STRING as EXPLAINED_NAME,
        JSONFIELD:EXPLAINED_NAME_J::STRING as EXPLAINED_NAME_J,
        JSONFIELD:EXPLAINED_DEPT_NAME::STRING as EXPLAINED_DEPT_NAME,
        JSONFIELD:EXPLAINED_DEPT_NAME_J::STRING as EXPLAINED_DEPT_NAME_J,
        JSONFIELD:EXPLAINED_FILE_NAMES::STRING as EXPLAINED_FILE_NAMES,
        JSONFIELD:EXPLAINED_DT::STRING as EXPLAINED_DT,
        JSONFIELD:RECEIVED_NAME::STRING as RECEIVED_NAME,
        JSONFIELD:RECEIVED_NAME_J::STRING as RECEIVED_NAME_J,
        JSONFIELD:RECEIVED_DEPT_NAME::STRING as RECEIVED_DEPT_NAME,
        JSONFIELD:RECEIVED_DEPT_NAME_J::STRING as RECEIVED_DEPT_NAME_J,
        JSONFIELD:RECEIVED_FILE_NAMES::STRING as RECEIVED_FILE_NAMES,
        JSONFIELD:RECEIVED_DT::STRING as RECEIVED_DT,
        JSONFIELD:REMARKS::STRING as REMARKS,
        JSONFIELD:REMARKS_J::STRING as REMARKS_J,
        JSONFIELD:ENT_EMP_NO::STRING as ENT_EMP_NO,
        JSONFIELD:ENT_DT::STRING as ENT_DT,
        JSONFIELD:MOD_EMP_NO::STRING as MOD_EMP_NO,
        JSONFIELD:MOD_DT::STRING as MOD_DT,
        JSONFIELD:LATEST::STRING as LATEST,
    from {{ source('WISDOM', 'UG_EXPLN_RCD') }} 
    WHERE _FILEDATE = (
    SELECT MAX(RUN_TIME)
    FROM {{ source('WISDOM', 'CONTROLTABLE') }}
    WHERE TABLE_NAME = 'V_WISDOM_UG_EXPLN_RCD'
)
),

transform_data as (
    select 
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        ID,
        WISDOM_UG_EXPLN_ID,
        EXPLAINED_NAME,
        EXPLAINED_NAME_J,
        EXPLAINED_DEPT_NAME,
        EXPLAINED_DEPT_NAME_J,
        EXPLAINED_FILE_NAMES,
        EXPLAINED_DT,
        RECEIVED_NAME,
        RECEIVED_NAME_J,
        RECEIVED_DEPT_NAME,
        RECEIVED_DEPT_NAME_J,
        RECEIVED_FILE_NAMES,
        RECEIVED_DT,
        REMARKS,
        REMARKS_J,
        ENT_EMP_NO,
        ENT_DT,
        MOD_EMP_NO,
        MOD_DT,
        LATEST,
    from source_data
),

type_data as (
    select 
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        ID,
        WISDOM_UG_EXPLN_ID,
        EXPLAINED_NAME,
        EXPLAINED_NAME_J,
        EXPLAINED_DEPT_NAME,
        EXPLAINED_DEPT_NAME_J,
        EXPLAINED_FILE_NAMES,
        EXPLAINED_DT,
        RECEIVED_NAME,
        RECEIVED_NAME_J,
        RECEIVED_DEPT_NAME,
        RECEIVED_DEPT_NAME_J,
        RECEIVED_FILE_NAMES,
        RECEIVED_DT,
        REMARKS,
        REMARKS_J,
        ENT_EMP_NO,
        ENT_DT,
        MOD_EMP_NO,
        MOD_DT,
        LATEST,
    from transform_data
)

select * from type_data