/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.00"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_AREAS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AREA,
        DESCRIPTION,
        SERVICEOFFICE
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_AREAS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data