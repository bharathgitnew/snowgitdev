/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU023_TVAKT',
    	  unique_key = [''],
    	  tags=["finance"],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:AUART::STRING AS AUART,
		JSONFIELD:BEZEI::STRING AS BEZEI
    from {{ source('SAPH','SAP_SDM_EV_TVAKT') }}
    WHERE _FILEDATE = (select COALESCE(MAX(_FILEDATE),'1900-01-01') from {{source('SAPH','SAP_SDM_EV_TVAKT')}})
	and SPRAS ='EN'
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY AUART, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		SPRAS as SPRAS,
		AUART as AUART,
		BEZEI as BEZEI
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		MANDT,
		SPRAS,
		AUART,
		BEZEI
    FROM transform_data 
)

	select * from type_data