/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SAPAPI_ZCDV_T_CMTU139_T685T',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:SPRAS::STRING AS SPRAS,
		JSONFIELD:KVEWE::STRING AS KVEWE,
		JSONFIELD:KAPPL::STRING AS KAPPL,
		JSONFIELD:KSCHL::STRING AS KSCHL,
		JSONFIELD:VTEXT::STRING AS VTEXT
    from {{ source('SAPH','SAP_SDM_EV_T685T_GMX') }}
    WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_T685T_GMX'
        )
	and SPRAS  ='EN'
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY KAPPL, KSCHL, KVEWE, SPRAS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		SPRAS as SPRAS,
		KVEWE as KVEWE,
		KAPPL as KAPPL,
		KSCHL as KSCHL,
		VTEXT as VTEXT
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		MANDT,
		SPRAS,
		KVEWE,
		KAPPL,
		KSCHL,
		VTEXT
    FROM transform_data 
)

	select * from type_data

