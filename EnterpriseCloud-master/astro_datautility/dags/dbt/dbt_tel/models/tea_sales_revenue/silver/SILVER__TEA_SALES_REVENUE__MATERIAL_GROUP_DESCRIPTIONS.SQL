{{ config(
        alias = 'MATERIAL_GROUP_DESCRIPTIONS',
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
from {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU123_T023T') }}

),

transform_data as (
select
    CLIENT,
    LANGUAGE_KEY,
    MATERIAL_GROUP,
    MATERIAL_GROUP_DESCRIPTION,
    DESCRIPTION_OF_THE_MATERIAL_GROUP,
    '{{ invocation_id }}' AS AUDIT_LOG_ID
from source_data
),

type_data as (
select
    CAST(CLIENT as VARCHAR(16777216)) as CLIENT,
    CAST(LANGUAGE_KEY as VARCHAR(16777216)) as LANGUAGE_KEY,
    CAST(MATERIAL_GROUP as VARCHAR(16777216)) as MATERIAL_GROUP,
    CAST(MATERIAL_GROUP_DESCRIPTION as VARCHAR(16777216)) as MATERIAL_GROUP_DESCRIPTION,
    CAST(DESCRIPTION_OF_THE_MATERIAL_GROUP as VARCHAR(16777216)) as DESCRIPTION_OF_THE_MATERIAL_GROUP,
    CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID
from transform_data
)

select * from type_data