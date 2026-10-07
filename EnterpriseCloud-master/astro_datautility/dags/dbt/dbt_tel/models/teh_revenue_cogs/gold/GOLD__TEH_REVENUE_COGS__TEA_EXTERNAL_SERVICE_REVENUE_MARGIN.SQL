{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEA_EXTERNAL_SERVICE_REVENUE_MARGIN',
    	transient=false
) }}

WITH ref_cte_CALENDARDATE as (
    select * from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
),

ref_cte_SALES_CRM_ACCOUNT as (
    select * from {{ ref('GOLD__TEH_REVENUE_COGS__SALES_CRM_ACCOUNT') }}
),

ref_cte_REVENUE_COGS_DAILY_REPORT as (
    select * from {{ ref('GOLD__TEH_REVENUE_COGS__DAILY_ACTUALS_SALES_LINE') }}
),

ref_cte_SAP_BUSINESS_UNIT as (
    select * from {{ ref('GOLD__TEH_REVENUE_COGS__SAP_BUSINESS_UNIT') }}
),

ref_cte_TIMESHEET as (
    SELECT * FROM {{ source('DE_OPERATIONS', 'TIMESHEET') }}
),

ref_cte_D_EMPLOYEE as (
    SELECT * FROM {{ source('DE_OPERATIONS', 'D_EMPLOYEE') }}
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

    substr(IDENTIFICATION_NUMBER,1,7)   as _7_Digit_Customer_Code,

    CORPORATION_NAME,

    case when startswith(BUSINESS_PARTNER_NUMBER,'B') then substr(IDENTIFICATION_NUMBER,3,7)

        when startswith(BUSINESS_PARTNER_NUMBER,'C') then substr(IDENTIFICATION_NUMBER,3,7)

        when startswith(BUSINESS_PARTNER_NUMBER,'D') then substr(IDENTIFICATION_NUMBER,3,7) 

        else null 

    end                                 as Code_Order

from ref_cte_SAP_SALES_ACCOUNT_REGION

where not startswith(BUSINESS_PARTNER_NUMBER,'A')

qualify row_number() over (partition by CORPORATION_ID order by Code_Order asc)=1

),

SAP_BU

as

(

select distinct

    case when BU_TYPE ilike '%Others%' then 'Others' 

        else BU_TYPE 

    end                                             as BU_TYPE,

    case when startswith(BU_TYPE, 'FS_') then substr(BU_TYPE, 4) 

        else BU_TYPE 

    end                                             as Service_BU,

    SEGMENT

from ref_cte_SAP_BUSINESS_UNIT

),

TimesheetPrep

as

(

select *,

    case when LEFT(FABCODE,1) in ('A','B','C','D') then FABCODE 

        else LEFT(FABCODE,7) 

    end                                                         as Adjusted_FABCODE,

    coalesce(EMPLOYEETYPE, case when emp.EMPLOYEE_TYPE ilike 'Regular%' then 'FTE' 

                                else 'Subcon' 

                           end)                                 as Adjusted_Employee_Type

from ref_cte_TIMESHEET time

left outer join ref_cte_D_EMPLOYEE Emp on Emp.EMPLOYEE_ID = time.EMPLOYEEID

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

        end)                                                     as Sales_Account_Region,

    bu.Service_BU                                                as BU,

    concat(

        coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION,

            case when Adjusted_FABCODE in ('B00000364', 'B00001870') then 'Intel'

                when Adjusted_FABCODE in ('BA2120201', 'DA2120201') then 'Samsung'

                when Adjusted_FABCODE = 'BA3435610' then 'Micron'

                when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

                when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY

                else null 

            end)

            , ' ', bu.Service_BU)                                 as SALES_ACCOUNT_BU,

    Adjusted_Employee_Type                                        as Employee_Type,

	sum(HOURSCHARGED)                                             as Hours_Charged

from TimesheetPrep hours

left outer join ref_cte_CALENDARDATE date on date.CALENDAR_DATE = hours.EVENTDATE

