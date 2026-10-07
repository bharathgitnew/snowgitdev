

	/************
	Model file generated from gmxDbtTemplateUtility.ipynb
	*************/


	{{ config(
	  materialized='incremental',
	  incremental_strategy='insert_overwrite',
	  alias='SAP_SDM_EV_DD07T_GMX',
	  transient=false,
	  enabled=false
	) }}

	with source_data as (
	SELECT
    	_FILEDATE,
		_FILENAME,
		JSONFIELD:"DOMNAME"::STRING AS "DOMNAME",
 	 	JSONFIELD:"DDLANGUAGE"::STRING AS "DDLANGUAGE",
 	 	JSONFIELD:"AS4LOCAL"::STRING AS "AS4LOCAL",
 	 	JSONFIELD:"VALPOS"::STRING AS "VALPOS",
 	 	JSONFIELD:"AS4VERS"::STRING AS "AS4VERS",
 	 	JSONFIELD:"DDTEXT"::STRING AS "DDTEXT",
 	 	JSONFIELD:"DOMVALUE_L"::STRING AS "DOMVALUE_L",
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG",
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR",
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE",
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE"
	from {{ source('SAPH','SAP_SDM_EV_DD07T_GMX') }}
	    WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_SDM_EV_DD07T_GMX') }})  
		AND JSONFIELD:"DDLANGUAGE"::STRING='EN' --Changes as a part of GMX migration
	),

	transform_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"DOMNAME",
 	 	"DDLANGUAGE",
 	 	"AS4LOCAL",
 	 	"VALPOS",
 	 	"AS4VERS",
 	 	"DDTEXT",
 	 	"DOMVALUE_L",
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
		CAST("DOMNAME" AS NVARCHAR) AS "DOMNAME",
 	 	CAST("DDLANGUAGE" AS NVARCHAR) AS "DDLANGUAGE",
 	 	CAST("AS4LOCAL" AS NVARCHAR) AS "AS4LOCAL",
 	 	CAST("VALPOS" AS VARCHAR) AS "VALPOS",
 	 	CAST("AS4VERS" AS VARCHAR) AS "AS4VERS",
 	 	CAST("DDTEXT" AS NVARCHAR) AS "DDTEXT",
 	 	CAST("DOMVALUE_L" AS NVARCHAR) AS "DOMVALUE_L",
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG",
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR",
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE",
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE"
	from transform_data
	)

	select * from type_data

