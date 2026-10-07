

	/************
	Model file generated from gmxDbtTemplateUtility.ipynb
	*************/


	{{ config(
	  materialized='incremental',
	  incremental_strategy='merge',
	  alias='SAP_US_PPT_EV_RESBOR',
	  unique_key = ['RSNUM','RSPOS','RSART'],
	  transient=false,
	  enabled=false
	) }}

	with source_data as (
	SELECT
    	_FILEDATE,
		_FILENAME,
		JSONFIELD:"RSNUM"::STRING AS "RSNUM",
 	 	JSONFIELD:"RSPOS"::STRING AS "RSPOS",
 	 	JSONFIELD:"RSART"::STRING AS "RSART",
 	 	JSONFIELD:"CHARG"::STRING AS "CHARG",
 	 	JSONFIELD:"AUFNR"::STRING AS "AUFNR",
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG",
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR",
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE",
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE"
	from {{ source('SAPH','SAP_US_PPT_EV_RESBOR') }}
	{% if is_incremental() %}WHERE  _FILENAME > IFNULL((SELECT MAX(_FILENAME) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"RSNUM"::STRING,JSONFIELD:"RSPOS"::STRING,JSONFIELD:"RSART"::STRING  ORDER BY _FILEDATE DESC )) = 1
	),

	transform_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		CASE WHEN LENGTH("RSNUM")<10 THEN LPAD("RSNUM",10,'0') ELSE RSNUM END AS "RSNUM",--Changes as a part of GMX migration
 	 	CASE WHEN LENGTH("RSPOS")<4 THEN LPAD("RSPOS",4,'0') ELSE RSPOS END AS "RSPOS",--Changes as a part of GMX migration
 	 	COALESCE("RSART",'') AS "RSART",--Changes as a part of GMX migration
 	 	COALESCE("CHARG",'') AS "CHARG",--Changes as a part of GMX migration
 	 	"AUFNR",
 	 	"DELFLAG",
 	 	"CDCHANGENR",
 	 	"PSL_INSDATE",
 	 	"PSL_UPDDATE"
	from source_data
	),

	type_data as (
	SELECT
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		CAST("RSNUM" AS VARCHAR) AS "RSNUM",
 	 	CAST("RSPOS" AS VARCHAR) AS "RSPOS",
 	 	CAST("RSART" AS NVARCHAR) AS "RSART",
 	 	CAST("CHARG" AS NVARCHAR) AS "CHARG",
 	 	CAST("AUFNR" AS NVARCHAR) AS "AUFNR",
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG",
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR",
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE",
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE"
	from transform_data
	)

	select * from type_data

