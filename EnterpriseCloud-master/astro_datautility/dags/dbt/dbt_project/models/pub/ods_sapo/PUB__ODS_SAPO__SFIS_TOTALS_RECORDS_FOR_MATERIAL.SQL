/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.49"
*************/

{{ config(
      materialized='view',
      alias='SFIS_TOTALS_RECORDS_FOR_MATERIAL',
      transient=false
) }}

with source_data as (
    SELECT
        ANZFA,
        DFZEH,
        DISPO,
        IAMNG,
        I_DFZ,
        I_DLZ,
        I_WTZ,
        LMEIN,
        MANDT,
        MATNR,
        PAMNG,
        PERIV,
        PGMNG,
        PIDLZ,
        PI_AUSS,
        PI_FREI,
        PI_LIEF,
        PI_MENG,
        PI_STAR,
        PSAMG,
        PSMNG,
        PS_AUSS,
        PS_FREI,
        PS_LIEF,
        PS_MENG,
        PS_STAR,
        P_DLZ,
        SIDLZ,
        SI_AUSS,
        SI_FREI,
        SI_LIEF,
        SI_MENG,
        SI_STAR,
        SPBUP,
        SPMON,
        SPTAG,
        SPWOC,
        SSOUR,
        S_DFZ,
        S_DLZ,
        S_WTZ,
        VRSIO,
        VWDAT,
        WEMNG,
        WERKS,
        WTZAB,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__SFIS_TOTALS_RECORDS_FOR_MATERIAL') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data