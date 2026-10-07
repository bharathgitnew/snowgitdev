/************
Model file generated from dbtGeneratePubViews: 06.15.2023.06.46.07"
*************/

{{ config(
      materialized='view',
      alias='TTDPUR040200',
      transient=false
) }}

with source_data as (
    SELECT
        T$ORNO,
        T$SUNO,
        T$COMP,
        T$COTP,
        T$CORG,
        T$RAGR,
        T$CPAY,
        T$ODAT,
        T$ODIS,
        T$CCUR,
        T$RATP,
        T$RATF,
        T$CCOR,
        T$CWAR,
        T$CCON,
        T$CVYN,
        T$CCRS,
        T$CFRW,
        T$CPLP,
        T$CCTY,
        T$CLAN,
        T$PSPR,
        T$PSTX,
        T$CDEC,
        T$CFSG,
        T$DDAT,
        T$DDTC,
        T$CBRN,
        T$CREG,
        T$REFA,
        T$REFB,
        T$PRNO,
        T$CTRJ,
        T$EGEN,
        T$TXTA,
        T$TXTB,
        T$POREV,
        T$CUNO,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('COMMON__BAAN_TEE__TTDPUR040200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data