/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_COM_EV_PRHI_GMX',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"POSNR"::STRING AS "POSNR", 
 	 	JSONFIELD:"PSPHI"::STRING AS "PSPHI", 
 	 	JSONFIELD:"UP"::STRING AS "UP", 
 	 	JSONFIELD:"DOWN"::STRING AS "DOWN", 
 	 	JSONFIELD:"RIGHT"::STRING AS "RIGHT", 
 	 	JSONFIELD:"LEFT"::STRING AS "LEFT", 
 	 	JSONFIELD:"PBUKR"::STRING AS "PBUKR", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_COM_EV_PRHI_GMX') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_COM_EV_PRHI_GMX') }})
	),
	
	transform_data as (
	SELECT 
		"POSNR", 
 	 	"PSPHI", 
 	 	"UP", 
 	 	"DOWN", 
 	 	"RIGHT", 
 	 	"LEFT", 
 	 	"PBUKR", 
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
		CAST("POSNR" AS VARCHAR) AS "POSNR", 
 	 	CAST("PSPHI" AS VARCHAR) AS "PSPHI", 
 	 	CAST("UP" AS VARCHAR) AS "UP", 
 	 	CAST("DOWN" AS VARCHAR) AS "DOWN", 
 	 	CAST("RIGHT" AS VARCHAR) AS "RIGHT", 
 	 	CAST("LEFT" AS VARCHAR) AS "LEFT", 
 	 	CAST("PBUKR" AS NVARCHAR) AS "PBUKR", 
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