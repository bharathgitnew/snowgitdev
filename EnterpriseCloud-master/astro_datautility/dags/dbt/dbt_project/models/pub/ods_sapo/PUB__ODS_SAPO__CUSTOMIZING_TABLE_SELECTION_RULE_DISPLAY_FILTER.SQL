/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.40"
*************/

{{ config(
      materialized='view',
      alias='CUSTOMIZING_TABLE_SELECTION_RULE_DISPLAY_FILTER',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        ERGBZ,
        SVPEB,
        SANGB,
        SKDAU,
        SLIEF,
        SSKBD,
        SMRES,
        SLBED,
        SARES,
        SAPLF,
        SABES,
        SABAN,
        SALPE,
        SURES,
        SFERT,
        SPLAF,
        SBEST,
        SBANF,
        SLPET,
        SAVIS,
        SQMPR,
        SBWRK,
        SBSIC,
        SBNFR,
        SBGSP,
        SBUML,
        SBKON_EDL,
        SRABR,
        SSGUT,
        DTALL,
        DTAPP,
        DTCUS,
        STADT,
        SSPAN,
        ENDDT,
        ESPAN,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__CUSTOMIZING_TABLE_SELECTION_RULE_DISPLAY_FILTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data