{{ config(
      materialized='view',
      alias='DEMAND_CAPACITY_LIST',
      transient=false
) }}

with source_data as (
    SELECT
    NO,
    IPN,
    SPN,
    DESCRIPTION
    FROM {{ ref('ODS__FILE__DEMAND_CAPACITY_LIST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data