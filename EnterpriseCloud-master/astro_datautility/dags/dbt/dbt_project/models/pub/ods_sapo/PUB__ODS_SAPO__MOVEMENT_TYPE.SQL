/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.50"
*************/

{{ config(
      materialized='view',
      alias='MOVEMENT_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        BWART,
        SHKZG,
        KZWES,
        KZVBU,
        KZDRU,
        KZKON,
        CHNEU,
        KZZDE,
        RSTYP,
        SELPA,
        XLAUT,
        KZSTR,
        KZGRU,
        XINVB,
        QSSBW,
        KZBWA,
        XSTBW,
        XPBED,
        XWSBR,
        KZMHD,
        KZCLA,
        XKOKO,
        XKCFC,
        XNEBE,
        J_1BNFREL,
        J_1BNFTYPE,
        J_1BITMTYP,
        J_1BSPCSTO,
        J_1BPARTYP,
        J_1BPARVW,
        RULES,
        J_1AREVIDX,
        J_1ADOCCL,
        J_1AEXPKZ,
        XOARC,
        BUSTR,
        KZDIR,
        OIJ1BNFFI,
        MILL_CPCONF,
        CO_WIPB_CPCONF,
        XWIPB,
        FSH_DEALLOC,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__MOVEMENT_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data