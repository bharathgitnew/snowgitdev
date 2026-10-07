{{ config(
      materialized='view',
      alias='PRODUCTLINES',
      transient=false
) }}

with source_data as (
    SELECT
        CompanyID,
        ProdLineCode,
        Description
    from {{ ref('ODS__TEACOMMON__PRODUCTLINES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data