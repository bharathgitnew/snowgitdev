/************
Model file generated from dbtGeneratePubViews: 06.15.2023.06.46.09"
*************/

{{ config(
      materialized='view',
      alias='TTIPCS020200',
      transient=false
) }}

with source_data as (
    SELECT
        T$CPRJ,
        T$DSCA,
        T$DSCB,
        T$DSCC,
        T$DSCD,
        T$REFE,
        T$SEAK,
        T$KOPR,
        T$PSTS,
        T$PSTA,
        T$PMAN,
        T$SDAT,
        T$DDAT,
        T$PLCD,
        T$CUNO,
        T$CBDG,
        T$BCAC,
        T$ECPR,
        T$ECPA,
        T$ASCP,
        T$TINV,
        T$FFCI,
        T$BKCS,
        T$BKDT,
        T$PRTP,
        T$NCMP,
        T$TXTA,
        T$BCBI,
        T$BCIM,
        T$EREV,
        T$INTP,
        T$NCLOSE,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('COMMON__BAAN_TEE__TTIPCS020200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data