/************
Model file generated from dbtGeneratePubViews: 06.15.2023.05.36.12"
*************/

{{ config(
      materialized='view',
      alias='TTFACR400203',
      transient=false
) }}

with source_data as (
    SELECT
        T$TTYP,
        T$NINV,
        T$CUNO,
        T$CCUR,
        T$RATE,
        T$RATF,
        T$CPAY,
        T$CCRS,
        T$ADRS,
        T$VATC,
        T$CCTY,
        T$CLAN,
        T$REFR,
        T$INVD,
        T$OTYP,
        T$OINV,
        T$INST,
        T$PAYM,
        T$COPY,
        T$TEXT,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('ODS__BAAN_TEE__TTFACR400203') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data