{{ config(
        materialized = 'view',
        alias = 'OPPORTUNITY_SNAPSHOT',
        transient = 'false'
) }}

with source_data as (
    select 
	* exclude (_FILEDATE,_FILENAME,_UPLOADDATE,AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__CRM__OPPORTUNITY_SNAPSHOT') }}
)

SELECT * FROM source_data