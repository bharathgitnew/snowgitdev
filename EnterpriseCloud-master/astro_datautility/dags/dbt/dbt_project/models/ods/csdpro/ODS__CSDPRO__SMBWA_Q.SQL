/************
Model file generated from csdproDbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SMBWA_Q',
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"SMBWA_Q_ID"::STRING AS "SMBWA_Q_ID", 
 	 	JSONFIELD:"QUESTION"::STRING AS "QUESTION", 
 	 	JSONFIELD:"incident_classification_id"::STRING AS "INCIDENT_CLASSIFICATION_ID", 
 	 	JSONFIELD:"question_number"::STRING AS "QUESTION_NUMBER", 
 	 	REGEXP_REPLACE(JSONFIELD:"inactive_date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS inactive_date
	FROM {{ source('CSDPRO','SMBWA_Q') }}
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('CSDPRO','SMBWA_Q') }})
),

transform_data as (
	SELECT 
		"SMBWA_Q_ID", 
 	 	"QUESTION", 
 	 	"INCIDENT_CLASSIFICATION_ID", 
 	 	"QUESTION_NUMBER", 
 	 	"INACTIVE_DATE",
		'{{ invocation_id }}' AS AUDIT_LOG_ID
	FROM source_data
),

type_data as (
	SELECT
		CAST("SMBWA_Q_ID" AS NUMBER(38,0)) AS "SMBWA_Q_ID", 
 	 	CAST("QUESTION" AS VARCHAR(16777216)) AS "QUESTION", 
 	 	CAST("INCIDENT_CLASSIFICATION_ID" AS NUMBER(38,0)) AS "INCIDENT_CLASSIFICATION_ID", 
 	 	CAST("QUESTION_NUMBER" AS NUMBER(38,0)) AS "QUESTION_NUMBER", 
 	 	CAST("INACTIVE_DATE" AS TIMESTAMP_LTZ(9)) AS "INACTIVE_DATE",
		CAST(AUDIT_LOG_ID AS varchar(128)) AS AUDIT_LOG_ID
	FROM transform_data
)

SELECT * FROM type_data