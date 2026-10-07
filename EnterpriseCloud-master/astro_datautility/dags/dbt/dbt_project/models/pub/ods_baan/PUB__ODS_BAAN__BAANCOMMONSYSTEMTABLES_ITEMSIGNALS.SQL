/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.02"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_ITEMSIGNALS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION,
        ITEMSIGNAL,
        PROCESSISSUEDESCRIPTION,
        PROCESSISSUEID,
        PRODUCTIONISSUEDESCRIPTION,
        PRODUCTIONISSUEID,
        PURCHASE_PERCENT_BLOCKINGSTATUSDESCRIPTION,
        PURCHASE_PERCENT_BLOCKINGSTATUSID,
        REQUISITIONTHROUGHPRODUCTIONDESCRIPTION,
        REQUISITIONTHROUGHPRODUCTIONID,
        SALES_PERCENT_BLOCKINGSTATUSDESCRIPTION,
        SALES_PERCENT_BLOCKINGSTATUSID,
        SERVICEDESCRIPTION,
        SERVICEID
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_ITEMSIGNALS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data