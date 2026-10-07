{{ config(
    materialized='incremental',
	incremental_strategy='insert_overwrite',
    alias='TEA_EXTERNAL_SPARES_REVENUE_FORECAST_TO_BUDGET',
    transient=false
) }}

with
SAP_Account
as
(
select distinct
    SALES_ACCOUNT
from {{ ref('COMMON__DE_SAP_MASTER_DATA__SAP_SALES_ACCOUNT_REGION') }}
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
    BAAN_CODE,
    ORACLE_CODE
from {{ ref('COMMON__DE_SAP_MASTER_DATA__SAP_BUSINESS_UNIT') }}
),
SAP_Account_BU
as
(
select distinct
    concat(SALES_ACCOUNT, ' ', BU_TYPE)  as SALES_ACCOUNT_BU
from SAP_ACCOUNT
cross join SAP_BU
),
FY_Half_table
as
(
select distinct 
    FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT as FY_Half
from {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }}
where CALENDAR_DATE = dateadd(day, -1, (date_trunc(month, current_date())))
),
BudgetPrep
as
(
select
    pnl.ENTITY,
    pnl.ACCOUNT_TYPE,
    pnl.REVENUE_SOURCE,
    pnl.SCENARIO,
    pnl.PRODUCT_TYPE_CATEGORY                                   as PRODUCT_TYPE,
    case when pnl.CUSTOMER_GROUP ilike 'GF%' then 'GF/IBM'
        when pnl.CUSTOMER_GROUP = 'TSMC' then 'tsmc'
        else pnl.CUSTOMER_GROUP
    end                                                         as SALES_ACCOUNT,
    bu.BU_TYPE                                                  as BU,
    concat(SALES_ACCOUNT, ' ', bu.BU_TYPE)                      as SALES_ACCOUNT_BU,
    pnl.CURRENCY,
    pnl.AMOUNT,
    to_date(pnl.CALENDAR_YEAR_MONTH || '-01')                   as FY_Month,
    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                   as FY_Half,
    date.FISCAL_HALF_YEAR_BEGINNING_DATE                        as Beginning_of_Current_FY_Half,
    date.FISCAL_HALF_YEAR_ENDING_DATE                           as End_of_Current_FY_Half,
    date.FISCAL_YEAR_BEGINNING_DATE                             as Beginning_of_Current_FY,
    date.FISCAL_YEAR_ENDING_DATE                                as End_of_Current_FY
from {{ ref('COMMON__SAPH__ACTUAL_BUDGET_FORECAST_PNL') }} pnl
left outer join {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }} date on date.CALENDAR_DATE = current_date()
left outer join SAP_BU bu on bu.ORACLE_CODE = pnl.SEGMENTCODE
where pnl.ACCOUNT_TYPE ilike 'Revenue'
    and pnl.ENTITY ilike 'TEA'
    and pnl.REVENUE_SOURCE ilike 'External'
    and pnl.SCENARIO ilike '%Budget'
    and case when month(current_date()) in (5, 6, 7, 8, 9) then pnl.SCENARIO = 'Original Budget' 
                                                                and FY_Month >= Beginning_of_Current_FY_Half
                                                                and FY_Month <= End_of_Current_FY_Half
            when month(current_date()) = 10 then pnl.SCENARIO = 'Original Budget' 
                                                and FY_Month >= dateadd(month, -6, Beginning_of_Current_FY_Half)
                                                and FY_Month <= dateadd(day, -1, dateadd(month, -6, End_of_Current_FY_Half))
            when month(current_date()) = 4 then pnl.SCENARIO = 'Revised Budget' 
                                                and FY_Month >= dateadd(month, -6, Beginning_of_Current_FY_Half)
                                                and FY_Month <= dateadd(day, 1, dateadd(month, -6, End_of_Current_FY_Half))
            else (pnl.SCENARIO = 'Revised Budget' 
                    and FY_Month >= BEGINNING_OF_CURRENT_FY_HALF 
                    and FY_Month <= END_OF_CURRENT_FY_HALF) 
        end
    and pnl.CUSTOMER_GROUP <> 'TEL Group'
    and pnl.PRODUCT_TYPE_CATEGORY ilike 'Parts'

),
Budget
as
(
select distinct
    date.FY_HALF,
    accbu.SALES_ACCOUNT_BU,
    zeroifnull(sum(budget.AMOUNT)) as AMOUNT
from BudgetPrep budget
    left outer join SAP_Account_BU accbu on accbu.SALES_ACCOUNT_BU = budget.SALES_ACCOUNT_BU
    left outer join FY_Half_Table date on date.FY_HALF = budget.FY_HALF
group by date.FY_HALF, accbu.SALES_ACCOUNT_BU
order by date.FY_HALF desc, accbu.SALES_ACCOUNT_BU asc
),
ForecastPrep
as
(
select
    pnl.ENTITY,
    pnl.ACCOUNT_TYPE,
    pnl.REVENUE_SOURCE,
    pnl.SCENARIO,
    pnl.PRODUCT_TYPE_CATEGORY as PRODUCT_TYPE,
    case when pnl.CUSTOMER_GROUP ilike 'GF%' then 'GF/IBM'
        when pnl.CUSTOMER_GROUP = 'TSMC' then 'tsmc'
        else pnl.CUSTOMER_GROUP
    end                                                         as SALES_ACCOUNT,
    bu.BU_TYPE                                                  as BU,
    concat(SALES_ACCOUNT, ' ', bu.BU_TYPE)                      as SALES_ACCOUNT_BU,
    pnl.CURRENCY,
    pnl.AMOUNT,
    to_date(pnl.CALENDAR_YEAR_MONTH || '-01')                   as FY_Month,
    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT                   as FY_Half,
    date.FISCAL_HALF_YEAR_BEGINNING_DATE                        as Beginning_of_Current_FY_Half,
    date.FISCAL_HALF_YEAR_ENDING_DATE                           as End_of_Current_FY_Half
from {{ ref('COMMON__SAPH__ACTUAL_BUDGET_FORECAST_PNL') }} pnl
left outer join {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }} date on date.CALENDAR_DATE = current_date()
left outer join SAP_BU bu on bu.ORACLE_CODE = pnl.SEGMENTCODE
where pnl.ACCOUNT_TYPE ilike 'Revenue'
    and pnl.ENTITY ilike 'TEA'
    and pnl.REVENUE_SOURCE ilike 'External'
    and pnl.SCENARIO ilike 'forecast'
    and FY_Month >= date_trunc(month, current_date())
    and FY_Month <= END_OF_CURRENT_FY_HALF 
    and not month(current_date()) in (4, 10)
    and pnl.CUSTOMER_GROUP <> 'TEL Group'
    and pnl.PRODUCT_TYPE_CATEGORY ilike 'Parts'
),
Forecast
as
(
select distinct
    date.FY_HALF,
    accbu.SALES_ACCOUNT_BU,
    zeroifnull(sum(fcst.AMOUNT)) as AMOUNT
from ForecastPrep fcst
    left outer join SAP_Account_BU accbu on accbu.SALES_ACCOUNT_BU = fcst.SALES_ACCOUNT_BU
    left outer join FY_Half_Table date on date.FY_HALF = fcst.FY_HALF
group by date.FY_HALF, accbu.SALES_ACCOUNT_BU
order by date.FY_HALF desc, accbu.SALES_ACCOUNT_BU asc
),
ActualPrep
as
(
select 
    *,
    case when sap.END_USER_GROUP = 'TSMC' then 'tsmc' 
        when sap.END_USER_GROUP ilike 'GF%' then 'GF/IBM'
        else sap.END_USER_GROUP 
    end                                             as SALES_ACCOUNT,
    concat(SALES_ACCOUNT, ' ', bu.BU_TYPE)          as SALES_ACCOUNT_BU
from {{ ref('COMMON__SAPH__DAILY_ACTUALS_SALES_LINE') }} sap
left outer join SAP_BU bu on bu.BAAN_CODE = sap.BAAN_SEGMENT_CODE
),
Actual
as
(
select distinct
    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT   as FY_Half,
    sap.PRODUCT_TYPE_CATEGORY,
    'Spares'                                    as Category,
    --SALES_CATEGORY_ORACLE,
    --ORACLE_PRODUCT_TYPE_GROUP,
    --SALES_CATEGORY_NAME,
    accbu.SALES_ACCOUNT_BU,
    sum(sap.AMOUNT_IN_COMPANY_CODE_CURRENCY)*-1 as Amount
from SAP_Account_BU accbu
left outer join ActualPrep sap on accbu.SALES_ACCOUNT_BU = sap.SALES_ACCOUNT_BU
left outer join {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }} date on date.CALENDAR_DATE = sap.POSTING_DATE
left outer join {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }} date2 on date2.CALENDAR_DATE = dateadd(day, -1, date_trunc(month, current_date()))
where sap.COMPANY_NAME = 'TEA'
    and sap.PNL_CATEGORY = 'Revenue'
    -- and sap.VERSION = 'Final'
    and sap.POSTING_DATE >= date2.FISCAL_HALF_YEAR_BEGINNING_DATE
    and sap.POSTING_DATE < date_trunc(month, current_date())
    and sap.SALES_CATEGORY_ORACLE IN ('PDPRT', 'RPREXC', 'RPRPRT', 'RPRSVC', 'SPAREC')
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
Actual_Forecast
as
(
select
    date.FY_HALF,
    accbu.SALES_ACCOUNT_BU,
    case when month(current_date()) in (4, 10) then zeroifnull(act.AMOUNT)
        else zeroifnull(fcst.AMOUNT) + zeroifnull(act.AMOUNT)
    end                                                                    as AMOUNT
from SAP_Account_BU accbu
    cross join FY_Half_Table date
    left outer join Actual act on act.SALES_ACCOUNT_BU = accbu.SALES_ACCOUNT_BU
    left outer join Forecast fcst on fcst.SALES_ACCOUNT_BU = accbu.SALES_ACCOUNT_BU
),
Summary
as
(
select
    coalesce(a.SALES_ACCOUNT_BU, 'TEA Overall') as SALES_ACCOUNT_BU,
    sum(b.AMOUNT)                               as Budget_AMOUNT,
    sum(a.Amount)                               as Actual_Amount,
    sum(a.AMOUNT-b.AMOUNT)                      as Actual_to_Budget_Variance
from Actual_Forecast a
left outer join Budget b on b.SALES_ACCOUNT_BU = a.SALES_ACCOUNT_BU
group by rollup (a.SALES_ACCOUNT_BU)
order by 
    case when a.SALES_ACCOUNT_BU = 'TEA Overall' then 0 
        else 1 
    end asc,
    a.SALES_ACCOUNT_BU asc
),
SOURCE_DATA AS (
select
    act.FY_Half,
    'Non Intel'                              as SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
where not sum.SALES_ACCOUNT_BU ilike any ('Intel %', 'TEA Overall')
group by 
    act.FY_Half

union all
select
    act.FY_Half,
    'Intel'                                  as SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'Intel %'
group by 
    act.FY_Half

union all
select
    act.FY_Half,
    'GF/IBM'                                 as SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'GF/IBM %'
group by
    act.FY_Half

union all
select
    act.FY_Half,
    'Regional'                               as SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'Regional %'
group by
    act.FY_Half

union all
select
    act.FY_Half,
    'Micron'                                 as SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'Micron %'
group by
    act.FY_Half

union all
select
    act.FY_Half,
    'Samsung'                                as SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'Samsung %'
group by
    act.FY_Half

union all
select
    act.FY_Half,
    'TI'                                     as SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'TI %'
group by
    act.FY_Half

union all
select
    act.FY_Half,
    'tsmc'                                   as SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
where sum.SALES_ACCOUNT_BU ilike any 'tsmc %'
group by
    act.FY_Half

union all
select
    act.FY_Half,
    sum.SALES_ACCOUNT_BU,
    sum(sum.BUDGET_AMOUNT)                   as BUDGET_AMOUNT,
    sum(sum.Actual_Amount)                   as Actual_Amount,
    sum(sum.Actual_to_Budget_Variance)       as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
left outer join Actual_Forecast act on sum.SALES_ACCOUNT_BU = act.SALES_ACCOUNT_BU
group by
    act.FY_Half,
    sum.SALES_ACCOUNT_BU
),
TRANSFORM_DATA AS (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	FY_HALF,
	SALES_ACCOUNT_BU,
	BUDGET_AMOUNT,
	ACTUAL_AMOUNT,
	ACTUAL_TO_BUDGET_VARIANCE,
	ACTUAL_TO_BUDGET_PERCENTAGE,
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
        else 16 end AS SALES_ACCOUNT_BU_NEW

FROM SOURCE_DATA
)

,
TYPE_DATA AS (
select
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	FY_HALF,
	SALES_ACCOUNT_BU,
	CAST(BUDGET_AMOUNT as NUMBER(38,2)) as BUDGET_AMOUNT,
	CAST(ACTUAL_AMOUNT as NUMBER(38,2)) as ACTUAL_AMOUNT,
	CAST(ACTUAL_TO_BUDGET_VARIANCE as NUMBER(38,2)) as ACTUAL_TO_BUDGET_VARIANCE,
	CAST(ACTUAL_TO_BUDGET_PERCENTAGE as NUMBER(38,2)) as ACTUAL_TO_BUDGET_PERCENTAGE,
    CAST(SALES_ACCOUNT_BU_NEW as NUMBER(2,0)) as SALES_ACCOUNT_BU_NEW
from transform_data
)
SELECT * FROM TYPE_DATA