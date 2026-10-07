{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_BUSINESS_UNIT',
    	transient=false
) }}

WITH ref_cte_CRM_COST_CENTER_GROUP as (
    select * from {{ ref('SILVER__TEH_SALES_TO_INSTALLATION__COST_CENTER_GROUP') }}
),



source_data as (
select

    TEL_SM_COST_CENTER_GROUPID                                              as BU_ID,

    TEL_SM_COST_CENTER_GROUP_CODE                                           as Cost_Center_Group_Code,

    case when tel_sm_cost_center_group in ('ES', 'Certas') then 'ES'

	    when tel_sm_cost_center_group in ('CT', 'SPS') then 'CTSPS'

		when tel_sm_cost_center_group in ('TPS', 'SD', 'PVD') then 'TFF'

		when tel_sm_cost_center_group like any ('TS', '3DI%') then 'ATS'

        when tel_sm_cost_center_group like 'FS_%' then 'DSS'

        else tel_sm_cost_center_group 

        end                                                                 as _BU,

    case when tel_sm_cost_center_group in ('ES', 'Certas') then 'ES' 

        when tel_sm_cost_center_group in ('SD', 'PVD') then 'SD' 

        when tel_sm_cost_center_group like '3DI%' then '3DI' 

        -- when tel_sm_cost_center_group like any ('FS_ES', 'FS_Certas') then 'DSS_ES'

        -- when tel_sm_cost_center_group like any ('FS_PVD', 'FS_SD') then 'DSS_SD'

        -- when tel_sm_cost_center_group like any ('FS_3DI', 'FS_CCS', 'FS_GCIB', 'FS_SiC', 'FS_SD', 'FS_TS', 'FS_Other') then 'DSS_Others'

        -- when tel_sm_cost_center_group like 'FS%' then concat('DSS_', substr(tel_sm_cost_center_group, 4))

        when tel_sm_cost_center_group like 'FS_%' then 'DSS'

        else tel_sm_cost_center_group 

        end                                                                 as _BU_Type,

    case when tel_sm_cost_center_group in ('ES', 'Certas') then 'ES' 

        when tel_sm_cost_center_group in ('SD', 'PVD') then 'SD' 

        when tel_sm_cost_center_group like '3DI%' then '3DI'

        when tel_sm_cost_center_group like any ('FS_ES', 'FS_Certas') then 'DSS_ES'

        when tel_sm_cost_center_group like any ('FS_PVD', 'FS_SD') then 'DSS_SD'

        when tel_sm_cost_center_group like 'FS%' then concat('DSS_', substr(tel_sm_cost_center_group, 4))

        else tel_sm_cost_center_group 

        end                                                                 as _BU_Group,

    case when tel_sm_cost_center_group like 'FS%' then concat('DSS_', substr(tel_sm_cost_center_group, 4))

        else tel_sm_cost_center_group

        end                                                                 as _Sub_BU,

    case when tel_sm_cost_center_group in ('ES', 'Certas') then 'ES'

	    when tel_sm_cost_center_group in ('CT', 'SPS') then 'CTSPS'

		when tel_sm_cost_center_group in ('TPS', 'SD', 'PVD') then 'TFF'

		when tel_sm_cost_center_group like any ('TS', '3DI%') then 'ATS'

        when tel_sm_cost_center_group like 'FS_%' then 'FS'

        else tel_sm_cost_center_group 

        end                                                                 as BU,

    case when tel_sm_cost_center_group in ('ES', 'Certas') then 'ES' 

        when tel_sm_cost_center_group in ('SD', 'PVD') then 'SD' 

        when tel_sm_cost_center_group like '3DI%' then '3DI' 

        -- when tel_sm_cost_center_group like any ('FS_ES', 'FS_Certas') then 'DSS_ES'

        -- when tel_sm_cost_center_group like any ('FS_PVD', 'FS_SD') then 'DSS_SD'

        -- when tel_sm_cost_center_group like any ('FS_3DI', 'FS_CCS', 'FS_GCIB', 'FS_SiC', 'FS_SD', 'FS_TS', 'FS_Other') then 'DSS_Others'

        -- when tel_sm_cost_center_group like 'FS%' then concat('DSS_', substr(tel_sm_cost_center_group, 4))

        when tel_sm_cost_center_group like 'FS_%' then 'FS'

        else tel_sm_cost_center_group 

        end                                                                 as BU_Type,

    case when tel_sm_cost_center_group in ('ES', 'Certas') then 'ES' 

        when tel_sm_cost_center_group in ('SD', 'PVD') then 'SD' 

        when tel_sm_cost_center_group like '3DI%' then '3DI'

        when tel_sm_cost_center_group like any ('FS_ES', 'FS_Certas') then 'FS_ES'

        when tel_sm_cost_center_group like any ('FS_PVD', 'FS_SD') then 'FS_SD'

        when tel_sm_cost_center_group like 'FS%' then concat('FS_', substr(tel_sm_cost_center_group, 4))

        else tel_sm_cost_center_group 

        end                                                                 as BU_Group,

    tel_sm_cost_center_group                                                as Sub_BU

from ref_cte_crm_COST_CENTER_GROUP

),

transform_data as (
select 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH,
    BU_ID,
	COST_CENTER_GROUP_CODE,
	_BU,
	_BU_TYPE,
	_BU_GROUP,
	_SUB_BU,
	BU,
	BU_TYPE,
	BU_GROUP,
	SUB_BU
from source_data
),

type_data as (
select
   	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	BU_ID,
	COST_CENTER_GROUP_CODE,
	_BU,
	_BU_TYPE,
	_BU_GROUP,
	_SUB_BU,
	BU,
	BU_TYPE,
	BU_GROUP,
	SUB_BU
from transform_data 
)
select * from type_data