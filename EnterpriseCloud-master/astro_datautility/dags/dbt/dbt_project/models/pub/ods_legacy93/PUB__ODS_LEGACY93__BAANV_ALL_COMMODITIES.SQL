/************
Model file generated from dbtGeneratePubViews: 10.12.2022.17.09.23"
*************/

{{ config(
      materialized='view',
      alias='BAANV_ALL_COMMODITIES',
      transient=false
) }}

with source_data as (
    SELECT
        COMPANY_NO,
        COMMODITY_CODE,
        DESCRIPTION
    from {{ ref('ODS__LEGACY93__BAANV_ALL_COMMODITIES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data