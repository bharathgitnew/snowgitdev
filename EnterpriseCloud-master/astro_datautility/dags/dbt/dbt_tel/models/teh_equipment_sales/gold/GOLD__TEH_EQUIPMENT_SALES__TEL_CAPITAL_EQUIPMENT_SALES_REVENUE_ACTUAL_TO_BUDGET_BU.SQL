{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_CAPITAL_EQUIPMENT_SALES_REVENUE_ACTUAL_TO_BUDGET_BU',
    transient=false
) }}

with
BU_table
as
(
select distinct 
    case when BU_GROUP ilike any ('FS_Other', 'FS_Sic', 'FS_CCS', 'FS_GCIB', 'FS_3DI', 'FS_TS', 'FS_SD') then 'Others'
        else BU_TYPE 
    end as BU
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_BUSINESS_UNIT') }}
where not BU_GROUP ilike any ('CCS', 'FPD%', 'GCIB', 'TEL%', 'FS_NEXX', 'FS_Other', 'DMS')
order by case when BU_GROUP ilike any ('FS_Other', 'FS_Sic', 'FS_CCS', 'FS_GCIB', 'FS_3DI', 'FS_TS', 'FS_SD') then 'Others'
            else BU_TYPE 
         end asc
),
FY_Half_table
as
(
select distinct 
    FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT as FY_Half
from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
where CALENDAR_DATE = dateadd(day, -1, (date_trunc(month, CURRENT_DATE())))
),
ForecastRegionPrep
as
(
select
    ACCOUNT_REVENUE_FY_HALF             as FY_HALF,
    BU_TYPE                             as BU,
    END_USER_SALES_AMOUNT_JPY           as SALES_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    ACCOUNT_REVENUE_FORECAST_FK_DATE,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_ACCOUNT_REVENUE_FORECAST') }}
where BEGINNING_OF_CURRENT_FY_HALF <= ACCOUNT_REVENUE_FORECAST_FK_DATE
    and END_OF_CURRENT_FY_HALF >= ACCOUNT_REVENUE_FORECAST_FK_DATE
    and not SALES_ACCOUNT ilike any ('TEL Group', 'N/A')
    and ADJUSTED_CONFIDENCE_ACCOUNT_SHORT ilike any ('S%', 'A', 'B')
),
Forecast
as
(
select distinct
    date.FY_HALF,
    bu.BU,
    sum(fcst.SALES_AMOUNT)        as SALES_AMOUNT
from ForecastRegionPrep fcst
    left outer join BU_Table bu on bu.BU = fcst.BU
    left outer join FY_Half_Table date on date.FY_HALF = fcst.FY_HALF
where date_trunc(month, CURRENT_DATE()) <= fcst.ACCOUNT_REVENUE_FORECAST_FK_DATE 
    and END_OF_CURRENT_FY_HALF >= fcst.ACCOUNT_REVENUE_FORECAST_FK_DATE
group by date.FY_HALF, bu.BU
order by date.FY_HALF desc, bu.BU asc
),
CurrentActualRegionPrep
as
(
select
    ACTUAL_REVENUE_FY_HALF      as FY_HALF,
    BU_TYPE                     as BU,
    END_USER_SALES_AMOUNT_JPY   as SALES_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    Actual_FK_Date              as Revenue_Actual_FK_Date,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_REVENUE_ACTUAL') }}
where BEGINNING_OF_CURRENT_FY_HALF <= Revenue_Actual_FK_Date
    and END_OF_CURRENT_FY_HALF >= Revenue_Actual_FK_Date
    and not SALES_ACCOUNT ilike any ('TEL Group', 'N/A')
),
CurrentHFActual
as
(
select distinct
    date.FY_HALF,
    bu.BU,
    sum(act.SALES_AMOUNT)    as SALES_AMOUNT
from CurrentActualRegionPrep act
    left outer join BU_Table bu on bu.BU = act.BU
    left outer join FY_Half_Table date on date.FY_HALF = act.FY_HALF
where BEGINNING_OF_CURRENT_FY_HALF <= act.Revenue_Actual_FK_Date
    and dateadd(day, -1, date_trunc(month, CURRENT_DATE())) >= act.Revenue_Actual_FK_Date
group by date.FY_HALF, bu.BU
order by date.FY_HALF desc, bu.BU asc
),
PreviousActualRegionPrep
as
(
select
    ACTUAL_REVENUE_FY_HALF      as FY_HALF,
    BU_TYPE                     as BU,
    END_USER_SALES_AMOUNT_JPY   as SALES_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    Actual_FK_Date              as Revenue_Actual_FK_Date,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_REVENUE_ACTUAL') }}
where month(CURRENT_DATE()) in (4, 10)
    and BEGINNING_OF_PREVIOUS_FY_HALF <= Revenue_Actual_FK_Date
    and END_OF_PREVIOUS_FY_HALF >= Revenue_Actual_FK_Date
    and not SALES_ACCOUNT ilike any ('TEL Group', 'N/A')
),
PreviousHFActual
as
(
select distinct
    date.FY_HALF,
    bu.BU,
    sum(act.SALES_AMOUNT)    as SALES_AMOUNT
from PreviousActualRegionPrep act
    left outer join BU_Table bu on bu.BU = act.BU
    left outer join FY_Half_Table date on date.FY_HALF = act.FY_HALF
where date.FY_HALF is not null
group by date.FY_HALF, bu.BU
order by date.FY_HALF desc, bu.BU asc
),
CRMActual
as
(
select
    date.FY_HALF,
    bu.BU,
    case when month(CURRENT_DATE()) in (4, 10) then coalesce(prev.SALES_AMOUNT, 0)
        else coalesce(curr.SALES_AMOUNT, 0)
    end                                                                            as SALES_AMOUNT
from BU_Table bu
    cross join FY_Half_Table date
    left outer join PreviousHFActual prev on prev.BU = bu.BU
    left outer join CurrentHFActual curr on curr.BU = bu.BU
),
GSBudgetRegionPrep
as
(
select
    GS_BUDGET_FY_HALF    as FY_HALF,
    BU_TYPE              as BU,
    SALES_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    GS_BUDGET_FK_DATE,
    BUDGET_TYPE,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }}
