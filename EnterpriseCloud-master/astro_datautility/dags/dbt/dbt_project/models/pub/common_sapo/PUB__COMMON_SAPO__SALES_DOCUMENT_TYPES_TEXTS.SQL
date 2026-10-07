{{ config(
        materialized='view',
         alias='SALES_DOCUMENT_TYPES_TEXTS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		SALES_DOCUMENT_TYPE,
		DESCRIPTION,
		TEXT_ON_BROWSER_BUTTON,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__SALES_DOCUMENT_TYPES_TEXTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data