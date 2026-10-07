{{ config(
        materialized='view',
         alias='DOCUMENT_TYPE_TEXTS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		LANGUAGE_KEY,
		DOCUMENT_TYPE,
		DOCUMENT_TYPE_DESCRIPTION,
		_CAPTUREDATETIME,
		IS_DELETED
    from {{ ref('COMMON__SAPO__DOCUMENT_TYPE_TEXTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data