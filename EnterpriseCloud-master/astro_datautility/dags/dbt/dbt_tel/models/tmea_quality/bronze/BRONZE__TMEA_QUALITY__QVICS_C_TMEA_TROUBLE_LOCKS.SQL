{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_TROUBLE_LOCKS'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:id::Number(38,0) AS id,
	JSONFIELD:troubleID::Number(38,0) AS troubleID,
	JSONFIELD:lockedBy::String AS lockedBy,
	JSONFIELD:lockedByName::String AS lockedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:lockedAt,'/Date()/')) AS lockedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Trouble_Locks') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Trouble_Locks') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	id
,	troubleID
,	lockedBy
,	lockedByName
,	lockedAt
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	id
,	troubleID
,	lockedBy
,	lockedByName
,	lockedAt
 from transform_data 
)
SELECT * from type_data