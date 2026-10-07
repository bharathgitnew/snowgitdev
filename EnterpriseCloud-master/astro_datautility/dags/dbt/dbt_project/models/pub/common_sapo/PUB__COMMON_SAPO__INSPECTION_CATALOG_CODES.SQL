{{ config(
        materialized='view',
         alias='INSPECTION_CATALOG_CODES',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		CATALOG,
		CODE_GROUP,
		CODE,
		VERSION_NUMBER,
		VALID_FROM_DATE,
		DEFECT_CLASS,
		NAME_OF_USER_WHO_CREATED_THE_DATA_RECORD,
		DATE_ON_WHICH_THE_DATA_RECORD_WAS_CREATED,
		NAME_OF_USER_WHO_MOST_RECENTLY_CHANGED_THE_DATA_RECORD,
		DATE_ON_WHICH_DATA_RECORD_WAS_CHANGED,
		STATUS_OF_CODE_GROUP_OR_CODE_RECORD,
		DATA_RECORD_IS_USED,
		DATA_RECORD_WAS_DELETED,
		FOLLOW_UP_ACTION,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__INSPECTION_CATALOG_CODES') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data