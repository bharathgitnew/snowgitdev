/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.52"
*************/

{{ config(
      materialized='view',
      alias='TIME_TYPES',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        MOBDE,
        ZTART,
        ENDDA,
        BEGDA,
        MOSUM,
        VORMO,
        EISUM,
        JAUEB,
        SAKOR,
        ZTNXP,
        ZTNXY,
        B1SUM,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__TIME_TYPES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data