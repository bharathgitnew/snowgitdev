/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.23"
*************/

{{ config(
      materialized='view',
      alias='MACHINEBU',
      transient=false
) }}

with source_data as (
    SELECT
        SOURCEMACHINEBU,
        STANDARDIZEDMACHINEBU
    from {{ ref('ODS__MDM__MACHINEBU') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data