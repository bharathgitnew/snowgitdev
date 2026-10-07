{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='ParmanentMeasure_ReportAttachments'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:id::Number(38,0) AS id,
	JSONFIELD:ReportAttachmentID::Number(38,0) AS ReportAttachmentID,
	JSONFIELD:ParmanentMeasureID::Number(38,0) AS ParmanentMeasureID,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'ParmanentMeasure_ReportAttachments') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'ParmanentMeasure_ReportAttachments') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	id
,	ReportAttachmentID
,	ParmanentMeasureID
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	id
,	ReportAttachmentID
,	ParmanentMeasureID
 from transform_data 
)
SELECT * from type_data