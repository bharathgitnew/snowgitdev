{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_FAB',
    	transient=false
) }}

WITH ref_cte_CRM_FAB_LINE as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__FAB_LINE') }}
),



source_data as (
SELECT
    FAB_Line_Id,
    sm_account_name     AS Account_Id,
    sm_fab_line_cd      AS FAB_Line_Code,
    sm_account_cd       AS Account_Code,
    sm_name             AS FAB
FROM ref_cte_CRM_FAB_LINE
),

transform_data as (
select 
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	FAB_LINE_ID,
	ACCOUNT_ID,
	FAB_LINE_CODE,
	ACCOUNT_CODE,
	FAB
from source_data
),

type_data as (
select * from transform_data 
)
select * from type_data