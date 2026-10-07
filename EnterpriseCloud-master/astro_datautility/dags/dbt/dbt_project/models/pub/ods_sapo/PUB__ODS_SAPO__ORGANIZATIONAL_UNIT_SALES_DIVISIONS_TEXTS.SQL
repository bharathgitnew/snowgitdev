/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.41"
*************/

{{ config(
      materialized='view',
      alias='ORGANIZATIONAL_UNIT_SALES_DIVISIONS_TEXTS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        SPART,
        VTEXT,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__ORGANIZATIONAL_UNIT_SALES_DIVISIONS_TEXTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data