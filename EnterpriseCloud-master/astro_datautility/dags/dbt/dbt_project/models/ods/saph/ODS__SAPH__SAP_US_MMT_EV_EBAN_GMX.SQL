

	/************
	Model file generated from gmxDbtTemplateUtility.ipynb
	*************/


	{{ config(
	  materialized='incremental',
	  incremental_strategy='merge',
	  alias='SAP_US_MMT_EV_EBAN_GMX',
	  unique_key = ['BANFN','BNFPO'],
	  transient=false,
	  enabled=false
	) }}

	with source_data as (
	SELECT
    	_FILEDATE,
		_FILENAME,
		JSONFIELD:"BANFN"::STRING AS "BANFN",
 	 	JSONFIELD:"BNFPO"::STRING AS "BNFPO",
 	 	JSONFIELD:"LOEKZ"::STRING AS "LOEKZ",
 	 	JSONFIELD:"MATNR"::STRING AS "MATNR",
 	 	JSONFIELD:"WERKS"::STRING AS "WERKS",
 	 	JSONFIELD:"LGORT"::STRING AS "LGORT",
 	 	JSONFIELD:"MENGE"::STRING AS "MENGE",
 	 	JSONFIELD:"MEINS"::STRING AS "MEINS",
 	 	JSONFIELD:"EBELN"::STRING AS "EBELN",
 	 	JSONFIELD:"EBELP"::STRING AS "EBELP",
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG",
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR",
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE",
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE"
	from {{ source('SAPH','SAP_US_MMT_EV_EBAN_GMX') }}
	{% if is_incremental() %}WHERE  _FILENAME > IFNULL((SELECT MAX(_FILENAME) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"BANFN"::STRING,JSONFIELD:"BNFPO"::STRING  ORDER BY _FILEDATE DESC )) = 1
	),

	transform_data as (
	SELECT
		_FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
		"BANFN",
 	 	LPAD("BNFPO",5,'0') as "BNFPO",
		coalesce("LOEKZ",'') as "LOEKZ",
 	 	"MATNR",
 	 	"WERKS",
		coalesce("LGORT",'') as "LGORT",
 	 	"MENGE",
 	 	"MEINS",
 	 	"EBELN",
 	 	LPAD("EBELP",5,'0') as "EBELP",
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
		CAST("BANFN" AS VARCHAR) AS "BANFN",
 	 	CAST("BNFPO" AS VARCHAR) AS "BNFPO",
 	 	CAST("LOEKZ" AS VARCHAR) AS "LOEKZ",
 	 	CAST("MATNR" AS VARCHAR) AS "MATNR",
 	 	CAST("WERKS" AS VARCHAR) AS "WERKS",
 	 	CAST("LGORT" AS VARCHAR) AS "LGORT",
 	 	CAST("MENGE" AS VARCHAR) AS "MENGE",
 	 	CAST("MEINS" AS VARCHAR) AS "MEINS",
 	 	CAST("EBELN" AS VARCHAR) AS "EBELN",
 	 	CAST("EBELP" AS VARCHAR) AS "EBELP",
 	 	CAST("DELFLAG" AS BOOLEAN) AS "DELFLAG",
 	 	CAST("CDCHANGENR" AS VARCHAR) AS "CDCHANGENR",
 	 	CAST("PSL_INSDATE" AS TIMESTAMP) AS "PSL_INSDATE",
 	 	CAST("PSL_UPDDATE" AS TIMESTAMP) AS "PSL_UPDDATE"
	from transform_data
	)

	select * from type_data

