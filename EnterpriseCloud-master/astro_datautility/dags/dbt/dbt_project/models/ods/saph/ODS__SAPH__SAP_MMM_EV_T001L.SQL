/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_MMM_EV_T001L',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"WERKS"::STRING AS "WERKS", 
 	 	JSONFIELD:"LGORT"::STRING AS "LGORT", 
 	 	JSONFIELD:"LGOBE"::STRING AS "LGOBE", 
 	 	JSONFIELD:"SPART"::STRING AS "SPART", 
 	 	JSONFIELD:"DISKZ"::STRING AS "DISKZ", 
 	 	JSONFIELD:"VKORG"::STRING AS "VKORG", 
 	 	JSONFIELD:"VTWEG"::STRING AS "VTWEG", 
 	 	JSONFIELD:"VSTEL"::STRING AS "VSTEL", 
 	 	JSONFIELD:"LIFNR"::STRING AS "LIFNR", 
 	 	JSONFIELD:"KUNNR"::STRING AS "KUNNR", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_MMM_EV_T001L') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_MMM_EV_T001L') }})
	),
	
	transform_data as (
	SELECT 
		"WERKS", 
 	 	"LGORT", 
 	 	"LGOBE", 
 	 	"SPART", 
 	 	"DISKZ", 
 	 	"VKORG", 
 	 	"VTWEG", 
 	 	"VSTEL", 
 	 	"LIFNR", 
 	 	"KUNNR", 
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
 	 	CAST("LGORT" AS NVARCHAR) AS "LGORT", 
 	 	CAST("LGOBE" AS NVARCHAR) AS "LGOBE", 
 	 	CAST("SPART" AS NVARCHAR) AS "SPART", 
 	 	CAST("DISKZ" AS NVARCHAR) AS "DISKZ", 
 	 	CAST("VKORG" AS NVARCHAR) AS "VKORG", 
 	 	CAST("VTWEG" AS NVARCHAR) AS "VTWEG", 
 	 	CAST("VSTEL" AS NVARCHAR) AS "VSTEL", 
 	 	CAST("LIFNR" AS NVARCHAR) AS "LIFNR", 
 	 	CAST("KUNNR" AS NVARCHAR) AS "KUNNR", 
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