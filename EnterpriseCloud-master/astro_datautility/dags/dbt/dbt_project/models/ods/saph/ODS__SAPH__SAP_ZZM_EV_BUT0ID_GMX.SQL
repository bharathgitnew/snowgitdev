

	/************
	Model file generated from gmxDbtTemplateUtility.ipynb
	*************/


	{{ config(
	  materialized='incremental',
	  incremental_strategy='insert_overwrite',
	  alias='SAP_ZZM_EV_BUT0ID_GMX',
	  transient=false
	) }}

	with source_data as (
	SELECT
    	_FILEDATE,
		_FILENAME,
		JSONFIELD:"PARTNER"::STRING AS "PARTNER",
 	 	JSONFIELD:"TYPE"::STRING AS "TYPE",
 	 	JSONFIELD:"IDNUMBER"::STRING AS "IDNUMBER",
 	 	JSONFIELD:"VALID_DATE_FROM"::STRING AS "VALID_DATE_FROM",
 	 	JSONFIELD:"VALID_DATE_TO"::STRING AS "VALID_DATE_TO",
 	 	JSONFIELD:"IDNUMBER_GUID"::STRING AS "IDNUMBER_GUID",
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG",
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR",
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE",
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE"
	from {{ source('SAPH','SAP_ZZM_EV_BUT0ID_GMX') }}
	    WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_ZZM_EV_BUT0ID_GMX') }})
	),

	transform_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"PARTNER",
 	 	"TYPE",
 	 	"IDNUMBER",
 	 	"VALID_DATE_FROM",
 	 	"VALID_DATE_TO",
 	 	"IDNUMBER_GUID",
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
		CAST("PARTNER" AS NVARCHAR) AS "PARTNER",
 	 	CAST("TYPE" AS NVARCHAR) AS "TYPE",
 	 	CAST("IDNUMBER" AS NVARCHAR) AS "IDNUMBER",
 	 	CAST("VALID_DATE_FROM" AS TIMESTAMP) AS "VALID_DATE_FROM",
 	 	CAST("VALID_DATE_TO" AS TIMESTAMP) AS "VALID_DATE_TO",
 	 	CAST("IDNUMBER_GUID" AS NVARCHAR) AS "IDNUMBER_GUID",
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG",
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR",
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE",
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE"
	from transform_data
	)

	select * from type_data

