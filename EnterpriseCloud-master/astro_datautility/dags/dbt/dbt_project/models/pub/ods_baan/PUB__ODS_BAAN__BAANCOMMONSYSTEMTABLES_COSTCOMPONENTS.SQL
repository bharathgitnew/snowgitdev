/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.01"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_COSTCOMPONENTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        COSTCOMPONENT,
        COSTTYPEDESCRIPTION,
        COSTTYPEID,
        DESCRIPTION
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_COSTCOMPONENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data