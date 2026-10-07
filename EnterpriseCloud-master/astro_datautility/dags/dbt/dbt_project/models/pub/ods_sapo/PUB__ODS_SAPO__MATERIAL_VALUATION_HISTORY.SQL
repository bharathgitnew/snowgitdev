/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.45"
*************/

{{ config(
      materialized='view',
      alias='MATERIAL_VALUATION_HISTORY',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        MATNR,
        BWKEY,
        BWTAR,
        LFGJA,
        LFMON,
        LBKUM,
        SALK3,
        VPRSV,
        VERPR,
        STPRS,
        PEINH,
        BKLAS,
        SALKV,
        VKSAL,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__MATERIAL_VALUATION_HISTORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data