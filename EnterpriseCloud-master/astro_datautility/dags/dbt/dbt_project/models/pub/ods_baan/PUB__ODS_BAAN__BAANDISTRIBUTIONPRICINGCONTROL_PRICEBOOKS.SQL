/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.06"
*************/

{{ config(
      materialized='view',
      alias='BAANDISTRIBUTIONPRICINGCONTROL_PRICEBOOKS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        BASEPRICE,
        CURRENCY,
        DEFAULTPRICEBOOKDESCRIPTION,
        DEFAULTPRICEBOOKID,
        DISCOUNTSCHEDULE,
        DISCOUNTSCHEDULEORIGINDESCRIPTION,
        DISCOUNTSCHEDULEORIGINID,
        EFFECTIVEDATE,
        ENTRYDATE_PERCENT_TIME,
        EXPIRATIONDATE,
        ITEM,
        LASTCHANGE,
        LOGINCODE,
        MINIMUMQUANTITY,
        PRICEBOOK,
        PRICEBOOKORIGINDESCRIPTION,
        PRICEBOOKORIGINID,
        PRICEUNIT,
        QUANTITYUNITS,
        QUOTATIONSONLYDESCRIPTION,
        QUOTATIONSONLYID
    from {{ ref('ODS__BAAN__BAANDISTRIBUTIONPRICINGCONTROL_PRICEBOOKS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data