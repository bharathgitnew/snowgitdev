/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_FIM_EV_SKA1',
    	  unique_key = [''],
    	  transient=false	,
	  enabled=false
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"KTOPL"::STRING AS "KTOPL", 
 	 	JSONFIELD:"SAKNR"::STRING AS "SAKNR", 
 	 	JSONFIELD:"SAKAN"::STRING AS "SAKAN", 
 	 	JSONFIELD:"BILKT"::STRING AS "BILKT", 
 	 	JSONFIELD:"ERDAT"::STRING AS "ERDAT", 
 	 	JSONFIELD:"ERNAM"::STRING AS "ERNAM", 
 	 	JSONFIELD:"XBILK"::STRING AS "XBILK", 
 	 	JSONFIELD:"GVTYP"::STRING AS "GVTYP", 
 	 	JSONFIELD:"KTOKS"::STRING AS "KTOKS", 
 	 	JSONFIELD:"XLOEV"::STRING AS "XLOEV", 
 	 	JSONFIELD:"XSPEA"::STRING AS "XSPEA", 
 	 	JSONFIELD:"XSPEB"::STRING AS "XSPEB", 
 	 	JSONFIELD:"XSPEP"::STRING AS "XSPEP", 
 	 	JSONFIELD:"MCOD1"::STRING AS "MCOD1", 
 	 	JSONFIELD:"GLACCOUNT_TYPE"::STRING AS "GLACCOUNT_TYPE", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_FIM_EV_SKA1') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_FIM_EV_SKA1') }})
	),
	
	transform_data as (
	SELECT 
		"KTOPL", 
 	 	"SAKNR", 
 	 	"SAKAN", 
 	 	"BILKT", 
 	 	"ERDAT", 
 	 	"ERNAM", 
 	 	"XBILK", 
 	 	"GVTYP", 
 	 	"KTOKS", 
 	 	"XLOEV", 
 	 	"XSPEA", 
 	 	"XSPEB", 
 	 	"XSPEP", 
 	 	"MCOD1", 
 	 	"GLACCOUNT_TYPE", 
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
		CAST("KTOPL" AS NVARCHAR) AS "KTOPL", 
 	 	CAST("SAKNR" AS NVARCHAR) AS "SAKNR", 
 	 	CAST("SAKAN" AS NVARCHAR) AS "SAKAN", 
 	 	CAST("BILKT" AS NVARCHAR) AS "BILKT", 
 	 	CAST("ERDAT" AS TIMESTAMP) AS "ERDAT", 
 	 	CAST("ERNAM" AS NVARCHAR) AS "ERNAM", 
 	 	CAST("XBILK" AS NVARCHAR) AS "XBILK", 
 	 	CAST("GVTYP" AS NVARCHAR) AS "GVTYP", 
 	 	CAST("KTOKS" AS NVARCHAR) AS "KTOKS", 
 	 	CAST("XLOEV" AS NVARCHAR) AS "XLOEV", 
 	 	CAST("XSPEA" AS NVARCHAR) AS "XSPEA", 
 	 	CAST("XSPEB" AS NVARCHAR) AS "XSPEB", 
 	 	CAST("XSPEP" AS NVARCHAR) AS "XSPEP", 
 	 	CAST("MCOD1" AS NVARCHAR) AS "MCOD1", 
 	 	CAST("GLACCOUNT_TYPE" AS NVARCHAR) AS "GLACCOUNT_TYPE", 
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