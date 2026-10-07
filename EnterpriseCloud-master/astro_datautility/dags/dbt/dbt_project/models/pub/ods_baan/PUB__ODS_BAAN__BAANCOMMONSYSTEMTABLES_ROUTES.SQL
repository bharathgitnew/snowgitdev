/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.03"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_ROUTES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DAYDESCRIPTION,
        DAYID,
        DESCRIPTION,
        ROUTE
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_ROUTES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data