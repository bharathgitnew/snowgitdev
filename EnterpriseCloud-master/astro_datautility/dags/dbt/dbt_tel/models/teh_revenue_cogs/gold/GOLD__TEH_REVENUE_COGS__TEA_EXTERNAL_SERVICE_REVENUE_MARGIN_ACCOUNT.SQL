{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEA_EXTERNAL_SERVICE_REVENUE_MARGIN_ACCOUNT',
    	transient=false
) }}

WITH ref_cte_CALENDARDATE as (
    select * from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
),

ref_cte_TIMESHEET as (
    SELECT * FROM {{ source('DE_OPERATIONS', 'TIMESHEET') }}
),

ref_cte_D_EMPLOYEE as (
    SELECT * FROM {{ source('DE_OPERATIONS', 'D_EMPLOYEE') }}
),

ref_cte_REVENUE_COGS_DAILY_REPORT as (
    select * from {{ ref('GOLD__TEH_REVENUE_COGS__DAILY_ACTUALS_SALES_LINE') }}
),

ref_cte_SALES_CRM_ACCOUNT as (
    select * from {{ ref('GOLD__TEH_REVENUE_COGS__SALES_CRM_ACCOUNT') }}
),

ref_cte_SAP_SALES_ACCOUNT_REGION as (
    select * from {{ ref('GOLD__TEH_REVENUE_COGS__SAP_SALES_ACCOUNT_REGION') }}
),

SAP_Baan_Account

as

(

select

    SALES_ACCOUNT_REGION,

    CORPORATION_ID,

    BUSINESS_PARTNER_NUMBER,

    IDENTIFICATION_NUMBER,

    substr(IDENTIFICATION_NUMBER,1,7) as _7_Digit_Customer_Code,

    CORPORATION_NAME,

    case when startswith(BUSINESS_PARTNER_NUMBER,'B') then substr(IDENTIFICATION_NUMBER,3,7)

        when startswith(BUSINESS_PARTNER_NUMBER,'C') then substr(IDENTIFICATION_NUMBER,3,7)

        when startswith(BUSINESS_PARTNER_NUMBER,'D') then substr(IDENTIFICATION_NUMBER,3,7) 

        else null 

    end                                                                                     as Code_Order

from ref_cte_SAP_SALES_ACCOUNT_REGION

where not startswith(BUSINESS_PARTNER_NUMBER,'A')

qualify row_number() over (partition by CORPORATION_ID order by Code_Order asc)=1

),

TimesheetPrep

as

(

select *,

    case when LEFT(FABCODE,1) in ('A','B','C','D') then FABCODE 

        else LEFT(FABCODE,7) 

    end                                                                             as Adjusted_FABCODE,

    coalesce(EMPLOYEETYPE, case when emp.EMPLOYEE_TYPE ilike 'Regular%' then 'FTE' 

                            else 'Subcon' 

                           end)                                                     as Adjusted_Employee_Type

from ref_cte_TIMESHEET time

left outer join ref_cte_D_EMPLOYEE Emp ON Emp.EMPLOYEE_ID = time.EMPLOYEEID

where PRODUCTTYPE ilike any ('CONTRA', 'CONFLX', 'PDSRV', 'PDEXP')

    and EVENTDATE >= dateadd(year, -1, date_trunc(month, current_date()))

    and EVENTDATE <= dateadd(day, -1, date_trunc(month, current_date()))

),

Timesheet

as

(

select distinct

    coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION, 

        case when Adjusted_FABCODE in ('B00000364', 'B00001870') then 'Intel'

            when Adjusted_FABCODE in ('BA2120201', 'DA2120201') then 'Samsung'

            when Adjusted_FABCODE = 'BA3435610' then 'Micron'

            when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

            when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY

            else null 

        end)                                                      as Sales_Account_Region,

    Adjusted_Employee_Type                                        as Employee_Type,

	sum(HOURSCHARGED)                                             as Hours_Charged

from TimesheetPrep hours

left outer join ref_cte_CALENDARDATE date on date.CALENDAR_DATE = hours.EVENTDATE

left outer join ref_cte_SAP_SALES_ACCOUNT_REGION sap on sap.BUSINESS_PARTNER_NUMBER = Adjusted_FABCODE

left outer join SAP_Baan_Account baan on baan._7_DIGIT_CUSTOMER_CODE = Adjusted_FABCODE

-- left outer join DE_SALES_OPERATIONS.SALES_CRM_ACCOUNT crm on crm.ACCOUNT_CODE = Adjusted_FABCODE

