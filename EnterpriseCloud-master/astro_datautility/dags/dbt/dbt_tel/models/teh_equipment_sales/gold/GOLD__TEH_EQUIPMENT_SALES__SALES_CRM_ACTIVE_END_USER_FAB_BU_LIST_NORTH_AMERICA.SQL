{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='SALES_CRM_ACTIVE_END_USER_FAB_BU_LIST_NORTH_AMERICA',
    transient=false
) }}

with
MaxCreated
as 
(
select 
    tel_sm_crm_opportunity_id  as Opportunity_ID,
    max(createdon)             as MaxCreatedOn
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__OPPORTUNITY_ONPRE') }}
group by tel_sm_crm_opportunity_id
),   
CurrentFilter    
as
(
select 
    Opp.opportunityid,
    Opp.tel_sm_crm_opportunity_id,
    case when Opp.Createdon = MaxCreated.MaxCreatedOn then 'Yes' else 'No' end as Is_Current
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__OPPORTUNITY_ONPRE') }}  Opp
  left outer join MaxCreated on MaxCreated.Opportunity_ID = Opp.tel_sm_crm_opportunity_id
),
TMEA_OPPORTUNITY
as
(
select
	Opp.opportunityid                       as Opportunity_GUID,
	Opp.tel_sm_crm_opportunity_id           as Opportunity_ID,
    Opp.tel_sm_project_no                   as Project_No,
    Opp.sm_tel_so_no                        as Sales_Order_No,
    Opp.TEL_SM_TMEA_TEL_MS_SO_NO            as TMEA_SALES_ORDER_NO,
    LABOrg.sales_organization               as Sales_Organization,
    LABDistrict.sales_district              as Sales_District, 
    LABCountry.country                      as End_User_Country,  
    LABAccount.sales_account_ti             as US_Sales_Account,
    LABAccount.sales_account_region         as US_Sales_Account_Region,           
    LABAccount.account_name                 as End_User,
    LABFab.FAB                              as FAB,
    LABBU.bu                                as BU,
    LABBU.BU_TYPE                           as BU_TYPE, 
    LABBU.bu_group                          as BU_Group, 
    LABBU.sub_bu                            as Sub_BU, 
    CurrentFilter.Is_Current,
	case when Opp.statecode = 2 then 'No' 
        else 'Yes' 
    end                                     as Is_Active,
	Opp.modifiedon                          as Record_Updated_Timestamp,
    GII.localizedlabel                      as GII,
    LABAccount.account_code                 as End_User_Code,
    LABFAB.fab_line_code                    as FAB_Code,
    LABBU.cost_center_group_code            as Cost_Center_Group_Code
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__OPPORTUNITY_ONPRE') }} Opp
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }} LABAccount on LABAccount.account_id = Opp.sm_account_name
    left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} LABAccountGroup on LABAccountGroup.id = Opp.sm_account_group_name
    left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_CRM_FAB') }} LABFab on LABFab.fab_line_id = Opp.sm_fab_line_name
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_BUSINESS_UNIT') }} LABBU on LABBU.bu_id = Opp.tel_sm_cost_center_group_name
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DISTRICT') }} LABDistrict on LABDistrict.sales_district_id = Opp.tel_sm_sales_district
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_ORGANIZATION') }} LABOrg on LABOrg.sales_organization_id = Opp.tel_sm_sales_organization
    left outer join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_COUNTRY') }} LABCountry on LABCountry.country_id = Opp.tel_sm_enduser_country
    left outer join CurrentFilter on CurrentFilter.opportunityid = Opp.opportunityid
    left outer join (select distinct * from {{ ref('SILVER__TEH_EQUIPMENT_SALES__SALES_GLOBALOPTIONSETMETADATA') }}
                    where localizedlabellanguagecode = 1033 and optionsetname = 'tel_sm_genpo_involvement_indicator') GII on GII.option = Opp.tel_sm_genpo_involvement_indicator
