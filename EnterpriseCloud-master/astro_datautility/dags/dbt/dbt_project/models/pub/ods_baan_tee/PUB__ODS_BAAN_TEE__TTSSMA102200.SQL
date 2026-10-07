/************
Model file generated from dbtGeneratePubViews: 06.15.2023.05.36.13"
*************/

{{ config(
      materialized='view',
      alias='TTSSMA102200',
      transient=false
) }}

with source_data as (
    SELECT
        T$CINS,
        T$DESC,
        T$SEAR,
        T$CUNO,
        T$CCON,
        T$SDAT,
        T$EDAT,
        T$CPAM,
        T$CPAC,
        T$PPRI,
        T$IDAT,
        T$CTYP,
        T$CCIN,
        T$CGUA,
        T$GDAT,
        T$CLOC,
        T$LOCD,
        T$CPRJ,
        T$ITEM,
        T$REVI,
        T$COUN,
        T$CNDT,
        T$PRNO,
        T$SUNO,
        T$SUCP,
        T$ORNO,
        T$PONO,
        T$CLOT,
        T$TXTA,
        T$TXTB,
        T$TXTC,
        T$TCHC,
        T$EQUI,
        T$CUPO,
        T$STAT,
        T$SYDA,
        T$PRDA,
        T$VAPO,
        T$PWED,
        T$WSDT,
        T$WEDT,
        T$ISDT,
        T$IEDT,
        T$PROC,
        T$CONF,
        T$FODT,
        T$EFDT,
        T$OSDT,
        T$INDT,
        T$WFRS,
        T$BLDN,
        T$TRNC,
        T$FACT,
        T$TRNA,
        T$AUDDAT,
        T$CHGDAT,
        T$USER,
        T$DSTAT,
        T$CMTS,
        T$TEDT,
        T$SUAG,
        T$CEMA_C,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('ODS__BAAN_TEE__TTSSMA102200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data