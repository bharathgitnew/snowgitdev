/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU206_LFBW',
    	  tags=["finance"],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:"LIFNR"::STRING AS "LIFNR",
 	 	JSONFIELD:"BUKRS"::STRING AS "BUKRS",
 	 	JSONFIELD:"WITHT"::STRING AS "WITHT",
		JSONFIELD:"WT_SUBJCT"::STRING AS "WTSUBJCT",
 	 	JSONFIELD:"QSREC"::STRING AS "QSREC",
 	 	JSONFIELD:"WT_WTSTCD"::STRING AS "WTWTSTCD",
 	 	JSONFIELD:"WT_WITHCD"::STRING AS "WTWITHCD",
 	 	JSONFIELD:"WT_EXNR"::STRING AS "WTEXNR",
 	 	JSONFIELD:"WT_EXRT"::STRING AS "WTEXRT",
 	 	JSONFIELD:"WT_EXDF"::STRING AS "WTEXDF",
 	 	JSONFIELD:"WT_EXDT"::STRING AS "WTEXDT",
 	 	JSONFIELD:"WT_WTEXRS"::STRING AS "WTWTEXRS"
    FROM {{ source('SAPH','SAP_FIM_EV_LFBW_GMX') }}
    WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_FIM_EV_LFBW_GMX'
        )
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY BUKRS, LIFNR, WITHT ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		LIFNR as LIFNR,
		BUKRS as BUKRS,
		WITHT as WITHT,
		Case when "WTSUBJCT"='X' then 'true' else 'false' end as WTSUBJCT,
		coalesce(QSREC,'') as QSREC,
		coalesce(WTWTSTCD,'') as WTWTSTCD,
		LPAD(coalesce(WTWITHCD,''),2,'0') as WTWITHCD,
		coalesce(WTEXNR,'') as WTEXNR,
		WTEXRT as WTEXRT,
		LPAD(coalesce(WTEXDF,''),8,'0') as WTEXDF,
		LPAD(coalesce(WTEXDT,''),8,'0') as WTEXDT,
		coalesce(WTWTEXRS,'') as WTWTEXRS
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
		BUKRS,
		WITHT,
		WTSUBJCT,
		QSREC,
		WTWTSTCD,
		WTWITHCD,
		WTEXNR,
		CAST(WTEXRT as number(38,2)) as WTEXRT,
		WTEXDF,
		WTEXDT,
		WTWTEXRS
    FROM transform_data 
)

	select * from type_data

