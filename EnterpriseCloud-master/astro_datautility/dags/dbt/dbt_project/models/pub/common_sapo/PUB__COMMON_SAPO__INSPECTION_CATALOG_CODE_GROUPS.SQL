{{ config(
        materialized='view',
         alias='INSPECTION_CATALOG_CODE_GROUPS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		CATALOG,
		CODE_GROUP,
		NAME_OF_USER_WHO_CREATED_THE_DATA_RECORD,
		DATE_ON_WHICH_THE_DATA_RECORD_WAS_CREATED,
		NAME_OF_USER_WHO_MOST_RECENTLY_CHANGED_THE_DATA_RECORD,
		DATE_ON_WHICH_DATA_RECORD_WAS_CHANGED,
		DATA_RECORD_IS_USED,
		STATUS_OF_CODE_GROUP_OR_CODE_RECORD,
		STATUS_OF_MASTER_RECORD,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__INSPECTION_CATALOG_CODE_GROUPS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data