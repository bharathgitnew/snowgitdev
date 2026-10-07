{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SALES_CRM_ACTIVE_END_USER_FAB_BU_LIST',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select distinct
    concat(crm.END_USER,', ',crm.FAB,', ',bu.SUB_BU)                   as End_User_FAB_BU,
    case when crm.SALES_ACCOUNT ilike 'GF/IBM%' then 'GF/IBM/Albany'
        else crm.SALES_ACCOUNT
    end                                                                as SALES_ACCOUNT,
    case when crm.SALES_ACCOUNT_REGION ilike 'GF/IBM%' then 'GF/IBM/Albany'
        else crm.SALES_ACCOUNT_REGION
    end                                                                as SALES_ACCOUNT_REGION,
    concat(crm.END_USER,', ',crm.FAB)                                  as End_User_FAB,
    crm.END_USER,
    crm.FAB,
    bu.BU,
    bu.BU_GROUP,
    bu.SUB_BU,
    concat(END_USER_CODE,', ',FAB_CODE,', ',bu.COST_CENTER_GROUP_CODE) as End_User_FAB_BU_Code,
    acc.com_address2 as End_User_Address,
    acc.address2_city as End_User_City,
    acc.address2_country as End_User_Country
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_OPPORTUNITIES') }} crm
cross join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SUB_BU_INCLUDE_TMEA_LIST') }} bu
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} acc on acc.accountnumber = crm.END_USER_CODE
where SALES_ACCOUNT <> 'Intel'
    and FAB is not null
    and End_User_FAB <> 'GF US2/NY, FAB10'
    and not bu.SUB_BU ilike any ('FS_3DI%', 'FS_TS', 'FS_SD', 'FS_PVD', '%CCS', '%GCIB', 'DMS', 'DSSTMEA')
qualify row_number() over (partition by End_User_FAB_BU order by record_updated_timestamp desc) = 1

union all
select
    'Regional'                                    as SALES_ACCOUNT,
    'Regional'                                    as SALES_ACCOUNT_REGION,
    concat('Regional Customers US, ',SUB_BU)      as End_User_FAB_BU,
    concat('Regional Customers US')               as End_User_FAB,
    'Regional Customers US'                       as END_USER,
    null                                          as FAB,
    BU,
    BU_GROUP,
    SUB_BU,
    concat('AA9223406, ', COST_CENTER_GROUP_CODE) as End_User_FAB_BU_Code,
    acc.com_address2 as End_User_Address,
    acc.address2_city as End_User_City,
    acc.address2_country as End_User_Country
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }} crm
cross join (select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SUB_BU_INCLUDE_TMEA_LIST') }} bu
    where not bu.SUB_BU ilike any ('FS_3DI%', 'FS_TS', 'FS_SD', 'FS_PVD', '%CCS', '%GCIB', 'DMS', 'DSSTMEA'))
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} acc on acc.accountnumber = 'AA9223406'
qualify row_number() over (partition by End_User_FAB_BU order by End_User_FAB_BU desc) = 1
order by
    SALES_ACCOUNT asc,
    End_User_FAB_BU asc
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        END_USER_FAB_BU,
        SALES_ACCOUNT,
        SALES_ACCOUNT_REGION,
        END_USER_FAB,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        END_USER_FAB_BU_CODE,
        END_USER_ADDRESS,
        END_USER_CITY,
        END_USER_COUNTRY
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        END_USER_FAB_BU,
        SALES_ACCOUNT,
        SALES_ACCOUNT_REGION,
        END_USER_FAB,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        END_USER_FAB_BU_CODE,
        END_USER_ADDRESS,
        END_USER_CITY,
        END_USER_COUNTRY
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA