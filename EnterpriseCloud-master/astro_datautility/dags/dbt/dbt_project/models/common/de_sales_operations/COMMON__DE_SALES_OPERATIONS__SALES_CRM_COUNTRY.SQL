{{ config(
    	materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_COUNTRY',
    	transient=false
) }}

WITH ref_cte_CRM_SALES_COM_COUNTRYMASTER as (
    select * from {{ ref('COMMON__CRM__SALES_COM_COUNTRYMASTER') }}
),



source_data as (
SELECT
    Id                              AS Country_ID,
    com_name                        AS Country,
    tel_com_country_code_2_digit    AS Country_Code    
FROM ref_cte_CRM_SALES_COM_COUNTRYMASTER
),

transform_data as (
select COUNTRY_ID,
	COUNTRY,
	COUNTRY_CODE,
	'{{ invocation_id }}' AS AUDIT_LOG_ID
from source_data
),

type_data as (
select
	CAST(COUNTRY_ID as VARCHAR(16777216)) as COUNTRY_ID,
	CAST(COUNTRY as VARCHAR(16777216)) as COUNTRY,
	CAST(COUNTRY_CODE as VARCHAR(16777216)) as COUNTRY_CODE,
	CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID
from transform_data 
)
select * from type_data