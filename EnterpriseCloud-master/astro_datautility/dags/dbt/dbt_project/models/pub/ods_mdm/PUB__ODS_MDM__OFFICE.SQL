/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.25"
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
    from {{ ref('ODS__MDM__OFFICE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data