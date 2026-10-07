/************
Model file generated from dbtGeneratePubViews: 03.03.2023.17.17.59"
*************/

{{ config(
      materialized='view',
      alias='PROFIT_CENTER',
      transient=false
) }}

with source_data as (
    SELECT
        PROFIT_CENTER_CODE,
        PROFIT_CENTER_NAME,
        SEGMENT_CODE,
        SEGMENT,
        DEPARTMENT_CODE,
        DEPARTMENT,
        OFFICE_CODE,
        OFFICE,
        NOTES,
        _FILEDATE
    from {{ ref('ODS__FILE__PROFIT_CENTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data