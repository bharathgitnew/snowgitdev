/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.01"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_CHANGE_LOG',
      transient=false
) }}

with source_data as (
    SELECT
        PO_NUMBER,
        LINE_NUMBER,
        REV,
        CHANGE_TYPE_ID,
        OLD_VALUE,
        NEW_VALUE
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_CHANGE_LOG') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data