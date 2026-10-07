/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU241_A017',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:KAPPL::STRING AS KAPPL,
		JSONFIELD:KSCHL::STRING AS KSCHL,
		JSONFIELD:LIFNR::STRING AS LIFNR,
		JSONFIELD:MATNR::STRING AS MATNR,
		JSONFIELD:EKORG::STRING AS EKORG,
		JSONFIELD:WERKS::STRING AS WERKS,
		JSONFIELD:ESOKZ::STRING AS ESOKZ,
		JSONFIELD:DATBI::STRING AS DATBI,
		JSONFIELD:DATAB::STRING AS DATAB,
		JSONFIELD:KNUMH::STRING AS KNUMH
    FROM {{ source('SAPH','SAP_MMM_EV_A017') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_MMM_EV_A017'
        )
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY DATBI, EKORG, ESOKZ, KAPPL, KSCHL, LIFNR, MATNR, WERKS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		KAPPL as KAPPL,
		KSCHL as KSCHL,
		LIFNR as LIFNR,
		MATNR as MATNR,
		EKORG as EKORG,
		WERKS as WERKS,
		ESOKZ as ESOKZ,
		REGEXP_REPLACE(TRY_TO_DATE("DATBI"),'-','') AS "DATBI",--Changes as a part of GMX migration
		REGEXP_REPLACE(TRY_TO_DATE("DATAB"),'-','') AS "DATAB",--Changes as a part of GMX migration
 	 	LPAD("KNUMH",10,'0') AS "KNUMH",--Changes as a part of GMX migration
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		KAPPL,
		KSCHL,
		LIFNR,
		MATNR,
		EKORG,
		WERKS,
		ESOKZ,
		DATBI,
		DATAB,
		KNUMH
    FROM transform_data 
)

	select * from type_data