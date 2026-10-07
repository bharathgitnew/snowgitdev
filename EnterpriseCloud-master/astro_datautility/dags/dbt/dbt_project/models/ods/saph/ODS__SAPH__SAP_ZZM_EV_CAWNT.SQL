/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='merge',
    	  alias='SAP_ZZM_EV_CAWNT',
    	  unique_key = ['ATINN',
    'ADZHL',
    'ATZHL',
    'SPRAS'],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"ATINN"::STRING AS "ATINN", 
 	 	JSONFIELD:"ADZHL"::STRING AS "ADZHL", 
 	 	JSONFIELD:"ATZHL"::STRING AS "ATZHL", 
 	 	JSONFIELD:"SPRAS"::STRING AS "SPRAS", 
 	 	JSONFIELD:"ATINN_INNER"::STRING AS "ATINN_INNER", 
 	 	JSONFIELD:"ADZHL001"::STRING AS "ADZHL001", 
 	 	JSONFIELD:"ATWTB"::STRING AS "ATWTB", 
 	 	JSONFIELD:"DATUV"::STRING AS "DATUV", 
 	 	JSONFIELD:"TECHV"::STRING AS "TECHV", 
 	 	JSONFIELD:"AENNR"::STRING AS "AENNR", 
 	 	JSONFIELD:"LKENZ"::STRING AS "LKENZ", 
 	 	JSONFIELD:"ADATU"::STRING AS "ADATU", 
 	 	JSONFIELD:"VDATU"::STRING AS "VDATU", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_ZZM_EV_CAWNT') }}
	{% if is_incremental() %}WHERE  _FILENAME > IFNULL((SELECT MAX(_FILENAME) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"ATINN"::STRING,JSONFIELD:"ADZHL"::STRING,JSONFIELD:"ATZHL"::STRING,JSONFIELD:"SPRAS"::STRING  ORDER BY _FILEDATE DESC )) = 1
	),
	
	transform_data as (
	SELECT 
		"ATINN", 
 	 	"ADZHL", 
 	 	"ATZHL", 
 	 	"SPRAS", 
 	 	"ATINN_INNER", 
 	 	"ADZHL001", 
 	 	"ATWTB", 
 	 	"DATUV", 
 	 	"TECHV", 
 	 	"AENNR", 
 	 	"LKENZ", 
 	 	"ADATU", 
 	 	"VDATU", 
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
		CAST("ATINN" AS VARCHAR) AS "ATINN", 
 	 	CAST("ADZHL" AS VARCHAR) AS "ADZHL", 
 	 	CAST("ATZHL" AS VARCHAR) AS "ATZHL", 
 	 	CAST("SPRAS" AS NVARCHAR) AS "SPRAS", 
 	 	CAST("ATINN_INNER" AS VARCHAR) AS "ATINN_INNER", 
 	 	CAST("ADZHL001" AS VARCHAR) AS "ADZHL001", 
 	 	CAST("ATWTB" AS NVARCHAR) AS "ATWTB", 
 	 	CAST("DATUV" AS TIMESTAMP) AS "DATUV", 
 	 	CAST("TECHV" AS NVARCHAR) AS "TECHV", 
 	 	CAST("AENNR" AS NVARCHAR) AS "AENNR", 
 	 	CAST("LKENZ" AS NVARCHAR) AS "LKENZ", 
 	 	CAST("ADATU" AS TIMESTAMP) AS "ADATU", 
 	 	CAST("VDATU" AS TIMESTAMP) AS "VDATU", 
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