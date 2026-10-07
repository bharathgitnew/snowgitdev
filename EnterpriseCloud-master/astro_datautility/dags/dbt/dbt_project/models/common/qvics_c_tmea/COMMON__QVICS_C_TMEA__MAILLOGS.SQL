{{ config(
        materialized='incremental'
        ,incremental_strategy='insert_overwrite'
        ,alias='MailLogs'
        ,unique_key = ['']
		,tags=["qvics"]
        ,transient=false
    ) }}

    with source_data as
    (
    SELECT
	ID AS ID,
	OPERATOR AS OPERATOR,
	OPERATORNAME AS OPERATORNAME,
	TOADDRESS AS TOADDRESS,
	CCADDRESS AS CCADDRESS,
	SENTAT AS SENTAT,
	SUBJECT AS SUBJECT,
	ERROR AS ERROR,
	ISREMINDER AS ISREMINDER,
	MODELNAME AS MODELNAME,
	MODELKEY AS MODELKEY,
	_FILEDATE,
	_FILENAME
FROM {{ ref('ODS__QVICS_C_TMEA__MAILLOGS') }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ ref('ODS__QVICS_C_TMEA__MAILLOGS') }})
    )
    ,transform_data as
    (
    SELECT
	_FILEDATE,
	_FILENAME,
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	 SHA2('hash_me') AS _ROW_HASH,
	ID,
	OPERATOR,
	OPERATORNAME,
	TOADDRESS,
	CCADDRESS,
	SENTAT,
	SUBJECT,
	ERROR,
	ISREMINDER,
	MODELNAME,
	MODELKEY
FROM source_data
)
,type_data as (
    SELECT 
	CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
	CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	ID,
	OPERATOR,
	OPERATORNAME,
	TOADDRESS,
	CCADDRESS,
	SENTAT,
	SUBJECT,
	ERROR,
	ISREMINDER,
	MODELNAME,
	MODELKEY
 from transform_data 
)
SELECT * from type_data