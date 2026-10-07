/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='incremental',
          incremental_strategy='merge',
          alias='ZCDV_T_CMTU246_EBEWH',
          unique_key = ['MATNR','BWKEY','BWTAR','SOBKZ','VBELN','POSNR','LFGJA','LFMON'],
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
		JSONFIELD:SOBKZ::STRING as SOBKZ,
		JSONFIELD:VBELN::STRING as VBELN,
		JSONFIELD:POSNR::STRING as POSNR,
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
        FROM {{ source('SAPH', 'SAP_US_MMT_EV_EBEWH') }} AS ZCDV_T_CMTU246_EBEWH
		{% if is_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"MATNR"::STRING,JSONFIELD:"BWKEY"::STRING,JSONFIELD:"BWTAR"::STRING,JSONFIELD:"SOBKZ"::STRING,JSONFIELD:"VBELN"::STRING,JSONFIELD:"POSNR"::STRING,JSONFIELD:"LFGJA"::STRING,JSONFIELD:"LFMON"::STRING  ORDER BY _FILEDATE DESC )) = 1
    --where _FILEDATE = (select ifnull(try_to_timestamp_ntz(max(MAX_FILE_DATE), 'YYYY-MM-DD_hh_mi_ss_ff6'), '1970-01-01') from {{ source('SAPAPI', 'CONTROLTABLE') }} where TABLE_NAME = 'ZCDV_T_CMTU246')
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
 	 	COALESCE("BWTAR",'') AS "BWTAR",
 	 	"SOBKZ", 
 	 	"VBELN", 
 	 	LPAD("POSNR",6,'0') AS "POSNR",
 	 	"LFGJA", 
 	 	LPAD("LFMON",2,'0') AS "LFMON",
 	 	"LBKUM", 
 	 	"SALK3", 
 	 	"VPRSV", 
 	 	"VERPR", 
 	 	"STPRS", 
 	 	"PEINH", 
 	 	"BKLAS", 
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
 	 	"SOBKZ", 
 	 	"VBELN", 
 	 	"POSNR", 
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