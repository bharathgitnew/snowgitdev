/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.59"
*************/

{{ config(
      materialized='view',
      alias='EMPLOYEE',
      transient=false
) }}

with source_data as (
    SELECT
        EMPLOYEEID,
        FULLNAME
    from {{ ref('COMMON__BAAN__EMPLOYEE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data