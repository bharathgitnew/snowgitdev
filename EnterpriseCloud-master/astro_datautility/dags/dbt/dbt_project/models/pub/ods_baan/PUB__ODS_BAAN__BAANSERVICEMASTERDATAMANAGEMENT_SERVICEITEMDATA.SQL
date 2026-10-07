/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.22"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICEMASTERDATAMANAGEMENT_SERVICEITEMDATA',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CURRENCY,
        DELIVERYTYPEDESCRIPTION,
        DELIVERYTYPEID,
        ITEM,
        LASTTRANSACTIONDATESERVICEPRICE,
        LIFECYCLE,
        LIFECYCLEUNIT,
        MAINTENANCECYCLE,
        MAINTENANCECYCLEUNIT,
        MEASUREMENTTYPE,
        OBJECTGROUP,
        OBJECTTYPEDESCRIPTION,
        OBJECTTYPEID,
        QUANTITYUNIT,
        REPAIRABLEDESCRIPTION,
        REPAIRABLEID,
        SALESPRICEUNIT,
        SEARCHARGUMENT,
        SERVICECENTER,
        SERVICEITEMGROUP,
        SERVICEKITTYPE,
        SERVICEPRICE,
        TAXCODE,
        TEXT,
        WARRANTY
    from {{ ref('ODS__BAAN__BAANSERVICEMASTERDATAMANAGEMENT_SERVICEITEMDATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data