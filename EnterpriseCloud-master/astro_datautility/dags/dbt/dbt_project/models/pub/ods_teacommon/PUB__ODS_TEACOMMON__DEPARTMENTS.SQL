{{ config(
      materialized='view',
      alias='DEPARTMENTS',
      transient=false
) }}

with source_data as (
    SELECT
        companyid,
        deptcode,
        description,
        abbreviation
    from {{ ref('ODS__TEACOMMON__DEPARTMENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data