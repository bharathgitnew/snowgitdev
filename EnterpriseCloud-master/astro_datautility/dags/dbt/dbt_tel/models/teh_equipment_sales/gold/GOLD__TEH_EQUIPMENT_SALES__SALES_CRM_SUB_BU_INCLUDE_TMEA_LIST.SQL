{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='SALES_CRM_SUB_BU_INCLUDE_TMEA_LIST',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
    BU,
    BU_TYPE,
	BU_GROUP,
	SUB_BU,
    COST_CENTER_GROUP_CODE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_BUSINESS_UNIT') }}
where cost_center_group_code not ilike 'zz%'
    and not sub_bu ilike any ('fpd%', '%nexx', '%other', '3di_sp', 'dms') 
order by SUB_BU
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        BU,
        BU_TYPE,
        BU_GROUP,
        SUB_BU,
        COST_CENTER_GROUP_CODE
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
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
SELECT * FROM TYPE_DATA