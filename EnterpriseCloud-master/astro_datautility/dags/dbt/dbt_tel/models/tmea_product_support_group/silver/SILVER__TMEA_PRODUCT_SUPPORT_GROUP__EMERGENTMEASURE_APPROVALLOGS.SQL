{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='EMERGENTMEASURE_APPROVALLOGS'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
    ) }}

    with source_data as
    (
    SELECT
	ID AS ID,
	EMERGENTMEASUREID AS EMERGENTMEASUREID,
	APPROVALLOGID AS APPROVALLOGID,
	_FILEDATE,
	_FILENAME
FROM {{ ref('BRONZE__TMEA_PRODUCT_SUPPORT_GROUP__QVICS_C_TMEA_EMERGENTMEASURE_APPROVALLOGS') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ ref('BRONZE__TMEA_PRODUCT_SUPPORT_GROUP__QVICS_C_TMEA_EMERGENTMEASURE_APPROVALLOGS') }})
    )
    ,transform_data as
    (
    SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	 SHA2('hash_me') AS _ROW_HASH,
	_FILEDATE,
	_FILENAME,
	ID,
	EMERGENTMEASUREID,
	APPROVALLOGID
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
	ID,
	EMERGENTMEASUREID,
	APPROVALLOGID
 from transform_data 
)
SELECT * from type_data