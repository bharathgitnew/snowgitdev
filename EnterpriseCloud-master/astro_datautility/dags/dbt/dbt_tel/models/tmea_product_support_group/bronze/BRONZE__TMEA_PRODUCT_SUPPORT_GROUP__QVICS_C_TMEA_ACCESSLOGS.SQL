{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_ACCESSLOGS'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:AccessedAt,'/Date()/')) AS AccessedAt,
	JSONFIELD:AccessedBy::String AS AccessedBy,
	JSONFIELD:AccessedByName::String AS AccessedByName,
	JSONFIELD:AccessedFrom::String AS AccessedFrom,
	JSONFIELD:Controller::String AS Controller,
	JSONFIELD:Action::String AS Action,
	JSONFIELD:ActionKey::String AS ActionKey,
	JSONFIELD:Params::String AS Params,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'AccessLogs') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'AccessLogs') }})
    )
    ,transform_data as
    (
    SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	_FILEDATE
,	_FILENAME
,	ID
,	AccessedAt
,	AccessedBy
,	AccessedByName
,	AccessedFrom
,	Controller
,	Action
,	ActionKey
,	Params
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	ID
,	AccessedAt
,	AccessedBy
,	AccessedByName
,	AccessedFrom
,	Controller
,	Action
,	ActionKey
,	Params
 from transform_data 
)
SELECT * from type_data