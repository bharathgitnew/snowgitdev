/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU092_CSKT',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:KOKRS::STRING AS KOKRS,
		JSONFIELD:KOSTL::STRING AS KOSTL,
		JSONFIELD:DATBI::STRING AS DATBI,
		JSONFIELD:KTEXT::STRING AS KTEXT,
		JSONFIELD:LTEXT::STRING AS LTEXT,
		JSONFIELD:MCTXT::STRING AS MCTXT,
		JSONFIELD:update_date::STRING AS UPDATE_DATE
    	FROM {{ source('SAPH','SAP_COM_EV_CSKT') }}
		WHERE _FILEDATE::STRING = (
			SELECT MAX(RUN_TIME)::STRING
			FROM {{ source('SAPH', 'CONTROLTABLE') }}
			WHERE TABLE_NAME = 'SAP_COM_EV_CSKT'
        )
QUALIFY ROW_NUMBER() OVER ( PARTITION BY DATBI, KOKRS, KOSTL, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		SPRAS as SPRAS,
		KOKRS as KOKRS,
		KOSTL as KOSTL,
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("DATBI"),'-',''),'') as "DATBI",
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
		KOKRS,
		KOSTL,
		DATBI,
		KTEXT,
		LTEXT,
		MCTXT,
		UPDATE_DATE
    FROM transform_data 
)

	select * from type_data