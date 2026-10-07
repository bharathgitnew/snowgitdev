/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.55"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_BBBREPORT_TEMPDATA',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCRUALAMOUNT,
        ASONDATE,
        BEGINBACKLOG,
        BILLINGAMOUNT,
        BOOKINGAMOUNTGROSS,
        BOOKINGCHANGES,
        BUSINESSUNIT,
        CANCELAMOUNT,
        CUSTOMER,
        CUSTOMERGROUP,
        DATASOURCEDESCRIPTION,
        DATASOURCEID,
        DATEOFUPDATE,
        DISCOUNTAMOUNTAPPLIED,
        ENDINGBACKLOGAMOUNT,
        ITEM,
        ORDER_NUMBER,
        POSITION,
        REMARKS,
        SEQUENCE,
        TRANSACTIONDATE,
        USER
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_BBBREPORT_TEMPDATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data