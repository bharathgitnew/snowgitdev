/************
Model file generated from dbtGeneratePubViews: 06.15.2023.06.46.07"
*************/

{{ config(
      materialized='view',
      alias='TTDSLS045200',
      transient=false
) }}

with source_data as (
    SELECT
        T$ORNO,
        T$PONO,
        T$SRNB,
        T$CUNO,
        T$CPRJ,
        T$ITEM,
        T$CNTR,
        T$CWAR,
        T$CPCP,
        T$DDAT,
        T$OQUA,
        T$DQUA,
        T$BQUA,
        T$RECQ,
        T$PINO,
        T$DINO,
        T$INVD,
        T$INVN,
        T$TTYP,
        T$FONO,
        T$TORN,
        T$TPON,
        T$TSRN,
        T$SSLS,
        T$PMSK,
        T$COPR,
        T$COOP,
        T$PRIC,
        T$DISC_1,
        T$DISC_2,
        T$DISC_3,
        T$DAMT_1,
        T$DAMT_2,
        T$DAMT_3,
        T$AMNT,
        T$LDAM,
        T$ODAM,
        T$RATS,
        T$RATF,
        T$CONO,
        T$POSI,
        T$OPRI,
        T$TXAM_L,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('COMMON__BAAN_TEE__TTDSLS045200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data