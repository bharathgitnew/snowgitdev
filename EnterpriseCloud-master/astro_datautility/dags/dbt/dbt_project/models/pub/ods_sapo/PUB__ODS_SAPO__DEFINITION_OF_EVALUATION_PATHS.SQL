/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.36"
*************/

{{ config(
      materialized='view',
      alias='DEFINITION_OF_EVALUATION_PATHS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        WEGID,
        WEGNR,
        OTYPE,
        RSIGN,
        RELAT,
        PRIOX,
        SCLAS,
        SKIPF,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__DEFINITION_OF_EVALUATION_PATHS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data