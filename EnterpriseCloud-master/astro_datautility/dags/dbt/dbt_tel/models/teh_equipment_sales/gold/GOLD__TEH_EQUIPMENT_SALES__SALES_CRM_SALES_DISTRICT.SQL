{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_SALES_DISTRICT',
    	transient=false
) }}

WITH ref_cte_CRM_SALES_DISTRICT as (
    select * from {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_DISTRICT') }}
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
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_DISTRICT_ID,
        ORGANIZATION_ID,
        SALES_DISTRICT,
        SALES_DISTRICT_CODE
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_DISTRICT_ID as VARCHAR(16777216)) as SALES_DISTRICT_ID,
        CAST(ORGANIZATION_ID as VARCHAR(16777216)) as ORGANIZATION_ID,
        CAST(SALES_DISTRICT as VARCHAR(16777216)) as SALES_DISTRICT,
        CAST(SALES_DISTRICT_CODE as VARCHAR(16777216)) as SALES_DISTRICT_CODE
from transform_data 
)
select * from type_data