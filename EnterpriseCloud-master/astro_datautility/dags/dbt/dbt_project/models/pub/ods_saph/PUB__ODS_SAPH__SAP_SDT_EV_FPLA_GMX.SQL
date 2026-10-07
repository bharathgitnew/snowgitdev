/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.56.01"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDT_EV_FPLA_GMX',
      enabled=false,
      transient=false
) }}

with source_data as (
    SELECT
        *
    from {{ ref('ODS__SAPH__SAP_SDT_EV_FPLA_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data