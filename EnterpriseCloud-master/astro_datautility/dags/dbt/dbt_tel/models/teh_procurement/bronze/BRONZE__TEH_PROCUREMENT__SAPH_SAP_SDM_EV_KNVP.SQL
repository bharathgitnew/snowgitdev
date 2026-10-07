{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPH_SAP_SDM_EV_KNVP',
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
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
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
 	 	"PSL_UPDDATE"
	from source_data
	),
	
	type_data as (
	SELECT
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		KUNNR, 
 	 	VKORG, 
 	 	VTWEG, 
 	 	SPART, 
 	 	PARVW, 
 	 	PARZA, 
 	 	KUNN2, 
 	 	LIFNR, 
 	 	PERNR, 
 	 	PARNR, 
 	 	KNREF, 
 	 	DELFLAG, 
 	 	CDCHANGENR, 
 	 	PSL_INSDATE, 
 	 	PSL_UPDDATE
	from transform_data
	)

	select * from type_data