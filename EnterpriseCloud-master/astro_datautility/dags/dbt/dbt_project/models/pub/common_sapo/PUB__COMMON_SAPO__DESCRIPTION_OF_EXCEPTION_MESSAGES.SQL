{{ config(
        materialized='view',
         alias='DESCRIPTION_OF_EXCEPTION_MESSAGES',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		EXCEPTION_MESSAGE_KEY,
		EXCEPTION_MESSAGE_TEXT,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__DESCRIPTION_OF_EXCEPTION_MESSAGES') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data