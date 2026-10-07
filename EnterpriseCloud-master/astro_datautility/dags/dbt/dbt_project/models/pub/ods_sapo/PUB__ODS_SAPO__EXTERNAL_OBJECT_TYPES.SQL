/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.44"
*************/

{{ config(
      materialized='view',
      alias='EXTERNAL_OBJECT_TYPES',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        OTYPE,
        PKSUB,
        DYNNR,
        PROG,
        INREL,
        SOTYP,
        BIRTH,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__EXTERNAL_OBJECT_TYPES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data