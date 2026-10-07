{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_REVENUE_RECOGNITION_CRITERIA',
    	transient=false
) }}

WITH ref_cte_CRM_REVENUE_RECOGNITION_CRITERIA as (
    select * from {{ ref('SILVER__TEH_EQUIPMENT_SALES__REVENUE_RECOGNITION_CRITERIA') }}
),



source_data as (
SELECT
    revenue_recognition_id                  AS Revenue_Recognition_Criteria_ID,
    tel_sm_rev_rec_criteria_code            AS Revenue_Recognition_Criteria_Code,
    tel_sm_rev_rec_criteria                 AS Revenue_Recognition_Criteria,
    CASE WHEN tel_sm_rev_rec_criteria = 'Shipment' THEN 'Ship'
        WHEN tel_sm_rev_rec_criteria = 'Technical Acceptance' THEN 'Acceptance'
        WHEN tel_sm_rev_rec_criteria = 'Completion of Service' THEN 'TSR'
        ELSE tel_sm_rev_rec_criteria END    AS Revenue_Recognition_Criteria_Short
FROM ref_cte_CRM_REVENUE_RECOGNITION_CRITERIA
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        REVENUE_RECOGNITION_CRITERIA_ID,
        REVENUE_RECOGNITION_CRITERIA_CODE,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_CRITERIA_SHORT
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(REVENUE_RECOGNITION_CRITERIA_ID as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_ID,
        CAST(REVENUE_RECOGNITION_CRITERIA_CODE as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_CODE,
        CAST(REVENUE_RECOGNITION_CRITERIA as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA,
        CAST(REVENUE_RECOGNITION_CRITERIA_SHORT as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_SHORT
from transform_data 
)
select * from type_data