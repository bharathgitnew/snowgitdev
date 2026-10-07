/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.03"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_SELECTIONCODES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION,
        SELECT_
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_SELECTIONCODES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data