where 
    Is_Current = 'Yes'
    and Is_Active = 'Yes'
    and (not TEL_SM_SALES_DOCUMENT_TYPENAME like any 'ZZ%' -- debit/credit
        or TEL_SM_SALES_DOCUMENT_TYPENAME is null)
    and
        --TEL
        ((Sales_Organization = 'TEL'    
        and Sub_BU like any ('FS_GCIB', 'FS_CCS')
        and GII ilike '1%')
        --TEE & Others
        or (Sales_Organization like any ('TEE', 'TMEA')    
        and Sub_BU like any ('GCIB', 'CCS')
        and GII ilike '4%'))
),
union_cte as (
--TEL other than TS and FS_SiC
select distinct
    concat(crm.END_USER,', ',crm.FAB,', ',bu.SUB_BU)                   as END_USER_FAB_BU,
    case when crm.SALES_ACCOUNT ilike 'GF/IBM%' then 'GF/IBM'
        else crm.SALES_ACCOUNT
    end                                                                as SALES_ACCOUNT,
    case when crm.SALES_ACCOUNT_REGION ilike 'GF/IBM%' then 'GF/IBM'
        else crm.SALES_ACCOUNT_REGION
    end                                                                as SALES_ACCOUNT_REGION,
    concat(crm.END_USER,', ',crm.FAB)                                  as END_USER_FAB,
    crm.END_USER,
    crm.FAB,
    bu.BU,
    bu.BU_GROUP,
    bu.SUB_BU,
    concat(crm.END_USER_CODE,', ',crm.FAB_CODE,', ',bu.COST_CENTER_GROUP_CODE) as END_USER_FAB_BU_CODE,
    acc.com_address2                                                   as END_USER_ADDRESS,
    acc.address2_city                                                  as END_USER_CITY,
    acc.address2_country                                               as END_USER_COUNTRY,
    crm.SALES_ORGANIZATION
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_OPPORTUNITIES') }} crm
cross join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SUB_BU_INCLUDE_TMEA_LIST') }} bu
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} acc on acc.accountnumber = crm.END_USER_CODE
where crm.FAB is not null
    and not End_User_FAB in ('GF US2/NY, FAB10', 'REGIONAL US, Dummy')
    and not bu.SUB_BU ilike any ('FS_3DI%', 'FS_TS', 'FS_SD', 'FS_PVD', 'CCS', 'GCIB', 'FS_CCS', 'FS_GCIB', 'DMS', 'TS', 'FS_SiC')
    and not crm.SUB_BU like any ('TS', 'FS_SiC')
qualify row_number() over (partition by END_USER_FAB_BU order by record_updated_timestamp desc) = 1

--TEL North America TS only
union all
select distinct
    concat(crm.END_USER,', ',crm.FAB,', ',crm.SUB_BU)                  as END_USER_FAB_BU,
    case when crm.SALES_ACCOUNT ilike 'GF/IBM%' then 'GF/IBM'
        else crm.SALES_ACCOUNT
    end                                                                as SALES_ACCOUNT,
    case when crm.SALES_ACCOUNT_REGION ilike 'GF/IBM%' then 'GF/IBM'
        else crm.SALES_ACCOUNT_REGION
    end                                                                as SALES_ACCOUNT_REGION,
    concat(crm.END_USER,', ',crm.FAB)                                  as END_USER_FAB,
    crm.END_USER,
    crm.FAB,
    crm.BU,
    crm.BU_GROUP,
    crm.SUB_BU,
    concat(crm.END_USER_CODE,', ',crm.FAB_CODE,', ',crm.COST_CENTER_GROUP_CODE)    as END_USER_FAB_BU_CODE,
    acc.com_address2                                                   as END_USER_ADDRESS,
    acc.address2_city                                                  as END_USER_CITY,
    acc.address2_country                                               as END_USER_COUNTRY,
    crm.SALES_ORGANIZATION
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_OPPORTUNITIES') }} crm
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} acc on acc.accountnumber = crm.END_USER_CODE
where FAB is not null
    and not End_User_FAB in ('GF US2/NY, FAB10', 'REGIONAL US, Dummy')
    and crm.SUB_BU ilike 'TS'
qualify row_number() over (partition by END_USER_FAB_BU order by record_updated_timestamp desc) = 1

--TEL Other Sales Districts TS only
union all
select distinct
    concat(crm.END_USER,', ',crm.FAB,', ',crm.SUB_BU)                  as END_USER_FAB_BU,
    case when crm.SALES_ACCOUNT ilike 'GF/IBM%' then 'GF/IBM'
        else crm.SALES_ACCOUNT
    end                                                                as SALES_ACCOUNT,
    case when crm.SALES_ACCOUNT_REGION ilike 'GF/IBM%' then 'GF/IBM'
        else crm.SALES_ACCOUNT_REGION
    end                                                                as SALES_ACCOUNT_REGION,
    concat(crm.END_USER,', ',crm.FAB)                                  as END_USER_FAB,
    crm.END_USER,
    crm.FAB,
    crm.BU,
    crm.BU_GROUP,
    crm.SUB_BU,
    concat(crm.END_USER_CODE,', ',crm.FAB_CODE,', ',crm.COST_CENTER_GROUP_CODE) as END_USER_FAB_BU_CODE,
    acc.com_address2                                                   as END_USER_ADDRESS,
    acc.address2_city                                                  as END_USER_CITY,
    acc.address2_country                                               as END_USER_COUNTRY,
    crm.SALES_ORGANIZATION
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_OPPORTUNITY_TS_OTHER_DISTRICTS') }} crm
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} acc on acc.accountnumber = crm.END_USER_CODE
where FAB is not null
    and crm.SUB_BU ilike 'TS'
qualify row_number() over (partition by END_USER_FAB_BU order by record_updated_timestamp desc) = 1

