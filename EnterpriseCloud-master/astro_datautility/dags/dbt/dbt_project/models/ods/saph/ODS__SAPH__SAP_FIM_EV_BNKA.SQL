/************
	Model file generated from gmxDbtTemplateUtility.ipynb 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAP_FIM_EV_BNKA',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
		JSONFIELD:"BANKS"::STRING AS "BANKS", 
 	 	JSONFIELD:"BANKL"::STRING AS "BANKL", 
 	 	JSONFIELD:"ERDAT"::STRING AS "ERDAT", 
 	 	JSONFIELD:"ERNAM"::STRING AS "ERNAM", 
 	 	JSONFIELD:"BANKA"::STRING AS "BANKA", 
 	 	JSONFIELD:"PROVZ"::STRING AS "PROVZ", 
 	 	JSONFIELD:"STRAS"::STRING AS "STRAS", 
 	 	JSONFIELD:"ORT01"::STRING AS "ORT01", 
 	 	JSONFIELD:"SWIFT"::STRING AS "SWIFT", 
 	 	JSONFIELD:"BGRUP"::STRING AS "BGRUP", 
 	 	JSONFIELD:"XPGRO"::STRING AS "XPGRO", 
 	 	JSONFIELD:"LOEVM"::STRING AS "LOEVM", 
 	 	JSONFIELD:"BNKLZ"::STRING AS "BNKLZ", 
 	 	JSONFIELD:"PSKTO"::STRING AS "PSKTO", 
 	 	JSONFIELD:"ADRNR"::STRING AS "ADRNR", 
 	 	JSONFIELD:"BRNCH"::STRING AS "BRNCH", 
 	 	JSONFIELD:"CHKME"::STRING AS "CHKME", 
 	 	JSONFIELD:"VERS"::STRING AS "VERS", 
 	 	JSONFIELD:"BICKY"::STRING AS "BICKY", 
 	 	JSONFIELD:"RCCODE"::STRING AS "RCCODE", 
 	 	JSONFIELD:"DELFLAG"::STRING AS "DELFLAG", 
 	 	JSONFIELD:"CDCHANGENR"::STRING AS "CDCHANGENR", 
 	 	JSONFIELD:"PSL_INSDATE"::STRING AS "PSL_INSDATE", 
 	 	JSONFIELD:"PSL_UPDDATE"::STRING AS "PSL_UPDDATE",
		_FILEDATE,
		_FILENAME
	from {{ source('SAPH','SAP_FIM_EV_BNKA') }}
	WHERE REGEXP_SUBSTR(_FILENAME,'\\d{14}') = (SELECT MAX(REGEXP_SUBSTR(_filename,'\\d{14}')) from {{ source('SAPH', 'SAP_FIM_EV_BNKA') }})
	),
	
	transform_data as (
	SELECT 
		"BANKS", 
 	 	"BANKL", 
 	 	"ERDAT", 
 	 	"ERNAM", 
 	 	"BANKA", 
 	 	"PROVZ", 
 	 	"STRAS", 
 	 	"ORT01", 
 	 	"SWIFT", 
 	 	"BGRUP", 
 	 	"XPGRO", 
 	 	"LOEVM", 
 	 	"BNKLZ", 
 	 	"PSKTO", 
 	 	"ADRNR", 
 	 	"BRNCH", 
 	 	"CHKME", 
 	 	"VERS", 
 	 	"BICKY", 
 	 	"RCCODE", 
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
		CAST("BANKS" AS NVARCHAR) AS "BANKS", 
 	 	CAST("BANKL" AS NVARCHAR) AS "BANKL", 
 	 	CAST("ERDAT" AS TIMESTAMP) AS "ERDAT", 
 	 	CAST("ERNAM" AS NVARCHAR) AS "ERNAM", 
 	 	CAST("BANKA" AS NVARCHAR) AS "BANKA", 
 	 	CAST("PROVZ" AS NVARCHAR) AS "PROVZ", 
 	 	CAST("STRAS" AS NVARCHAR) AS "STRAS", 
 	 	CAST("ORT01" AS NVARCHAR) AS "ORT01", 
 	 	CAST("SWIFT" AS NVARCHAR) AS "SWIFT", 
 	 	CAST("BGRUP" AS NVARCHAR) AS "BGRUP", 
 	 	CAST("XPGRO" AS NVARCHAR) AS "XPGRO", 
 	 	CAST("LOEVM" AS NVARCHAR) AS "LOEVM", 
 	 	CAST("BNKLZ" AS NVARCHAR) AS "BNKLZ", 
 	 	CAST("PSKTO" AS NVARCHAR) AS "PSKTO", 
 	 	CAST("ADRNR" AS NVARCHAR) AS "ADRNR", 
 	 	CAST("BRNCH" AS NVARCHAR) AS "BRNCH", 
 	 	CAST("CHKME" AS NVARCHAR) AS "CHKME", 
 	 	CAST("VERS" AS NVARCHAR) AS "VERS", 
 	 	CAST("BICKY" AS NVARCHAR) AS "BICKY", 
 	 	CAST("RCCODE" AS NVARCHAR) AS "RCCODE", 
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