/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.12"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DIMENSIONDESCRIPTION,
        DIMENSIONTYPE,
        SHORTDESCRIPTION
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data