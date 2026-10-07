/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.38"
*************/

{{ config(
      materialized='view',
      alias='INFOTYPES',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        INFTY,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__INFOTYPES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data