/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='merge',
    	  alias='SAP_MMM_EV_MLAN_GMX',
    	  unique_key = ['MATNR',
    'ALAND'],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"MATNR"::STRING AS "MATNR", 
 	 	JSONFIELD:"ALAND"::STRING AS "ALAND", 
 	 	JSONFIELD:"TAXM1"::STRING AS "TAXM1", 
 	 	JSONFIELD:"TAXM2"::STRING AS "TAXM2", 
 	 	JSONFIELD:"TAXM3"::STRING AS "TAXM3", 
 	 	JSONFIELD:"TAXM4"::STRING AS "TAXM4", 
 	 	JSONFIELD:"TAXM5"::STRING AS "TAXM5", 
 	 	JSONFIELD:"TAXM6"::STRING AS "TAXM6", 
 	 	JSONFIELD:"TAXM7"::STRING AS "TAXM7", 
 	 	JSONFIELD:"TAXM8"::STRING AS "TAXM8", 
 	 	JSONFIELD:"TAXM9"::STRING AS "TAXM9", 
 	 	JSONFIELD:"TAXIM"::STRING AS "TAXIM", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_MMM_EV_MLAN_GMX') }}
	{% if is_incremental() %}WHERE  _FILENAME > IFNULL((SELECT MAX(_FILENAME) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"MATNR"::STRING,JSONFIELD:"ALAND"::STRING  ORDER BY _FILEDATE DESC )) = 1
	),
	
	transform_data as (
	SELECT 
		"MATNR", 
 	 	"ALAND", 
 	 	"TAXM1", 
 	 	"TAXM2", 
 	 	"TAXM3", 
 	 	"TAXM4", 
 	 	"TAXM5", 
 	 	"TAXM6", 
 	 	"TAXM7", 
 	 	"TAXM8", 
 	 	"TAXM9", 
 	 	"TAXIM", 
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
 	 	CAST("ALAND" AS NVARCHAR) AS "ALAND", 
 	 	CAST("TAXM1" AS NVARCHAR) AS "TAXM1", 
 	 	CAST("TAXM2" AS NVARCHAR) AS "TAXM2", 
 	 	CAST("TAXM3" AS NVARCHAR) AS "TAXM3", 
 	 	CAST("TAXM4" AS NVARCHAR) AS "TAXM4", 
 	 	CAST("TAXM5" AS NVARCHAR) AS "TAXM5", 
 	 	CAST("TAXM6" AS NVARCHAR) AS "TAXM6", 
 	 	CAST("TAXM7" AS NVARCHAR) AS "TAXM7", 
 	 	CAST("TAXM8" AS NVARCHAR) AS "TAXM8", 
 	 	CAST("TAXM9" AS NVARCHAR) AS "TAXM9", 
 	 	CAST("TAXIM" AS NVARCHAR) AS "TAXIM", 
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