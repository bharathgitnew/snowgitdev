{{ config(
        alias = 'COMMON_US_SUB_BU_INCLUDE_TMEA',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
select
        BU,
        BU_TYPE,
        BU_GROUP,
	SUB_BU,
        COST_CENTER_GROUP_CODE
FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SHAREPOINT_COMMON_BUSINESS_UNIT') }}
where cost_center_group_code not ilike 'zz%'
and not sub_bu ilike any ('fpd%', '%nexx', '%other', 'dms') 
order by SUB_BU
),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        BU,
	BU_TYPE,
	BU_GROUP,
	SUB_BU,
	COST_CENTER_GROUP_CODE
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        BU,
	BU_TYPE,
	BU_GROUP,
	SUB_BU,
	COST_CENTER_GROUP_CODE
from transform_data
)

select * from type_data