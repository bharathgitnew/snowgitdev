{{ config(
        materialized='view',
         alias='MENU_SCREEN_MODIFICATIONS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		SCREEN_MODIFICATION,
		SEQUENCE_NUMBER,
		DYNPRO_FIELD_NAME,
		REQUIRED_FIELD,
		FIELD_NOT_READY_FOR_INPUT,
		INVISIBLE_FIELD,
		HIGHLIGHTED_FIELD,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__MENU_SCREEN_MODIFICATIONS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data