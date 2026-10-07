/************
Model file generated from dbtGeneratePubViews: 06.15.2023.05.36.11"
*************/

{{ config(
      materialized='view',
      alias='TTDPUR045200',
      transient=false
) }}

with source_data as (
    SELECT
        T$ORNO,
        T$PONO,
        T$SRNB,
        T$SUNO,
        T$CPRJ,
        T$ITEM,
        T$CNTR,
        T$CWAR,
        T$PRIC,
        T$DISC_1,
        T$DISC_2,
        T$DISC_3,
        T$DAMT_1,
        T$DAMT_2,
        T$DAMT_3,
        T$CPCP,
        T$DATE,
        T$IQAN,
        T$IAMT,
        T$STSD,
        T$STSC,
        T$PDNO,
        T$OPNO,
        T$RONO,
        T$SPUR,
        T$PMSK,
        T$RENO,
        T$DINO,
        T$TORN,
        T$TPON,
        T$TSRN,
        T$INVN,
        T$INVD,
        T$DDTB,
        T$MARK,
        T$DIQU,
        T$DQUA,
        T$BQUA,
        T$QUAP,
        T$QUAD,
        T$CDIS,
        T$COPR,
        T$COOP,
        T$AMNT,
        T$LDAM,
        T$ODAM,
        T$CONO,
        T$POSI,
        T$MATC,
        T$COMP,
        T$FICO,
        T$TXTA,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('ODS__BAAN_TEE__TTDPUR045200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data