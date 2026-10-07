{{ config(
        alias = 'MATERIAL_TYPE_DESCRIPTIONS',
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
        transient = false
) }}

with source_data as (
select
    MANDT as CLIENT,
    SPRAS as LANGUAGE_KEY,
    MTART as MATERIAL_TYPE,
    MTBEZ as DESCRIPTION_OF_MATERIAL_TYPE
from {{ ref('BRONZE__TEA_LOGISTICS__SAPAPI_ZCDV_T_CMTU125_T134T') }}

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        CLIENT,
        LANGUAGE_KEY,
        MATERIAL_TYPE,
        DESCRIPTION_OF_MATERIAL_TYPE
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(CLIENT as VARCHAR(16777216)) as CLIENT,
        CAST(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
        CAST(MATERIAL_TYPE as VARCHAR(16777216)) as MATERIAL_TYPE,
        CAST(DESCRIPTION_OF_MATERIAL_TYPE as VARCHAR(16777216)) as DESCRIPTION_OF_MATERIAL_TYPE
from transform_data
)

select * from type_data