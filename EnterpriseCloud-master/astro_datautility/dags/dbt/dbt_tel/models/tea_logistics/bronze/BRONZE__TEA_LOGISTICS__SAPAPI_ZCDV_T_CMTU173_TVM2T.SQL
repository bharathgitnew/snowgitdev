/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
    	  alias='SAPAPI_ZCDV_T_CMTU173_TVM2T',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:MVGR2::STRING AS MVGR2,
		JSONFIELD:BEZEI::STRING AS BEZEI
    from {{ source('SAPH','SAP_MMM_EV_TVM2T') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_MMM_EV_TVM2T'
        )
	and SPRAS='EN'
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY MVGR2, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        MANDT as MANDT,
        SPRAS as SPRAS,
        MVGR2 as MVGR2,
        BEZEI as BEZEI
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
        MVGR2,
        BEZEI
FROM transform_data 
)

	select * from type_data