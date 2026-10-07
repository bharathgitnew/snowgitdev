{{ config(
    alias='FILE_SAP_MATERIAL_CLASSIFICATIONS',
    materialized='tel_incremental',
    incremental_strategy = 'insert_overwrite',
    meta = {
        'owners': ['Michael Lleverino']
    }
) }}

with source_data as (
    select
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        MATERIAL_NUMBER,
        CLASSIFICATION,
    from {{ source('FILE', 'SAP_MATERIAL_CLASSIFICATIONS') }} 
    where _UPLOADDATE >= (select max(_UPLOADDATE) from {{ source('FILE', 'SAP_MATERIAL_CLASSIFICATIONS') }})
),

transform_data as (
    select distinct
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        MATERIAL_NUMBER,
        CLASSIFICATION,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE,
        MATERIAL_NUMBER,
        CLASSIFICATION,
    from transform_data
)

select * from type_data

