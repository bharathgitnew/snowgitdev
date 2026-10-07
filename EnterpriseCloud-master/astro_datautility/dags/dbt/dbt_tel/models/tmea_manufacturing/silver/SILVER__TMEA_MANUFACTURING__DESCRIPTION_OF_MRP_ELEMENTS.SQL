{{ config(
    alias='DESCRIPTION_OF_MRP_ELEMENTS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key=['CLIENT','LANGUAGE_KEY','MRP_ELEMENT_INDEX'],
    transient = false
) }}

with source_data as (
    select
        _CAPTUREDATETIME,
        MANDT as CLIENT,
        SPRAS as LANGUAGE_KEY,
        DELKZ as MRP_ELEMENT_INDEX,
        DELB0 as MRP_ELEMENT_ABBREVIATION,
        DELB1 as MRP_ELEMENT_SHORT_DESCRIPTION
    from {{ ref('BRONZE__TMEA_MANUFACTURING__SAPO_DESCRIPTION_OF_MRP_ELEMENTS') }}
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _CAPTUREDATETIME,
        CLIENT,
        LANGUAGE_KEY,
        MRP_ELEMENT_INDEX,
        MRP_ELEMENT_ABBREVIATION,
        MRP_ELEMENT_SHORT_DESCRIPTION
    from source_data
),

type_data as (
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
        CLIENT,
        LANGUAGE_KEY,
        MRP_ELEMENT_INDEX,
        MRP_ELEMENT_ABBREVIATION,
        MRP_ELEMENT_SHORT_DESCRIPTION
    from transform_data
)

select * from type_data