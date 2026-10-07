/************
Model file generated from csdproDbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='merge',
    	alias='BU',
    	unique_key = ['BU_ID'],
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"BU_ID"::STRING AS "BU_ID", 
 	 	JSONFIELD:"BUCODE"::STRING AS "BUCODE", 
 	 	JSONFIELD:"DESCRIPTION"::STRING AS "DESCRIPTION", 
 	 	JSONFIELD:"SORT_ORDER"::STRING AS "SORT_ORDER", 
 	 	REGEXP_REPLACE(JSONFIELD:"INACTIVE_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS INACTIVE_DATE, 
 	 	JSONFIELD:"BAAN_BU_NBR"::STRING AS "BAAN_BU_NBR"
	FROM {{ source('CSDPRO','BU') }}
	{% if is_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(Hist._FILEDATE) FROM {{ source('CSDPRO','BU') }} Hist),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"BU_ID"::STRING  ORDER BY _FILENAME DESC,_FILEDATE DESC )) = 1
),

transform_data as (
	SELECT 
		"BU_ID", 
 	 	"BUCODE", 
 	 	"DESCRIPTION", 
 	 	"SORT_ORDER", 
 	 	"INACTIVE_DATE", 
 	 	"BAAN_BU_NBR",
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
	FROM source_data
),

type_data as (
	SELECT
		CAST("BU_ID" AS NUMBER(38,0)) AS "BU_ID", 
 	 	CAST("BUCODE" AS VARCHAR(16777216)) AS "BUCODE", 
 	 	CAST("DESCRIPTION" AS VARCHAR(16777216)) AS "DESCRIPTION", 
 	 	CAST("SORT_ORDER" AS NUMBER(38,0)) AS "SORT_ORDER", 
 	 	CAST("INACTIVE_DATE" AS TIMESTAMP_LTZ(9)) AS "INACTIVE_DATE", 
 	 	CAST("BAAN_BU_NBR" AS NUMBER(38,0)) AS "BAAN_BU_NBR",
		CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
	FROM transform_data
)

SELECT * FROM type_data