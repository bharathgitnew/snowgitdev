{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='INSTRUCTION_KEY_EXPLANATION',
        transient=false
) }}

with source_data as
(
    SELECT
        SPRAS
        ,BANKS
        ,ZLSCH
        ,DTAWS
        ,TEXT 
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU249_T015WT') }} 
),
transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
        ,SPRAS
        ,BANKS
        ,ZLSCH
        ,DTAWS
        ,TEXT    
    FROM source_data
),
type_data as
(
    SELECT
        _AUDIT_LOG_ID AS _AUDIT_LOG_ID
        ,_ROW_HASH AS _ROW_HASH
        ,SPRAS AS SPRAS
        ,BANKS AS BANKS
        ,ZLSCH AS ZLSCH
        ,DTAWS AS DTAWS
        ,TEXT AS TEXT
    FROM transform_data
)
select * from type_data