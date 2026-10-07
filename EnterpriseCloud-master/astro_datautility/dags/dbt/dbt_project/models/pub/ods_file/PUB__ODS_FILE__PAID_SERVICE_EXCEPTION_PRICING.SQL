/************
Model file generated from dbtGeneratePubViews: 03.16.2022.12.10.20"
*************/

{{ config(
      materialized='view',
      alias='PAID_SERVICE_EXCEPTION_PRICING',
      transient=false
) }}

with source_data as (
    SELECT
        SERVICE_ORDER,
        DESCRIPTION,
        HOURLY_RATE,
        TYPE,
        PROGRAM_YEAR,
        BU,
        PFP_PO,
        MAPPED_SO,
        FAB
    from {{ source('ODS__FILE', 'PAID_SERVICE_EXCEPTION_PRICING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data