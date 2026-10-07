/************
Model file generated from dbtGeneratePubViews: 06.15.2023.05.36.13"
*************/

{{ config(
      materialized='view',
      alias='TTFGLD410200',
      transient=false
) }}

with source_data as (
    SELECT
        T$OCOM,
        T$TROR,
        T$FITR,
        T$TRDT,
        T$TRTM,
        T$SERN,
        T$LINE,
        T$TSLS,
        T$TTYP,
        T$DOCN,
        T$FCOM,
        T$CUNO,
        T$SUNO,
        T$LEAC,
        T$DIM1,
        T$DIM2,
        T$DIM3,
        T$DIM4,
        T$DIM5,
        T$FYER,
        T$FPRD,
        T$VYER,
        T$VPRD,
        T$RYER,
        T$RPRD,
        T$DCDT,
        T$CCUR,
        T$RATE,
        T$FACT,
        T$AMNT,
        T$AMTH,
        T$DBCR,
        T$REFR,
        T$CCTY,
        T$CVAT,
        T$VTYP,
        T$VAMT,
        T$VAMH,
        T$QTY1,
        T$QTY2,
        T$NUNI,
        T$CUNI,
        T$CRUS,
        T$CRDT,
        T$CRTM,
        T$ORNO,
        T$PONO,
        T$SRNO,
        T$CPCP,
        T$CWAR,
        T$ITEM,
        T$CPRJ,
        T$NPER,
        T$SINT,
        T$BTNO,
        T$LINO,
        T$POUS,
        T$PODT,
        T$POTM,
        T$TMPK,
        T$INPO,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('ODS__BAAN_TEE__TTFGLD410200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data