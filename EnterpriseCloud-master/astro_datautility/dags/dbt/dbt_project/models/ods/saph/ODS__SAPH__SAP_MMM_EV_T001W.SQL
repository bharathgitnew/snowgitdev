/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_MMM_EV_T001W',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"WERKS"::STRING AS "WERKS", 
 	 	JSONFIELD:"NAME1"::STRING AS "NAME1", 
 	 	JSONFIELD:"BWKEY"::STRING AS "BWKEY", 
 	 	JSONFIELD:"FABKL"::STRING AS "FABKL", 
 	 	JSONFIELD:"LAND1"::STRING AS "LAND1", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_MMM_EV_T001W') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_MMM_EV_T001W') }})
	),
	
	transform_data as (
	SELECT 
		"WERKS", 
 	 	"NAME1", 
 	 	"BWKEY", 
 	 	"FABKL", 
 	 	"LAND1", 
 	 	"DELFLAG", 
 	 	"CDCHANGENR", 
 	 	"PSL_INSDATE", 
 	 	"PSL_UPDDATE",
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
	from source_data
	),
	
	type_data as (
	SELECT
		CAST("WERKS" AS NVARCHAR) AS "WERKS", 
 	 	CAST("NAME1" AS NVARCHAR) AS "NAME1", 
 	 	CAST("BWKEY" AS NVARCHAR) AS "BWKEY", 
 	 	CAST("FABKL" AS NVARCHAR) AS "FABKL", 
 	 	CAST("LAND1" AS NVARCHAR) AS "LAND1", 
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG", 
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR", 
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE", 
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE",
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
	from transform_data
	)

	select * from type_data