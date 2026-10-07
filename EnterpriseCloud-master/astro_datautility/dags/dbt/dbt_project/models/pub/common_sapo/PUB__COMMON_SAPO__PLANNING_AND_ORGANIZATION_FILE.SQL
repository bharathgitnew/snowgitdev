{{ config(
        materialized='view',
         alias='PLANNING_AND_ORGANIZATION_FILE',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		PLAN_VERSION,
		OBJECT_TYPE,
		OBJECT_ID,
		INFOTYPE,
		SUBTYPE,
		PLANNING_STATUS,
		PRIORITY,
		START_DATE,
		END_DATE,
		VARIATION_FIELD_FOR_FILE_PLOG,
		NUMBER_OF_INFOTYPE_RECORD_WITH_SAME_KEY,
		CHANGED_ON,
		USER_NAME,
		REASON,
		HISTORICAL_RECORD_FLAG,
		TEXT_MODULE_FOR_INFOTYPE,
		DATA_FIELD_PLOG,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__PLANNING_AND_ORGANIZATION_FILE') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data