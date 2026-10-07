{{ config(
      materialized='view',
      alias='MATERIAL_GROUP_DESCRIPTIONS',
      transient=false
) }}

with source_data as (
    SELECT
        CLIENT,
        LANGUAGE_KEY,
        MATERIAL_GROUP,
        MATERIAL_GROUP_DESCRIPTION,
        DESCRIPTION_OF_THE_MATERIAL_GROUP
    from {{ ref('COMMON__SAPH__MATERIAL_GROUP_DESCRIPTIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data