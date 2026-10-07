{{ config(
      materialized='view',
      alias='MATERIAL_TYPE_DESCRIPTIONS',
      transient=false
) }}

with source_data as (
    SELECT
        CLIENT,
        LANGUAGE_KEY,
        MATERIAL_TYPE,
        DESCRIPTION_OF_MATERIAL_TYPE
    from {{ ref('COMMON__SAPH__MATERIAL_TYPE_DESCRIPTIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data