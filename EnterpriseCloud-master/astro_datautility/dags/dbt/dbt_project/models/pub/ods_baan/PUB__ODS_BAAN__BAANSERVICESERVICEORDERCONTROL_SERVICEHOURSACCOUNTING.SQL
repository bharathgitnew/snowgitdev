/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.23"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICESERVICEORDERCONTROL_SERVICEHOURSACCOUNTING',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        COSTCOMPONENT,
        COSTRATE1,
        COSTRATE2,
        COSTRATE3,
        COSTTYPEDESCRIPTION,
        COSTTYPEID,
        EMPLOYEE,
        HOURLYLABORTYPE,
        LABORLINE,
        LINENUMBER,
        REGISTRATIONDATE,
        SALESRATE,
        SERVICECENTER,
        SERVICEORDER,
        SPENTTIME,
        TASK,
        TRANSACTIONDATE,
        TRAVELLINE,
        TSSOC210ACLN,
        WEEK,
        YEARNUMBER
    from {{ ref('ODS__BAAN__BAANSERVICESERVICEORDERCONTROL_SERVICEHOURSACCOUNTING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data