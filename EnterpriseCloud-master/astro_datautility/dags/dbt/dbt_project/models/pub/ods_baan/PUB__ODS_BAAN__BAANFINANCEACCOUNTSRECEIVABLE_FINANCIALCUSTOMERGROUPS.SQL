/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.08"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEACCOUNTSRECEIVABLE_FINANCIALCUSTOMERGROUPS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION,
        FINANCIALBPGROUPAR,
        TEXT
    from {{ ref('ODS__BAAN__BAANFINANCEACCOUNTSRECEIVABLE_FINANCIALCUSTOMERGROUPS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data