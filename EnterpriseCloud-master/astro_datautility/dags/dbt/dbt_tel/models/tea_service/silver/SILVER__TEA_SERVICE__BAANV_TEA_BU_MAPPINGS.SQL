{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='BaanV_TEA_BU_Mappings',
      transient=false
) }}

with source_data as (
    SELECT
    BUCODETEA AS TEA_BU_CODE,
    BUCODETEL AS TEL_BU_CODE,
    BUCODEBYCONFIGURATION AS BU_CONFIGURATION_CODE
    from {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANCOMMONCOMMONDATA_BUCODEMAPPING') }}
),

transform_data AS
(
    select
     TEA_BU_CODE,
     TEL_BU_CODE,
     BU_CONFIGURATION_CODE
    from source_data
)

    select * from transform_data