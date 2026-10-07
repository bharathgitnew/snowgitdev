/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.41.24"
*************/

{{ config(
      materialized='view',
      alias='PAID_SERVICE_CUSTOMER_PO',
      transient=false
) }}

with source_data as (
    SELECT
        PONUMBER2,
        PONUMBER2SO,
        PONUMBER,
        CUSTOMERGROUP,
        FAB2PARENTCUSTOMERNAME,
        BUSINESSISSUINGPO,
        PODATE,
        WORKSTART,
        PLANNEDENDDATE,
        BU,
        FAB,
        CONFIG,
        SITESUPERVISOR,
        POAMOUNT,
        RECEIVEDDATE,
        POTYPE,
        POSTATUS,
        QUOTE,
        PODESCRIPTION,
        CORRECTPAYMENTTERMS,
        ISSUEDTOTEA,
        SIGCOMMENTS,
        QUOTEREQUESTORNAME,
        QUOTEREQUESTORSUPERVISOR,
        TEHHR,
        QUOTENUMBERLOOKUP,
        QUOTENUMBERLOOKUPREQUESTORNAME,
        QUOTENUMBERLOOKUPREQUESTORSUPERVISOR,
        QUOTENUMBERLOOKUPSTART,
        QUOTENUMBERLOOKUPEND,
        QUOTENUMBERLOOKUPCUSTOMER,
        QUOTENUMBERLOOKUPFABLOCATION,
        QUOTENUMBERLOOKUPPRODUCTLINE,
        QUOTENUMBERLOOKUPCONFIG,
        QUOTENUMBERLOOKUPBUYER,
        REVISEDPODATE,
        REVISEDPOAMOUNT
    from {{ ref('ODS__SHAREPOINT__PAID_SERVICE_CUSTOMER_PO') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data