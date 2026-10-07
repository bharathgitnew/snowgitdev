{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_PARMANENTMEASURE_APPROVALLOGS'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:ParmanentMeasureID::Number(38,0) AS ParmanentMeasureID,
	JSONFIELD:ApprovalLogID::Number(38,0) AS ApprovalLogID,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'ParmanentMeasure_ApprovalLogs') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'ParmanentMeasure_ApprovalLogs') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	ParmanentMeasureID
,	ApprovalLogID
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	ParmanentMeasureID
,	ApprovalLogID
 from transform_data 
)
SELECT * from type_data