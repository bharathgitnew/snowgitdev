{{ config(
        materialized='view',
         alias='COST_ELEMENT_TEXTS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		CHART_OF_ACCOUNTS,
		COST_ELEMENT,
		GENERAL_NAME,
		DESCRIPTION,
		SEARCH_TERM_FOR_MATCHCODE_USE,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__COST_ELEMENT_TEXTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data