/************
Model file generated from legacy93DbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='BAANV_ALL_ITEM_GROUPS',
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"COMPANY_NO"::STRING AS "COMPANY_NO", 
 	 	JSONFIELD:"ITEM_GROUP"::STRING AS "ITEM_GROUP", 
 	 	JSONFIELD:"DESCRIPTION"::STRING AS "DESCRIPTION"
	FROM {{ source('LEGACY93','BAANV_ALL_ITEM_GROUPS') }}
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('LEGACY93','BAANV_ALL_ITEM_GROUPS') }})
),

transform_data as (
	SELECT 
		"COMPANY_NO", 
 	 	"ITEM_GROUP", 
 	 	"DESCRIPTION",
		'{{ invocation_id }}' AS AUDIT_LOG_ID
	FROM source_data
),

type_data as (
	SELECT
		CAST("COMPANY_NO" AS NUMBER(38,0)) AS "COMPANY_NO", 
 	 	CAST("ITEM_GROUP" AS VARCHAR(16777216)) AS "ITEM_GROUP", 
 	 	CAST("DESCRIPTION" AS VARCHAR(16777216)) AS "DESCRIPTION",
		CAST(AUDIT_LOG_ID AS varchar(128)) AS AUDIT_LOG_ID
	FROM transform_data
)

SELECT * FROM type_data