/************
Model file generated from dbtGeneratePubViews: 03.16.2022.09.47.03"
*************/

{{ config(
      materialized='view',
      alias='CAPITAL_PO_VALIDATION_LOG',
      transient=false
) }}

with source_data as (
    SELECT
        PO_NUMBER,
        LINE_NUMBER,
        REV,
        FIELD,
        MESSAGE,
        STATUS,
        REASON_CODE,
        REASON,
        TYPE
    from {{ ref('ODS__TELCUSTOMER__CAPITAL_PO_VALIDATION_LOG') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data