/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.06"
*************/

{{ config(
      materialized='view',
      alias='BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOLINEDETAILS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCOUNTCATERY,
        BILLINGADDRESS,
        COMMENTS,
        COMMODITYCODE,
        COMPANY,
        DELIVERYTO,
        ERPCOMMODITYCODE,
        ERSALLOWED,
        EXTERNALLINENO,
        ID,
        ISCOMPOSITE,
        ISTAXDEDUCTIBLE,
        ITEMCATERY,
        LASTMODIFIEDBY,
        LASTMODIFIEDDATE,
        LINEDESCRIPTION,
        LINENUMBER,
        LINETYPE,
        LINETYPECATERY,
        NEEDBY,
        NUMBERSHIPPED,
        PARENTLINENO,
        PRICE,
        PRICECURRENCY,
        PRICEINBASECURRENCY,
        PRICEUNIT,
        PRICEUNITQUANTITY,
        PRICINGDESCRIPTION,
        PURCHASEGROUP,
        PURCHASEORDERNO,
        PURCHASEORG,
        QUANTITY,
        REQUISITIONID,
        REQUISITIONREQUESTER,
        SHIPPINGADDRESS,
        SHORTNAME,
        SUPPLIERPARTAUXID,
        SUPPLIERPARTNUMBER,
        TAXABLEAMOUNT,
        TAXABLEAMOUNTCURRENCY,
        TAXABLEAMOUNTINBASECURRENCY,
        TAXCODE,
        TAXPERCENT,
        TAXPERUNIT,
        UNITCONVERSION,
        UNITOFMEASURE,
        UNITPRICECURRENCY,
        UNITPRICEINBASECURRENCY_UNBC,
        UNITPRICEINBASECURRENCY_UNPR,
        VERSION
    from {{ ref('ODS__BAAN__BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOLINEDETAILS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data