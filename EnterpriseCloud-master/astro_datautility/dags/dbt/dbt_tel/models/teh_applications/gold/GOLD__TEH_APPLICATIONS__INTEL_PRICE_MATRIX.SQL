{{ config(
    alias='INTEL_PRICE_MATRIX',
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    meta = {
        'owners': ['Paul Benson'],
    },
) }}

with source_data as (
    SELECT
        CONDITION_RECORD_NUMBER, 
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION, 
        VALIDITY_START_DATE_OF_THE_CONDITION_RECORD,
        VALIDITY_END_DATE_OF_THE_CONDITION_RECORD,
        CONDITION_AMOUNT,
        CONDITION_UNIT,
    FROM {{ ref('GOLD__TEH_APPLICATIONS__PRICE_MATRIX') }} pm
    where CUSTOMER ilike '%INTEL%'
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        CONDITION_RECORD_NUMBER, 
        MATERIAL_NUMBER, 
        MATERIAL_DESCRIPTION, 
        VALIDITY_START_DATE_OF_THE_CONDITION_RECORD as START_DATE, 
        VALIDITY_END_DATE_OF_THE_CONDITION_RECORD as END_DATE, 
        CONDITION_AMOUNT, 
        CONDITION_UNIT, 
    FROM source_data
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CONDITION_RECORD_NUMBER,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        START_DATE,
        END_DATE,
        CONDITION_AMOUNT::number(38,2) as CONDITION_AMOUNT,
        CONDITION_UNIT,
    FROM transform_data
)

SELECT * from type_data