where BEGINNING_OF_CURRENT_FY_HALF <= GS_BUDGET_FK_DATE
    and END_OF_CURRENT_FY_HALF >= GS_BUDGET_FK_DATE
    and case when month(CURRENT_DATE()) in (5, 6, 7, 8, 9, 10) then BUDGET_TYPE = 'Original' 
            else BUDGET_TYPE = 'Revised' 
        end
    and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} 
                        where case when month(CURRENT_DATE()) in (5, 6, 7, 8, 9, 10) then BUDGET_TYPE = 'Original' 
                                else BUDGET_TYPE = 'Revised' 
                              end)
    and not SALES_ACCOUNT ilike any ('TEL Group', 'N/A')
),
CurrentHFBudget
as
(
select distinct
    date.FY_HALF,
    bu.BU,
    sum(budget.SALES_AMOUNT) as SALES_AMOUNT
from GSBudgetRegionPrep budget
    left outer join BU_Table bu on bu.BU = budget.BU
    left outer join FY_Half_Table date on date.FY_HALF = budget.FY_HALF
group by date.FY_HALF, bu.BU
order by date.FY_HALF desc, bu.BU asc
),
PreviousBudgetRegionPrep
as
(
select
    GS_BUDGET_FY_HALF    as FY_HALF,
    BU_TYPE              as BU,
    SALES_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    GS_BUDGET_FK_DATE,
    BUDGET_TYPE,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }}
