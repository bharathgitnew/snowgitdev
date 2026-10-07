/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_ZZM_EV_T005',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"LAND1"::STRING AS "LAND1", 
 	 	JSONFIELD:"SPRAS"::STRING AS "SPRAS", 
 	 	JSONFIELD:"INTCA"::STRING AS "INTCA", 
 	 	JSONFIELD:"INTCA3"::STRING AS "INTCA3", 
 	 	JSONFIELD:"INTCN3"::STRING AS "INTCN3", 
 	 	JSONFIELD:"WAERS"::STRING AS "WAERS", 
 	 	JSONFIELD:"KALSM"::STRING AS "KALSM", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE", 
 	 	JSONFIELD:"XF_CountryGrpCode"::STRING AS "XF_COUNTRYGRPCODE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_ZZM_EV_T005') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_ZZM_EV_T005') }})
	),
	
	transform_data as (
	SELECT 
		"LAND1", 
 	 	"SPRAS", 
 	 	"INTCA", 
 	 	"INTCA3", 
 	 	"INTCN3", 
 	 	"WAERS", 
 	 	"KALSM", 
 	 	"DELFLAG", 
 	 	"CDCHANGENR", 
 	 	"PSL_INSDATE", 
 	 	"PSL_UPDDATE", 
 	 	"XF_COUNTRYGRPCODE",
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
	from source_data
	),
	
	type_data as (
	SELECT
		CAST("LAND1" AS NVARCHAR) AS "LAND1", 
 	 	CAST("SPRAS" AS NVARCHAR) AS "SPRAS", 
 	 	CAST("INTCA" AS NVARCHAR) AS "INTCA", 
 	 	CAST("INTCA3" AS NVARCHAR) AS "INTCA3", 
 	 	CAST("INTCN3" AS VARCHAR) AS "INTCN3", 
 	 	CAST("WAERS" AS NVARCHAR) AS "WAERS", 
 	 	CAST("KALSM" AS NVARCHAR) AS "KALSM", 
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG", 
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR", 
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE", 
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE", 
 	 	CAST("XF_COUNTRYGRPCODE" AS NVARCHAR) AS "XF_COUNTRYGRPCODE",
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
	from transform_data
	)

	select * from type_data