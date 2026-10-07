/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.21"
*************/

{{ config(
      materialized='view',
      alias='FINANCIALDEPARTMENT',
      transient=false
) }}

with source_data as (
    SELECT
        DEPARTMENTCODE,
        DEPARTMENTTYPE,
        BILLBACKTYPE,
        FUNCTIONALGROUP
    from {{ ref('ODS__MDM__FINANCIALDEPARTMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data