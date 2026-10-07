/************
Model file generated from dbtGeneratePubViews: 03.09.2023.04.53.34"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU100_LFM1',
      transient=false
) }}

with source_data as (
    SELECT
        LIFNR,
        EKORG,
        ERDAT,
        ERNAM,
        SPERM,
        LOEVM,
        LFABC,
        WAERS,
        VERKF,
        TELF1,
        MINBW,
        ZTERM,
        INCO1,
        INCO2,
        WEBRE,
        KZABS,
        KALSK,
        KZAUT,
        EXPVZ,
        ZOLLA,
        MEPRF,
        EKGRP,
        XERSY,
        PLIFZ,
        MRPPP,
        LFRHY,
        LIBES,
        LIPRE,
        LISER,
        INCOV,
        INCO2L,
        INCO3L,
        PRFRE,
        NRGEW,
        BOIND,
        BLIND,
        KZRET,
        SKRIT,
        BSTAE,
        RDPRF,
        MEGRU,
        VENSL,
        BOPNR,
        XERSR,
        EIKTO,
        ABUEB,
        PAPRF,
        AGREL,
        XNBWY,
        VSBED,
        LEBRE,
        BOLRE,
        UMSAE,
        VENDORRMAREQ,
        LFM1EEWPS,
        ZZEDIC,
        ZZDCBF,
        ZZDREF,
        ZZDCSD,
        ZZDCFD,
        J1NBOESL,
        AUBEL,
        VALIDPRO,
        HSCABS,
        HSCPE,
        HSCMIN,
        HSCMAX,
        FSHSCCID,
        FSHVASDETC,
        UPPRS,
        ACTIVITYPROFIL,
        TRANSPORTCHAIN,
        STAGINGTIME,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU100_LFM1') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data