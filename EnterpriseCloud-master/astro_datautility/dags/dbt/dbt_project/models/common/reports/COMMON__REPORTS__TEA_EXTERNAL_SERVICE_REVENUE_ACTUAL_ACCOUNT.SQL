{{ config(
    	materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEA_EXTERNAL_SERVICE_REVENUE_ACTUAL_ACCOUNT',
    	transient=false
) }}

WITH ref_cte_CALENDARDATE as (
    select * from {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }}
),

ref_cte_REVENUE_COGS_DAILY_REPORT as (
    select * from {{ ref('COMMON__SAPH__DAILY_ACTUALS_SALES_LINE') }}
),

ref_cte_SAP_SALES_ACCOUNT_REGION as (
    select * from {{ ref('COMMON__DE_SAP_MASTER_DATA__SAP_SALES_ACCOUNT_REGION') }}
),

SAP_Account

as

(

select distinct

    SALES_ACCOUNT

from ref_cte_SAP_SALES_ACCOUNT_REGION

where SALES_ACCOUNT <> 'TEL Group'

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

    acc.SALES_ACCOUNT,

    sum(sap.AMOUNT_IN_COMPANY_CODE_CURRENCY)*-1 as Actual_Amount

from SAP_Account acc

left outer join ref_cte_REVENUE_COGS_DAILY_REPORT sap on acc.SALES_ACCOUNT = case when sap.END_USER_GROUP = 'TSMC' then 'tsmc' else sap.END_USER_GROUP end

left outer join ref_cte_CALENDARDATE date on date.CALENDAR_DATE = sap.POSTING_DATE

left outer join ref_cte_CALENDARDATE date2 on date2.CALENDAR_DATE = current_date()

where sap.COMPANY_NAME = 'TEA'

    and sap.PNL_CATEGORY = 'Revenue'

    -- and sap.VERSION = 'Final'

    and sap.POSTING_DATE >= date2.FISCAL_HALF_YEAR_BEGINNING_DATE

    and sap.POSTING_DATE < DATE_TRUNC(month, CURRENT_DATE())

    and sap.SALES_CATEGORY_ORACLE in ('CONTRA', 'SMSRV', 'TSCSTD', 'TSCREM', 'PDSRV', 'TRNPD')

    and sap.END_USER_GROUP <> 'TEL Group'

    and sap.END_USER_GROUP is not null

group by 

    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT,

    PRODUCT_TYPE_CATEGORY,

    SALES_ACCOUNT

order by 

    PRODUCT_TYPE_CATEGORY asc,

    SALES_ACCOUNT asc

),

NotinActual

as

(

select

    SALES_ACCOUNT

from SAP_Account



except

select 

    SALES_ACCOUNT

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

    SALES_ACCOUNT,

    0                                           as Actual_Amount

from NotinActual

left outer join ref_cte_CALENDARDATE date2 on date2.CALENDAR_DATE = current_date()

),

Summary

as

(

select

    case when SALES_ACCOUNT is not null then SALES_ACCOUNT else 'TEA Overall' end as SALES_ACCOUNT,

    sum(Actual_Amount)                                                            as Actual_Amount

from Merged

group by rollup (SALES_ACCOUNT)

order by 

    case when SALES_ACCOUNT = 'TEA Overall' then 0 else 1 end asc,

    SALES_ACCOUNT asc

),

source_data as (
SELECT FY_Half,

    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Labor' end as PRODUCT_TYPE_CATEGORY,

    case when Category is not null then Category else 'Service' end                         as Category,

    'Non Intel'                                                                             as SALES_ACCOUNT,

    sum(sum.Actual_Amount)                                                                  as Actual_Amount

from Summary sum

left outer join Merged on Merged.SALES_ACCOUNT = sum.SALES_ACCOUNT

where not sum.SALES_ACCOUNT ilike any ('Intel', 'TEA Overall')

group by 

    FY_Half,

    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Labor' end,

    case when Category is not null then Category else 'Service' end



union all

select

    FY_Half,

    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Labor' end as PRODUCT_TYPE_CATEGORY,

    case when Category is not null then Category else 'Service' end                         as Category,

    sum.SALES_ACCOUNT,

    sum(sum.Actual_Amount)                                                                  as Actual_Amount

from Summary sum

left outer join Merged on Merged.SALES_ACCOUNT = sum.SALES_ACCOUNT

group by

    FY_Half,

    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Labor' end,

    case when Category is not null then Category else 'Service' end,

    sum.SALES_ACCOUNT

order by 

    case when SALES_ACCOUNT = 'TEA Overall' then 0

        when SALES_ACCOUNT = 'Intel' then 1

        when SALES_ACCOUNT = 'Non Intel' then 2 else 3 end asc,

    SALES_ACCOUNT asc

),

transform_data as (
select FY_HALF,
	PRODUCT_TYPE_CATEGORY,
	CATEGORY,
	SALES_ACCOUNT,
	ACTUAL_AMOUNT,
	'{{ invocation_id }}' AS AUDIT_LOG_ID
from source_data
),

type_data as (
    SELECT
        CAST(FY_HALF AS VARCHAR(16777216)) AS FY_HALF,
        CAST(PRODUCT_TYPE_CATEGORY AS VARCHAR(16777216)) AS PRODUCT_TYPE_CATEGORY,
        CAST(CATEGORY AS VARCHAR(16777216)) AS CATEGORY,
        CAST(SALES_ACCOUNT AS VARCHAR(16777216)) AS SALES_ACCOUNT,
        CAST(ACTUAL_AMOUNT AS NUMBER(38,2)) AS ACTUAL_AMOUNT,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID
    FROM transform_data
)

SELECT * from type_data