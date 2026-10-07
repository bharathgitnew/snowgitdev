/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.15"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_PERIODS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CORRECTIONPERIODDESCRIPTION,
        CORRECTIONPERIODID,
        DESCRIPTION,
        PERIOD,
        PERIODSTARTDATE,
        PERIODTYPEDESCRIPTION,
        PERIODTYPEID,
        YEAR
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_PERIODS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data