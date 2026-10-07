/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.10"
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
        ACTIVEINDICATOR
    from {{ ref('COMMON__MDM__COMPANY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data