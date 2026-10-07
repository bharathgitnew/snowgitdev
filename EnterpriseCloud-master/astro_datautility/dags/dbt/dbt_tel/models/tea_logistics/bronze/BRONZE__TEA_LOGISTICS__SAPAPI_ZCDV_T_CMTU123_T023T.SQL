/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
    	  alias='SAPAPI_ZCDV_T_CMTU123_T023T',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT DISTINCT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:MATKL::STRING AS MATKL,
		JSONFIELD:WGBEZ::STRING AS WGBEZ,
		JSONFIELD:WGBEZ60::STRING AS WGBEZ60
    FROM {{ source('SAPH','SAP_MMM_EV_T023T') }}
   WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_MMM_EV_T023T'
        )
	and SPRAS = 'EN' --in sync with SAPAPI
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY MATKL, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        MANDT as MANDT,
        SPRAS as SPRAS,
        MATKL as MATKL,
        WGBEZ as WGBEZ,
        IFNULL(WGBEZ60, '') as WGBEZ60 -- to be in sync with SAPAPI
FROM source_data 
),

type_data as (
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        MANDT,
        SPRAS,
        MATKL,
        WGBEZ,
        WGBEZ60
FROM transform_data 
)

	select * from type_data