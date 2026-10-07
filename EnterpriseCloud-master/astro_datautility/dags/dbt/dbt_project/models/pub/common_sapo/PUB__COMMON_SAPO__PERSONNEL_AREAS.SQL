{{ config(
        materialized='view',
         alias='PERSONNEL_AREAS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		PERSONNEL_AREA,
		COUNTRY_GROUPING,
		COMPANY_CODE,
		PERSONNEL_AREA_TEXT,
		NAME_2,
		STREET_AND_HOUSE_NUMBER,
		PO_BOX,
		POSTAL_CODE,
		CITY,
		COUNTRY,
		REGION,
		COUNTY_CODE,
		CITY_CODE,
		ADDRESS,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__PERSONNEL_AREAS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data