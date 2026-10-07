/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_SDM_EV_A114_GMX',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"KAPPL"::STRING AS "KAPPL", 
 	 	JSONFIELD:"KSCHL"::STRING AS "KSCHL", 
 	 	JSONFIELD:"VKORG"::STRING AS "VKORG", 
 	 	JSONFIELD:"KUNNR"::STRING AS "KUNNR", 
 	 	JSONFIELD:"DATBI"::STRING AS "DATBI", 
 	 	JSONFIELD:"DATAB"::STRING AS "DATAB", 
 	 	JSONFIELD:"KNUMH"::STRING AS "KNUMH", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_SDM_EV_A114_GMX') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_SDM_EV_A114_GMX') }})
	),
	
	transform_data as (
	SELECT 
		"KAPPL", 
 	 	"KSCHL", 
 	 	"VKORG", 
 	 	"KUNNR", 
 	 	"DATBI", 
 	 	"DATAB", 
 	 	"KNUMH", 
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
		CAST("KAPPL" AS NVARCHAR) AS "KAPPL", 
 	 	CAST("KSCHL" AS NVARCHAR) AS "KSCHL", 
 	 	CAST("VKORG" AS NVARCHAR) AS "VKORG", 
 	 	CAST("KUNNR" AS NVARCHAR) AS "KUNNR", 
 	 	CAST("DATBI" AS TIMESTAMP) AS "DATBI", 
 	 	CAST("DATAB" AS TIMESTAMP) AS "DATAB", 
 	 	CAST("KNUMH" AS NVARCHAR) AS "KNUMH", 
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