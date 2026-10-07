{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEA_EXTERNAL_SERVICE_REVENUE_ACTUAL',
    transient=false
) }}

with
SAP_Account
as
(
select distinct
    SALES_ACCOUNT
from {{ ref('GOLD__TEH_REVENUE_COGS__SAP_SALES_ACCOUNT_REGION') }}
where SALES_ACCOUNT <> 'TEL Group'
),
SAP_BU
as
(
select distinct
    case when BU_TYPE ilike any ('CT', 'FS_CT') then 'CT'
        when BU_TYPE ilike any ('ES', 'FS_ES') then 'ES'
        when BU_TYPE ilike any ('SPS', 'FS_SPS') then 'SPS'
        when BU_TYPE ilike any ('TPS', 'FS_TPS') then 'TPS'
        when BU_GROUP ilike any ('3DI', 'FS_3DI') then '3DI'
        when BU_TYPE ilike any ('SD', 'FS_SD') then 'SD'
        when BU_GROUP ilike any ('TS', 'FS_TS') then 'TS' 
        when BU_TYPE ilike '%Others%' then 'Others'
        end                                                     as BU_TYPE,
    BAAN_CODE
from {{ ref('GOLD__TEH_REVENUE_COGS__SAP_BUSINESS_UNIT') }}
),
SAP_Account_BU
as
(
select distinct
    concat(SALES_ACCOUNT, ' ', BU_TYPE)  as SALES_ACCOUNT_BU
from SAP_ACCOUNT
    cross join SAP_BU
),

SAP_Revenue_Prep
as
(
select 
    *,
    case when sap.END_USER_GROUP = 'TSMC' then 'tsmc' 
        when sap.END_USER_GROUP ilike 'GF%' then 'GF/IBM'
        else sap.END_USER_GROUP 
    end                                             as SALES_ACCOUNT,
    concat(SALES_ACCOUNT, ' ', bu.BU_TYPE)          as SALES_ACCOUNT_BU
from {{ ref('GOLD__TEH_REVENUE_COGS__DAILY_ACTUALS_SALES_LINE') }} sap
    left outer join SAP_BU bu on bu.BAAN_CODE = sap.BAAN_SEGMENT_CODE
),
Actual
as
(
select distinct
    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT   as FY_Half,
    sap.PRODUCT_TYPE_CATEGORY,
    'Service'                                   as Category,
    --SALES_CATEGORY_ORACLE,
    --ORACLE_PRODUCT_TYPE_GROUP,
    --SALES_CATEGORY_NAME,
    accbu.SALES_ACCOUNT_BU,
    sum(sap.AMOUNT_IN_COMPANY_CODE_CURRENCY)*-1 as Actual_Amount
from SAP_Account_BU accbu
left outer join SAP_Revenue_Prep sap on accbu.SALES_ACCOUNT_BU = sap.SALES_ACCOUNT_BU
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} date on date.CALENDAR_DATE = sap.POSTING_DATE
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} date2 on date2.CALENDAR_DATE = dateadd(day, -1, date_trunc(month, current_date()))
where sap.COMPANY_NAME = 'TEA'
    and sap.PNL_CATEGORY = 'Revenue'
    -- and sap.VERSION = 'Final'
    and sap.POSTING_DATE >= date2.FISCAL_HALF_YEAR_BEGINNING_DATE
    and sap.POSTING_DATE < date_trunc(month, current_date())
    and sap.SALES_CATEGORY_ORACLE in ('CONTRA', 'SMSRV', 'TSCSTD', 'TSCREM', 'PDSRV', 'TRNPD')
    and sap.END_USER_GROUP <> 'TEL Group'
    and sap.END_USER_GROUP is not null
group by 
    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT,
    PRODUCT_TYPE_CATEGORY,
    accbu.SALES_ACCOUNT_BU
