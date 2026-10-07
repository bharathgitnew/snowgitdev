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
	ID AS ID,
	REPORTATTACHMENTID AS REPORTATTACHMENTID,
	PARMANENTMEASUREID AS PARMANENTMEASUREID,
	_FILEDATE,
	_FILENAME
FROM {{ ref('ODS__QVICS_C_TMEA__PARMANENTMEASURE_REPORTATTACHMENTS') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ ref('ODS__QVICS_C_TMEA__PARMANENTMEASURE_REPORTATTACHMENTS') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE,
	_FILENAME,
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	 SHA2('hash_me') AS _ROW_HASH,
	ID,
	REPORTATTACHMENTID,
	PARMANENTMEASUREID
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	ID,
	REPORTATTACHMENTID,
	PARMANENTMEASUREID
 from transform_data 
)
SELECT * from type_data