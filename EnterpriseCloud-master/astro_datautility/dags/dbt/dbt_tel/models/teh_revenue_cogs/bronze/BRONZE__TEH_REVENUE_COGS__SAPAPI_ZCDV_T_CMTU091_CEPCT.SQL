/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU091_CEPCT',
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:"Mandt"::STRING AS MANDT, -- No Mapping in GMX
		JSONFIELD:"SPRAS"::STRING AS SPRAS,
		JSONFIELD:"PRCTR"::STRING AS PRCTR,
		JSONFIELD:"DATBI"::STRING AS DATBI,
		JSONFIELD:"KOKRS"::STRING AS KOKRS,
		JSONFIELD:"KTEXT"::STRING AS KTEXT,
		JSONFIELD:"LTEXT"::STRING AS LTEXT,
		JSONFIELD:"Mctxt"::STRING AS MCTXT, -- No Mapping in GMX
		JSONFIELD:"update_date"::STRING AS UPDATE_DATE -- No Mapping in GMX
    FROM {{ source('SAPH','SAP_COM_EV_CEPCT') }}
		WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_COM_EV_CEPCT'
        )	
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY DATBI, KOKRS, PRCTR, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		SPRAS as SPRAS,
		PRCTR as PRCTR,
		TO_CHAR(TO_DATE(DATBI), 'YYYYMMDD') AS DATBI,
		KOKRS as KOKRS,
		KTEXT as KTEXT,
		LTEXT as LTEXT,
		MCTXT as MCTXT,
		UPDATE_DATE as UPDATE_DATE
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		SPRAS,
		PRCTR,
		DATBI,
		KOKRS,
		KTEXT,
		LTEXT,
		MCTXT,
		UPDATE_DATE
    FROM transform_data 
)

	select * from type_data