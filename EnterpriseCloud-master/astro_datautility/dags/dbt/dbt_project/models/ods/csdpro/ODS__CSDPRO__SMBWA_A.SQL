/************
Model file generated from csdproDbtTemplateUtility.ipynb 
*************/


{{ config(
    	materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SMBWA_A',
    	transient=false
) }} 

with source_data as (
	SELECT
		JSONFIELD:"SMBWA_A_ID"::STRING AS "SMBWA_A_ID", 
 	 	JSONFIELD:"incident_id"::STRING AS "INCIDENT_ID", 
 	 	JSONFIELD:"SMBWA_Q_ID"::STRING AS "SMBWA_Q_ID", 
 	 	JSONFIELD:"is_satisfactory"::STRING AS "IS_SATISFACTORY", 
 	 	JSONFIELD:"comment"::STRING AS "COMMENT"
	FROM {{ source('CSDPRO','SMBWA_A') }}
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('CSDPRO','SMBWA_A') }})
),

transform_data as (
	SELECT 
		"SMBWA_A_ID", 
 	 	"INCIDENT_ID", 
 	 	"SMBWA_Q_ID", 
 	 	"IS_SATISFACTORY", 
 	 	"COMMENT",
		'{{ invocation_id }}' AS AUDIT_LOG_ID
	FROM source_data
),

type_data as (
	SELECT
		CAST("SMBWA_A_ID" AS NUMBER(38,0)) AS "SMBWA_A_ID", 
 	 	CAST("INCIDENT_ID" AS NUMBER(38,0)) AS "INCIDENT_ID", 
 	 	CAST("SMBWA_Q_ID" AS NUMBER(38,0)) AS "SMBWA_Q_ID", 
 	 	CAST("IS_SATISFACTORY" AS NUMBER(38,0)) AS "IS_SATISFACTORY", 
 	 	CAST("COMMENT" AS VARCHAR(16777216)) AS "COMMENT",
		CAST(AUDIT_LOG_ID AS varchar(128)) AS AUDIT_LOG_ID
	FROM transform_data
)

SELECT * FROM type_data