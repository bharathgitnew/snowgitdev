/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.01"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_CHANGE_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
        CHANGE_TYPE_ID,
        DESCRIPTION
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_CHANGE_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data