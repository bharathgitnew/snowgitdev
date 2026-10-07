/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.02"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_PRICELISTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CURRENCY,
        DESCRIPTION,
        PRICELIST
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_PRICELISTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data