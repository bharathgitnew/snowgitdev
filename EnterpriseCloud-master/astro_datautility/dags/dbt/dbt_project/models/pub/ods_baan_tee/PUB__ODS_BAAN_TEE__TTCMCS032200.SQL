/************
Model file generated from dbtGeneratePubViews: 06.15.2023.05.36.10"
*************/

{{ config(
      materialized='view',
      alias='TTCMCS032200',
      transient=false
) }}

with source_data as (
    SELECT
        T$CCTY,
        T$CVAT,
        T$EDAT,
        T$PVAT,
        T$AMXT_L,
        T$ATXB_L,
        T$PEXT_L,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('ODS__BAAN_TEE__TTCMCS032200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data