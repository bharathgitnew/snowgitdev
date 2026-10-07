/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.02"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_QUOTE_MAP',
      transient=false
) }}

with source_data as (
    SELECT
        QUOTE_PREFIX,
        BU,
        SUB_BU
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_QUOTE_MAP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data