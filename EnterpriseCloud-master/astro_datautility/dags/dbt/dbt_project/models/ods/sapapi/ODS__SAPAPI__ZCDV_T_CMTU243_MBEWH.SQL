/************
    Model file generated from SAPAPIUtility
    *************/


    {{ config(
          materialized='incremental',
          incremental_strategy='merge',
          alias='ZCDV_T_CMTU243_MBEWH',
          unique_key=['MATNR','BWKEY','LFGJA','LFMON','BWTAR'],
          transient=false
) }}

    with source_data as (
        SELECT
        _FILEDATE, 
		_FILENAME,
        _UPLOADDATE,
		JSONFIELD:MATNR::STRING as MATNR,
		JSONFIELD:BWKEY::STRING as BWKEY,
		JSONFIELD:BWTAR::STRING as BWTAR,
		JSONFIELD:LFGJA::STRING as LFGJA,
		JSONFIELD:LFMON::STRING as LFMON,
		JSONFIELD:LBKUM::STRING as LBKUM,
		JSONFIELD:SALK3::STRING as SALK3,
		JSONFIELD:VPRSV::STRING as VPRSV,
		JSONFIELD:VERPR::STRING as VERPR,
		JSONFIELD:STPRS::STRING as STPRS,
		JSONFIELD:PEINH::STRING as PEINH,
		JSONFIELD:BKLAS::STRING as BKLAS,
		JSONFIELD:SALKV::STRING as SALKV,
		JSONFIELD:VKSAL::STRING as VKSAL
		from {{ source('SAPH','SAP_US_MMT_EV_MBEWH') }}
	 {% if is_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"MATNR"::STRING,JSONFIELD:"BWKEY"::STRING,JSONFIELD:"LFGJA"::STRING,JSONFIELD:"LFMON"::STRING,JSONFIELD:"BWTAR"::STRING  ORDER BY _FILEDATE DESC )) = 1
	),
    transform_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        "MATNR",
 	 	"BWKEY",
 	 	COALESCE("BWTAR",'') AS "BWTAR", --Changes as a part of GMX migration
 	 	"LFGJA",
 	 	CASE WHEN LENGTH("LFMON")=1 THEN CONCAT('0',"LFMON") ELSE "LFMON" END AS "LFMON",--Changes as a part of GMX migration
 	 	"LBKUM",
 	 	"SALK3",
		coalesce("VPRSV",'') as "VPRSV",
 	 	"VERPR",
 	 	"STPRS",
 	 	"PEINH",
		coalesce("BKLAS",'') as "BKLAS",
 	 	"SALKV",
 	 	"VKSAL"
        FROM source_data
    ),
    type_data as (
        SELECT
		_FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		AUDIT_LOG_ID,
        _ROW_HASH,
        "MATNR",
 	 	"BWKEY",
 	 	"BWTAR",
 	 	"LFGJA",
 	 	"LFMON",
 	 	"LBKUM",
 	 	"SALK3",
 	 	"VPRSV",
 	 	"VERPR",
 	 	"STPRS",
 	 	"PEINH",
 	 	"BKLAS",
 	 	"SALKV",
 	 	"VKSAL"
        FROM transform_data
    )
    SELECT * FROM type_data