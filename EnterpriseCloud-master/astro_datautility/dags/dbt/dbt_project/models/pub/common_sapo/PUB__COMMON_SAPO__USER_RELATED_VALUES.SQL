{{ config(
        materialized='view',
         alias='USER_RELATED_VALUES',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		OBJECT_TYPE_PROGRAM_CLASS,
		OBJECT_NAME_PARAMETER,
		USER_NAME,
		USER_VALUES,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__USER_RELATED_VALUES') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data