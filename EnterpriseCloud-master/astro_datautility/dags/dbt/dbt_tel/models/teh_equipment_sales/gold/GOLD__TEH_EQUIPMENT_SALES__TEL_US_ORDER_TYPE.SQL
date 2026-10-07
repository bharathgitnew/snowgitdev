{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEL_US_ORDER_TYPE',
    	transient=false
) }}

WITH ref_cte_GS_SALES_CATEGORY as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_SALES_CATEGORY') }}
),

ref_cte_ORDER_TYPE as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ORDER_TYPE') }}
),



source_data as (
select 

    ORDER_TYPE_ID,

    ORDER_TYPE_CODE,

    ORDER_TYPE_GROUP,

    ORDER_TYPE

from ref_cte_ORDER_TYPE



union all



select distinct

    ''                                                                          as ORDER_TYPE_ID,

    SALES_CATEGORY_CODE                                                         as ORDER_TYPE_CODE,

    case when SALES_CATEGORY_CODE = '24' then 'Modification' 

        when SALES_CATEGORY_CODE = '25' then 'Chamber' else 'Unmapped' end      as ORDER_TYPE_GROUP,

    SALES_CATEGORY                                                              as ORDER_TYPE

from ref_cte_GS_SALES_CATEGORY

where SALES_CATEGORY_CODE in ('24', '25')

order by ORDER_TYPE_CODE asc

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ORDER_TYPE_ID,
        ORDER_TYPE_CODE,
        ORDER_TYPE_GROUP,
        ORDER_TYPE
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(ORDER_TYPE_ID as VARCHAR(16777216)) as ORDER_TYPE_ID,
        CAST(ORDER_TYPE_CODE as VARCHAR(16777216)) as ORDER_TYPE_CODE,
        CAST(ORDER_TYPE_GROUP as VARCHAR(16777216)) as ORDER_TYPE_GROUP,
        CAST(ORDER_TYPE as VARCHAR(16777216)) as ORDER_TYPE
from transform_data 
)
select * from type_data