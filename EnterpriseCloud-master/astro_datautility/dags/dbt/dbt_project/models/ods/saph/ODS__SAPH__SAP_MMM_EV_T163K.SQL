/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_MMM_EV_T163K',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"KNTTP"::STRING AS "KNTTP", 
 	 	JSONFIELD:"KZVBR"::STRING AS "KZVBR", 
 	 	JSONFIELD:"KNTAE"::STRING AS "KNTAE", 
 	 	JSONFIELD:"REUPD"::STRING AS "REUPD", 
 	 	JSONFIELD:"WEPOS"::STRING AS "WEPOS", 
 	 	JSONFIELD:"WEPOV"::STRING AS "WEPOV", 
 	 	JSONFIELD:"WEUNB"::STRING AS "WEUNB", 
 	 	JSONFIELD:"WEUNV"::STRING AS "WEUNV", 
 	 	JSONFIELD:"REPOS"::STRING AS "REPOS", 
 	 	JSONFIELD:"REPOV"::STRING AS "REPOV", 
 	 	JSONFIELD:"KOMOK"::STRING AS "KOMOK", 
 	 	JSONFIELD:"KNTDY"::STRING AS "KNTDY", 
 	 	JSONFIELD:"SOBKZ"::STRING AS "SOBKZ", 
 	 	JSONFIELD:"KONAB"::STRING AS "KONAB", 
 	 	JSONFIELD:"TAXIK"::STRING AS "TAXIK", 
 	 	JSONFIELD:"XBNSB"::STRING AS "XBNSB", 
 	 	JSONFIELD:"VRTKZ"::STRING AS "VRTKZ", 
 	 	JSONFIELD:"TWRKZ"::STRING AS "TWRKZ", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_MMM_EV_T163K') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_MMM_EV_T163K') }})
	),
	
	transform_data as (
	SELECT 
		"KNTTP", 
 	 	"KZVBR", 
 	 	"KNTAE", 
 	 	"REUPD", 
 	 	"WEPOS", 
 	 	"WEPOV", 
 	 	"WEUNB", 
 	 	"WEUNV", 
 	 	"REPOS", 
 	 	"REPOV", 
 	 	"KOMOK", 
 	 	"KNTDY", 
 	 	"SOBKZ", 
 	 	"KONAB", 
 	 	"TAXIK", 
 	 	"XBNSB", 
 	 	"VRTKZ", 
 	 	"TWRKZ", 
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
		CAST("KNTTP" AS NVARCHAR) AS "KNTTP", 
 	 	CAST("KZVBR" AS NVARCHAR) AS "KZVBR", 
 	 	CAST("KNTAE" AS NVARCHAR) AS "KNTAE", 
 	 	CAST("REUPD" AS NVARCHAR) AS "REUPD", 
 	 	CAST("WEPOS" AS NVARCHAR) AS "WEPOS", 
 	 	CAST("WEPOV" AS NVARCHAR) AS "WEPOV", 
 	 	CAST("WEUNB" AS NVARCHAR) AS "WEUNB", 
 	 	CAST("WEUNV" AS NVARCHAR) AS "WEUNV", 
 	 	CAST("REPOS" AS NVARCHAR) AS "REPOS", 
 	 	CAST("REPOV" AS NVARCHAR) AS "REPOV", 
 	 	CAST("KOMOK" AS NVARCHAR) AS "KOMOK", 
 	 	CAST("KNTDY" AS NVARCHAR) AS "KNTDY", 
 	 	CAST("SOBKZ" AS NVARCHAR) AS "SOBKZ", 
 	 	CAST("KONAB" AS NVARCHAR) AS "KONAB", 
 	 	CAST("TAXIK" AS NVARCHAR) AS "TAXIK", 
 	 	CAST("XBNSB" AS NVARCHAR) AS "XBNSB", 
 	 	CAST("VRTKZ" AS NVARCHAR) AS "VRTKZ", 
 	 	CAST("TWRKZ" AS NVARCHAR) AS "TWRKZ", 
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