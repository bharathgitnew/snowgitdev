/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.13"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_FINANCIALCOMPANIESBYGROUPCOMPANY',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        COMPANYNUMBER,
        PRIORITYNUMBER
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_FINANCIALCOMPANIESBYGROUPCOMPANY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data