/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.41"
*************/

{{ config(
      materialized='view',
      alias='INSPECTION_TYPE_MATERIAL_PARAMETERS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        ART,
        MATNR,
        WERKS,
        PPL,
        SPEZUEBER,
        CONF,
        TLS,
        APP,
        MER,
        INSMK,
        AVE,
        STICHPRVER,
        DYNREGEL,
        SPROZ,
        HPZ,
        DYN,
        MPB,
        MST,
        EIN,
        MPDAU,
        CHG,
        QKZVERF,
        QPMAT,
        KZPRFKOST,
        AUFNR_CO,
        AKTIV,
        APA,
        AFR,
        MMA,
        FEH,
        PRFRQ,
        NKMPR,
        MS_FLAG,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__INSPECTION_TYPE_MATERIAL_PARAMETERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data