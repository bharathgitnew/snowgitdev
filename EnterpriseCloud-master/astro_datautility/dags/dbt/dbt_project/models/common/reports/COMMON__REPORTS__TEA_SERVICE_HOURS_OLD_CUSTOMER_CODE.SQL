{{ config(
    	materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEA_SERVICE_HOURS_OLD_CUSTOMER_CODE',
    	transient=false
) }}

with ref_cte_SAP_SALES_ACCOUNT_REGION as (
    select * from {{ ref('COMMON__DE_SALES_OPERATIONS__SAP_SALES_ACCOUNT_REGION') }}
),

ref_cte_SAP_BUSINESS_UNIT as (
    select * from {{ ref('COMMON__DE_SALES_OPERATIONS__SAP_BUSINESS_UNIT') }}
),

ref_cte_CALENDARDATE as (
    select * from {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }}
),

ref_cte_TIMESHEET as (
    SELECT * FROM {{ ref('PUB__DE_OPERATIONS__TIMESHEET') }}
),

ref_cte_D_EMPLOYEE as (
    SELECT * FROM {{ ref('PUB__DE_OPERATIONS__D_EMPLOYEE') }}
),
SAP_Baan_Account as
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

        when startswith(BUSINESS_PARTNER_NUMBER,'D') then substr(IDENTIFICATION_NUMBER,3,7) else null end  as Code_Order

from ref_cte_SAP_SALES_ACCOUNT_REGION

where not startswith(BUSINESS_PARTNER_NUMBER,'A')

qualify row_number() over (partition by CORPORATION_ID order by Code_Order asc)=1

),

SAP_BU

as

(

select

    case when BU_TYPE ilike '%Others%' then 'Others' else BU_TYPE end              as BU_TYPE,

    case when startswith(BU_TYPE, 'FS_') then substr(BU_TYPE, 4) else BU_TYPE end  as Service_BU,

    SEGMENT

from ref_cte_SAP_BUSINESS_UNIT

),

TimesheetPrep

as

(

select *,

    case when LEFT(FABCODE,1) in ('A','B','C','D') then FABCODE else LEFT(FABCODE,7) end              as Adjusted_FABCODE,

    coalesce(EMPLOYEETYPE, case when emp.EMPLOYEE_TYPE ilike 'Regular%' then 'FTE' else 'Subcon' end) as Adjusted_Employee_Type

from ref_cte_TIMESHEET time

left outer join ref_cte_D_EMPLOYEE Emp ON Emp.EMPLOYEE_ID = time.EMPLOYEEID

where PRODUCTTYPE ilike any ('CONTRA', 'CONFLX', 'PDSRV', 'PDEXP')

    and EVENTDATE >= dateadd(year, -1, date_trunc(month, current_date()))

    and EVENTDATE <= dateadd(day, -1, date_trunc(month, current_date()))

),

source_data as (
SELECT distinct

    case when LEFT(FABCODE,1) in ('A','B','C','D') then FABCODE 

        else LEFT(FABCODE,7) end                                  as Adjusted_FABCODE,

    FAB,

    coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION,

        case when Adjusted_FABCODE IN ('B00000364', 'B00001870') then 'Intel'

            when Adjusted_FABCODE IN ('BA2120201', 'DA2120201') then 'Samsung'

            when Adjusted_FABCODE = 'BA3435610' then 'Micron'

            when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

            when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY

            else null end)                                        as Sales_Account_Region,

    bu.Service_BU                                                 as BU,

    concat(

        coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION,

            case when Adjusted_FABCODE IN ('B00000364', 'B00001870') then 'Intel'

                when Adjusted_FABCODE IN ('BA2120201', 'DA2120201') then 'Samsung'

                when Adjusted_FABCODE = 'BA3435610' then 'Micron'

                when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

                when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY

                else null end)

            , ' ', bu.Service_BU)                                 as SALES_ACCOUNT_BU,

    Adjusted_Employee_Type                                        as Employee_Type,

	HOURSCHARGED                                                  as Hours_Charged

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

        else MACHINEBU end

where PRODUCTTYPE ilike any ('CONTRA', 'CONFLX', 'PDSRV', 'PDEXP')

    and coalesce(sap.SALES_ACCOUNT_REGION, baan.SALES_ACCOUNT_REGION, 

        case when Adjusted_FABCODE IN ('B00000364', 'B00001870') then 'Intel'

            when Adjusted_FABCODE IN ('BA2120201', 'DA2120201') then 'Samsung'

            when Adjusted_FABCODE = 'BA3435610' then 'Micron'

            when Adjusted_FABCODE = 'BA3621800' then 'Regional West' -- Robert Bosch

            when Adjusted_FABCODE = 'BA4369001' then 'GF/IBM' -- The Research Foundation of SUNY 

            else null end) is null

    and EVENTDATE >= dateadd(year, -1, date_trunc(month, current_date()))

    and EVENTDATE <= dateadd(day, -1, date_trunc(month, current_date()))

),

transform_data as (
    SELECT 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH, 
    ADJUSTED_FABCODE,
	FAB,
	SALES_ACCOUNT_REGION,
	BU,
	SALES_ACCOUNT_BU,
	EMPLOYEE_TYPE,
	HOURS_CHARGED
    FROM source_data
),

type_data as (
    SELECT 
    CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
    ADJUSTED_FABCODE,
	FAB,
	SALES_ACCOUNT_REGION,
	BU,
	SALES_ACCOUNT_BU,
	EMPLOYEE_TYPE,
	HOURS_CHARGED
    from transform_data
)

select * from type_data