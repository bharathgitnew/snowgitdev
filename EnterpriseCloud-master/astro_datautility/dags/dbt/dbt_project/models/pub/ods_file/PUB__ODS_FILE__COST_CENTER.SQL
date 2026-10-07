/************
Model file generated from dbtGeneratePubViews: 03.03.2023.17.17.59"
*************/

{{ config(
      materialized='view',
      alias='COST_CENTER',
      transient=false
) }}

with source_data as (
    SELECT
        COST_CENTER_CODE,
        COST_CENTER_NAME,
        SEGMENT_CODE
        SEGMENT,
        DEPARTMENT_CODE,
        DEPARTMENT,
        OFFICE_CODE,
        OFFICE,
        _FILEDATE
    from {{ ref('ODS__FILE__COST_CENTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data