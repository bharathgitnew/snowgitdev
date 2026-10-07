/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_SDM_EV_KNVP',
    	  unique_key = [''],
    	  transient=false	
) }} 
	
	with source_data as (
	SELECT
		JSONFIELD:"KUNNR"::STRING AS "KUNNR", 
 	 	JSONFIELD:"VKORG"::STRING AS "VKORG", 
 	 	JSONFIELD:"VTWEG"::STRING AS "VTWEG", 
 	 	JSONFIELD:"SPART"::STRING AS "SPART", 
 	 	JSONFIELD:"PARVW"::STRING AS "PARVW", 
 	 	JSONFIELD:"PARZA"::STRING AS "PARZA", 
 	 	JSONFIELD:"KUNN2"::STRING AS "KUNN2", 
 	 	JSONFIELD:"LIFNR"::STRING AS "LIFNR", 
 	 	JSONFIELD:"PERNR"::STRING AS "PERNR", 
 	 	JSONFIELD:"PARNR"::STRING AS "PARNR", 
 	 	JSONFIELD:"KNREF"::STRING AS "KNREF", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_SDM_EV_KNVP') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH','SAP_SDM_EV_KNVP') }})
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY KUNNR, PARVW, PARZA, SPART, VKORG, VTWEG ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
	SELECT 
		"KUNNR", 
 	 	"VKORG", 
 	 	"VTWEG", 
 	 	"SPART", 
 	 	"PARVW", 
 	 	"PARZA", 
 	 	"KUNN2", 
 	 	"LIFNR", 
 	 	"PERNR", 
 	 	"PARNR", 
 	 	"KNREF", 
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
		CAST("KUNNR" AS NVARCHAR) AS "KUNNR", 
 	 	CAST("VKORG" AS NVARCHAR) AS "VKORG", 
 	 	CAST("VTWEG" AS NVARCHAR) AS "VTWEG", 
 	 	CAST("SPART" AS NVARCHAR) AS "SPART", 
 	 	CAST("PARVW" AS NVARCHAR) AS "PARVW", 
 	 	CAST("PARZA" AS VARCHAR) AS "PARZA", 
 	 	CAST("KUNN2" AS NVARCHAR) AS "KUNN2", 
 	 	CAST("LIFNR" AS NVARCHAR) AS "LIFNR", 
 	 	CAST("PERNR" AS VARCHAR) AS "PERNR", 
 	 	CAST("PARNR" AS VARCHAR) AS "PARNR", 
 	 	CAST("KNREF" AS NVARCHAR) AS "KNREF", 
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