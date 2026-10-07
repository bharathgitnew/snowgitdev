{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_PROGRESS_STATUSES'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:StatusName_J::String AS StatusName_J,
	JSONFIELD:StatusName_E::String AS StatusName_E,
	JSONFIELD:Precedence::Number(38,0) AS Precedence,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Progress_Statuses') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Progress_Statuses') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	StatusName_J
,	StatusName_E
,	Precedence
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	StatusName_J
,	StatusName_E
,	Precedence
 from transform_data 
)
SELECT * from type_data