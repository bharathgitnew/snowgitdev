{{ config(
        materialized='view',
         alias='POSITION_TEXTS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE,
		OBJECT_TYPE,
		POSITION,
		END_DATE,
		START_DATE,
		POSITION_SHORT_TEXT,
		OM,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__POSITION_TEXTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data