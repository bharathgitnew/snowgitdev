{{ config(
      materialized='view',
      alias='ActivitiesTotal',
      transient=false
) }}

with source_data as (
    select 
      * exclude(_AUDIT_LOG_ID, _ROW_HASH, _FILENAME, _UPLOADDATE)
    from {{ ref('ODS__KRONOS__ACTIVITIESTOTAL') }}
),
transform_data AS
(
	select * from source_data
)
select * from transform_data