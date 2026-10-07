{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_CAPITAL_EQUIPMENT_SALES_BOOKING_ACTUAL_TO_BUDGET_ACCOUNT_NON_INTEL',
    transient=false
) }}

with
Account_table
as
(
select distinct 
    SALES_ACCOUNT_TI as Sales_Account
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT') }}
where not SALES_ACCOUNT_TI in ('N/A', 'TEL Group')
order by SALES_ACCOUNT_TI asc
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
    ACCOUNT_BOOKING_FY_HALF             as FY_HALF,
    SALES_ACCOUNT,
    END_USER_BOOKING_AMOUNT_JPY         as BOOKING_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    ACCOUNT_BOOKING_FORECAST_FK_DATE,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_ACCOUNT_BOOKING_FORECAST') }}
where BEGINNING_OF_CURRENT_FY_HALF <= ACCOUNT_BOOKING_FORECAST_FK_DATE
    and END_OF_CURRENT_FY_HALF >= ACCOUNT_BOOKING_FORECAST_FK_DATE
    and not SALES_ACCOUNT ilike any ('TEL Group', 'N/A')
    and ADJUSTED_CONFIDENCE_ACCOUNT_SHORT ilike any ('S%', 'A', 'B')
),
Forecast
as
(
select distinct
    date.FY_HALF,
    acc.SALES_ACCOUNT,
    sum(fcst.BOOKING_AMOUNT)        as BOOKING_AMOUNT
from ForecastRegionPrep fcst
    left outer join Account_Table acc on acc.SALES_ACCOUNT = fcst.SALES_ACCOUNT
    left outer join FY_Half_Table date on date.FY_HALF = fcst.FY_HALF
where date_trunc(month, CURRENT_DATE()) <= fcst.ACCOUNT_BOOKING_FORECAST_FK_DATE
    and END_OF_CURRENT_FY_HALF >= fcst.ACCOUNT_BOOKING_FORECAST_FK_DATE
group by date.FY_HALF, acc.SALES_ACCOUNT
order by date.FY_HALF desc, acc.SALES_ACCOUNT asc
),
CurrentActualRegionPrep
as
(
select
    ACTUAL_BOOKING_FY_HALF        as FY_HALF,
    SALES_ACCOUNT,
    END_USER_BOOKING_AMOUNT_JPY   as BOOKING_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    Actual_FK_Date                as Booking_Actual_FK_Date,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_BOOKING_ACTUAL') }}
where BEGINNING_OF_CURRENT_FY_HALF <= Booking_Actual_FK_Date
    and END_OF_CURRENT_FY_HALF >= Booking_Actual_FK_Date
    and not SALES_ACCOUNT ilike any ('TEL Group', 'N/A')
),
CurrentHFActual
as
(
select distinct
    date.FY_HALF,
    acc.SALES_ACCOUNT,
    sum(act.BOOKING_AMOUNT)    as BOOKING_AMOUNT
from CurrentActualRegionPrep act
    left outer join Account_Table acc on acc.SALES_ACCOUNT = act.SALES_ACCOUNT
    left outer join FY_Half_Table date on date.FY_HALF = act.FY_HALF
where BEGINNING_OF_CURRENT_FY_HALF <= act.Booking_Actual_FK_Date
    and dateadd(day, -1, date_trunc(month, CURRENT_DATE())) >= act.Booking_Actual_FK_Date
group by date.FY_HALF, acc.SALES_ACCOUNT
order by date.FY_HALF desc, acc.SALES_ACCOUNT asc
),
PreviousActualRegionPrep
as
(
select
    ACTUAL_BOOKING_FY_HALF        as FY_HALF,
    SALES_ACCOUNT,
    END_USER_BOOKING_AMOUNT_JPY   as BOOKING_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    Actual_FK_Date                as Booking_Actual_FK_Date,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_BOOKING_ACTUAL') }}
where month(CURRENT_DATE()) in (4, 10) 
    and BEGINNING_OF_PREVIOUS_FY_HALF <= Booking_Actual_FK_Date
    and END_OF_PREVIOUS_FY_HALF >= Booking_Actual_FK_Date
    and not SALES_ACCOUNT ilike any ('TEL Group', 'N/A')
),
PreviousHFActual
as
(
select distinct
    date.FY_HALF,
    acc.SALES_ACCOUNT,
    sum(act.BOOKING_AMOUNT)    as BOOKING_AMOUNT
from PreviousActualRegionPrep act
    left outer join Account_Table acc on acc.SALES_ACCOUNT = act.SALES_ACCOUNT
    left outer join FY_Half_Table date on date.FY_HALF = act.FY_HALF
where date.FY_HALF IS not null
group by date.FY_HALF, acc.SALES_ACCOUNT
order by date.FY_HALF desc, acc.SALES_ACCOUNT asc
),
CRMActual
as
(
select
    date.FY_HALF,
    acc.SALES_ACCOUNT,
    case when month(CURRENT_DATE()) in (4, 10) then coalesce(prev.BOOKING_AMOUNT, 0)
        else coalesce(curr.BOOKING_AMOUNT, 0)
    end                                                                             as BOOKING_AMOUNT
from Account_Table acc
    cross join FY_Half_Table date
    left outer join PreviousHFActual prev on prev.SALES_ACCOUNT = acc.SALES_ACCOUNT
    left outer join CurrentHFActual curr on curr.SALES_ACCOUNT = acc.SALES_ACCOUNT
),
CurrentBudgetRegionPrep
as
(
select
    GS_BUDGET_FY_HALF    as FY_HALF,
    SALES_ACCOUNT,
    BOOKING_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    GS_BUDGET_FK_DATE,
    BUDGET_TYPE,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }}
