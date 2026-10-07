/************
Model file generated from legacy93DbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='merge',
    	alias='BAANV_TEA_ADDRESSES',
    	unique_key = ['ADDRESS_CODE'],
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"ADDRESS_CODE"::STRING AS "ADDRESS_CODE", 
 	 	JSONFIELD:"NAME"::STRING AS "NAME", 
 	 	JSONFIELD:"NAME2"::STRING AS "NAME2", 
 	 	JSONFIELD:"ADDRESS"::STRING AS "ADDRESS", 
 	 	JSONFIELD:"ADDRESS2"::STRING AS "ADDRESS2", 
 	 	JSONFIELD:"HOUSE_NUMBER"::STRING AS "HOUSE_NUMBER", 
 	 	JSONFIELD:"CITY"::STRING AS "CITY", 
 	 	JSONFIELD:"CITY2"::STRING AS "CITY2", 
 	 	JSONFIELD:"STATE_PROVINCE"::STRING AS "STATE_PROVINCE", 
 	 	JSONFIELD:"COUNTRY"::STRING AS "COUNTRY", 
 	 	JSONFIELD:"POSTAL_CODE"::STRING AS "POSTAL_CODE", 
 	 	JSONFIELD:"ROUTE"::STRING AS "ROUTE", 
 	 	JSONFIELD:"TELEPHONE"::STRING AS "TELEPHONE", 
 	 	JSONFIELD:"FAX"::STRING AS "FAX",
		_FILENAME,
		_FILEDATE
	FROM {{ source('LEGACY93','BAANV_TEA_ADDRESSES') }}
	{% if is_incremental() %}WHERE _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"ADDRESS_CODE"::STRING  ORDER BY _FILENAME DESC )) = 1
),

transform_data as (
	SELECT 
		"ADDRESS_CODE", 
 	 	"NAME", 
 	 	"NAME2", 
 	 	"ADDRESS", 
 	 	"ADDRESS2", 
 	 	"HOUSE_NUMBER", 
 	 	"CITY", 
 	 	"CITY2", 
 	 	"STATE_PROVINCE", 
 	 	"COUNTRY", 
 	 	"POSTAL_CODE", 
 	 	"ROUTE", 
 	 	"TELEPHONE", 
 	 	"FAX",
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
	FROM source_data
),

type_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		AUDIT_LOG_ID,
		_ROW_HASH,
		"ADDRESS_CODE", 
		"NAME", 
		"NAME2", 
		"ADDRESS", 
		"ADDRESS2", 
		"HOUSE_NUMBER", 
		"CITY", 
		"CITY2", 
		"STATE_PROVINCE", 
		"COUNTRY", 
		"POSTAL_CODE", 
		"ROUTE", 
		"TELEPHONE", 
		"FAX"
	FROM transform_data
)

SELECT * FROM type_data