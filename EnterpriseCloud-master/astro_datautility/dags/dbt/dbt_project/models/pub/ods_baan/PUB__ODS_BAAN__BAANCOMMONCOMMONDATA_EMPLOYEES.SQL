/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.56"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_EMPLOYEES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ADDRESSCODE,
        BILLINGRATE,
        CALENDARCODE,
        CIVILSTATUSDESCRIPTION,
        CIVILSTATUSID,
        COSTCOMPONENT,
        DATEOFBIRTH,
        DAYSBYWEEK,
        DEPARTMENT,
        E_MAIL,
        EMPLOYEE,
        EMPLOYMENT,
        FAX,
        FIRSTDATEOFEMPLOYMENT,
        FISCALNUMBER,
        HOURLYLABORRATE1,
        HOURLYLABORRATE2,
        HOURLYLABORRATE3,
        HOURSBYDAY,
        LANGUAGE,
        LASTDATEOFEMPLOYMENT,
        NAME,
        SEARCHKEY,
        SEXDESCRIPTION,
        SEXID,
        TELEPHONE,
        TELEPHONE2,
        TEXT,
        TRADEGROUP,
        WORKINGTIMETABLE
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_EMPLOYEES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data