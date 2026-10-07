/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.57.00"
*************/

{{ config(
      materialized='view',
      alias='OFFICE',
      transient=false
) }}

with source_data as (
    SELECT
        COMPANYID,
        OFFICEID,
        OFFICENAME,
        SERVICECENTERID,
        ISDEFAULT
    from {{ ref('COMMON__BAAN__OFFICE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data