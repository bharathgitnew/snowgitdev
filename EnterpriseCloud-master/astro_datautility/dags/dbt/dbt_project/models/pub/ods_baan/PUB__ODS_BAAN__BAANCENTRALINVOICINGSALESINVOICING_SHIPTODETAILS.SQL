/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.55"
*************/

{{ config(
      materialized='view',
      alias='BAANCENTRALINVOICINGSALESINVOICING_SHIPTODETAILS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        SHIPTOBPFROMARIBA,
        SHIPTOBPFROMBAAN
    from {{ ref('ODS__BAAN__BAANCENTRALINVOICINGSALESINVOICING_SHIPTODETAILS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data