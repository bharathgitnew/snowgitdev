/************
Model file generated from dbtGeneratePubViews: 06.15.2023.05.36.10"
*************/

{{ config(
      materialized='view',
      alias='TTDINV001200',
      transient=false
) }}

with source_data as (
    SELECT
        T$CWAR,
        T$ITEM,
        T$CNTR,
        T$WLOC,
        T$UIDT,
        T$SFST,
        T$CSPS,
        T$MAXS,
        T$SLMP,
        T$SERV,
        T$SCST,
        T$OMTH,
        T$OINT,
        T$FODT,
        T$MIOQ,
        T$MAOQ,
        T$FIOQ,
        T$ECOQ,
        T$OQMF,
        T$OCST,
        T$AUSO,
        T$CSPD,
        T$CFMD,
        T$STOC,
        T$ORDR,
        T$ALLO,
        T$HALL,
        T$LTDT,
        T$LCOD,
        T$USCU,
        T$USAB,
        T$REOP,
        T$HSTB,
        T$HSTD,
        T$WIST,
        T$BLCK,
        T$QBSI,
        T$LSID,
        T$ALPL,
        T$LLCD,
        T$REFA,
        T$REFB,
        T$ROPC,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('ODS__BAAN_TEE__TTDINV001200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data