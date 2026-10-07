/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.22"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONTRACTMANAGEMENT_TERMS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CONFIGURATION,
        COSTAMOUNT1,
        COSTAMOUNT2,
        COSTAMOUNT3,
        COSTTYPEDESCRIPTION,
        COSTTYPEID,
        GROSSMARGIN,
        REQUIREDCOST1,
        REQUIREDCOST2,
        REQUIREDCOST3,
        REQUIREDSALES,
        SALESAMOUNT,
        SERVICETYPE,
        SPENTCOSTS1,
        SPENTCOSTS2,
        SPENTCOSTS3,
        SPENTSALES,
        TERMID,
        TOTALWARRANTYDISCOUNTAMOUNT,
        TYPEOFLINEDESCRIPTION,
        TYPEOFLINEID
    from {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_TERMS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data