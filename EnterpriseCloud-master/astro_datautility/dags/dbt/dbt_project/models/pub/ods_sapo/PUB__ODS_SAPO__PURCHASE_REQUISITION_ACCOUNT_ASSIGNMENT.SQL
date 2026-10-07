/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.46"
*************/

{{ config(
      materialized='view',
      alias='PURCHASE_REQUISITION_ACCOUNT_ASSIGNMENT',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        BANFN,
        BNFPO,
        ZEBKN,
        LOEKZ,
        ERDAT,
        ERNAM,
        MENGE,
        VPROZ,
        SAKTO,
        GSBER,
        KOSTL,
        PROJN,
        VBELN,
        VBELP,
        VETEN,
        ANLN1,
        ANLN2,
        AUFNR,
        WEMPF,
        ABLAD,
        KOKRS,
        XBKST,
        XBAUF,
        XBPRO,
        KSTRG,
        PAOBJNR,
        PRCTR,
        PS_PSP_PNR,
        NPLNR,
        AUFPL,
        IMKEY,
        APLZL,
        VPTNR,
        FIPOS,
        RECID,
        FISTL,
        GEBER,
        FKBER,
        DABRZ,
        NETWR,
        AUFPL_ORD,
        APLZL_ORD,
        KBLNR,
        KBLPOS,
        LSTAR,
        PRZNR,
        GRANT_NBR,
        FM_SPLIT_BATCH,
        FM_SPLIT_BEGRU,
        BUDGET_PD,
        FMFGUS_KEY,
        EGRUP,
        VNAME,
        TCOBJNR,
        DATEOFSERVICE,
        NOTAXCORR,
        DIFFOPTRATE,
        HASDIFFOPTRATE,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__PURCHASE_REQUISITION_ACCOUNT_ASSIGNMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data