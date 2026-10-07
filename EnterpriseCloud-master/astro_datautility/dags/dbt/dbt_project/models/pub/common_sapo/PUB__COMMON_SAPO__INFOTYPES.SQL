{{ config(
        materialized='view',
         alias='INFOTYPES',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		INFOTYPE,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__INFOTYPES') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data