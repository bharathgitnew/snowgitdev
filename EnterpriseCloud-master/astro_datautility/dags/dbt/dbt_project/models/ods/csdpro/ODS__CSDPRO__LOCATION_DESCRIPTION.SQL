/************
Model file generated from csdproDbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='merge',
    	alias='LOCATION_DESCRIPTION',
    	unique_key = ['LOCATION_DESCRIPTION_ID'],
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"LOCATION_DESCRIPTION_ID"::STRING AS "LOCATION_DESCRIPTION_ID", 
 	 	JSONFIELD:"DESCRIPTION"::STRING AS "DESCRIPTION", 
 	 	JSONFIELD:"SORT_ORDER"::STRING AS "SORT_ORDER", 
 	 	REGEXP_REPLACE(JSONFIELD:"INACTIVE_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS INACTIVE_DATE
	FROM {{ source('CSDPRO','LOCATION_DESCRIPTION') }}
	{% if is_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(Hist._FILEDATE) FROM {{ source('CSDPRO','LOCATION_DESCRIPTION') }} Hist),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"LOCATION_DESCRIPTION_ID"::STRING  ORDER BY _FILENAME DESC,_FILEDATE DESC )) = 1
),

transform_data as (
	SELECT 
		"LOCATION_DESCRIPTION_ID", 
 	 	"DESCRIPTION", 
 	 	"SORT_ORDER", 
 	 	"INACTIVE_DATE",
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
	FROM source_data
),

type_data as (
	SELECT
		CAST("LOCATION_DESCRIPTION_ID" AS NUMBER(38,0)) AS "LOCATION_DESCRIPTION_ID", 
 	 	CAST("DESCRIPTION" AS VARCHAR(16777216)) AS "DESCRIPTION", 
 	 	CAST("SORT_ORDER" AS NUMBER(38,0)) AS "SORT_ORDER", 
 	 	CAST("INACTIVE_DATE" AS TIMESTAMP_LTZ(9)) AS "INACTIVE_DATE",
		CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
	FROM transform_data
)

SELECT * FROM type_data