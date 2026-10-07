{{ config(
      materialized='view',
      alias='DAYS_OF_INVENTORY_MASTER',
      transient=false
) }}

with source_data as (
    SELECT
        MATERIAL
        , PLANT
        , STORAGE_LOCATION
        , ON_HAND
        , mth1
        , mth2
        , mth3
        , mth4
        , mth5
        , mth6
        , mth7
        , mth8
        , mth9
        , mth10
        , mth11
        , mth12
        , DOI_12_months
        , DOI_3_months
        , SALES_INTEL_FLAG
        , INV_INTEL_FLAG
    FROM {{ ref('COMMON__SAPH__DAYS_OF_INVENTORY_MASTER') }}
),

transform_data as (
    SELECT
        *
    FROM source_data
),

type_data as (
    SELECT
        *
    FROM transform_data
)

SELECT * FROM type_data