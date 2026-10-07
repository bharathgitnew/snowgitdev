/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.43"
*************/

{{ config(
      materialized='view',
      alias='VALUATION_AREA',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        BWKEY,
        BUKRS,
        BWMOD,
        XBKNG,
        MLBWA,
        MLBWV,
        XVKBW,
        ERKLAERKOM,
        UPROF,
        WBPRO,
        MLAST,
        MLASV,
        BDIFP,
        XLBPD,
        XEWRX,
        X2FDO,
        PRSFR,
        MLCCS,
        XEFRE,
        EFREJ,
        FMP_PRSFR,
        FMP_PRFRGR,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__VALUATION_AREA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data