{{ config(
        materialized='view',
         alias='LANGUAGE_DEPENDENT_TEXTS_FOR_TABLE_TQ15',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		CATALOG,
		SHORT_TEXT_FOR_THE_CATALOG,
		KEYWORD_FOR_CATALOG_TYPE,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__LANGUAGE_DEPENDENT_TEXTS_FOR_TABLE_TQ15') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data