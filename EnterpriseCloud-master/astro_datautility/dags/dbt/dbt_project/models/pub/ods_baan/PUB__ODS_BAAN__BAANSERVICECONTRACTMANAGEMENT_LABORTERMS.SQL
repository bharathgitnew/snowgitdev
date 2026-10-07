/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.21"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONTRACTMANAGEMENT_LABORTERMS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ALLOCATEDCOSTS1,
        ALLOCATEDCOSTS2,
        ALLOCATEDCOSTS3,
        ALLOCATEDHOURS,
        ALLOCATEDSALES,
        CONFIGURATION,
        CONTRACTSEQNO,
        COSTAMOUNT1,
        COSTAMOUNT2,
        COSTAMOUNT3,
        COSTCOMPONENT,
        COSTRATE1,
        COSTRATE2,
        COSTRATE3,
        COSTTYPEDESCRIPTION,
        COSTTYPEID,
        COVERAGETERMNUMBER,
        COVEREDTIME,
        DERIVEDFROMSPCDESCRIPTION,
        DERIVEDFROMSPCID,
        HOURLYLABORTYPE,
        INCLUDEDDESCRIPTION,
        INCLUDEDID,
        LABORRATE,
        SALESAMOUNT,
        SALESRATE,
        SERVICETYPE,
        SPENTCOSTS1,
        SPENTCOSTS2,
        SPENTCOSTS3,
        SPENTHOURS,
        SPENTSALES,
        TASK,
        TERMID,
        TEXT
    from {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_LABORTERMS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data