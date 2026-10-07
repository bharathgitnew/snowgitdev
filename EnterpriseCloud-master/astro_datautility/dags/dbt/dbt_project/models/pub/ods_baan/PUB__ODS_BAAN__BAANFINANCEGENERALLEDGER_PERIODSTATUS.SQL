/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.15"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_PERIODSTATUS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        FISCALYEAR,
        PERIODNUMBER,
        PERIODTYPEDESCRIPTION,
        PERIODTYPEID,
        STATUSOFACPDESCRIPTION,
        STATUSOFACPID,
        STATUSOFACRMODULEDESCRIPTION,
        STATUSOFACRMODULEID,
        STATUSOFCMGMODULEDESCRIPTION,
        STATUSOFCMGMODULEID,
        STATUSOFGLDDESCRIPTION,
        STATUSOFGLDID,
        STATUSOFINTEGRATIONDESCRIPTION,
        STATUSOFINTEGRATIONID
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_PERIODSTATUS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data