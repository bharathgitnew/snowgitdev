/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.10"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEFINANCIALSTATEMENTS_STATEMENTLEDGERDIMENSIONACCOUNTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        COMPANYMASK,
        DIMENSIONMASK1,
        DIMENSIONMASK2,
        DIMENSIONMASK3,
        DIMENSIONMASK4,
        DIMENSIONMASK5,
        FINANCIALSTATEMENT,
        FROMCOMPANY,
        FROMDIMENSION1,
        FROMDIMENSION2,
        FROMDIMENSION3,
        FROMDIMENSION4,
        FROMDIMENSION5,
        FROMLEDGERACCOUNT,
        LEDGERACCOUNTMASK,
        SEQUENCENUMBER,
        STATEMENTACCOUNT,
        TOCOMPANY,
        TODIMENSION1,
        TODIMENSION2,
        TODIMENSION3,
        TODIMENSION4,
        TODIMENSION5,
        TOLEDGERACCOUNT
    from {{ ref('ODS__BAAN__BAANFINANCEFINANCIALSTATEMENTS_STATEMENTLEDGERDIMENSIONACCOUNTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data