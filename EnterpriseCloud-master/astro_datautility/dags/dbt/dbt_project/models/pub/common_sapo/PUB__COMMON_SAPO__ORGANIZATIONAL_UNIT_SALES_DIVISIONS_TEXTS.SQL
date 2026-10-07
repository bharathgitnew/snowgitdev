{{ config(
        materialized='view',
         alias='ORGANIZATIONAL_UNIT_SALES_DIVISIONS_TEXTS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		DIVISION,
		NAME,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__ORGANIZATIONAL_UNIT_SALES_DIVISIONS_TEXTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data