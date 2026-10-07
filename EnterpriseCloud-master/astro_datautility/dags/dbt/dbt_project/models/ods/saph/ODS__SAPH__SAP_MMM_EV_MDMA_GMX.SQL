

	/************
	Model file generated from gmxDbtTemplateUtility.ipynb
	*************/


	{{ config(
	  materialized='incremental',
	  incremental_strategy='merge',
	  alias='SAP_MMM_EV_MDMA_GMX',
	  unique_key = ['MATNR','BERID'],
	  transient=false,
	  enabled=false
	) }}

	with source_data as (
	SELECT
    	_FILEDATE,
		_FILENAME,
		JSONFIELD:"MaterialCode"::STRING AS "MATNR",--Changes as a part of GMX migration
 	 	JSONFIELD:"MRPAreaText"::STRING AS "BERID_TEXT",--Changes as a part of GMX migration
 	 	JSONFIELD:"MRPArea"::STRING AS "BERID",--Changes as a part of GMX migration
 	 	JSONFIELD:"MRPType2"::STRING AS "DISMM",--Changes as a part of GMX migration
 	 	JSONFIELD:"SafetyStock"::STRING AS "EISBE",--Changes as a part of GMX migration
 	 	JSONFIELD:"MaximumStockLevel"::STRING AS "MABST",--Changes as a part of GMX migration
 	 	JSONFIELD:"ReorderPoint"::STRING AS "MINBE",--Changes as a part of GMX migration
 	 	JSONFIELD:"WERKS"::STRING AS "WERKS",
 	 	JSONFIELD:"BSTMA"::STRING AS "BSTMA",
 	 	JSONFIELD:"LOEKZ"::STRING AS "LOEKZ",
 	 	JSONFIELD:"AUTRU"::STRING AS "AUTRU",
 	 	JSONFIELD:"PSTAT"::STRING AS "PSTAT",
 	 	JSONFIELD:"KZKFK"::STRING AS "KZKFK",
 	 	JSONFIELD:"SCM_MATLOCID_GUID16"::STRING AS "SCM_MATLOCID_GUID16",
 	 	JSONFIELD:"SCM_MATLOCID_GUID22"::STRING AS "SCM_MATLOCID_GUID22",
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG",
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR",
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE",
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE"
	from {{ source('SAPH','SAP_MMM_EV_MDMA_GMX') }}
	{% if is_incremental() %}WHERE  _FILENAME > IFNULL((SELECT MAX(_FILENAME) FROM {{ this }}),'1970-01-01') AND JSONFIELD:"WERKS"::STRING IN(3200,3300){% endif %}--Changes as a part of GMX migration
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"MaterialCode"::STRING,JSONFIELD:"MRPArea"::STRING  ORDER BY _FILEDATE DESC )) = 1
),

	transform_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"MATNR",
 	 	"BERID_TEXT",
 	 	"BERID",
 	 	"DISMM",
 	 	"EISBE",
 	 	"MABST",
 	 	"MINBE",
 	 	"WERKS",
 	 	"BSTMA",
		Case when "LOEKZ"='X' then 'true' else 'false' end as "LOEKZ",
		Case when "AUTRU"='X' then 'true' else 'false' end as "AUTRU",
 	 	"PSTAT",
		Case when "KZKFK"='X' then 'true' else 'false' end as "KZKFK",
		substr(lower("SCM_MATLOCID_GUID16"),1,8) || '-' || substr(lower("SCM_MATLOCID_GUID16"),9,4) || '-' || substr(lower("SCM_MATLOCID_GUID16"),13,4) || '-' || substr(lower("SCM_MATLOCID_GUID16"),17,4) || '-' || substr(lower("SCM_MATLOCID_GUID16"),21) as "SCM_MATLOCID_GUID16",
 	 	"SCM_MATLOCID_GUID22",
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
		"MATNR",
 	 	"BERID_TEXT",
 	 	"BERID",
 	 	"DISMM",
 	 	CAST("EISBE" AS FLOAT) AS "EISBE",
 	 	CAST("MABST" AS FLOAT) AS "MABST",
 	 	CAST("MINBE" AS FLOAT) AS "MINBE",
 	 	"WERKS",
 	 	CAST("BSTMA" AS FLOAT) AS "BSTMA",
 	 	"LOEKZ",
 	 	"AUTRU",
 	 	"PSTAT",
 	 	"KZKFK",
 	 	"SCM_MATLOCID_GUID16",
 	 	"SCM_MATLOCID_GUID22",
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG",
 	 	"CDCHANGENR",
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE",
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE"
	from transform_data
	)

	select * from type_data

