/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.12"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_DIMENSIONLEDGERACCOUNTTOTALS_DATAWAREHOUSE',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CLOSINGBALANCE,
        COMPANYNUMBER,
        DIMENSION1,
        DIMENSION2,
        DIMENSION3,
        DIMENSION4,
        DIMENSION5,
        DUALACCOUNTINGINDICATORDESCRIPTION,
        DUALACCOUNTINGINDICATORID,
        FINLCRAMOUNTCURRQUARTER,
        FINLCRAMOUNTPREVQUARTER,
        FINLDRAMOUNTCURRQUARTER,
        FINLDRAMOUNTPREVQUARTER,
        FISCALYEAR,
        LASTMAINTDATE,
        LASTMODIFICATIONBY,
        LEDGERACCOUNT,
        OPENINGBALANCE,
        PERIODNUMBER,
        PERIODTYPEDESCRIPTION,
        PERIODTYPEID
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONLEDGERACCOUNTTOTALS_DATAWAREHOUSE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data