left outer join ref_cte_SAP_SALES_ACCOUNT_REGION sap on sap.BUSINESS_PARTNER_NUMBER = Adjusted_FABCODE

left outer join SAP_Baan_Account baan on baan._7_DIGIT_CUSTOMER_CODE = Adjusted_FABCODE

left outer join SAP_BU bu on bu.SEGMENT = 

    case when MACHINEBU ilike '3DI%' then '3DI'

        when MACHINEBU ilike 'RLSA%' then 'ES'

        when MACHINEBU = 'CERTAS' then 'Certas'

        when MACHINEBU ilike 'FS-3DI%' then 'FS_3DI'

        when MACHINEBU ilike 'FS - %' then concat('FS_', substr(MACHINEBU,6,length(MACHINEBU)-5))

        when MACHINEBU ilike 'FS-%' then concat('FS_', substr(MACHINEBU,4,length(MACHINEBU)-3))

        else MACHINEBU 

    end

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

    and Service_BU is not null

group by

    coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION, 

        case when Adjusted_FABCODE in ('B00000364', 'B00001870') then 'Intel'

            when Adjusted_FABCODE in ('BA2120201', 'DA2120201') then 'Samsung'

            when Adjusted_FABCODE = 'BA3435610' then 'Micron'

            when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

            when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY 

            else null 

        end),

    bu.Service_BU,

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

    bu.Service_BU asc,

	Adjusted_Employee_Type asc   

),

Total_Hours

as

(

select distinct

    SALES_ACCOUNT_BU,

	sum(Hours_Charged) as Total_Hours

from Timesheet

group by

    SALES_ACCOUNT_BU

order by

    SALES_ACCOUNT_BU asc

),

FTE_Hours

as

(

select

    total.SALES_ACCOUNT_BU,

    hours.Employee_Type,

	hours.Hours_Charged         as FTE_Hours,

    FTE_Hours/total.Total_Hours as FTE_Ratio

from Timesheet hours

left outer join Total_Hours total on total.SALES_ACCOUNT_BU = hours.SALES_ACCOUNT_BU

where EMPLOYEE_TYPE = 'FTE'

),

Subcon_Hours

as

(

select

    total.SALES_ACCOUNT_BU,

    hours.Employee_Type,

	hours.Hours_Charged            as Subcon_Hours,

    Subcon_Hours/total.Total_Hours as Subcon_Ratio

from Timesheet hours

left outer join Total_Hours total on total.SALES_ACCOUNT_BU = hours.SALES_ACCOUNT_BU

where EMPLOYEE_TYPE = 'Subcon'

),

FTE_Subcon_Hours

as

(

select

    total.SALES_ACCOUNT_BU,

    total.Total_Hours,

    case when FTE_Hours is not null then FTE_Hours 

        else 0 

    end                                             as FTE_Hours,

    case when Subcon_Hours is not null then Subcon_Hours 

        else 0 

    end                                             as Subcon_Hours

from Total_Hours total

left outer join FTE_Hours fte on fte.SALES_ACCOUNT_BU = total.SALES_ACCOUNT_BU

left outer join Subcon_Hours sub on sub.SALES_ACCOUNT_BU = total.SALES_ACCOUNT_BU

order by total.SALES_ACCOUNT_BU asc

),

Revenue_Actual

as

(

select

    PNL_CATEGORY                                                                            as Account_Category,

    concat(coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION), ' ', Service_BU)   as SALES_ACCOUNT_BU,

    sum(AMOUNT_IN_COMPANY_CODE_CURRENCY)*-1                                                 as Actual_Revenue_Amount

from ref_cte_REVENUE_COGS_DAILY_REPORT sap

left outer join SAP_Baan_Account acc on acc.BUSINESS_PARTNER_NUMBER = sap.END_USER

