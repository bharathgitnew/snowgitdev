{{ config(
        alias = 'MATERIAL_PRICING_GROUP1',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
select
    MANDT as CLIENT,
    SPRAS as LANGUAGE_KEY,
    MVGR1 as MATERIAL_GROUP_1,
    BEZEI as DESCRIPTION
from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU171_TVM1T') }}
),

transform_data as (
select
    CLIENT,
    LANGUAGE_KEY,
    MATERIAL_GROUP_1,
    DESCRIPTION,
    '{{ invocation_id }}' AS AUDIT_LOG_ID
from source_data
),

type_data as (
select
    CAST(CLIENT as VARCHAR(16777216)) as CLIENT,
    CAST(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
    CAST(MATERIAL_GROUP_1 as VARCHAR(16777216)) as MATERIAL_GROUP_1,
    CAST(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
    CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID
from transform_data
)

select * from type_data