{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_SALES_ORGANIZATION',
    	transient=false
) }}

WITH ref_cte_CRM_SALES_ORGANIZATION as (
    select * from {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_ORGANIZATION') }}
),



source_data as (
SELECT
    sales_organization_id               AS Sales_Organization_Id,
    tel_com_sales_organization_name     AS Sales_Organization,
    tel_com_sales_organization_code     AS Sales_Organization_Code
FROM ref_cte_CRM_SALES_ORGANIZATION
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ORGANIZATION_ID,
        SALES_ORGANIZATION,
        SALES_ORGANIZATION_CODE
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_ORGANIZATION_ID as VARCHAR(16777216)) as SALES_ORGANIZATION_ID,
        CAST(SALES_ORGANIZATION as VARCHAR(16777216)) as SALES_ORGANIZATION,
        CAST(SALES_ORGANIZATION_CODE as VARCHAR(16777216)) as SALES_ORGANIZATION_CODE
from transform_data 
)
select * from type_data