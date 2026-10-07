/************
Model file generated from csdproDbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='merge',
    	alias='BAAN_BP',
    	unique_key = ['BAAN_BP_ID'],
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"BAAN_BP_ID"::STRING AS "BAAN_BP_ID", 
 	 	JSONFIELD:"TEL_SUBSIDIARY_ID"::STRING AS "TEL_SUBSIDIARY_ID", 
 	 	JSONFIELD:"NAME"::STRING AS "NAME", 
 	 	REGEXP_REPLACE(JSONFIELD:"INACTIVE_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS INACTIVE_DATE, 
 	 	REGEXP_REPLACE(JSONFIELD:"CREATED_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS CREATED_DATE, 
 	 	REGEXP_REPLACE(JSONFIELD:"MODIFIED_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS MODIFIED_DATE
	FROM {{ source('CSDPRO','BAAN_BP') }}
	{% if is_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(Hist._FILEDATE) FROM {{ source('CSDPRO','BAAN_BP') }} Hist),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"BAAN_BP_ID"::STRING  ORDER BY _FILENAME DESC,_FILEDATE DESC )) = 1
),

transform_data as (
	SELECT 
		"BAAN_BP_ID", 
 	 	"TEL_SUBSIDIARY_ID", 
 	 	"NAME", 
 	 	"INACTIVE_DATE", 
 	 	"CREATED_DATE", 
 	 	"MODIFIED_DATE",
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
	FROM source_data
),

type_data as (
	SELECT
		CAST("BAAN_BP_ID" AS VARCHAR(16777216)) AS "BAAN_BP_ID", 
 	 	CAST("TEL_SUBSIDIARY_ID" AS NUMBER(38,0)) AS "TEL_SUBSIDIARY_ID", 
 	 	CAST("NAME" AS VARCHAR(16777216)) AS "NAME", 
 	 	CAST("INACTIVE_DATE" AS TIMESTAMP_LTZ(9)) AS "INACTIVE_DATE", 
 	 	CAST("CREATED_DATE" AS TIMESTAMP_LTZ(9)) AS "CREATED_DATE", 
 	 	CAST("MODIFIED_DATE" AS TIMESTAMP_LTZ(9)) AS "MODIFIED_DATE",
		CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
	FROM transform_data
)

SELECT * FROM type_data