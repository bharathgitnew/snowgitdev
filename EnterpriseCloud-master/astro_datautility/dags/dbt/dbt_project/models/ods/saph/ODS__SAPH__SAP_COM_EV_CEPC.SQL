/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_COM_EV_CEPC',
    	  unique_key = [''],
    	  transient=false	,
		  enabled=false
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"KOKRS"::STRING AS "KOKRS", 
 	 	JSONFIELD:"PRCTR"::STRING AS "PRCTR", 
 	 	JSONFIELD:"DATBI"::STRING AS "DATBI", 
 	 	JSONFIELD:"DATAB"::STRING AS "DATAB", 
 	 	JSONFIELD:"ERSDA"::STRING AS "ERSDA", 
 	 	JSONFIELD:"USNAM"::STRING AS "USNAM", 
 	 	JSONFIELD:"MERKMAL"::STRING AS "MERKMAL", 
 	 	JSONFIELD:"ABTEI"::STRING AS "ABTEI", 
 	 	JSONFIELD:"VERAK"::STRING AS "VERAK", 
 	 	JSONFIELD:"WAERS"::STRING AS "WAERS", 
 	 	JSONFIELD:"BUKRS"::STRING AS "BUKRS", 
 	 	JSONFIELD:"KHINR"::STRING AS "KHINR", 
 	 	JSONFIELD:"ZPCSRGKY"::STRING AS "ZPCSRGKY", 
 	 	JSONFIELD:"LOCK_IND"::STRING AS "LOCK_IND", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_COM_EV_CEPC') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_COM_EV_CEPC') }})
	),
	
	transform_data as (
	SELECT 
		"KOKRS", 
 	 	"PRCTR", 
 	 	"DATBI", 
 	 	"DATAB", 
 	 	"ERSDA", 
 	 	"USNAM", 
 	 	"MERKMAL", 
 	 	"ABTEI", 
 	 	"VERAK", 
 	 	"WAERS", 
 	 	"BUKRS", 
 	 	"KHINR", 
 	 	"ZPCSRGKY", 
 	 	"LOCK_IND", 
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
		CAST("KOKRS" AS NVARCHAR) AS "KOKRS", 
 	 	CAST("PRCTR" AS NVARCHAR) AS "PRCTR", 
 	 	CAST("DATBI" AS TIMESTAMP) AS "DATBI", 
 	 	CAST("DATAB" AS TIMESTAMP) AS "DATAB", 
 	 	CAST("ERSDA" AS TIMESTAMP) AS "ERSDA", 
 	 	CAST("USNAM" AS NVARCHAR) AS "USNAM", 
 	 	CAST("MERKMAL" AS NVARCHAR) AS "MERKMAL", 
 	 	CAST("ABTEI" AS NVARCHAR) AS "ABTEI", 
 	 	CAST("VERAK" AS NVARCHAR) AS "VERAK", 
 	 	CAST("WAERS" AS NVARCHAR) AS "WAERS", 
 	 	CAST("BUKRS" AS NVARCHAR) AS "BUKRS", 
 	 	CAST("KHINR" AS NVARCHAR) AS "KHINR", 
 	 	CAST("ZPCSRGKY" AS NVARCHAR) AS "ZPCSRGKY", 
 	 	CAST("LOCK_IND" AS NVARCHAR) AS "LOCK_IND", 
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