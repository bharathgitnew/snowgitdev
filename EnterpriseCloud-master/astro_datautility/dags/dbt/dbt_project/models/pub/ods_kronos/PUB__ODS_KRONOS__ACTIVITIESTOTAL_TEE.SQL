{{ config(
      materialized='view',
      alias='ActivitiesTotal_TEE',
      transient=false
) }}

with source_data as (
    select * from {{ ref('ODS__KRONOS__ACTIVITIESTOTAL_TEE') }}
),
transform_data AS
(
	select * from source_data
)
select * from transform_data