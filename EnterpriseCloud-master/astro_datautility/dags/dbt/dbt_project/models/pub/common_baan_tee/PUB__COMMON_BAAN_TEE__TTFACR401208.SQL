/************
Model file generated from dbtGeneratePubViews: 06.15.2023.06.46.08"
*************/

{{ config(
      materialized='view',
      alias='TTFACR401208',
      transient=false
) }}

with source_data as (
    SELECT
        T$TTYP,
        T$NINV,
        T$LINO,
        T$QUAN,
        T$CUNI,
        T$DESC,
        T$PRIC,
        T$AMNT,
        T$VATC,
        T$CVAT,
        T$VAMT,
        T$LEAC,
        T$VAMH,
        T$DIM1,
        T$DIM2,
        T$DIM3,
        T$DIM4,
        T$DIM5,
        T$TYP1,
        T$TYP2,
        T$TYP3,
        T$TYP4,
        T$TYP5,
        T$TEXT,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('COMMON__BAAN_TEE__TTFACR401208') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data