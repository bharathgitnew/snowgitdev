{{ config(
    materialized='view',
    alias='TEA_EXTERNAL_SERVICE_REVENUE_MARGIN_BU'
) }}

WITH source_data as (
select
    BU,
	ACTUAL_REVENUE_AMOUNT,
	SUBCON_HOURS,
	SUBCON_COGS,
	FTE_HOURS,
	FTE_COGS,
	ESTIMATED_COGS,
	ESTIMATED_SERVICE_MARGIN,
	SERVICE_MARGIN_RATIO
FROM {{ ref('COMMON__REPORTS__TEA_EXTERNAL_SERVICE_REVENUE_MARGIN_BU') }}
),

transform_data as (
select * from source_data
)

select * from transform_data