{{ config(
        materialized='view',
         alias='DEFINITION_OF_EVALUATION_PATHS',
         transient=false
) }}

with source_data as (
    select
        CLIENT,
		EVALUATION_PATH,
		SEQUENCE_NUMBER,
		OBJECT_TYPE,
		RELATIONSHIP_SPECIFICATION,
		RELATIONSHIP_BETWEEN_OBJECTS,
		PRIORITY,
		TYPE_OF_RELATED_OBJECT,
		SKIP_FLAG,
		_CAPTUREDATETIME
    from {{ ref('COMMON__SAPO__DEFINITION_OF_EVALUATION_PATHS') }}
),

transform_data as (
    select
        *
    from source_data
)
    
select * from transform_data