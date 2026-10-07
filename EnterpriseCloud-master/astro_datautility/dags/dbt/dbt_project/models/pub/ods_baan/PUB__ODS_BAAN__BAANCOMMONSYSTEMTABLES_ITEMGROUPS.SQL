/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.01"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_ITEMGROUPS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        COSTSTOBESPECIFIEDDESCRIPTION,
        COSTSTOBESPECIFIEDID,
        CURRENCY,
        DESCRIPTION,
        ITEMGROUP
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_ITEMGROUPS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data