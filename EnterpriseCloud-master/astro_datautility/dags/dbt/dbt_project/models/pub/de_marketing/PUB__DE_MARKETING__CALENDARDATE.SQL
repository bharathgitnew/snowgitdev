{{ config(
      materialized='view',
      alias='CALENDARDATE',
      transient=false
) }}

with source_data as (
    SELECT
        * 
    from {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data