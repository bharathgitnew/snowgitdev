{{ config(
        materialized='view',
         alias='FIRMING_DATA_OF_MRP_MRP_AREA',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		MATERIAL_NUMBER,
		MRP_AREA,
		PLANNING_SCENARIO_OF_LONG_TERM_PLANNING,
		DATE_OF_FIRM_PLANNED_ORDER_LAST_COPIED_FROM_MRP,
		MANUAL_FIRMING_DATE,
		SET_MANUAL_FIRMING_DATE_USER,
		SET_MANUAL_FIRMING_DATE_DATE_TO_SET,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__FIRMING_DATA_OF_MRP_MRP_AREA') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data