where not coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION, 

        case when Adjusted_FABCODE in ('B00000364', 'B00001870') then 'Intel'

            when Adjusted_FABCODE in ('BA2120201', 'DA2120201') then 'Samsung'

            when Adjusted_FABCODE = 'BA3435610' then 'Micron'

            when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

            when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY 

            else null 

        end) in ('TEL Group', 'Regional Others')

    and coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION, 

        case when Adjusted_FABCODE in ('B00000364', 'B00001870') then 'Intel'

            when Adjusted_FABCODE in ('BA2120201', 'DA2120201') then 'Samsung'

            when Adjusted_FABCODE = 'BA3435610' then 'Micron'

            when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

            when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY 

            else null 

        end) is not null

group by

    coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION, 

        case when Adjusted_FABCODE in ('B00000364', 'B00001870') then 'Intel'

            when Adjusted_FABCODE in ('BA2120201', 'DA2120201') then 'Samsung'

            when Adjusted_FABCODE = 'BA3435610' then 'Micron'

            when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

            when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY 

            else null 

        end),

    Adjusted_Employee_Type

order by

    coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION, 

        case when Adjusted_FABCODE in ('B00000364', 'B00001870') then 'Intel'

            when Adjusted_FABCODE in ('BA2120201', 'DA2120201') then 'Samsung'

            when Adjusted_FABCODE = 'BA3435610' then 'Micron'

            when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

            when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY 

            else null 

        end) asc,

	Adjusted_Employee_Type asc   

),

Total_Hours

as

(

select distinct

    Sales_Account_Region,

	sum(Hours_Charged) as Total_Hours

from Timesheet

group by

    Sales_Account_Region

order by

    Sales_Account_Region asc

),

FTE_Hours

as

(

select

    total.Sales_Account_Region,

    hours.Employee_Type,

	hours.Hours_Charged           as FTE_Hours,

    FTE_Hours/total.Total_Hours   as FTE_Ratio

from Timesheet hours

left outer join Total_Hours total on total.Sales_Account_Region = hours.Sales_Account_Region

where EMPLOYEE_TYPE = 'FTE'

),

Subcon_Hours

as

(

select

    total.Sales_Account_Region,

    hours.Employee_Type,

	hours.Hours_Charged            as Subcon_Hours,

    Subcon_Hours/total.Total_Hours as Subcon_Ratio

from Timesheet hours

left outer join Total_Hours total on total.Sales_Account_Region = hours.Sales_Account_Region

where EMPLOYEE_TYPE = 'Subcon'

),

FTE_Subcon_Hours

as

(

select

    total.Sales_Account_Region,

    total.Total_Hours,

    zeroifnull(FTE_Hours)    as FTE_Hours,

    zeroifnull(Subcon_Hours) as Subcon_Hours

from Total_Hours total

left outer join FTE_Hours fte on fte.Sales_Account_Region = total.Sales_Account_Region

left outer join Subcon_Hours sub on sub.Sales_Account_Region = total.Sales_Account_Region

order by total.Sales_Account_Region asc

),

Revenue_Actual

as

(

select

    PNL_CATEGORY                                                  as Account_Category,

    coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION)  as Sales_Account_Region,

    sum(AMOUNT_IN_COMPANY_CODE_CURRENCY)*-1                       as Actual_Revenue_Amount

from ref_cte_REVENUE_COGS_DAILY_REPORT sap

left outer join ref_cte_SAP_SALES_ACCOUNT_REGION acc on acc.BUSINESS_PARTNER_NUMBER = sap.END_USER

-- left outer join SAP_Baan_Account acc2 on acc2.CORPORATION_ID = sap.END_USER

left outer join ref_cte_SALES_CRM_ACCOUNT crm on crm.ACCOUNT_CODE = sap.END_USER

left outer join ref_cte_CALENDARDATE date on date.CALENDAR_DATE = sap.POSTING_DATE

where PNL_CATEGORY = 'Revenue'

    and not coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION) in ('TEL Group', 'Regional Others')

    and coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION) is not null

    and COMPANY_NAME = 'TEA'

    and sap.SALES_CATEGORY_ORACLE IN ('CONTRA', 'PDSRV') --, 'TSCSTD', 'TSCREM') --'SMSRV', 'TRNPD',  'CONFLX', 'PDEXP', 

    and POSTING_DATE >= '5/1/2023'

    and POSTING_DATE >= dateadd(year, -1, date_trunc(month, current_date()))

    and POSTING_DATE < date_trunc(month, current_date())

group by

    PNL_CATEGORY,

    coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION)

order by

    PNL_CATEGORY,

    coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION) asc

),

Summary

as

