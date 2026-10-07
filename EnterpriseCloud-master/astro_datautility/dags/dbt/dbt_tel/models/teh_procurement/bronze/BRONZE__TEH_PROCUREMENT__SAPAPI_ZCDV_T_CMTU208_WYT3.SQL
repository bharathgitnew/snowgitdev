/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU208_WYT3',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:LIFNR::STRING AS LIFNR,
		JSONFIELD:EKORG::STRING AS EKORG,
		JSONFIELD:LTSNR::STRING AS LTSNR,
		JSONFIELD:WERKS::STRING AS WERKS,
		JSONFIELD:PARVW::STRING AS PARVW,
		JSONFIELD:PARZA::STRING AS PARZA,
		JSONFIELD:ERNAM::STRING AS ERNAM,
		JSONFIELD:ERDAT::STRING AS ERDAT,
		JSONFIELD:LIFN2::STRING AS LIFN2,
		JSONFIELD:DEFPA::STRING AS DEFPA,
		JSONFIELD:Pernr::STRING AS PERNR,
		JSONFIELD:Parnr::STRING AS PARNR,
		JSONFIELD:update_date::STRING AS UPDATE_DATE
    FROM {{ source('SAPH','SAP_SDM_EV_WYT3_GMX') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_WYT3_GMX'
        )
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY EKORG, LIFNR, LTSNR, PARVW, PARZA, WERKS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		LIFNR as LIFNR,
		EKORG as EKORG,
		COALESCE("LTSNR",'') AS "LTSNR",--Changes as a part of GMX migration
 	 	COALESCE("WERKS",'') AS "WERKS",--Changes as a part of GMX migration
		PARVW as PARVW,
		LPAD("PARZA",3,'0') AS "PARZA",
		COALESCE("ERNAM",'') AS "ERNAM",--Changes as a part of GMX migration
 	 	COALESCE(REGEXP_REPLACE(TRY_TO_DATE("ERDAT"),'-',''),'') AS "ERDAT",--Changes as a part of GMX migration
		LIFN2 as LIFN2,
		Case when "DEFPA"='X' then 'true' else 'false' end as "DEFPA",
		PERNR as PERNR,
		PARNR as PARNR,
		UPDATE_DATE as UPDATE_DATE
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		MANDT,
		LIFNR,
		EKORG,
		LTSNR,
		WERKS,
		PARVW,
		PARZA,
		ERNAM,
		ERDAT,
		LIFN2,
		DEFPA,
		PERNR,
		PARNR,
		UPDATE_DATE
    FROM transform_data 
)

	select * from type_data