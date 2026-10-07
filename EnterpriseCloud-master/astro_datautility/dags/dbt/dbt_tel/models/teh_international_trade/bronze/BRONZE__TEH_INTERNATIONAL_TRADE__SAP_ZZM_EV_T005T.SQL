/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_ZZM_EV_T005T',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"SPRAS"::STRING AS "SPRAS", 
 	 	JSONFIELD:"LAND1"::STRING AS "LAND1", 
 	 	JSONFIELD:"LANDX"::STRING AS "LANDX", 
 	 	JSONFIELD:"NATIO"::STRING AS "NATIO", 
 	 	JSONFIELD:"LANDX50"::STRING AS "LANDX50", 
 	 	JSONFIELD:"NATIO50"::STRING AS "NATIO50", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_ZZM_EV_T005T') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_ZZM_EV_T005T') }})

	QUALIFY ROW_NUMBER() OVER ( PARTITION BY LAND1, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
	SELECT 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		_FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
		"SPRAS", 
 	 	"LAND1", 
 	 	"LANDX", 
 	 	"NATIO", 
 	 	"LANDX50", 
 	 	"NATIO50", 
 	 	"DELFLAG", 
 	 	"CDCHANGENR", 
 	 	"PSL_INSDATE", 
 	 	"PSL_UPDDATE"
	from source_data
	),
	
	type_data as (
	SELECT
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
		CAST("SPRAS" AS NVARCHAR) AS "SPRAS", 
 	 	CAST("LAND1" AS NVARCHAR) AS "LAND1", 
 	 	CAST("LANDX" AS NVARCHAR) AS "LANDX", 
 	 	CAST("NATIO" AS NVARCHAR) AS "NATIO", 
 	 	CAST("LANDX50" AS NVARCHAR) AS "LANDX50", 
 	 	CAST("NATIO50" AS NVARCHAR) AS "NATIO50", 
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG", 
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR", 
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE", 
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE"
	from transform_data
	)

	select * from type_data