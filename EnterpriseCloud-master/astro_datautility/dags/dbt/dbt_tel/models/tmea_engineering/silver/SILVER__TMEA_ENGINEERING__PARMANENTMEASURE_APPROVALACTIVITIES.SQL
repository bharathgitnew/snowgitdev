{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='PARMANENTMEASURE_APPROVALACTIVITIES'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
    ) }}

    with source_data as
    (
    SELECT
	ID AS ID,
	APPROVALID AS APPROVALID,
	PARMANENTMEASUREID AS PARMANENTMEASUREID,
	TROUBLEID AS TROUBLEID,
	_FILEDATE,
	_FILENAME
FROM {{ ref('BRONZE__TMEA_ENGINEERING__QVICS_C_TMEA_PARMANENTMEASURE_APPROVALACTIVITIES') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ ref('BRONZE__TMEA_ENGINEERING__QVICS_C_TMEA_PARMANENTMEASURE_APPROVALACTIVITIES') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE,
	_FILENAME,
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	 SHA2('hash_me') AS _ROW_HASH,
	ID,
	APPROVALID,
	PARMANENTMEASUREID,
	TROUBLEID
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	ID,
	APPROVALID,
	PARMANENTMEASUREID,
	TROUBLEID
 from transform_data 
)
SELECT * from type_data