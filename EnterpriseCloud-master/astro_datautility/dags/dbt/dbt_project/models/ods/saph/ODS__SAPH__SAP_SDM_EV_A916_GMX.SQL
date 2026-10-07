

	/************
	Model file generated from gmxDbtTemplateUtility.ipynb
	*************/


	{{ config(
	  materialized='incremental',
	  incremental_strategy='insert_overwrite',
	  alias='SAP_SDM_EV_A916_GMX',
	  transient=false,
	  enabled=false
	) }}

	with source_data as (
	SELECT
    	_FILEDATE,
		_FILENAME,
		JSONFIELD:"KAPPL"::STRING AS "KAPPL",
 	 	JSONFIELD:"KSCHL"::STRING AS "KSCHL",
 	 	JSONFIELD:"VKORG"::STRING AS "VKORG",
 	 	JSONFIELD:"KUNNR"::STRING AS "KUNNR",
 	 	JSONFIELD:"ZZPRCODE"::STRING AS "ZZPRCODE",
 	 	JSONFIELD:"ZZLEAPFLAG"::STRING AS "ZZLEAPFLAG",
 	 	JSONFIELD:"DATBI"::STRING AS "DATBI",
 	 	JSONFIELD:"DATAB"::STRING AS "DATAB",
 	 	JSONFIELD:"KNUMH"::STRING AS "KNUMH",
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG",
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR",
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE",
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE"
	from {{ source('SAPH','SAP_SDM_EV_A916_GMX') }}
	    WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_SDM_EV_A916_GMX') }})
	),

	transform_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"KAPPL",
 	 	"KSCHL",
 	 	"VKORG",
 	 	"KUNNR",
 	 	"ZZPRCODE",
 	 	"ZZLEAPFLAG",
 	 	REGEXP_REPLACE(TRY_TO_DATE("DATBI"),'-','') AS "DATBI",--Changes as a part of GMX migration
		REGEXP_REPLACE(TRY_TO_DATE("DATAB"),'-','') AS "DATAB",--Changes as a part of GMX migration
 	 	LPAD("KNUMH",10,'0') AS "KNUMH",--Changes as a part of GMX migration
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
		CAST("KAPPL" AS NVARCHAR) AS "KAPPL",
 	 	CAST("KSCHL" AS NVARCHAR) AS "KSCHL",
 	 	CAST("VKORG" AS NVARCHAR) AS "VKORG",
 	 	CAST("KUNNR" AS NVARCHAR) AS "KUNNR",
 	 	CAST("ZZPRCODE" AS NVARCHAR) AS "ZZPRCODE",
 	 	CAST("ZZLEAPFLAG" AS NVARCHAR) AS "ZZLEAPFLAG",
 	 	CAST("DATBI" AS VARCHAR(16777216)) AS "DATBI",
 	 	CAST("DATAB" AS VARCHAR(16777216)) AS "DATAB",
 	 	CAST("KNUMH" AS NVARCHAR) AS "KNUMH",
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG",
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR",
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE",
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE"
	from transform_data
	)

	select * from type_data

