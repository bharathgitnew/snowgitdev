{{ config(
    alias='SAPO_DESCRIPTION_OF_MRP_ELEMENTS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key=['MANDT','SPRAS','DELKZ'],
    transient = false
) }}

with source_data as (
    select
        _CAPTUREDATETIME,
        MANDT,
        SPRAS,
        DELKZ,
        DELB0,
        DELB1
    from {{ source('SAP_ORACLE_LIVE', 'T457T') }}
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _CAPTUREDATETIME,
        MANDT,
        SPRAS,
        DELKZ,
        DELB0,
        DELB1
    from source_data
),

type_data as (
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	    CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
        MANDT,
        SPRAS,
        DELKZ,
        DELB0,
        DELB1
    from transform_data
)

select * from type_data