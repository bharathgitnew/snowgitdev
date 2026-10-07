/************
Model file generated from dbtGeneratePubViews: 06.15.2023.06.46.06"
*************/

{{ config(
      materialized='view',
      alias='TTCMCS030200',
      transient=false
) }}

with source_data as (
    SELECT
        T$SKLL,
        T$DESC,
        T$REFCNTD,
        T$REFCNTU,
        _CAPTUREDATETIME,
        _INTEGRATEDATETIME,
        _INTEGRATIONKEY,
        _TRANSACTIONTYPE
    from {{ ref('COMMON__BAAN_TEE__TTCMCS030200') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data