where BEGINNING_OF_CURRENT_FY_HALF <= GS_BUDGET_FK_DATE
    and END_OF_CURRENT_FY_HALF >= GS_BUDGET_FK_DATE
    and case when month(CURRENT_DATE()) in (5, 6, 7, 8, 9, 10) then BUDGET_TYPE = 'Original' 
            else BUDGET_TYPE = 'Revised' 
        end
    and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} 
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
    acc.SALES_ACCOUNT,
    sum(budget.BOOKING_AMOUNT) as BOOKING_AMOUNT
from CurrentBudgetRegionPrep budget
    left outer join Account_Table acc on acc.SALES_ACCOUNT = budget.SALES_ACCOUNT
    left outer join FY_Half_Table date on date.FY_HALF = budget.FY_HALF
group by date.FY_HALF, acc.SALES_ACCOUNT
order by date.FY_HALF desc, acc.SALES_ACCOUNT asc
),
PreviousBudgetRegionPrep
as
(
select
    GS_BUDGET_FY_HALF    as FY_HALF,
    SALES_ACCOUNT,
    BOOKING_AMOUNT,
    BEGINNING_OF_CURRENT_FY_HALF,
    END_OF_CURRENT_FY_HALF,
    BEGINNING_OF_PREVIOUS_FY_HALF,
    END_OF_PREVIOUS_FY_HALF,
    GS_BUDGET_FK_DATE,
    BUDGET_TYPE,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }}
where month(CURRENT_DATE()) in (4, 10)
    and BEGINNING_OF_PREVIOUS_FY_HALF <= GS_BUDGET_FK_DATE
    and END_OF_PREVIOUS_FY_HALF >= GS_BUDGET_FK_DATE
    and case when month(CURRENT_DATE()) = 10 then BUDGET_TYPE = 'Original' 
            else BUDGET_TYPE = 'Revised' 
        end
    and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} 
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
    acc.SALES_ACCOUNT,
    sum(budget.BOOKING_AMOUNT) as BOOKING_AMOUNT
from PreviousBudgetRegionPrep budget
    left outer join Account_Table acc on acc.SALES_ACCOUNT = budget.SALES_ACCOUNT
    left outer join FY_Half_Table date on date.FY_HALF = budget.FY_HALF
