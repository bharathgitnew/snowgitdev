{{ config(
      materialized='view',
      alias='Timecard_TEE',
      transient=false
) }}

with source_data as (
    select * from {{ ref('ODS__KRONOS__TIMECARD_TEE') }}
),
transform_data AS
(
	select * from source_data
)
select * from transform_data