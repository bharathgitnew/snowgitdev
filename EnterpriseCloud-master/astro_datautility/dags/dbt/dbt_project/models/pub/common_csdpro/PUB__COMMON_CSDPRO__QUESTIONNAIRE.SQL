{{ config(
      materialized='view',
      alias='QUESTIONNAIRE',
      transient=false
) }}

with source_data as (
SELECT
    INCIDENT_ID, 
 	QUESTION_NUMBER, 
	INCIDENT_REPORT_DATE_KEY, 
 	QUESTION_TEXT,
 	ANSWER_TEXT,
 	COMMENT
from {{ ref('COMMON__CSDPRO__QUESTIONNAIRE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data