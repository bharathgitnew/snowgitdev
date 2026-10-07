{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_BUSINESS_UNIT',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
    ORACLE_CODE,
    SAP_CODE,
	SAP_DESCRIPTION,
	BAAN_CODE,
	BAAN_DESCRIPTION,
    case when SAP_DESCRIPTION ilike '3DI%' then '3DI'
        when SAP_DESCRIPTION ilike 'RLSA%' then 'ES'
        when SAP_DESCRIPTION ilike 'FS-3DI%' then 'FS_3DI'
        when SAP_DESCRIPTION ilike 'FS - %' then concat('FS_', substr(SAP_DESCRIPTION,6,length(SAP_DESCRIPTION)-5))
        when SAP_DESCRIPTION ilike 'FS-%' then concat('FS_', substr(SAP_DESCRIPTION,4,length(SAP_DESCRIPTION)-3))
        when SAP_DESCRIPTION ilike any ('CT', 'Certas', 'ES', 'SD', 'PVD', 'TPS', 'SPS', 'TS') then SAP_DESCRIPTION
        else SAP_DESCRIPTION end                            as SEGMENT,
    case when SAP_DESCRIPTION ilike '3DI%' then '3DI'
        when SAP_DESCRIPTION ilike 'RLSA%' then 'ES'
        when SAP_DESCRIPTION ilike 'FS-3DI%' then 'FS_3DI'
        when SAP_DESCRIPTION ilike 'FS - %' then concat('FS_', substr(SAP_DESCRIPTION,6,length(SAP_DESCRIPTION)-5))
        when SAP_DESCRIPTION ilike 'FS-%' then concat('FS_', substr(SAP_DESCRIPTION,4,length(SAP_DESCRIPTION)-3))
        when SAP_DESCRIPTION ilike any ('CT', 'Certas', 'ES', 'SD', 'PVD', 'TPS', 'SPS', 'TS') then SAP_DESCRIPTION
        else 'Others' end                                   as SUB_BU,
    case when SAP_DESCRIPTION ilike 'FS-FSI' then 'FS_FSI'
        when crm.BU_GROUP is not null then crm.BU_GROUP 
        else 'Others' end                                   as BU_GROUP,
    case when SAP_DESCRIPTION in ('ES', 'Certas', 'RLSA') then 'ES' 
        when SAP_DESCRIPTION in ('SD', 'PVD') then 'SD' 
        when SAP_DESCRIPTION like '3DI%' then '3DI'
        when case when SAP_DESCRIPTION ilike 'FS - %' then concat('FS_', substr(SAP_DESCRIPTION,6,length(SAP_DESCRIPTION)-5))
                    when SAP_DESCRIPTION ilike 'FS-%' then concat('FS_', substr(SAP_DESCRIPTION,4,length(SAP_DESCRIPTION)-3))
                    else null end like any ('FS_ES', 'FS_Certas') then 'FS_ES'
        when case when SAP_DESCRIPTION ilike 'FS - %' then concat('FS_', substr(SAP_DESCRIPTION,6,length(SAP_DESCRIPTION)-5))
                    when SAP_DESCRIPTION ilike 'FS-%' then concat('FS_', substr(SAP_DESCRIPTION,4,length(SAP_DESCRIPTION)-3))
                    else null end like any ('FS_PVD', 'FS_SD') then 'FS_SD'
        when case when SAP_DESCRIPTION ilike 'FS - %' then concat('FS_', substr(SAP_DESCRIPTION,6,length(SAP_DESCRIPTION)-5))
                    when SAP_DESCRIPTION ilike 'FS-%' then concat('FS_', substr(SAP_DESCRIPTION,4,length(SAP_DESCRIPTION)-3))
                    else null end like any ('FS_CT', 'FS_SPS', 'FS_TPS') then 
                        case when SAP_DESCRIPTION ilike 'FS - %' then concat('FS_', substr(SAP_DESCRIPTION,6,length(SAP_DESCRIPTION)-5))
                                when SAP_DESCRIPTION ilike 'FS-%' then concat('FS_', substr(SAP_DESCRIPTION,4,length(SAP_DESCRIPTION)-3))
                                else null end
        when case when SAP_DESCRIPTION ilike 'FS - %' then concat('FS_', substr(SAP_DESCRIPTION,6,length(SAP_DESCRIPTION)-5))
                    when SAP_DESCRIPTION ilike 'FS-%' then concat('FS_', substr(SAP_DESCRIPTION,4,length(SAP_DESCRIPTION)-3))
                    else null end like any ('FS_3DI%', 'FS_FSI', 'FS_CCS', 'FS_GCIB', 'FS_SiC', 'FS_TS') then 'FS_Others'
        when SAP_DESCRIPTION ilike any ('CT', 'TPS', 'SPS', 'TS') then SAP_DESCRIPTION
        else 'Others' end                                   as BU_Type,
    case when SAP_DESCRIPTION ilike 'FS-FSI' then 'FS'
         when crm.BU is not null then crm.BU 
        else 'Others' end                                   as BU
from {{ ref('SILVER__TEH_REVENUE_COGS__SAP_SEGMENT') }}
left outer join {{ ref('GOLD__TEH_REVENUE_COGS__SALES_CRM_BUSINESS_UNIT') }} crm on crm.SUB_BU = 
    case when SAP_DESCRIPTION ilike '3DI%' then '3DI'
        when SAP_DESCRIPTION ilike 'RLSA%' then 'ES'
        when SAP_DESCRIPTION ilike 'FS-3DI%' then 'FS_3DI'
        when SAP_DESCRIPTION ilike 'FS - %' then concat('FS_', substr(SAP_DESCRIPTION,6,length(SAP_DESCRIPTION)-5))
        when SAP_DESCRIPTION ilike 'FS-%' then concat('FS_', substr(SAP_DESCRIPTION,4,length(SAP_DESCRIPTION)-3))
        when SAP_DESCRIPTION ilike any ('CT', 'Certas', 'ES', 'SD', 'PVD', 'TPS', 'SPS', 'TS') then SAP_DESCRIPTION
        else SAP_DESCRIPTION end
where not ORACLE_CODE ilike any ('s5930', 's4190') --'s5500-1', 
    and not (SAP_DESCRIPTION = 'SMS' and BAAN_DESCRIPTION is null)
    -- not SAP_DESCRIPTION ilike any ('mems', 'magnetic%', 'spe%', 'npp', 'nexx', 'fst', 'export', 'bill%', 'admin', 'FSI', 'sms', 'epion')
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ORACLE_CODE,
        SAP_CODE,
        SAP_DESCRIPTION,
        BAAN_CODE,
        BAAN_DESCRIPTION,
        SEGMENT,
        SUB_BU,
        BU_GROUP,
        BU_TYPE,
        BU
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ORACLE_CODE,
        SAP_CODE,
        SAP_DESCRIPTION,
        BAAN_CODE,
        BAAN_DESCRIPTION,
        SEGMENT,
        SUB_BU,
        BU_GROUP,
        BU_TYPE,
        BU
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA