/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.12"
*************/

{{ config(
      materialized='view',
      alias='PDSHOURLYRATE',
      transient=false
) }}

with source_data as (
    SELECT
        INVOICE_TO_BP,
        INVOICE_TO_BPID,
        PAID_SERVICE_HOURLY_RATE
    from {{ ref('COMMON__MDM__PDSHOURLYRATE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data