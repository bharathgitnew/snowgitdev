/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU212_DFKKBPTAXNUM',
    	  unique_key = [''],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:MANDT::STRING AS MANDT,
		JSONFIELD:CLIENT::STRING AS CLIENT,
		JSONFIELD:PARTNER::STRING AS PARTNER,
		JSONFIELD:TAXTYPE::STRING AS TAXTYPE,
		JSONFIELD:TAXNUM::STRING AS TAXNUM,
		JSONFIELD:TAXNUMXL::STRING AS TAXNUMXL
    FROM {{ source('SAPH','SAP_FIM_EV_DFKKBPTAXNUM_GMX') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_FIM_EV_DFKKBPTAXNUM_GMX'
        )
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY CLIENT, PARTNER, TAXTYPE ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		CLIENT as CLIENT,
		PARTNER as PARTNER,
		TAXTYPE as TAXTYPE,
		coalesce("TAXNUM",'') as "TAXNUM",
		coalesce("TAXNUMXL",'') as "TAXNUMXL"
    FROM source_data 
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		CLIENT,
		PARTNER,
		TAXTYPE,
		TAXNUM,
		TAXNUMXL
    FROM transform_data 
)

	select * from type_data