left outer join SAP_BU bu on bu.SEGMENT = 

    case when sap.SEGMENT ilike '3DI%' then '3DI'

        when sap.SEGMENT ilike 'RLSA%' then 'ES'

        when sap.SEGMENT = 'CERTAS' then 'Certas'

        when sap.SEGMENT ilike 'FS-3DI%' then 'FS_3DI'

        when sap.SEGMENT ilike 'FS - %' then concat('FS_', substr(sap.SEGMENT,6,length(sap.SEGMENT)-5))

        when sap.SEGMENT ilike 'FS-%' then concat('FS_', substr(sap.SEGMENT,4,length(sap.SEGMENT)-3))

        else sap.SEGMENT 

    end

left outer join ref_cte_SALES_CRM_ACCOUNT crm on crm.ACCOUNT_CODE = sap.END_USER

left outer join ref_cte_CALENDARDATE date on date.CALENDAR_DATE = sap.POSTING_DATE

where PNL_CATEGORY = 'Revenue'

    and not coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION) in ('TEL Group', 'Regional Others')

    and coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION) is not null

    and Service_BU is not null

    and COMPANY_NAME = 'TEA'

    and sap.SALES_CATEGORY_ORACLE IN ('CONTRA', 'PDSRV') --, 'TSCSTD', 'TSCREM') --'SMSRV', 'TRNPD',  'CONFLX', 'PDEXP', 

    and POSTING_DATE >= '5/1/2023'

    and POSTING_DATE >= dateadd(year, -1, date_trunc(month, current_date()))

    and POSTING_DATE < date_trunc(month, current_date())

group by

    PNL_CATEGORY,

    concat(coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION), ' ', Service_BU)

order by

    PNL_CATEGORY,

    concat(coalesce(acc.SALES_ACCOUNT_REGION, crm.SALES_ACCOUNT_REGION), ' ', Service_BU) asc

),

Summary

as

(

select

    case when coalesce(cog.SALES_ACCOUNT_BU, rev.SALES_ACCOUNT_BU) is not null then coalesce(cog.SALES_ACCOUNT_BU, rev.SALES_ACCOUNT_BU) 

        else 'TEA Overall' 

    end                                      as SALES_ACCOUNT_BU,

    coalesce(sum(Actual_Revenue_Amount),0)   as Actual_Revenue_Amount,

    coalesce(sum(Subcon_Hours),0)            as Subcon_Hours,

    coalesce(sum(Subcon_Hours*48*-1),0)      as Subcon_COGS,

    coalesce(sum(FTE_Hours),0)               as FTE_Hours,

    coalesce(sum(FTE_Hours*93*-1),0)         as FTE_COGS,

    coalesce(sum(Total_Hours),0)             as Total_Hours

from Revenue_Actual rev

full outer join FTE_Subcon_Hours cog on cog.SALES_ACCOUNT_BU = rev.SALES_ACCOUNT_BU

group by rollup (coalesce(cog.SALES_ACCOUNT_BU, rev.SALES_ACCOUNT_BU))

order by coalesce(cog.SALES_ACCOUNT_BU, rev.SALES_ACCOUNT_BU) asc

),

