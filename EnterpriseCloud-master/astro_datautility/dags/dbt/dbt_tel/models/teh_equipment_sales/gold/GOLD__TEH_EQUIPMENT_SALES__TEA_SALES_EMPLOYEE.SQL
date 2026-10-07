{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEA_SALES_EMPLOYEE',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
    COSTCENTER                                      as COST_CENTER,
    case when JOB_FAMILY ilike 'Sales & Marketing Management' then 'Yes'
        when FULLNAME ilike any ('Saito, Masa%', 'Prendergast%', 'Wilkinson%', 'Trembath%', 'Gandhi%', 'Rathsack%', 'Dodd%', 'Van %', 'Tsuruta%', 'Barnet%') then 'Yes'
        else null
    end                                             as SALES_LEADER,
    case when COSTCENTER ilike any ('1322806101', '1323700501', '1322819601', '1322806701', '1322806301') then 'Account'
        when COSTCENTER ilike any ('1321704201', '1321904201', '1321804201', '1322104201', '1322204201', '1321204201') then 'BU'
        when COSTCENTER ilike '1323719401' then 'SBO'
        when COSTCENTER ilike '1323700401' then 'VP'
        when FULLNAME ilike 'Shirai, Koki' then 'VP'
        --when FULLNAME ilike 'Makimura, Eri' then 'Marketing'
        else 'Others'
    end                                             as JOB_FUNCTION,
    case when JOB_FUNCTION ilike any ('VP', 'SBO', 'Marketing', 'Others') then JOB_FUNCTION
        when SALES_LEADER is not null then concat(JOB_FUNCTION,' Leader')
        else concat(JOB_FUNCTION, ' Sales')
    end                                             as JOB_GROUP,
    case when COSTCENTER ilike '1322806101' then 'Intel'
        when COSTCENTER ilike any ('1323700501', '1322819601') then 'Strategic'
        when COSTCENTER ilike any ('1322806701', '1322806301') then 'Regional'
        else null
    end                                             as SALES_ACCOUNT,
    case when BUSINESS_UNIT_NAME ilike any ('SPE%', 'Admin', 'BILL%') then null
        when BUSINESS_UNIT_NAME ilike '3DI%' then '3DI'
        else BUSINESS_UNIT_NAME
    end                                             as BU,
    coalesce(SALES_ACCOUNT, BU)                     as ACCOUNT_BU,
    EMPLOYEEID                                      as EMPLOYEE_ID,
    FULLNAME                                        as FULL_NAME,
    LASTNAME                                        as LAST_NAME,
    case when FULLNAME ilike 'Snyder, Stephen' then 'Snyder, Todd'
        when FULLNAME ilike 'Prendergast, Joshua' then 'Prendergast, Josh'
        when FULLNAME ilike 'VanEvery, Kerry' then 'Van Every, Kerry'
        when FULLNAME ilike 'Mitzman, Gregory' then 'Mitzman, Greg'
        when FULLNAME ilike 'Armbruster, Andrew' then 'Armbruster, Andy'
        when FULLNAME ilike 'Edmondson, Martin' then 'Edmondson, Marty'
        when FULLNAME ilike 'Gebler, Deborah' then 'Gebler, Debbie'
        when FULLNAME ilike 'Smith, Chris' then 'Smith, Christopher'
        when FULLNAME ilike 'King, Masami' then 'Hollingsworth, Masami'
        when FULLNAME ilike 'Heins, Douglas' then 'Heins, Doug'
        when FULLNAME ilike 'Barnett, Anthony' then 'Barnett, Tony'
        when FULLNAME ilike 'Banisaukas Stein, Heather' then 'Banisaukas, Heather'
        when FULLNAME ilike 'Dodd, Christopher' then 'Dodd, Chris'
        when FULLNAME ilike 'Gardner, Howard' then 'Gardner, John'
        when FULLNAME ilike 'Giammarco, Nicholas' then 'Giamarco, Nick'
        when FULLNAME ilike 'Klages, William' then 'Klages, Bill'
        when FULLNAME ilike 'Klein, Joseph' then 'Klein, Joe'
        --when FULLNAME ilike 'Napolitano, Joseph' then 'Napolitano, Joe'
        when FULLNAME ilike 'Perras, Richard' then 'Perras, Rick'
        when FULLNAME ilike 'Seyoum, Keflemariam' then 'Seyoum, Kefle'
        when FULLNAME ilike 'Shin, Engpeak' then 'Shin, Freddie'
        --when FULLNAME ilike 'Trembath, Jeffrey' then 'Trembath, Jeff'
        when FULLNAME ilike 'Tyler, William' then 'Tyler, Bill'
        when FULLNAME ilike 'Young, Kenneth' then 'Young, Ken'
        when FULLNAME ilike 'Van Horn, Joseph' then 'Van Horn, Joe'
        when FULLNAME ilike 'Sickler, Timothy' then 'Sickler, Tim'
        when FULLNAME ilike 'Evans, Christopher' then 'Evans, Chris'
        when FULLNAME ilike 'Garrow, Zachary' then 'Garrow, Zach'
        when FULLNAME ilike 'Gebler, Deborah' then 'Gebler, Debbie'
        when FULLNAME ilike 'Chinick, Thomas' then 'Chinick, Tom'

        else FULLNAME
    end                                             as FULL_NAME_MICROSOFT, --SharePoint, PBI, CRM
    EMAIL                                           as EMAIL,
    JOBTITLE                                        as JOB_TITLE
    FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__EMPLOYEE') }}
where COSTCENTER like any
    (
    '1322806101', --Intel
    '1322819601', --GF/IBM, Micron, Samsung, TI, tsmc
    '1322806701', --West
    '1322806301', --East
    '1321704201', --CT
    '1321804201', --SD, TPS
    '1321904201', --ES
    '1322104201', --SPS
    '1322204201', --TS
    '1321204201', --3DI
    '1323719401', --SBO
    '1323700401', --TEA
    '1313700401'  --TEH
    )
    and EMPLOYEEID <> '223242'
    and not BUSINESS_UNIT_NAME ilike any ('BILL BACK', 'TMEA')
    and not COSTCENTER ilike any ('1322804201', '1323700601')
    and FUNCTION1 ilike any ('func_Sales&Marketing', 'Func_TELGM')
    and ACTIVE ilike 'true'
    and not JOBTITLE ilike any ('Administrative Assistant', '%Tech%', '%Product Marketing%')
    or
    (COMPANYID ilike 'TEA' and FUNCTION1 ilike 'Func_LEGM')
    or
    FULLNAME ilike any ('Shirai, Koki', 'Makimura, Eri', 'Ayala, Vanessa', 'Young, Mary', 'Garrow, Zachary', 'Gebler, Deborah')
order by JOB_GROUP asc, BUSINESS_UNIT_NAME asc
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        COST_CENTER,
        SALES_LEADER,
        JOB_FUNCTION,
        JOB_GROUP,
        SALES_ACCOUNT,
        BU,
        ACCOUNT_BU,
        EMPLOYEE_ID,
        FULL_NAME,
        LAST_NAME,
        FULL_NAME_MICROSOFT,
        EMAIL,
        JOB_TITLE
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        COST_CENTER,
        SALES_LEADER,
        JOB_FUNCTION,
        JOB_GROUP,
        SALES_ACCOUNT,
        BU,
        ACCOUNT_BU,
        EMPLOYEE_ID,
        FULL_NAME,
        LAST_NAME,
        FULL_NAME_MICROSOFT,
        EMAIL,
        JOB_TITLE
from transform_data
)
SELECT * FROM TYPE_DATA