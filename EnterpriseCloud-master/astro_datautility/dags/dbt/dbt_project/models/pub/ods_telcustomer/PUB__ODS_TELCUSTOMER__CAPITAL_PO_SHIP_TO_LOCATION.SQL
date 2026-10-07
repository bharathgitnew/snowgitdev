/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.03"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_SHIP_TO_LOCATION',
      transient=false
) }}

with source_data as (
    SELECT
        SHIP_TO_LOCATION_ID,
        BAAN_BPID
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_SHIP_TO_LOCATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data