--TEL FS_SiC only
union all
select distinct
    concat(crm.END_USER,', ',crm.FAB,', ',crm.SUB_BU)                  as END_USER_FAB_BU,
    case when crm.SALES_ACCOUNT ilike 'GF/IBM%' then 'GF/IBM'
        else crm.SALES_ACCOUNT
    end                                                                as SALES_ACCOUNT,
    case when crm.SALES_ACCOUNT_REGION ilike 'GF/IBM%' then 'GF/IBM'
        else crm.SALES_ACCOUNT_REGION
    end                                                                as SALES_ACCOUNT_REGION,
    concat(crm.END_USER,', ',crm.FAB)                                  as END_USER_FAB,
    crm.END_USER,
    crm.FAB,
    crm.BU,
    crm.BU_GROUP,
    crm.SUB_BU,
    concat(crm.END_USER_CODE,', ',crm.FAB_CODE,', ',crm.COST_CENTER_GROUP_CODE) as END_USER_FAB_BU_CODE,
    acc.com_address2                                                   as END_USER_ADDRESS,
    acc.address2_city                                                  as END_USER_CITY,
    acc.address2_country                                               as END_USER_COUNTRY,
    crm.SALES_ORGANIZATION
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_OPPORTUNITIES') }} crm
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} acc on acc.accountnumber = crm.END_USER_CODE
where FAB is not null
    and End_User_FAB <> 'GF US2/NY, FAB10'
    and crm.SUB_BU ilike 'FS_SiC'
qualify row_number() over (partition by END_USER_FAB_BU order by record_updated_timestamp desc) = 1

--Regional US dummy records
union all
select distinct    
    concat(crm.END_USER,', ',crm.FAB,', ',bu.SUB_BU)                   as END_USER_FAB_BU,
    'Regional'                                                         as SALES_ACCOUNT,
    'Regional'                                                         as SALES_ACCOUNT_REGION,
    concat(crm.END_USER,', ',crm.FAB)                                  as END_USER_FAB,
    crm.END_USER,
    crm.FAB,
    bu.BU,
    bu.BU_GROUP,
    bu.SUB_BU,
    concat(crm.END_USER_CODE,', ',crm.FAB_CODE,', ',bu.COST_CENTER_GROUP_CODE) as END_USER_FAB_BU_CODE,
    acc.com_address2                                                   as END_USER_ADDRESS,
    acc.address2_city                                                  as END_USER_CITY,
    acc.address2_country                                               as END_USER_COUNTRY,
    crm.SALES_ORGANIZATION
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_OPPORTUNITIES') }} crm
cross join {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SUB_BU_INCLUDE_TMEA_LIST') }} bu
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} acc on acc.accountnumber = crm.END_USER_CODE
where crm.FAB is not null
    and End_User_FAB ilike 'REGIONAL US, Dummy'
    and not bu.SUB_BU ilike any ('FS_3DI%', 'FS_TS', 'FS_SD', 'FS_PVD', 'CCS', 'GCIB', 'FS_CCS', 'FS_GCIB', 'DMS', 'FS_SiC')
    and not crm.SUB_BU like any ('TS', 'FS_SiC')
qualify row_number() over (partition by END_USER_FAB_BU order by record_updated_timestamp desc) = 1

--TMEA
union all
select distinct
    concat(crm.END_USER,', ',crm.FAB,', ',crm.SUB_BU)                  as END_USER_FAB_BU,
    case when crm.US_SALES_ACCOUNT ilike 'GF/IBM%' then 'GF/IBM'
        else crm.US_SALES_ACCOUNT
    end                                                                as SALES_ACCOUNT,
    case when crm.US_SALES_ACCOUNT_REGION ilike 'GF/IBM%' then 'GF/IBM'
        else crm.US_SALES_ACCOUNT_REGION
    end                                                                as SALES_ACCOUNT_REGION,
    concat(crm.END_USER,', ',crm.FAB)                                  as END_USER_FAB,
    crm.END_USER,
    crm.FAB,
    crm.BU,
    crm.BU_GROUP,
    crm.SUB_BU,
    concat(crm.END_USER_CODE,', ',crm.FAB_CODE,', ',crm.COST_CENTER_GROUP_CODE) as END_USER_FAB_BU_Code,
    acc.com_address2                                                   as END_USER_Address,
    acc.address2_city                                                  as END_USER_City,
    acc.address2_country                                               as END_USER_Country,
    crm.SALES_ORGANIZATION
from TMEA_OPPORTUNITY crm
left outer join {{ ref('SILVER__TEH_EQUIPMENT_SALES__ACCOUNT') }} acc on acc.accountnumber = crm.END_USER_CODE
where crm.SALES_DISTRICT ilike 'North America'
    and crm.FAB is not null
    and END_USER_FAB <> 'GF US2/NY, FAB10'
qualify row_number() over (partition by END_USER_FAB_BU order by crm.record_updated_timestamp desc) = 1
order by
    SALES_ORGANIZATION asc,
    SALES_ACCOUNT asc,
    END_USER_FAB_BU asc
),
source_data as (
    SELECT 
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
	END_USER_COUNTRY,
	SALES_ORGANIZATION
FROM union_cte
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
        END_USER_COUNTRY,
        SALES_ORGANIZATION
FROM SOURCE_DATA
)
select * from TRANSFORM_DATA