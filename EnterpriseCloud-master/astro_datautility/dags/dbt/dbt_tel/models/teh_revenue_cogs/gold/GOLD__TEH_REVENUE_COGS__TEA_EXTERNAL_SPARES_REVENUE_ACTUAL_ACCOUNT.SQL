{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEA_EXTERNAL_SPARES_REVENUE_ACTUAL_ACCOUNT',
    	transient=false
) }}

WITH ref_cte_CALENDARDATE as (
    select * from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
),

ref_cte_SAP_SALES_ACCOUNT_REGION as (
    select * from {{ ref('GOLD__TEH_REVENUE_COGS__SAP_SALES_ACCOUNT_REGION') }}
),

ref_cte_REVENUE_COGS_DAILY_REPORT as (
    select * from {{ ref('GOLD__TEH_REVENUE_COGS__DAILY_ACTUALS_SALES_LINE') }}
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

    'Spares'                                    as Category,

    --SALES_CATEGORY_ORACLE,

    --ORACLE_PRODUCT_TYPE_GROUP,

    --SALES_CATEGORY_NAME,

    acc.SALES_ACCOUNT                           as Sales_Account,

    sum(sap.amount_in_company_code_currency)*-1 as Actual_Amount

from SAP_Account acc

left outer join ref_cte_REVENUE_COGS_DAILY_REPORT sap on acc.SALES_ACCOUNT = case when sap.END_USER_GROUP = 'TSMC' then 'tsmc' else sap.END_USER_GROUP end

left outer join ref_cte_CALENDARDATE date on date.CALENDAR_DATE = sap.POSTING_DATE

left outer join ref_cte_CALENDARDATE date2 on date2.CALENDAR_DATE = current_date()

where sap.COMPANY_NAME = 'TEA'

    and sap.PNL_CATEGORY = 'Revenue'

    -- and sap.VERSION = 'Final'

    and sap.POSTING_DATE >= date2.FISCAL_HALF_YEAR_BEGINNING_DATE

    and sap.POSTING_DATE < DATE_TRUNC(month, CURRENT_DATE())

    and sap.SALES_CATEGORY_ORACLE IN ('PDPRT', 'RPREXC', 'RPRPRT', 'RPRSVC', 'SPAREC')

    and sap.END_USER_GROUP <> 'TEL Group'

    and sap.END_USER_GROUP is not null

group by 

    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT,

    sap.PRODUCT_TYPE_CATEGORY,

    acc.SALES_ACCOUNT

order by 

    sap.PRODUCT_TYPE_CATEGORY asc,

    acc.SALES_ACCOUNT asc

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

    'Parts'                                     as PRODUCT_TYPE_CATEGORY,

    'Spares'                                    as Category,

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

    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Parts' end as PRODUCT_TYPE_CATEGORY,

    case when Category is not null then Category else 'Spares' end                          as Category,

    'Non Intel'                                                                             as SALES_ACCOUNT,

    sum(sum.Actual_Amount)                                                                  as Actual_Amount

from Summary sum

left outer join Merged on Merged.SALES_ACCOUNT = sum.SALES_ACCOUNT

where not sum.SALES_ACCOUNT ilike any ('Intel', 'TEA Overall')

group by

    FY_Half,

    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Parts' end,

    case when Category is not null then Category else 'Spares' end



union all

select

    FY_Half,

    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Parts' end as PRODUCT_TYPE_CATEGORY,

    case when Category is not null then Category else 'Spares' end                          as Category,

    sum.SALES_ACCOUNT,

    sum(sum.Actual_Amount)                                                                  as Actual_Amount

from Summary sum

left outer join Merged on Merged.SALES_ACCOUNT = sum.SALES_ACCOUNT

group by

    FY_Half,

    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Parts' end,

    case when Category is not null then Category else 'Spares' end,

    sum.SALES_ACCOUNT

order by 

    case when SALES_ACCOUNT = 'TEA Overall' then 0

        when SALES_ACCOUNT = 'Intel' then 1

        when SALES_ACCOUNT = 'Non Intel' then 2 else 3 end asc,

    SALES_ACCOUNT asc

),

transform_data as (
select 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    FY_HALF,
	PRODUCT_TYPE_CATEGORY,
	CATEGORY,
	SALES_ACCOUNT,
	ACTUAL_AMOUNT
from source_data
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(FY_HALF AS VARCHAR(16777216)) AS FY_HALF,
        CAST(PRODUCT_TYPE_CATEGORY AS VARCHAR(16777216)) AS PRODUCT_TYPE_CATEGORY,
        CAST(CATEGORY AS VARCHAR(16777216)) AS CATEGORY,
        CAST(SALES_ACCOUNT AS VARCHAR(16777216)) AS SALES_ACCOUNT,
        CAST(ACTUAL_AMOUNT AS NUMBER(38,2)) AS ACTUAL_AMOUNT
    FROM transform_data
)

SELECT * from type_data