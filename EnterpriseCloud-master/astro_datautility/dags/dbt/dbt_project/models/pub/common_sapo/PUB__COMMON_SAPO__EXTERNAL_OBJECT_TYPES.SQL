{{ config(
        materialized='view',
         alias='EXTERNAL_OBJECT_TYPES',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		OBJECT_TYPE,
		KEY_STRUCTURE_OF_EXTERNAL_OBJECT_TYPES,
		SCREEN_NUMBER_OF_EXTERNAL_OBJECT_TYPES,
		INTERFACE_NAME,
		INVERSE_RELATIONSHIP,
		INDICATOR_FOR_STANDARD_OBJECT_TYPE,
		EXTERNAL_OBJECT_INCLUDED_IN_ENHANCED_REL_MAINTENANCE,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__EXTERNAL_OBJECT_TYPES') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data