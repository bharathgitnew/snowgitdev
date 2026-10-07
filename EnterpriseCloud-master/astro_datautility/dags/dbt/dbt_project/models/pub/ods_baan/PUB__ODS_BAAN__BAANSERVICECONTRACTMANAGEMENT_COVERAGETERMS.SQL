/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.21"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONTRACTMANAGEMENT_COVERAGETERMS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ALLOCATEDCOSTS1,
        ALLOCATEDCOSTS2,
        ALLOCATEDCOSTS3,
        ALLOCATEDDISCOUNT,
        ALLOCATEDSALES,
        CEILINGAMOUNT,
        CONFIGURATION,
        CONTRACTTERM,
        COSTAMOUNT1,
        COSTAMOUNT2,
        COSTAMOUNT3,
        COSTCOVERINGMETHODDESCRIPTION,
        COSTCOVERINGMETHODID,
        COSTTYPEDESCRIPTION,
        COSTTYPEID,
        COVERAGETERMNUMBER,
        DISCOUNT,
        ENDDATE,
        LIMITINGCOUNTERVALUE,
        MODELITEM,
        NUMBEROFPERIODS,
        PERIODUNITDESCRIPTION,
        PERIODUNITID,
        REQUIREDCOST1,
        REQUIREDCOST2,
        REQUIREDCOST3,
        REQUIREDSALES,
        SALESAMOUNT,
        SERVICETYPE,
        SPENTCOSTS1,
        SPENTCOSTS2,
        SPENTCOSTS3,
        SPENTDISCOUNT,
        SPENTSALES,
        STATISTICALDATA,
        TERMID,
        TEXT
    from {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_COVERAGETERMS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data