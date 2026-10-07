/************
Model file generated from dbtGeneratePubViews: 06.15.2023.05.36.11"
*************/

{{ config(
      materialized='view',
      alias='TTDSLS040200',
      transient=false
) }}

with source_data as (
    SELECT
        T$ORNO,
        T$CUNO,
        T$CPER,
        T$COMP,
        T$CORG,
        T$CPAY,
        T$COTP,
        T$ODAT,
        T$ODIS,
        T$CCUR,
        T$FCRT,
        T$RATS,
        T$RATF,
        T$CCOR,
        T$CDEL,
        T$CREP,
        T$CFCG,
        T$CVYN,
        T$CCRS,
        T$CFRW,
        T$CPLS,
        T$PLDD,
        T$PCPR,
        T$PCTX,
        T$CCTY,
        T$CLAN,
        T$CDEC,
        T$CRTE,
        T$DDAT,
        T$FUTO,
        T$CBRN,
        T$CREG,
        T$REFA,
        T$REFB,
        T$BKYN,
        T$CBLC,
        T$PRNO,
        T$SCOM,
        T$PRDT,
        T$CTRJ,
        T$EONO,
        T$TXTA,
        T$TXTB,
        T$AGEN,
        T$CINS,
        T$SGRP,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('ODS__BAAN_TEE__TTDSLS040200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data