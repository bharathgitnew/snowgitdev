/**********************************
File built from dbt_code_generator.ipynb
model file generated on: 2022-08-12 12:49:12.091298
***********************************/

{{ config(
        materialized='view',
         alias='SAP_REPORTING_DETAILS',
         transient=false
) }}

with source_data as
(   
    SELECT
        REPID, 
		RPT_DATE, 
		RPT_TIME, 
		USER_ID, 
		NOTE, 
		_CAPTUREDATETIME
    FROM {{ ref('COMMON__SAPO__SAP_REPORTING_DETAILS') }}
), 

transform_data as
(
 SELECT * FROM source_data
)

SELECT * FROM transform_data