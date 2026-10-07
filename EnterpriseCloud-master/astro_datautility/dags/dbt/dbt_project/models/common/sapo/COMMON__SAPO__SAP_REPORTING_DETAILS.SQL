/**********************************
File built from dbt_code_generator.py
model file generated on: 2022-08-04 17:17:12.101586
***********************************/

{{ config(
        materialized='incremental',
        incremental_strategy='merge',
        alias='SAP_REPORTING_DETAILS',
        unique_key = ['REPID',
     'RPT_DATE',
     'RPT_TIME',
     'USER_ID'],
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
    FROM {{ ref('ODS__SAPO__SAP_REPORTING_DETAILS') }}
), 

transform_data as 
(
    SELECT
        REPID, 
		RPT_DATE, 
		RPT_TIME, 
		USER_ID, 
		NOTE, 
		_CAPTUREDATETIME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
), 

type_data as
(
    SELECT
        CAST(REPID as VARCHAR(40)) as REPID, 
		CAST(RPT_DATE as VARCHAR(8)) as RPT_DATE, 
		CAST(RPT_TIME as VARCHAR(6)) as RPT_TIME, 
		CAST(USER_ID as VARCHAR(12)) as USER_ID, 
		CAST(NOTE as VARCHAR(132)) as NOTE, 
		CAST(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
    FROM transform_data
)

SELECT * FROM type_data