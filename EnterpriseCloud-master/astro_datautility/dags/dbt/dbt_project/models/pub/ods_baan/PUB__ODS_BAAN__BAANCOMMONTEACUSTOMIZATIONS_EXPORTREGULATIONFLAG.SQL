/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.04"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONTEACUSTOMIZATIONS_EXPORTREGULATIONFLAG',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION,
        EXPORTREGULATIONFLAGIPDB
    from {{ ref('ODS__BAAN__BAANCOMMONTEACUSTOMIZATIONS_EXPORTREGULATIONFLAG') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data