(

select

    case when coalesce(cog.Sales_Account_Region, rev.Sales_Account_Region) is not null then coalesce(cog.Sales_Account_Region, rev.Sales_Account_Region) 

        else 'TEA Overall' 

    end                                                 as Sales_Account_Region,

    coalesce(sum(Actual_Revenue_Amount),0)   as Actual_Revenue_Amount,

    coalesce(sum(Subcon_Hours),0)            as Subcon_Hours,

    coalesce(sum(Subcon_Hours*48*-1),0)      as Subcon_COGS,

    coalesce(sum(FTE_Hours),0)               as FTE_Hours,

    coalesce(sum(FTE_Hours*93*-1),0)         as FTE_COGS,

    coalesce(sum(Total_Hours),0)             as Total_Hours

from Revenue_Actual rev

full outer join FTE_Subcon_Hours cog on cog.SALES_ACCOUNT_REGION = rev.SALES_ACCOUNT_REGION

group by rollup (coalesce(cog.Sales_Account_Region, rev.Sales_Account_Region))

order by coalesce(cog.Sales_Account_Region, rev.Sales_Account_Region)  asc

),

source_data as (
SELECT 'Non Intel'                                         as Sales_Account_Region,

    to_number(sum(Actual_Revenue_Amount),38,2)          as Actual_Revenue_Amount,

    to_number(sum(Subcon_Hours),38,2)                   as Subcon_Hours,

    to_number(sum(Subcon_Hours*48*-1),38,2)             as Subcon_COGS,

    to_number(sum(FTE_Hours),38,2)                      as FTE_Hours,

    to_number(sum(FTE_Hours*93*-1),38,2)                as FTE_COGS,

    to_number(sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1),38,2)                                                              as Estimated_COGS,

    to_number(sum(Actual_Revenue_Amount) + sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1),38,2)                                 as Estimated_Service_Margin,

    to_number(case when sum(Actual_Revenue_Amount)=0 then null

                else (sum(Actual_Revenue_Amount) + sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1))/sum(Actual_Revenue_Amount)

              end,10,4)                                                                                                         as Service_Margin_Ratio

from Summary

where not Sales_Account_Region ilike any ('Intel', 'TEA Overall')



union all

select

    Sales_Account_Region,

    to_number(sum(Actual_Revenue_Amount),38,2)          as Actual_Revenue_Amount,

    to_number(sum(Subcon_Hours),38,2)                   as Subcon_Hours,

    to_number(sum(Subcon_Hours*48*-1),38,2)             as Subcon_COGS,

    to_number(sum(FTE_Hours),38,2)                      as FTE_Hours,

    to_number(sum(FTE_Hours*93*-1),38,2)                as FTE_COGS,

    to_number(sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1),38,2)                                                              as Estimated_COGS,

    to_number(sum(Actual_Revenue_Amount) + sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1),38,2)                                 as Estimated_Service_Margin,

    to_number(case when sum(Actual_Revenue_Amount)=0 then null

                else (sum(Actual_Revenue_Amount) + sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1))/sum(Actual_Revenue_Amount)

              end,10,4)                                                                                                         as Service_Margin_Ratio

from Summary

group by Sales_Account_Region

order by 

    case when Sales_Account_Region = 'TEA Overall' then 0

        when Sales_Account_Region = 'Intel' then 1

        when Sales_Account_Region = 'Non Intel' then 2 

        else 3 

    end asc,

    Sales_Account_Region asc

),

transform_data as (
select 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    SALES_ACCOUNT_REGION,
	ACTUAL_REVENUE_AMOUNT::NUMBER(38,2) AS ACTUAL_REVENUE_AMOUNT,
	SUBCON_HOURS::NUMBER(38,2) AS SUBCON_HOURS,
	SUBCON_COGS::NUMBER(38,2) AS SUBCON_COGS,
	FTE_HOURS::NUMBER(38,2) AS FTE_HOURS,
	FTE_COGS::NUMBER(38,2) AS FTE_COGS,
	ESTIMATED_COGS::NUMBER(38,2) AS ESTIMATED_COGS,
	ESTIMATED_SERVICE_MARGIN::NUMBER(38,2) AS ESTIMATED_SERVICE_MARGIN,
	SERVICE_MARGIN_RATIO::NUMBER(38,4) AS SERVICE_MARGIN_RATIO,
from source_data
),

type_data as (
select 
    _AUDIT_LOG_ID,
    _ROW_HASH,
    SALES_ACCOUNT_REGION,
	ACTUAL_REVENUE_AMOUNT,
	SUBCON_HOURS,
	SUBCON_COGS,
	FTE_HOURS,
	FTE_COGS,
	ESTIMATED_COGS,
	ESTIMATED_SERVICE_MARGIN,
	SERVICE_MARGIN_RATIO
from transform_data 
)
select * from type_data