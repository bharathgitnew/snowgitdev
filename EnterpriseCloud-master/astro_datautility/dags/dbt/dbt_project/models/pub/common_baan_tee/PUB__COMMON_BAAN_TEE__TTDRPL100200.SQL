/************
Model file generated from dbtGeneratePubViews: 06.15.2023.06.46.10"
*************/

{{ config(
      materialized='view',
      alias='TTDRPL100200',
      transient=false
) }}

with source_data as (
    SELECT
        T$ORNO,
        T$PONO,
        T$SRNB,
        T$ITEM,
        T$CNTR,
        T$REVI,
        T$CLOT,
        T$DATE,
        T$DWAR,
        T$DPRJ,
        T$DLOC,
        T$DSPA,
        T$DPLA,
        T$DACT,
        T$DSTL,
        T$DCCO,
        T$ODAT,
        T$PDDT,
        T$RDDT,
        T$PRDT,
        T$RRDT,
        T$RWAR,
        T$RPRJ,
        T$RLOC,
        T$RSPA,
        T$RPLA,
        T$RACT,
        T$RSTL,
        T$RCCO,
        T$TWAR,
        T$CUNI,
        T$CONV,
        T$OQUA,
        T$DQUA,
        T$BQUA,
        T$PQUA,
        T$RECQ,
        T$COTP,
        T$SRPL,
        T$PMSK,
        T$PINO,
        T$DINO,
        T$FONO,
        T$SORN,
        T$SPON,
        T$TORN,
        T$TPON,
        T$TSRN,
        T$CTRJ,
        T$TXTA,
        T$TXTB,
        T$EGEN,
        T$CRTE,
        T$ASHS,
        T$ASCS,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('COMMON__BAAN_TEE__TTDRPL100200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data