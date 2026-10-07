/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.10"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEFINANCIALSTATEMENTS_STATEMENTACCOUNTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCOUNTDESCRIPTION,
        ACCOUNTTYPEDESCRIPTION,
        ACCOUNTTYPEID,
        APPLYDEBITCREDITSIGNSWITCHDESCRIPTION,
        APPLYDEBITCREDITSIGNSWITCHID,
        FINANCIALSTATEMENT,
        FORMULAREFACCOUNTA,
        FORMULAREFACCOUNTB,
        PARENTSTATEMENTACCOUNT,
        PLUSMINUSDESCRIPTION,
        PLUSMINUSID,
        STATEMENTACCOUNT,
        SUBLEVEL
    from {{ ref('ODS__BAAN__BAANFINANCEFINANCIALSTATEMENTS_STATEMENTACCOUNTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data