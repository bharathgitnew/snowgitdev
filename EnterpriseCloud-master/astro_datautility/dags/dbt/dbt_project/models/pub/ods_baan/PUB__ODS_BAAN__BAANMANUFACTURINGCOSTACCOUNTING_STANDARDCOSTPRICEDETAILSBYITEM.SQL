/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.16"
*************/

{{ config(
      materialized='view',
      alias='BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICEDETAILSBYITEM',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADDEDAMOUNT_FIXEDPART1,
        ADDEDAMOUNT_FIXEDPART2,
        ADDEDAMOUNT_FIXEDPART3,
        ADDEDAMOUNT_VARIABLEPART1,
        ADDEDAMOUNT_VARIABLEPART2,
        ADDEDAMOUNT_VARIABLEPART3,
        COSTCOMPONENT,
        EFFECTIVEDATE,
        ITEM,
        NUMBEROFUNITS,
        TOTALAMOUNT_FIXEDPART1,
        TOTALAMOUNT_FIXEDPART2,
        TOTALAMOUNT_FIXEDPART3,
        TOTALAMOUNT_VARIABLEPART1,
        TOTALAMOUNT_VARIABLEPART2,
        TOTALAMOUNT_VARIABLEPART3
    from {{ ref('ODS__BAAN__BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICEDETAILSBYITEM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data