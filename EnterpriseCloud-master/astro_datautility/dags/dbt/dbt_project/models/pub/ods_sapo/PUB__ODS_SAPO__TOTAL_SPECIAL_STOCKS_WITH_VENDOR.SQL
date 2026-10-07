/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.50"
*************/

{{ config(
      materialized='view',
      alias='TOTAL_SPECIAL_STOCKS_WITH_VENDOR',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        MATNR,
        WERKS,
        SOBKZ,
        LIFNR,
        LFGJA,
        LFMON,
        SLLAB,
        SLINS,
        SLEIN,
        ERSDA,
        XOBEW,
        SLUML,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__TOTAL_SPECIAL_STOCKS_WITH_VENDOR') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data