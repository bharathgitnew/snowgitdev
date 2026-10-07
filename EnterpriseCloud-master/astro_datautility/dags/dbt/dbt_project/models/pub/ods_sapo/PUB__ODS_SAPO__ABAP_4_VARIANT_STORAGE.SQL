/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.34"
*************/

{{ config(
      materialized='view',
      alias='ABAP_4_VARIANT_STORAGE',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        RELID,
        REPORT,
        VARIANT,
        SRTF2,
        VDATE,
        VTIME,
        VERNR,
        CLUSTR,
        CLUSTD,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__ABAP_4_VARIANT_STORAGE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data