order by 
    PRODUCT_TYPE_CATEGORY asc,
    accbu.SALES_ACCOUNT_BU asc
),
NotinActual
as
(
select
    SALES_ACCOUNT_BU
from SAP_Account_BU

except
select 
    SALES_ACCOUNT_BU
from Actual
),
Merged
as
(
select *
from Actual

union all
select
    date2.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT  as FY_Half,
    'Labor'                                     as PRODUCT_TYPE_CATEGORY,
    'Service'                                   as Category,
    SALES_ACCOUNT_BU,
    0                                           as Actual_Amount
from NotinActual
left outer join {{ source('STATIC_OBJECTS', 'CALENDARDATE') }} date2 on date2.CALENDAR_DATE = dateadd(day, -1, date_trunc(month, current_date()))
),
Summary
as
(
select
    coalesce(SALES_ACCOUNT_BU, 'TEA Overall')   as SALES_ACCOUNT_BU,
    sum(Actual_Amount)                          as Actual_Amount
from Merged
group by rollup (SALES_ACCOUNT_BU)
order by 
    case when SALES_ACCOUNT_BU = 'TEA Overall' then 0 
        else 1 
    end asc,
    SALES_ACCOUNT_BU asc
),
SOURCE_DATA AS (
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    'Non Intel'                              as SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
where not sum.SALES_ACCOUNT_BU ilike any ('Intel %', 'TEA Overall')
group by 
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service')

union all
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    'Intel'                                  as SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'Intel %'
group by 
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service')

union all
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    'GF/IBM'                                 as SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'GF/IBM %'
group by
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service')

union all
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    'Regional'                               as SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'Regional %'
group by
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service')

union all
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    'Micron'                                 as SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'Micron %'
group by
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service')

union all
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    'Samsung'                                as SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'Samsung %'
group by
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service')

union all
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    'TI'                                     as SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'TI %'
group by
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service')

union all
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    'tsmc'                                   as SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'tsmc %'
group by
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service')

union all
select
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor') as PRODUCT_TYPE_CATEGORY,
    coalesce(Category, 'Service')            as Category,
    sum.SALES_ACCOUNT_BU,
    sum(sum.Actual_Amount)                   as Actual_Amount
from Summary sum
left outer join Merged on Merged.SALES_ACCOUNT_BU = sum.SALES_ACCOUNT_BU
group by
    FY_Half,
    coalesce(PRODUCT_TYPE_CATEGORY, 'Labor'),
    coalesce(Category, 'Service'),
    sum.SALES_ACCOUNT_BU
),
TRANSFORM_DATA AS (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	FY_HALF,
	PRODUCT_TYPE_CATEGORY,
	CATEGORY,
	SALES_ACCOUNT_BU,
	ACTUAL_AMOUNT,
    case when SALES_ACCOUNT_BU = 'TEA Overall' then 0
        when SALES_ACCOUNT_BU = 'Intel' then 1
        when SALES_ACCOUNT_BU = 'Non Intel' then 2
        when SALES_ACCOUNT_BU = 'GF/IBM' then 3
        when SALES_ACCOUNT_BU = 'Micron' then 4
        when SALES_ACCOUNT_BU = 'Regional' then 5
        when SALES_ACCOUNT_BU = 'Samsung' then 6
        when SALES_ACCOUNT_BU = 'TI' then 7
        when SALES_ACCOUNT_BU = 'tsmc' then 8
        when SALES_ACCOUNT_BU ilike any 'Intel %' then 9
        when SALES_ACCOUNT_BU ilike any 'GF/IBM %' then 10
        when SALES_ACCOUNT_BU ilike any 'Micron %' then 11
        when SALES_ACCOUNT_BU ilike any 'Regional %' then 12
        when SALES_ACCOUNT_BU ilike any 'Samsung %' then 13
        when SALES_ACCOUNT_BU ilike any 'TI %' then 14
        when SALES_ACCOUNT_BU ilike any 'tsmc %' then 15
        else 16 end SALES_ACCOUNT_BU_NEW

FROM SOURCE_DATA
)

,
TYPE_DATA AS (
select
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	FY_HALF,
	PRODUCT_TYPE_CATEGORY,
	CATEGORY,
	SALES_ACCOUNT_BU,
	CAST(ACTUAL_AMOUNT as NUMBER(38,2)) as ACTUAL_AMOUNT,
    CAST(SALES_ACCOUNT_BU_NEW as NUMBER(2,0)) as SALES_ACCOUNT_BU_NEW
from transform_data
)
SELECT * FROM TYPE_DATA