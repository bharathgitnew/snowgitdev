/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='UPS_ALL_PARTS_MATERIAL',
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE
        ,_FILENAME
		,JSONFIELD:"0"::STRING AS GLOBAL_PRODUCT_SPEC_INFORMATION
        ,JSONFIELD:"1"::STRING AS JUGEMENT_FLAG
    FROM {{ source('UPS','UPS_ALL_PARTS_MATERIAL') }}
	where _FILEDATE = (select max(_FILEDATE) from {{ source('UPS', 'UPS_ALL_PARTS_MATERIAL') }})
    and  JSONFIELD:"0"::STRING <> 'Primary Material' 

	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		GLOBAL_PRODUCT_SPEC_INFORMATION,
		JUGEMENT_FLAG
    FROM source_data
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		GLOBAL_PRODUCT_SPEC_INFORMATION,
		JUGEMENT_FLAG
    FROM transform_data 
)

	select * from type_data