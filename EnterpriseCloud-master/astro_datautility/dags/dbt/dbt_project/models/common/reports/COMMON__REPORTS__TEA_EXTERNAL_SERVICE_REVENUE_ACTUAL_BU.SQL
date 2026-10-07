{{ config(
    materialized='incremental',
	incremental_strategy='insert_overwrite',
    alias='TEA_EXTERNAL_SERVICE_REVENUE_ACTUAL_BU',
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
    BAAN_CODE
from {{ ref('COMMON__DE_SAP_MASTER_DATA__SAP_BUSINESS_UNIT') }}
),
Actual
as
(
select distinct
    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT   as FY_Half,
    sap.PRODUCT_TYPE_CATEGORY,
    'Service'                                   as Category,
    bu.BU_TYPE                                  as BU,
    sum(sap.AMOUNT_IN_COMPANY_CODE_CURRENCY)*-1 as Actual_Amount
from SAP_BU bu
left outer join {{ ref('COMMON__SAPH__DAILY_ACTUALS_SALES_LINE') }} sap on bu.BAAN_CODE = sap.BAAN_SEGMENT_CODE
left outer join {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }} date on date.CALENDAR_DATE = sap.POSTING_DATE
left outer join {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }} date2 on date2.CALENDAR_DATE = dateadd(day, -1, date_trunc(month, current_date()))
where sap.COMPANY_NAME = 'TEA'
    and sap.PNL_CATEGORY = 'Revenue'
    -- and sap.VERSION = 'Final'
    and sap.POSTING_DATE >= date2.FISCAL_HALF_YEAR_BEGINNING_DATE
    and sap.POSTING_DATE < date_trunc(month, current_date())
    and sap.SALES_CATEGORY_ORACLE IN ('CONTRA', 'SMSRV', 'TSCSTD', 'TSCREM', 'PDSRV', 'TRNPD')
    and sap.END_USER_GROUP <> 'TEL Group'
    and sap.END_USER_GROUP is not null
group by 
    date.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT,
    sap.PRODUCT_TYPE_CATEGORY,
    bu.BU_TYPE
order by 
    PRODUCT_TYPE_CATEGORY asc,
    bu.BU_TYPE asc
),
NotinActual
as
(
select
    BU_TYPE as BU
from SAP_BU

except
select 
    BU
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
    BU,
    0                                           as Actual_Amount
from NotinActual
left outer join {{ source('PUB__COMMON_SYSTEM', 'CALENDARDATE') }} date2 on date2.CALENDAR_DATE = dateadd(day, -1, date_trunc(month, current_date()))
),
Summary
as
(
select
    case when BU is not null then BU else 'TEA Overall' end as BU,
    sum(Actual_Amount)                                      as Actual_Amount
from Merged
group by rollup (BU)
order by 
    case when BU = 'TEA Overall' then 0 else 1 end asc,
    BU asc
),
SOURCE_DATA AS (
select
    FY_Half,
    case when PRODUCT_TYPE_CATEGORY is not null then PRODUCT_TYPE_CATEGORY else 'Labor' end as PRODUCT_TYPE_CATEGORY,
    case when Category is not null then Category else 'Service' end                         as Category,
    sum.BU,
    sum.Actual_Amount
from Summary sum
left outer join Merged on Merged.BU = sum.BU
order by 
    case when sum.BU = 'TEA Overall' then 0 else 1 end asc,
    sum.BU asc
),
TRANSFORM_DATA AS (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	FY_HALF,
	PRODUCT_TYPE_CATEGORY,
	CATEGORY,
	BU,
	ACTUAL_AMOUNT

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
	BU,
	CAST(ACTUAL_AMOUNT as NUMBER(38,2)) as ACTUAL_AMOUNT
from transform_data
)
SELECT * FROM TYPE_DATA