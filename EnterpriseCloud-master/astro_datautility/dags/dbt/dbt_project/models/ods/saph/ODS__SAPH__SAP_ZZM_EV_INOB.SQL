/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_ZZM_EV_INOB',
    	  unique_key = [''],
    	  transient=false,
	  enabled=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"CUOBJ"::STRING AS "CUOBJ", 
 	 	JSONFIELD:"KLART"::STRING AS "KLART", 
 	 	JSONFIELD:"OBTAB"::STRING AS "OBTAB", 
 	 	JSONFIELD:"OBJEK"::STRING AS "OBJEK", 
 	 	JSONFIELD:"ROBTAB"::STRING AS "ROBTAB", 
 	 	JSONFIELD:"ROBJEK"::STRING AS "ROBJEK", 
 	 	JSONFIELD:"CLINT"::STRING AS "CLINT", 
 	 	JSONFIELD:"STATU"::STRING AS "STATU", 
 	 	JSONFIELD:"CUCOZHL"::STRING AS "CUCOZHL", 
 	 	JSONFIELD:"PARENT"::STRING AS "PARENT", 
 	 	JSONFIELD:"ROOT"::STRING AS "ROOT", 
 	 	JSONFIELD:"EXPERTE"::STRING AS "EXPERTE", 
 	 	JSONFIELD:"MATNR"::STRING AS "MATNR", 
 	 	JSONFIELD:"DATUV"::STRING AS "DATUV", 
 	 	JSONFIELD:"TECHS"::STRING AS "TECHS", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_ZZM_EV_INOB') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH','SAP_ZZM_EV_INOB') }})
	
	),
	
	transform_data as (
	SELECT 
		"CUOBJ", 
 	 	"KLART", 
 	 	"OBTAB", 
 	 	"OBJEK", 
 	 	"ROBTAB", 
 	 	"ROBJEK", 
 	 	"CLINT", 
 	 	"STATU", 
 	 	"CUCOZHL", 
 	 	"PARENT", 
 	 	"ROOT", 
 	 	"EXPERTE", 
 	 	"MATNR", 
 	 	"DATUV", 
 	 	"TECHS", 
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
		CAST("CUOBJ" AS VARCHAR) AS "CUOBJ", 
 	 	CAST("KLART" AS NVARCHAR) AS "KLART", 
 	 	CAST("OBTAB" AS NVARCHAR) AS "OBTAB", 
 	 	CAST("OBJEK" AS NVARCHAR) AS "OBJEK", 
 	 	CAST("ROBTAB" AS NVARCHAR) AS "ROBTAB", 
 	 	CAST("ROBJEK" AS NVARCHAR) AS "ROBJEK", 
 	 	CAST("CLINT" AS VARCHAR) AS "CLINT", 
 	 	CAST("STATU" AS NVARCHAR) AS "STATU", 
 	 	CAST("CUCOZHL" AS VARCHAR) AS "CUCOZHL", 
 	 	CAST("PARENT" AS VARCHAR) AS "PARENT", 
 	 	CAST("ROOT" AS VARCHAR) AS "ROOT", 
 	 	CAST("EXPERTE" AS NVARCHAR) AS "EXPERTE", 
 	 	CAST("MATNR" AS NVARCHAR) AS "MATNR", 
 	 	CAST("DATUV" AS TIMESTAMP) AS "DATUV", 
 	 	CAST("TECHS" AS NVARCHAR) AS "TECHS", 
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