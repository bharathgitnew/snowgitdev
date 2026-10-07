/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.20"
*************/

{{ config(
      materialized='view',
      alias='EMPLOYEE_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
        EMPLOYEETYPEID,
        NAME,
        NAMEFST
    from {{ ref('ODS__MDM__EMPLOYEE_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data