where month(CURRENT_DATE()) in (4, 10)
    and BEGINNING_OF_PREVIOUS_FY_HALF <= GS_BUDGET_FK_DATE
    and END_OF_PREVIOUS_FY_HALF >= GS_BUDGET_FK_DATE
    and case when month(CURRENT_DATE()) = 10 then BUDGET_TYPE = 'Original' 
            else BUDGET_TYPE = 'Revised' 
        end
    and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} 
                        where case when month(CURRENT_DATE()) = 10 then BUDGET_TYPE = 'Original' 
                                else BUDGET_TYPE = 'Revised' 
                              end)
    and not SALES_ACCOUNT ilike any ('TEL Group', 'N/A')
),
PreviousHFBudget
as
(
select distinct
    date.FY_HALF,
    bu.BU,
    sum(budget.SALES_AMOUNT) as SALES_AMOUNT
from PreviousBudgetRegionPrep  budget
    left outer join BU_Table bu on bu.BU = budget.BU
    left outer join FY_Half_Table date on date.FY_HALF = budget.FY_HALF
where date.FY_HALF is not null
group by date.FY_HALF, bu.BU
order by date.FY_HALF desc, bu.BU asc
),
Budget
as
(
select
    date.FY_HALF,
    bu.BU,
    case when month(CURRENT_DATE()) in (4, 10) then coalesce(prev.SALES_AMOUNT, 0) 
        else coalesce(curr.SALES_AMOUNT, 0)
    end                                                                             as SALES_AMOUNT
from BU_Table bu
    cross join FY_Half_Table date
    left outer join PreviousHFBudget prev on prev.BU = bu.BU
    left outer join CurrentHFBudget curr on curr.BU = bu.BU   
),
Actual
as 
(
select
    date.FY_HALF,
    bu.BU,
    case when month(CURRENT_DATE()) in (4, 10) then coalesce(act.SALES_AMOUNT, 0)
        else coalesce(fcst.SALES_AMOUNT + act.SALES_AMOUNT, 0)
    end                                                                         as SALES_AMOUNT
from BU_Table bu
    cross join FY_Half_Table date
    left outer join CRMActual act on act.BU = bu.BU
    left outer join Forecast fcst on fcst.BU = bu.BU
),
Summary
as
(
select
    coalesce(a.BU, 'TEA Overall')       as BU,
    sum(b.SALES_AMOUNT)                 as Budget_AMOUNT,
    sum(a.SALES_AMOUNT)                 as Actual_AMOUNT,
    sum(a.SALES_AMOUNT-b.SALES_AMOUNT)  as Actual_to_Budget_Variance
from Actual a
    left outer join Budget b on b.BU = a.BU
group by rollup (a.BU)
),
SOURCE_DATA AS (
select
    act.FY_HALF,
    sum.BU,
    sum(sum.Budget_AMOUNT)              as Budget_AMOUNT,
    sum(sum.Actual_AMOUNT)              as Actual_AMOUNT,
    sum(sum.Actual_to_Budget_Variance)  as Actual_to_Budget_Variance,
    sum(case when sum.Budget_AMOUNT = 0 then null 
            else to_number(sum.Actual_AMOUNT/sum.Budget_AMOUNT, 10, 4) 
        end)                                                        as Actual_to_Budget_Percentage
from Summary sum
    left outer join Actual act on sum.BU = act.BU
group by 
    act.FY_HALF,
    sum.BU
order by 
    case when sum.BU = 'TEA Overall' then 0 
        else 1 
    end asc,
    sum.BU asc
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FY_HALF,
        BU,
        BUDGET_AMOUNT,
        ACTUAL_AMOUNT,
        ACTUAL_TO_BUDGET_VARIANCE,
        ACTUAL_TO_BUDGET_PERCENTAGE
FROM SOURCE_DATA
)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        FY_HALF,
        BU,
        CAST(BUDGET_AMOUNT as NUMBER(38,0)) as BUDGET_AMOUNT,
        CAST(ACTUAL_AMOUNT as FLOAT) as ACTUAL_AMOUNT,
        CAST(ACTUAL_TO_BUDGET_VARIANCE as FLOAT) as ACTUAL_TO_BUDGET_VARIANCE,
        CAST(ACTUAL_TO_BUDGET_PERCENTAGE as NUMBER(38,10)) as ACTUAL_TO_BUDGET_PERCENTAGE
from transform_data
)
SELECT * FROM TYPE_DATA