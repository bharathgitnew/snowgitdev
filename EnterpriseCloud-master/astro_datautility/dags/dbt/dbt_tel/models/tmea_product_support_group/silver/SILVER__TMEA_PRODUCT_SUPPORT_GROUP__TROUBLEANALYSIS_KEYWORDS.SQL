{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='TROUBLEANALYSIS_KEYWORDS'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
    ) }}

    with source_data as
    (
    SELECT
	TROUBLEID AS TROUBLEID,
	KEYWORDID AS KEYWORDID,
	_FILEDATE,
	_FILENAME
FROM {{ ref('BRONZE__TMEA_PRODUCT_SUPPORT_GROUP__QVICS_C_TMEA_TROUBLEANALYSIS_KEYWORDS') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ ref('BRONZE__TMEA_PRODUCT_SUPPORT_GROUP__QVICS_C_TMEA_TROUBLEANALYSIS_KEYWORDS') }})
    )
    ,transform_data as
    (
    SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	 SHA2('hash_me') AS _ROW_HASH,
	_FILEDATE,
	_FILENAME,
	TROUBLEID,
	KEYWORDID
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
	TROUBLEID,
	KEYWORDID
 from transform_data 
)
SELECT * from type_data