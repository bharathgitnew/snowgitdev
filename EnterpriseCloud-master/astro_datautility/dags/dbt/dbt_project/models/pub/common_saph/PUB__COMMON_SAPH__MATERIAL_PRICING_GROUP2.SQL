{{ config(
      materialized='view',
      alias='MATERIAL_PRICING_GROUP2',
      transient=false
) }}

with source_data as (
    SELECT
        CLIENT,
        LANGUAGE_KEY,
        MATERIAL_GROUP_2,
        DESCRIPTION
    from {{ ref('COMMON__SAPH__MATERIAL_PRICING_GROUP2') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data