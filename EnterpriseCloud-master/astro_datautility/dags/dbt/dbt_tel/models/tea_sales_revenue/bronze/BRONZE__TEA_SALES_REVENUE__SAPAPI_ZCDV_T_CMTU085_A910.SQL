/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU085_A910',
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:"Mandt"::STRING AS MANDT, -- No Mapping in GMX
		JSONFIELD:"KAPPL"::STRING AS KAPPL,
		JSONFIELD:"KSCHL"::STRING AS KSCHL,
		JSONFIELD:"ZPLAND"::STRING AS ZPLAND,
		JSONFIELD:"MATNR"::STRING AS MATNR,
		JSONFIELD:"DATBI"::STRING AS DATBI,
		JSONFIELD:"DATAB"::STRING AS DATAB,
		JSONFIELD:"KNUMH"::STRING AS KNUMH,
		JSONFIELD:"update_date"::STRING AS UPDATE_DATE -- No Mapping in GMX
    from {{ source('SAPH','SAP_SDM_EV_A910_GMX') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_A910_GMX'
        )	
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY DATBI, KAPPL, KSCHL, MATNR, ZPLAND ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	transform_data as (
		SELECT 
		_FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		KAPPL as KAPPL,
		KSCHL as KSCHL,
		ZPLAND as ZPLAND,
		MATNR as MATNR,
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("DATBI"),'-',''),'') as "DATBI",
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("DATAB"),'-',''),'') as "DATAB",
		LPAD(coalesce("KNUMH",''),10,'0') as "KNUMH",
		UPDATE_DATE as UPDATE_DATE
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
		ZPLAND,
		MATNR,
		DATBI,
		DATAB,
		KNUMH,
		UPDATE_DATE
    FROM transform_data 
)

	select * from type_data