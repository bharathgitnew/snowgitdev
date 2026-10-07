/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.03"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_SHIP_TO_DESCR',
      transient=false
) }}

with source_data as (
    SELECT
        BAAN_BPID,
        DESCR
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_SHIP_TO_DESCR') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data