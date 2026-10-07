/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.28"
*************/

{{ config(
      materialized='view',
      alias='PDS_HOURLY_RATE',
      transient=false
) }}

with source_data as (
    SELECT
        INVOICE_TO_BP,
        INVOICE_TO_BPID,
        PAID_SERVICE_HOURLY_RATE
    from {{ ref('ODS__MDM__PDS_HOURLY_RATE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data