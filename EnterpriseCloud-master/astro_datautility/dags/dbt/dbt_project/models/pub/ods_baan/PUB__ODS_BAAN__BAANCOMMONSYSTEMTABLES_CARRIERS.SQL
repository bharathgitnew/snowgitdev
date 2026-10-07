/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.00"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_CARRIERS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        BUYFROMBUSINESSPARTNER,
        CARRIER,
        DESCRIPTION,
        STANDARDCARRIERALPHACODE,
        TRANSPORTCATERYDESCRIPTION,
        TRANSPORTCATERYID
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_CARRIERS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data