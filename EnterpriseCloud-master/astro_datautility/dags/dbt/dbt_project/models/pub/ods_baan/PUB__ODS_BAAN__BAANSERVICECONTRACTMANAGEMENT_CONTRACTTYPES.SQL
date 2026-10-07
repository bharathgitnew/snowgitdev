/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.20"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONTRACTMANAGEMENT_CONTRACTTYPES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CONTRACTTYPE,
        DESCRIPTION,
        TAXINDICATORDESCRIPTION,
        TAXINDICATORID
    from {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_CONTRACTTYPES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data