/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.17"
*************/

{{ config(
      materialized='view',
      alias='BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICESBYITEM',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AMOUNT1,
        AMOUNT2,
        AMOUNT3,
        COSTCOMPONENT,
        EFFECTIVEDATE,
        ITEM,
        NUMBEROFUNITS
    from {{ ref('ODS__BAAN__BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICESBYITEM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data