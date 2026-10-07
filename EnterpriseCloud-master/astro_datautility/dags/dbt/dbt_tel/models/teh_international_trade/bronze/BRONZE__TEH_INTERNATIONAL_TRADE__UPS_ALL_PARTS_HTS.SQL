/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='UPS_ALL_PARTS_HTS',
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE
        ,_FILENAME
		,JSONFIELD:"0"::STRING AS HTS_NUMBER
        ,JSONFIELD:"1"::STRING AS HTS_CODE
    FROM {{ source('UPS','UPS_ALL_PARTS_HTS') }}
	where _FILEDATE = (select max(_FILEDATE) from {{ source('UPS', 'UPS_ALL_PARTS_HTS') }})


	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		HTS_NUMBER,
		HTS_CODE
    FROM source_data
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		HTS_NUMBER,
		HTS_CODE
    FROM transform_data 
)

	select * from type_data