/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.01"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_COMMODITIES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        COMMODITYCODE,
        DESCRIPTION
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_COMMODITIES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data