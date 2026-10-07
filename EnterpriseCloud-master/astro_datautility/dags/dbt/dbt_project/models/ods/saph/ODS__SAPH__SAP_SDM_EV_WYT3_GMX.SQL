

	/************
	Model file generated from gmxDbtTemplateUtility.ipynb
	*************/


	{{ config(
	  materialized='incremental',
	  incremental_strategy='insert_overwrite',
	  alias='SAP_SDM_EV_WYT3_GMX',
	  transient=false,
	  enabled=false
	) }}

	with source_data as (
	SELECT
    	_FILEDATE,
		_FILENAME,
		JSONFIELD:"LIFNR"::STRING AS "LIFNR",
 	 	JSONFIELD:"EKORG"::STRING AS "EKORG",
 	 	JSONFIELD:"LTSNR"::STRING AS "LTSNR",
 	 	JSONFIELD:"WERKS"::STRING AS "WERKS",
 	 	JSONFIELD:"PARVW"::STRING AS "PARVW",
 	 	JSONFIELD:"PARZA"::STRING AS "PARZA",
 	 	JSONFIELD:"ERNAM"::STRING AS "ERNAM",
 	 	JSONFIELD:"ERDAT"::STRING AS "ERDAT",
 	 	JSONFIELD:"LIFN2"::STRING AS "LIFN2",
 	 	JSONFIELD:"DEFPA"::STRING AS "DEFPA",
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG",
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR",
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE",
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE"
	from {{ source('SAPH','SAP_SDM_EV_WYT3_GMX') }}
	    WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_SDM_EV_WYT3_GMX') }})
	),

	transform_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"LIFNR",
 	 	"EKORG",
 	 	COALESCE("LTSNR",'') AS "LTSNR",--Changes as a part of GMX migration
 	 	COALESCE("WERKS",'') AS "WERKS",--Changes as a part of GMX migration
 	 	"PARVW",
 	 	LPAD("PARZA",3,'0') AS "PARZA",
 	 	COALESCE("ERNAM",'') AS "ERNAM",--Changes as a part of GMX migration
 	 	COALESCE(REGEXP_REPLACE(TRY_TO_DATE("ERDAT"),'-',''),'') AS "ERDAT",--Changes as a part of GMX migration
 	 	"LIFN2",
		Case when "DEFPA"='X' then 'true' else 'false' end as "DEFPA",
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
		CAST("LIFNR" AS NVARCHAR) AS "LIFNR",
 	 	CAST("EKORG" AS NVARCHAR) AS "EKORG",
 	 	CAST("LTSNR" AS NVARCHAR) AS "LTSNR",
 	 	CAST("WERKS" AS NVARCHAR) AS "WERKS",
 	 	CAST("PARVW" AS NVARCHAR) AS "PARVW",
 	 	CAST("PARZA" AS VARCHAR) AS "PARZA",
 	 	CAST("ERNAM" AS NVARCHAR) AS "ERNAM",
 	 	CAST("ERDAT" AS NVARCHAR) AS "ERDAT",
 	 	CAST("LIFN2" AS NVARCHAR) AS "LIFN2",
 	 	CAST("DEFPA" AS NVARCHAR) AS "DEFPA",
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG",
 	 	CAST("CDCHANGENR" AS NVARCHAR) AS "CDCHANGENR",
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE",
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE"
	from transform_data
	)

	select * from type_data

