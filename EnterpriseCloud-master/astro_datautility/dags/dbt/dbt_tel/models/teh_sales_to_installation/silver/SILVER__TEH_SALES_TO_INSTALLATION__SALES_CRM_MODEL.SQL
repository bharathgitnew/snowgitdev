{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_MODEL',
    	transient=false
) }}

WITH ref_cte_CRM_MODEL as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__MODEL') }}
),



source_data as (
select distinct

    Model_Id,

    tel_sm_product_code     as Product_Code,

    tel_sm_model_type_code  as Model_Type_Code,

    tel_sm_model            as Model

from ref_cte_crm_MODEL

where TEL_SM_MODEL_TYPE_CODE <> 'ZZZ'

),

transform_data as (
select 
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH,
	MODEL_ID,
	PRODUCT_CODE,
	MODEL_TYPE_CODE,
	MODEL
from source_data
),

type_data as (
select
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MODEL_ID,
	PRODUCT_CODE,
	MODEL_TYPE_CODE,
	MODEL
from transform_data 
)
select * from type_data