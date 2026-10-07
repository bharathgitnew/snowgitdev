{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='TroubleForTotalization_ListColumns'
        ,unique_key = ['']
        ,tags=["qvics"]
        ,transient=false
        ) }}

    with source_data as
    (
    SELECT
	JSONFIELD:id::String AS id,
	JSONFIELD:labelName_J::String AS labelName_J,
	JSONFIELD:labelName_E::String AS labelName_E,
	JSONFIELD:columnName_J::String AS columnName_J,
	JSONFIELD:columnName_E::String AS columnName_E,
	JSONFIELD:isSelectable::String AS isSelectable,
	JSONFIELD:isHidden::String AS isHidden,
	JSONFIELD:width::Number(38,0) AS width,
	JSONFIELD:firstSortInDesc::String AS firstSortInDesc,
	JSONFIELD:precedence::Number(38,0) AS precedence,
	_FILEDATE,
	_FILENAME
FROM {{ source('QVICS', 'TroubleForTotalization_ListColumns') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('QVICS', 'TroubleForTotalization_ListColumns') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE
,	_FILENAME
,	'{{ invocation_id }}' AS _AUDIT_LOG_ID
,	 SHA2('hash_me') AS _ROW_HASH
,	id
,	labelName_J
,	labelName_E
,	columnName_J
,	columnName_E
,	isSelectable
,	isHidden
,	width
,	firstSortInDesc
,	precedence
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE
,	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME
,	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID
,	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
,	id
,	labelName_J
,	labelName_E
,	columnName_J
,	columnName_E
,	isSelectable
,	isHidden
,	width
,	firstSortInDesc
,	precedence
 from transform_data 
)
SELECT * from type_data