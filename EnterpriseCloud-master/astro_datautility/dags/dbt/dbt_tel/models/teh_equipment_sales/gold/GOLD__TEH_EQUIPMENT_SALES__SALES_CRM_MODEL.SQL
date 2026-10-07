{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_MODEL',
    	transient=false
) }}

WITH ref_cte_CRM_MODEL as (
    select * from {{ ref('SILVER__TEH_EQUIPMENT_SALES__MODEL') }}
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
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(MODEL_ID as VARCHAR(16777216)) as MODEL_ID,
        CAST(PRODUCT_CODE as VARCHAR(16777216)) as PRODUCT_CODE,
        CAST(MODEL_TYPE_CODE as VARCHAR(16777216)) as MODEL_TYPE_CODE,
        CAST(MODEL as VARCHAR(16777216)) as MODEL
from transform_data 
)
select * from type_data