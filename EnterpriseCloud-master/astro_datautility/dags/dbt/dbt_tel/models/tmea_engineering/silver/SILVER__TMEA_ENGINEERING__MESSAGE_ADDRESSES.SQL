{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='MESSAGE_ADDRESSES'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
    ) }}

    with source_data as
    (
    SELECT
	ID AS ID,
	MESSAGEID AS MESSAGEID,
	ADDRESSCATEGORY AS ADDRESSCATEGORY,
	ADDRESS AS ADDRESS,
	ADDRESSNAME AS ADDRESSNAME,
	_FILEDATE,
	_FILENAME
FROM {{ ref('BRONZE__TMEA_ENGINEERING__QVICS_C_TMEA_MESSAGE_ADDRESSES') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ ref('BRONZE__TMEA_ENGINEERING__QVICS_C_TMEA_MESSAGE_ADDRESSES') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE,
	_FILENAME,
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	 SHA2('hash_me') AS _ROW_HASH,
	ID,
	MESSAGEID,
	ADDRESSCATEGORY,
	ADDRESS,
	ADDRESSNAME
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	ID,
	MESSAGEID,
	ADDRESSCATEGORY,
	ADDRESS,
	ADDRESSNAME
 from transform_data 
)
SELECT * from type_data