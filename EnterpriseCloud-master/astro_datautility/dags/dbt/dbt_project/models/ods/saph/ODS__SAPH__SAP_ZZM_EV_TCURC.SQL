/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_ZZM_EV_TCURC',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"WAERS"::STRING AS "WAERS", 
 	 	JSONFIELD:"ISOCD"::STRING AS "ISOCD", 
 	 	JSONFIELD:"ALTWR"::STRING AS "ALTWR", 
 	 	JSONFIELD:"GDATU"::STRING AS "GDATU", 
 	 	JSONFIELD:"XPRIMARY"::STRING AS "XPRIMARY", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_ZZM_EV_TCURC') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_ZZM_EV_TCURC') }})
	),
	
	transform_data as (
	SELECT 
		"WAERS", 
 	 	"ISOCD", 
 	 	"ALTWR", 
 	 	"GDATU", 
 	 	"XPRIMARY", 
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
		CAST("WAERS" AS NVARCHAR) AS "WAERS", 
 	 	CAST("ISOCD" AS NVARCHAR) AS "ISOCD", 
 	 	CAST("ALTWR" AS NVARCHAR) AS "ALTWR", 
 	 	CAST("GDATU" AS TIMESTAMP) AS "GDATU", 
 	 	CAST("XPRIMARY" AS NVARCHAR) AS "XPRIMARY", 
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