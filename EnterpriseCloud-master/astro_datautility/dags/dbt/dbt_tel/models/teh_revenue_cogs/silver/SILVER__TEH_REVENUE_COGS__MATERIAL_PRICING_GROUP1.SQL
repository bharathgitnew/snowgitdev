{{ config(
        alias='MATERIAL_PRICING_GROUP1',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
select
    MANDT as CLIENT,
    SPRAS as LANGUAGE_KEY,
    MVGR1 as MATERIAL_GROUP_1,
    BEZEI as DESCRIPTION
from {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU171_TVM1T') }}
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH ,-- Adds column to table on full refresh.
    CLIENT,
    LANGUAGE_KEY,
    MATERIAL_GROUP_1,
    DESCRIPTION,
from source_data
),

type_data as (
select
    CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
    CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
    CAST(CLIENT as VARCHAR(16777216)) as CLIENT,
    CAST(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
    CAST(MATERIAL_GROUP_1 as VARCHAR(16777216)) as MATERIAL_GROUP_1,
    CAST(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
from transform_data
)

select * from type_data