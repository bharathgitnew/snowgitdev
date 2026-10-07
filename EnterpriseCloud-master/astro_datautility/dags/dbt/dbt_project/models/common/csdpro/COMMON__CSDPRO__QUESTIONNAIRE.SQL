{{ config(
    	materialized='incremental',
    	incremental_strategy='merge',
    	alias='QUESTIONNAIRE',
    	unique_key = ['INCIDENT_ID',
    'QUESTION_NUMBER'],
    	transient=false
) }} 

with source_data_answer as (
	SELECT 
		SMBWA_A_ID, 
 	 	INCIDENT_ID, 
 	 	SMBWA_Q_ID, 
 	 	IS_SATISFACTORY, 
 	 	COMMENT
	FROM {{ ref('ODS__CSDPRO__SMBWA_A') }}
),source_data_question as (
	SELECT 
		SMBWA_Q_ID, 
 	 	QUESTION, 
 	 	INCIDENT_CLASSIFICATION_ID, 
 	 	QUESTION_NUMBER
	FROM {{ ref('ODS__CSDPRO__SMBWA_Q') }}
),source_data_incident as (
	SELECT 
 	 	INCIDENT_ID, 
		INCIDENT_REPORT_DATETIME
	FROM {{ ref('ODS__CSDPRO__INCIDENTS') }}
),
transform_data as (
    SELECT 
 	 	a.INCIDENT_ID, 
        q.QUESTION_NUMBER AS QUESTION_NUMBER,
		TO_NUMBER(TO_VARCHAR(TO_DATE(i.INCIDENT_REPORT_DATETIME),'YYYYMMDD')) AS INCIDENT_REPORT_DATE_KEY, 
        q.QUESTION AS QUESTION_TEXT, 
 	 	CASE a.IS_SATISFACTORY
            WHEN 1 THEN 'Satisfactory'
            WHEN 0 THEN 'Unsatisfactory'
            WHEN 2 THEN 'N/A'
            WHEN 3 THEN 'Observed and Corrected' ELSE 'Unknown' END AS ANSWER_TEXT,  
 	 	a.COMMENT,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data_answer a 
	JOIN source_data_incident i ON a.INCIDENT_ID = i.INCIDENT_ID
    JOIN source_data_question q ON a.SMBWA_Q_ID = q.SMBWA_Q_ID
), 

type_data as (
SELECT
 	 	CAST(INCIDENT_ID AS NUMBER(38,0)) AS INCIDENT_ID, 
 	 	CAST(QUESTION_NUMBER AS NUMBER(38,0)) AS QUESTION_NUMBER, 
		CAST(INCIDENT_REPORT_DATE_KEY AS NUMBER(38,0)) AS INCIDENT_REPORT_DATE_KEY, 
 	 	CAST(QUESTION_TEXT AS VARCHAR(16777216)) AS QUESTION_TEXT,
 	 	CAST(ANSWER_TEXT AS VARCHAR(16777216)) AS ANSWER_TEXT,
 	 	CAST(COMMENT AS VARCHAR(16777216)) AS COMMENT,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    FROM transform_data
)

SELECT * FROM type_data