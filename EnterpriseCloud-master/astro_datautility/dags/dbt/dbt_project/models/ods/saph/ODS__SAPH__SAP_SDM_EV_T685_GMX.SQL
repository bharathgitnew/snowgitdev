/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_SDM_EV_T685_GMX',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"KVEWE"::STRING AS "KVEWE", 
 	 	JSONFIELD:"KAPPL"::STRING AS "KAPPL", 
 	 	JSONFIELD:"KSCHL"::STRING AS "KSCHL", 
 	 	JSONFIELD:"KOZGF"::STRING AS "KOZGF", 
 	 	JSONFIELD:"DATVO"::STRING AS "DATVO", 
 	 	JSONFIELD:"DTVOB"::STRING AS "DTVOB", 
 	 	JSONFIELD:"OBSOLETE"::STRING AS "OBSOLETE", 
 	 	JSONFIELD:"J_3GPRAEND"::STRING AS "J_3GPRAEND", 
 	 	JSONFIELD:"J_3GBUARTL"::STRING AS "J_3GBUARTL", 
 	 	JSONFIELD:"J_3GBUARTB"::STRING AS "J_3GBUARTB", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_SDM_EV_T685_GMX') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_SDM_EV_T685_GMX') }})
	),
	
	transform_data as (
	SELECT 
		"KVEWE", 
 	 	"KAPPL", 
 	 	"KSCHL", 
 	 	"KOZGF", 
 	 	"DATVO", 
 	 	"DTVOB", 
 	 	"OBSOLETE", 
 	 	"J_3GPRAEND", 
 	 	"J_3GBUARTL", 
 	 	"J_3GBUARTB", 
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
		CAST("KVEWE" AS NVARCHAR) AS "KVEWE", 
 	 	CAST("KAPPL" AS NVARCHAR) AS "KAPPL", 
 	 	CAST("KSCHL" AS NVARCHAR) AS "KSCHL", 
 	 	CAST("KOZGF" AS NVARCHAR) AS "KOZGF", 
 	 	CAST("DATVO" AS NVARCHAR) AS "DATVO", 
 	 	CAST("DTVOB" AS NVARCHAR) AS "DTVOB", 
 	 	CAST("OBSOLETE" AS NVARCHAR) AS "OBSOLETE", 
 	 	CAST("J_3GPRAEND" AS NVARCHAR) AS "J_3GPRAEND", 
 	 	CAST("J_3GBUARTL" AS VARCHAR) AS "J_3GBUARTL", 
 	 	CAST("J_3GBUARTB" AS VARCHAR) AS "J_3GBUARTB", 
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