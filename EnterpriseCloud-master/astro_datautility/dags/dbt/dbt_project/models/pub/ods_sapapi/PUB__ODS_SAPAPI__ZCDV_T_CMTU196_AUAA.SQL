/************
Model file generated from dbtGeneratePubViews: 03.17.2023.07.27.51"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU196_AUAA',
      transient=false
) }}

with source_data as (
    SELECT
        BELNR,
        LFDNR,
        EMTYP,
        KOKRS,
        BUKRS,
        WERKS,
        SAKNR,
        KOSTL,
        AUFNR,
        PSPNR,
        ANLN1,
        ANLN2,
        MATNR,
        PAOBJNR,
        PRCTR,
        WAERS,
        COOBJNR,
        GSBER,
        VNAME,
        RECID,
        EGRUP,
        COPAR,
        BWTAR,
        KSTRG,
        NPLNR,
        AUFPL,
        APLZL,
        KDAUF,
        KDPOS,
        ETYPE,
        RIFIND,
        SCOPE,
        POSNR,
        ERLKZ,
        PRZNR,
        IMKEY,
        DABRZ,
        GMENG,
        GEINH,
        LSQTY,
        ANBWA,
        --PSPNR_NEW,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU196_AUAA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data