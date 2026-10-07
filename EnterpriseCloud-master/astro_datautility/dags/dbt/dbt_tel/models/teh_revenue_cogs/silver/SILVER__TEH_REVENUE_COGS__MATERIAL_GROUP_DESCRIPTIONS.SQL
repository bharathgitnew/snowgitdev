{{ config(
        alias='MATERIAL_GROUP_DESCRIPTIONS',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
select
    MANDT as CLIENT,
    SPRAS as LANGUAGE_KEY,
    MATKL as MATERIAL_GROUP,
    WGBEZ as MATERIAL_GROUP_DESCRIPTION,
    WGBEZ60 as DESCRIPTION_OF_THE_MATERIAL_GROUP
from {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU123_T023T') }}

),

transform_data as (
select
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    CLIENT,
    LANGUAGE_KEY,
    MATERIAL_GROUP,
    MATERIAL_GROUP_DESCRIPTION,
    DESCRIPTION_OF_THE_MATERIAL_GROUP
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
    CAST(CLIENT as VARCHAR(16777216)) as CLIENT,
    CAST(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
    CAST(MATERIAL_GROUP as VARCHAR(16777216)) as MATERIAL_GROUP,
    CAST(MATERIAL_GROUP_DESCRIPTION as VARCHAR(16777216)) as MATERIAL_GROUP_DESCRIPTION,
    CAST(DESCRIPTION_OF_THE_MATERIAL_GROUP as VARCHAR(16777216)) as DESCRIPTION_OF_THE_MATERIAL_GROUP
from transform_data
)

select * from type_data