source_data as (
SELECT 'Non Intel'                                         as Sales_Account_BU,

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

where not Sales_Account_BU ilike any ('Intel %', 'TEA Overall')



union all

select

    'Intel'                                             as Sales_Account_BU,

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

where Sales_Account_BU ilike 'Intel %'



union all

select

    'GF/IBM'                                            as Sales_Account_BU,

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

where Sales_Account_BU ilike 'GF/IBM %'



union all

select

    'Micron'                                            as Sales_Account_BU,

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

where Sales_Account_BU ilike 'Micron %'



union all

select

    'Regional East'                                     as Sales_Account_BU,

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

where Sales_Account_BU ilike 'Regional East %'



union all

select

    'Regional West'                                     as Sales_Account_BU,

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

where Sales_Account_BU ilike 'Regional West %'



union all

select

    'Samsung'                                           as Sales_Account_BU,

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

where Sales_Account_BU ilike 'Samsung %'



union all

select

    'TI'                                                as Sales_Account_BU,

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

where Sales_Account_BU ilike 'TI %'



union all

select

    'tsmc'                                              as Sales_Account_BU,

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

where Sales_Account_BU ilike 'tsmc %'



union all

select

    SALES_ACCOUNT_BU,

    sum(case when Actual_Revenue_Amount is null then 0 

            else Actual_Revenue_Amount 

        end)                                            as Actual_Revenue_Amount,

    to_number(sum(Subcon_Hours),38,2)                   as Subcon_Hours,

    to_number(sum(Subcon_Hours*48*-1),38,2)             as Subcon_COGS,

    to_number(sum(FTE_Hours),38,2)                      as FTE_Hours,

    to_number(sum(FTE_Hours*93*-1),38,2)                as FTE_COGS,

    to_number(sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1),38,2)                                                          as Estimated_COGS,

    to_number(sum(Actual_Revenue_Amount) + sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1),38,2)                             as Estimated_Service_Margin,

    to_number(case when sum(Actual_Revenue_Amount)=0 then null

                else (sum(Actual_Revenue_Amount)+ sum(Subcon_Hours*48*-1) + sum(FTE_Hours*93*-1))/sum(Actual_Revenue_Amount) 

              end,10,4)                                                                                                     as Service_Margin_Ratio

from Summary

group by SALES_ACCOUNT_BU

order by 

    case when SALES_ACCOUNT_BU = 'TEA Overall' then 0

        when SALES_ACCOUNT_BU = 'Intel' then 1

        when SALES_ACCOUNT_BU = 'Non Intel' then 2 

        when SALES_ACCOUNT_BU = 'GF/IBM' then 3

        when SALES_ACCOUNT_BU = 'Micron' then 4

        when SALES_ACCOUNT_BU = 'Regional East' then 5

        when SALES_ACCOUNT_BU = 'Regional West' then 6

        when SALES_ACCOUNT_BU = 'Samsung' then 7

        when SALES_ACCOUNT_BU = 'TI' then 8

        when SALES_ACCOUNT_BU = 'tsmc' then 9

        when SALES_ACCOUNT_BU ilike any 'Intel %' then 10

        when SALES_ACCOUNT_BU ilike any 'GF/IBM %' then 11

        when SALES_ACCOUNT_BU ilike any 'Micron %' then 12

        when SALES_ACCOUNT_BU ilike any 'Regional %' then 13

        when SALES_ACCOUNT_BU ilike any 'Samsung %' then 14

        when SALES_ACCOUNT_BU ilike any 'TI %' then 15

        when SALES_ACCOUNT_BU ilike any 'tsmc %' then 16

        else 17 

    end asc,

    case when startswith(SALES_ACCOUNT_BU, 'Regional') then concat(split_part(SALES_ACCOUNT_BU, ' ', 1), ' ', split_part(SALES_ACCOUNT_BU, ' ', 2))

        else split_part(SALES_ACCOUNT_BU, ' ', 1) 

    end asc,

    case when not split_part(SALES_ACCOUNT_BU, ' ', -1) ilike any 'Others' then 0 

        else 1 

    end asc,

    split_part(SALES_ACCOUNT_BU, ' ', -1) asc

),

transform_data as (
select 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    SALES_ACCOUNT_BU::VARCHAR(16777216) AS SALES_ACCOUNT_BU,
	ACTUAL_REVENUE_AMOUNT,
	SUBCON_HOURS::NUMBER(38,2) AS SUBCON_HOURS,
	SUBCON_COGS::NUMBER(38,2) AS SUBCON_COGS,
	FTE_HOURS::NUMBER(38,2) AS FTE_HOURS,
	FTE_COGS,
	ESTIMATED_COGS,
	ESTIMATED_SERVICE_MARGIN,
	SERVICE_MARGIN_RATIO::NUMBER(38,4) AS SERVICE_MARGIN_RATIO
from source_data
),

type_data as (
select 
    _AUDIT_LOG_ID,
    _ROW_HASH,    
    SALES_ACCOUNT_BU,
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