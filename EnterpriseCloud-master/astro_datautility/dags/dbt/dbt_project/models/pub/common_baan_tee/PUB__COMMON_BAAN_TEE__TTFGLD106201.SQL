/************
Model file generated from dbtGeneratePubViews: 06.15.2023.06.46.10"
*************/

{{ config(
      materialized='view',
      alias='TTFGLD106201',
      transient=false
) }}

with source_data as (
    SELECT
        T$OTYP,
        T$ODOC,
        T$OLIN,
        T$OSRL,
        T$OSRN,
        T$OCMP,
        T$FTYP,
        T$FDOC,
        T$OYER,
        T$OBAT,
        T$LEAC,
        T$DCDT,
        T$TYP1,
        T$DIM1,
        T$TYP2,
        T$DIM2,
        T$TYP3,
        T$DIM3,
        T$TYP4,
        T$DIM4,
        T$TYP5,
        T$DIM5,
        T$REFR,
        T$AMNT,
        T$CCUR,
        T$RATE,
        T$FACT,
        T$AMTH,
        T$DBCR,
        T$CCTY,
        T$CVAT,
        T$VTYP,
        T$VLAC,
        T$VAMT,
        T$VAMH,
        T$QTY1,
        T$QTY2,
        T$FPRD,
        T$FYER,
        T$RPRD,
        T$RYER,
        T$VPRD,
        T$VYER,
        T$CUNO,
        T$SUNO,
        T$CATG,
        T$USER,
        T$DATE,
        T$TIME,
        T$TRUN,
        T$CONT,
        T$CTYP,
        T$CINV,
        T$CORN,
        T$CSRN,
        T$TCSH,
        T$TRAN,
        T$TXTA,
        T$DELE,
        T$INTT,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('COMMON__BAAN_TEE__TTFGLD106201') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data