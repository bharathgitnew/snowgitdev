/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.17"
*************/

{{ config(
      materialized='view',
      alias='ARIBASECURITY',
      transient=false
) }}

with source_data as (
    SELECT
        EMPLOYEE_ID_CODE,
        DEPARTMENT_CODE,
        SEGMENT_CODE
    from {{ ref('ODS__MDM__ARIBASECURITY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data