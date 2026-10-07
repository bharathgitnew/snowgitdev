/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_AAM_EV_ANLBZW_GMX',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"BUKRS"::STRING AS "BUKRS", 
 	 	JSONFIELD:"ANLN1"::STRING AS "ANLN1", 
 	 	JSONFIELD:"ANLN2"::STRING AS "ANLN2", 
 	 	JSONFIELD:"AFABE"::STRING AS "AFABE", 
 	 	JSONFIELD:"BGJAHR"::STRING AS "BGJAHR", 
 	 	JSONFIELD:"BZWPRZ"::STRING AS "BZWPRZ", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_AAM_EV_ANLBZW_GMX') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_AAM_EV_ANLBZW_GMX') }})
	),
	
	transform_data as (
	SELECT 
		"BUKRS", 
 	 	"ANLN1", 
 	 	"ANLN2", 
 	 	"AFABE", 
 	 	"BGJAHR", 
 	 	"BZWPRZ", 
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
		CAST("BUKRS" AS NVARCHAR) AS "BUKRS", 
 	 	CAST("ANLN1" AS NVARCHAR) AS "ANLN1", 
 	 	CAST("ANLN2" AS NVARCHAR) AS "ANLN2", 
 	 	CAST("AFABE" AS VARCHAR) AS "AFABE", 
 	 	CAST("BGJAHR" AS VARCHAR) AS "BGJAHR", 
 	 	CAST("BZWPRZ" AS FLOAT) AS "BZWPRZ", 
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