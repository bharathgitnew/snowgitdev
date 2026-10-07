/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_FIM_EV_TSTL_GMX',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"TALND"::STRING AS "TALND", 
 	 	JSONFIELD:"LFDNR"::STRING AS "LFDNR", 
 	 	JSONFIELD:"TATYP"::STRING AS "TATYP", 
 	 	JSONFIELD:"STPRZ"::STRING AS "STPRZ", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_FIM_EV_TSTL_GMX') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_FIM_EV_TSTL_GMX') }})
	),
	
	transform_data as (
	SELECT 
		"TALND", 
 	 	"LFDNR", 
 	 	"TATYP", 
 	 	"STPRZ", 
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
		CAST("TALND" AS NVARCHAR) AS "TALND", 
 	 	CAST("LFDNR" AS VARCHAR) AS "LFDNR", 
 	 	CAST("TATYP" AS NVARCHAR) AS "TATYP", 
 	 	CAST("STPRZ" AS NVARCHAR) AS "STPRZ", 
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