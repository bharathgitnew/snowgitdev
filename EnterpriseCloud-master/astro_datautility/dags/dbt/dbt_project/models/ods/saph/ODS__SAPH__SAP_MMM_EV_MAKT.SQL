/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='merge',
    	  alias='SAP_MMM_EV_MAKT',
    	  unique_key = ['MATNR',
    'SPRAS'],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"MATNR"::STRING AS "MATNR", 
 	 	JSONFIELD:"ERSDA"::STRING AS "ERSDA", 
 	 	JSONFIELD:"LAEDA"::STRING AS "LAEDA", 
 	 	JSONFIELD:"SPRAS"::STRING AS "SPRAS", 
 	 	JSONFIELD:"MAKTX"::STRING AS "MAKTX", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_MMM_EV_MAKT') }}
	{% if is_incremental() %}WHERE  _FILENAME > IFNULL((SELECT MAX(_FILENAME) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"MATNR"::STRING,JSONFIELD:"SPRAS"::STRING  ORDER BY _FILEDATE DESC )) = 1
	),
	
	transform_data as (
	SELECT 
		"MATNR", 
 	 	"ERSDA", 
 	 	"LAEDA", 
 	 	"SPRAS", 
 	 	"MAKTX", 
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
		CAST("MATNR" AS NVARCHAR) AS "MATNR", 
 	 	CAST("ERSDA" AS TIMESTAMP) AS "ERSDA", 
 	 	CAST("LAEDA" AS TIMESTAMP) AS "LAEDA", 
 	 	CAST("SPRAS" AS NVARCHAR) AS "SPRAS", 
 	 	CAST("MAKTX" AS NVARCHAR) AS "MAKTX", 
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