{{ config(
    alias='FILE_SAP_MATERIAL_CLASSIFICATIONS',
    materialized = 'tel_incremental',
    incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
    transient = false
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
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        MATERIAL_NUMBER,
        CLASSIFICATION
from source_data
),

type_data as (
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _UPLOADDATE,
        MATERIAL_NUMBER,
        CLASSIFICATION
from transform_data
)

select * from type_data