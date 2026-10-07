/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_AAM_EV_ANLH_GMX',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"BUKRS"::STRING AS "BUKRS", 
 	 	JSONFIELD:"ANLN1"::STRING AS "ANLN1", 
 	 	JSONFIELD:"LUNTN"::STRING AS "LUNTN", 
 	 	JSONFIELD:"LANEP"::STRING AS "LANEP", 
 	 	JSONFIELD:"ANUPD"::STRING AS "ANUPD", 
 	 	JSONFIELD:"FUNTN"::STRING AS "FUNTN", 
 	 	JSONFIELD:"ANLHTXT"::STRING AS "ANLHTXT", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_AAM_EV_ANLH_GMX') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_AAM_EV_ANLH_GMX') }})
	),
	
	transform_data as (
	SELECT 
		"BUKRS", 
 	 	"ANLN1", 
 	 	"LUNTN", 
 	 	"LANEP", 
 	 	"ANUPD", 
 	 	"FUNTN", 
 	 	"ANLHTXT", 
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
 	 	CAST("LUNTN" AS NVARCHAR) AS "LUNTN", 
 	 	CAST("LANEP" AS VARCHAR) AS "LANEP", 
 	 	CAST("ANUPD" AS NVARCHAR) AS "ANUPD", 
 	 	CAST("FUNTN" AS NVARCHAR) AS "FUNTN", 
 	 	CAST("ANLHTXT" AS NVARCHAR) AS "ANLHTXT", 
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