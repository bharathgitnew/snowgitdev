/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.16"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DIMENSIONCODE,
        DIMENSIONTYPE,
        ENUMVALUE1ADESCRIPTION,
        ENUMVALUE1AID,
        INTEGRATIONELEMENT,
        INTEGRATIONPRIORITY,
        LOGISTICCOMPANY,
        LONGVALUE1,
        STRINGVALUE1
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data