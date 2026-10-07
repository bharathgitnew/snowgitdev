{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_ORDER_TYPE',
    	transient=false
) }}

WITH ref_cte_CRM_ORDER_TYPE as (
    select * from {{ ref('SILVER__TEH_EQUIPMENT_SALES__ORDER_TYPE') }}
),



source_data as (
SELECT
    ORDER_TYPE_ID                    AS Order_Type_ID,
	TEL_COM_ORDER_TYPE_CODE          AS Order_Type_Code,
    TEL_COM_ORDER_TYPE               AS Order_Type,
	CASE WHEN TEL_COM_ORDER_TYPE IN ('New Equipment', 'Used Equip w/Core', 'Used Equip w/o Core', 'Used Equip (as is)') THEN 'Equipment'
        WHEN TEL_COM_ORDER_TYPE IN ('In-house Mod', 'On-site Mod') THEN 'Modification'
        ELSE TEL_COM_ORDER_TYPE END  AS Order_Type_Group
FROM ref_cte_CRM_ORDER_TYPE
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ORDER_TYPE_ID,
        ORDER_TYPE_CODE,
        ORDER_TYPE,
        ORDER_TYPE_GROUP
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(ORDER_TYPE_ID as VARCHAR(16777216)) as ORDER_TYPE_ID,
        CAST(ORDER_TYPE_CODE as VARCHAR(16777216)) as ORDER_TYPE_CODE,
        CAST(ORDER_TYPE as VARCHAR(16777216)) as ORDER_TYPE,
        CAST(ORDER_TYPE_GROUP as VARCHAR(16777216)) as ORDER_TYPE_GROUP
from transform_data 
)
select * from type_data