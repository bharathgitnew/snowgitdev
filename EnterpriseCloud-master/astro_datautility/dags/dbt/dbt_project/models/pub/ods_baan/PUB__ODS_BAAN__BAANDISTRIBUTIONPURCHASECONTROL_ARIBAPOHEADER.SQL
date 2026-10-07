/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.06"
*************/

{{ config(
      materialized='view',
      alias='BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOHEADER',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADVANCEDSHIPNOTICE,
        CLOSEDPOSTATUS,
        COMMENTS,
        COMPANYCODE,
        DELIVERYDATE,
        EVENTDATE,
        EVENTSTATUS,
        EVENTTYPE,
        LASTMODIFIEDBY,
        LASTMODIFIEDDATE,
        ORIGNATINGSYSTEM,
        ORIGNATINGSYSTEMREFID,
        PAYMENTTERMS,
        PROCUREMENTUNIT,
        PURCHASEORDERNO,
        SHIPMENTIDENTIFIER,
        SHIPNOTICEDATE,
        SHIPPINGCARRIER,
        SUPPLIER,
        SUPPLIERLOCATION,
        TITLE,
        UNIQUENAME,
        VERSION
    from {{ ref('ODS__BAAN__BAANDISTRIBUTIONPURCHASECONTROL_ARIBAPOHEADER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data