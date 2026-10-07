{{ config(
        alias = 'MATERIAL_TYPE_DESCRIPTIONS',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
select
    MANDT as CLIENT,
    SPRAS as LANGUAGE_KEY,
    MTART as MATERIAL_TYPE,
    MTBEZ as DESCRIPTION_OF_MATERIAL_TYPE
from {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU125_T134T') }}

),

transform_data as (
select
    CLIENT,
    LANGUAGE_KEY,
    MATERIAL_TYPE,
    DESCRIPTION_OF_MATERIAL_TYPE,
    '{{ invocation_id }}' AS AUDIT_LOG_ID
from source_data
),

type_data as (
select
    CAST(CLIENT as VARCHAR(16777216)) as CLIENT,
    CAST(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
    CAST(MATERIAL_TYPE as VARCHAR(16777216)) as MATERIAL_TYPE,
    CAST(DESCRIPTION_OF_MATERIAL_TYPE as VARCHAR(16777216)) as DESCRIPTION_OF_MATERIAL_TYPE,
    CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID
from transform_data
)

select * from type_data

