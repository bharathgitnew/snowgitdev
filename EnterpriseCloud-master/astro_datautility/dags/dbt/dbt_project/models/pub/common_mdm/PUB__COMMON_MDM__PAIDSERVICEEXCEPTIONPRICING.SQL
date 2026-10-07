/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.12"
*************/

{{ config(
      materialized='view',
      alias='PAIDSERVICEEXCEPTIONPRICING',
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
    from {{ ref('COMMON__MDM__PAIDSERVICEEXCEPTIONPRICING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data