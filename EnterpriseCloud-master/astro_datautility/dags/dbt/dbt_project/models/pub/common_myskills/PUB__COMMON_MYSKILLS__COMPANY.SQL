/************
Model file generated from dbtGeneratePubViews: 04.13.2022.12.48.52"
*************/

{{ config(
      materialized='view',
      alias='COMPANY',
      transient=false
) }}

with source_data as (
    SELECT
        COMPANYID,
        NAME,
        SHORTNAME,
        COUNTRYCODE
    from {{ ref('COMMON__MYSKILLS__COMPANY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data