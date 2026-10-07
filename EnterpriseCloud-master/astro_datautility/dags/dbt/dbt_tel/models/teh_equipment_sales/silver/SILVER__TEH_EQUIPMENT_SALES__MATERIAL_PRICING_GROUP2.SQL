{{ config(
        alias = 'MATERIAL_PRICING_GROUP2',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
select
    MANDT as CLIENT,
    SPRAS as LANGUAGE_KEY,
    MVGR2 as MATERIAL_GROUP_2,
    BEZEI as DESCRIPTION
from {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SAPAPI_ZCDV_T_CMTU173_TVM2T') }}
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        CLIENT,
        LANGUAGE_KEY,
        MATERIAL_GROUP_2,
        DESCRIPTION
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(CLIENT as VARCHAR(16777216)) as CLIENT,
        CAST(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
        CAST(MATERIAL_GROUP_2 as VARCHAR(16777216)) as MATERIAL_GROUP_2,
        CAST(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION
from transform_data
)

select * from type_data