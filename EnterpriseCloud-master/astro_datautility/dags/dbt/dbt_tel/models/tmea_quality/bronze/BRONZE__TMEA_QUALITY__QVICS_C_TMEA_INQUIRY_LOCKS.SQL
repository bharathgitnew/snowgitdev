{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_INQUIRY_LOCKS'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:id::Number(38,0) AS id,
	JSONFIELD:InquiryID::Number(38,0) AS InquiryID,
	JSONFIELD:LockedBy::String AS LockedBy,
	JSONFIELD:LockedByName::String AS LockedByName,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:LockedAt,'/Date()/')) AS LockedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'Inquiry_Locks') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'Inquiry_Locks') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	id
,	InquiryID
,	LockedBy
,	LockedByName
,	LockedAt
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	id
,	InquiryID
,	LockedBy
,	LockedByName
,	LockedAt
 from transform_data 
)
SELECT * from type_data