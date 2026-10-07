
{{ config(
    materialized='view', 
    alias='ACTIVITY_TYPE_TEXTS', 
    transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		CONTROLLING_AREA,
		ACTIVITY_TYPE,
		VALID_TO_DATE,
		GENERAL_NAME,
		DESCRIPTION,
		SEARCH_TERM_FOR_MATCHCODE_USE,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__ACTIVITY_TYPE_TEXTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data