where date.FY_HALF IS not null
group by date.FY_HALF, acc.SALES_ACCOUNT
order by date.FY_HALF desc, acc.SALES_ACCOUNT asc
),
Budget
as
(
select
    date.FY_HALF,
    acc.SALES_ACCOUNT,
    case when month(CURRENT_DATE()) in (4, 10) then coalesce(prev.BOOKING_AMOUNT, 0)
        else coalesce(curr.BOOKING_AMOUNT, 0) 
    end                                                                             as BOOKING_AMOUNT
from Account_Table acc
    cross join FY_Half_Table date
    left outer join PreviousHFBudget prev on prev.SALES_ACCOUNT = acc.SALES_ACCOUNT
    left outer join CurrentHFBudget curr on curr.SALES_ACCOUNT = acc.SALES_ACCOUNT
),
Actual
as 
(
select
    date.FY_HALF,
    acc.SALES_ACCOUNT,
    case when month(CURRENT_DATE()) in (4, 10) then coalesce(act.BOOKING_AMOUNT, 0)
        else coalesce(fcst.BOOKING_AMOUNT + act.BOOKING_AMOUNT, 0)
    end                                                                             as BOOKING_AMOUNT
from Account_Table acc
    cross join FY_Half_Table date
    left outer join CRMActual act on act.SALES_ACCOUNT = acc.SALES_ACCOUNT
    left outer join Forecast fcst on fcst.SALES_ACCOUNT = acc.SALES_ACCOUNT
),
Summary
as
(
select
    coalesce(a.SALES_ACCOUNT, 'TEA Overall') as SALES_ACCOUNT,
    sum(b.BOOKING_AMOUNT)                    as Budget_AMOUNT,
    sum(a.BOOKING_AMOUNT)                    as Actual_AMOUNT,
    sum(a.BOOKING_AMOUNT-b.BOOKING_AMOUNT)   as Actual_to_Budget_Variance
from Actual a
    left outer join Budget b on b.SALES_ACCOUNT = a.SALES_ACCOUNT
group by rollup (a.SALES_ACCOUNT)
),
SOURCE_DATA AS (
select 
    act.FY_HALF,
    'Non Intel'                         as SALES_ACCOUNT,
    sum(sum.Budget_AMOUNT)              as Budget_AMOUNT,
    sum(sum.Actual_AMOUNT)              as Actual_AMOUNT,
    sum(sum.Actual_to_Budget_Variance)  as Actual_to_Budget_Variance,
    case when sum(sum.Budget_AMOUNT) = 0 then null
        else to_number(sum(sum.Actual_AMOUNT)/sum(sum.Budget_AMOUNT), 10, 4)
    end                                                                     as Actual_to_Budget_Percentage
from Summary sum
    left outer join Actual act on sum.SALES_ACCOUNT = act.SALES_ACCOUNT
where not sum.SALES_ACCOUNT ilike any ('Intel', 'TEA Overall')
group by 
    act.FY_HALF

union all 
select
    act.FY_HALF,
    sum.SALES_ACCOUNT,
    sum(sum.Budget_AMOUNT)              as Budget_AMOUNT,
    sum(sum.Actual_AMOUNT)              as Actual_AMOUNT,
    sum(sum.Actual_to_Budget_Variance)  as Actual_to_Budget_Variance,
    sum(case when sum.Budget_AMOUNT = 0 then null 
            else to_number(sum.Actual_AMOUNT/sum.Budget_AMOUNT, 10, 4) 
        end)                                                          as Actual_to_Budget_Percentage
from Summary sum
    left outer join Actual act on sum.SALES_ACCOUNT = act.SALES_ACCOUNT
group by 
    act.FY_HALF,
    sum.SALES_ACCOUNT
order by 
    case when SALES_ACCOUNT = 'TEA Overall' then 0
        when SALES_ACCOUNT = 'Intel' then 1
        when SALES_ACCOUNT = 'Non Intel' then 2 
        else 3 
    end asc,
    SALES_ACCOUNT asc
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FY_HALF,
        SALES_ACCOUNT,
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
        SALES_ACCOUNT,
        CAST(BUDGET_AMOUNT as NUMBER(38,0)) as BUDGET_AMOUNT,
        CAST(ACTUAL_AMOUNT as FLOAT) as ACTUAL_AMOUNT,
        CAST(ACTUAL_TO_BUDGET_VARIANCE as FLOAT) as ACTUAL_TO_BUDGET_VARIANCE,
        CAST(ACTUAL_TO_BUDGET_PERCENTAGE as NUMBER(38,4)) as ACTUAL_TO_BUDGET_PERCENTAGE
from transform_data
)
SELECT * FROM TYPE_DATA