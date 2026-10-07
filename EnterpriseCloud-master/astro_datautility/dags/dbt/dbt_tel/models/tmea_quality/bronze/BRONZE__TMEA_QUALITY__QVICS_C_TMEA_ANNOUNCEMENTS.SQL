{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_ANNOUNCEMENTS'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:announcement_J::String AS announcement_J,
	JSONFIELD:announcement_E::String AS announcement_E,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:announcedAt,'/Date()/')) AS announcedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:validUntil,'/Date()/')) AS validUntil,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:createdAt,'/Date()/')) AS createdAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:updatedAt,'/Date()/')) AS updatedAt,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:deletedAt,'/Date()/')) AS deletedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Announcements') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Announcements') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	announcement_J
,	announcement_E
,	announcedAt
,	validUntil
,	createdAt
,	updatedAt
,	deletedAt
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	announcement_J
,	announcement_E
,	announcedAt
,	validUntil
,	createdAt
,	updatedAt
,	deletedAt
 from transform_data 
)
SELECT * from type_data