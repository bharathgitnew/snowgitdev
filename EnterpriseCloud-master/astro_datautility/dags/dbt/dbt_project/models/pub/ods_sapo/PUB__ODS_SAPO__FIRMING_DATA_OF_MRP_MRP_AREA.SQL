/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.44"
*************/

{{ config(
      materialized='view',
      alias='FIRMING_DATA_OF_MRP_MRP_AREA',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        MATNR,
        BERID,
        PLSCN,
        OPFDT,
        MFXDT,
        MFNAM,
        MFDAT,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__FIRMING_DATA_OF_MRP_MRP_AREA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data