{{ config(
        materialized='tel_incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='QVICS_C_TMEA_ASSIGNEDPEOPLE'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:ID::Number(38,0) AS ID,
	JSONFIELD:QVICSID::Number(38,0) AS QVICSID,
	JSONFIELD:DepartmentID::Number(38,0) AS DepartmentID,
	JSONFIELD:GroupID::Number(38,0) AS GroupID,
	JSONFIELD:AssignedPerson::String AS AssignedPerson,
	JSONFIELD:AssignedPersonName::String AS AssignedPersonName,
	JSONFIELD:AssignCategory::Number(38,0) AS AssignCategory,
	TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:DeletedAt,'/Date()/')) AS DeletedAt,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'AssignedPeople') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'AssignedPeople') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	ID
,	QVICSID
,	DepartmentID
,	GroupID
,	AssignedPerson
,	AssignedPersonName
,	AssignCategory
,	DeletedAt
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	ID
,	QVICSID
,	DepartmentID
,	GroupID
,	AssignedPerson
,	AssignedPersonName
,	AssignCategory
,	DeletedAt
 from transform_data 
)
SELECT * from type_data