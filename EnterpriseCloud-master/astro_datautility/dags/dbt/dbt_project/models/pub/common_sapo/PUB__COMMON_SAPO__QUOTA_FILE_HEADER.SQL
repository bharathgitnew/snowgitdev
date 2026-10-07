{{ config(
        materialized='view',
         alias='QUOTA_FILE_HEADER',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		MATERIAL_NUMBER,
		PLANT,
		QUOTA_ARRANGEMENT_PERIOD_VALID_UNTIL,
		QUOTA_ARRANGEMENT_PERIOD_VALID_FROM,
		NUMBER_OF_QUOTA_ARRANGEMENT,
		DATE_ON_WHICH_RECORD_WAS_CREATED,
		NAME_OF_PERSON_WHO_CREATED_THE_OBJECT,
		MINIMUM_QUANTITY_FOR_SPLITTING_QUOTA,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__QUOTA_FILE_HEADER') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data