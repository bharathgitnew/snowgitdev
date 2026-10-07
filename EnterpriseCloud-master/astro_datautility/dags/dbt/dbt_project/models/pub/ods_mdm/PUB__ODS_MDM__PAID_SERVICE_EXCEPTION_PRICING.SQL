/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.28"
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
    from {{ ref('ODS__MDM__PAID_SERVICE_EXCEPTION_PRICING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data