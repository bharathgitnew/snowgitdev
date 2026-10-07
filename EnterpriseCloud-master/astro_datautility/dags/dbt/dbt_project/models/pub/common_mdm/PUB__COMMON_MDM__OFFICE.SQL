/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.11"
*************/

{{ config(
      materialized='view',
      alias='OFFICE',
      transient=false
) }}

with source_data as (
    SELECT
        OFFICECODE,
        REGION,
        OFFICEKEY,
        ORACLEOFFICECODE
    from {{ ref('COMMON__MDM__OFFICE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data