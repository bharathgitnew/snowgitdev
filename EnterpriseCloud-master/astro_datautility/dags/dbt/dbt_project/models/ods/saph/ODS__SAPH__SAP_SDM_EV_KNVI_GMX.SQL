/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_SDM_EV_KNVI_GMX',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"KUNNR"::STRING AS "KUNNR", 
 	 	JSONFIELD:"ALAND"::STRING AS "ALAND", 
 	 	JSONFIELD:"TATYP"::STRING AS "TATYP", 
 	 	JSONFIELD:"TAXKD"::STRING AS "TAXKD", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_SDM_EV_KNVI_GMX') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_SDM_EV_KNVI_GMX') }})
	),
	
	transform_data as (
	SELECT 
		"KUNNR", 
 	 	"ALAND", 
 	 	"TATYP", 
 	 	"TAXKD", 
 	 	"DELFLAG", 
 	 	"CDCHANGENR",
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
	from source_data
	),
	
	type_data as (
	SELECT
		CAST("KUNNR" AS NVARCHAR) AS "KUNNR", 
 	 	CAST("ALAND" AS NVARCHAR) AS "ALAND", 
 	 	CAST("TATYP" AS NVARCHAR) AS "TATYP", 
 	 	CAST("TAXKD" AS NVARCHAR) AS "TAXKD", 
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG", 
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR",
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
	from transform_data
	)

	select * from type_data