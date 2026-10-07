{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_SALES_DISTRICT',
    	transient=false
) }}

WITH ref_cte_CRM_SALES_DISTRICT as (
    select * from {{ ref('SILVER__TEA_TECHNICAL_SUPPORT__CRM_SALES_DISTRICT') }}
),



source_data as (
SELECT
    sales_district_id               AS Sales_District_Id,
    organizationid                  AS Organization_Id,
    tel_com_sales_district          AS Sales_District,
    tel_com_sales_district_code     AS Sales_District_Code		
FROM ref_cte_CRM_SALES_DISTRICT
),

transform_data as (
select SALES_DISTRICT_ID,
	ORGANIZATION_ID,
	SALES_DISTRICT,
	SALES_DISTRICT_CODE,
	'{{ invocation_id }}' AS _AUDIT_LOG_ID
from source_data
),

type_data as (
select
	CAST(SALES_DISTRICT_ID as VARCHAR(16777216)) as SALES_DISTRICT_ID,
	CAST(ORGANIZATION_ID as VARCHAR(16777216)) as ORGANIZATION_ID,
	CAST(SALES_DISTRICT as VARCHAR(16777216)) as SALES_DISTRICT,
	CAST(SALES_DISTRICT_CODE as VARCHAR(16777216)) as SALES_DISTRICT_CODE,
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID
from transform_data 
)
select * from type_data