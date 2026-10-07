{{ config(
        materialized='view',
         alias='COST_ELEMENTS_DATA_DEPENDENT_ON_CHART_OF_ACCOUNTS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		CHART_OF_ACCOUNTS,
		COST_ELEMENT,
		CREATED_ON,
		ENTERED_BY,
		COST_ELEMENT_IS_TAX_RELEVANT,
		COST_ELEMENT_AFFECTING_PAYMENT,
		KSTSN_COST_ELEMENT,
		FUNCTIONAL_AREA,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__COST_ELEMENTS_DATA_DEPENDENT_ON_CHART_OF_ACCOUNTS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data