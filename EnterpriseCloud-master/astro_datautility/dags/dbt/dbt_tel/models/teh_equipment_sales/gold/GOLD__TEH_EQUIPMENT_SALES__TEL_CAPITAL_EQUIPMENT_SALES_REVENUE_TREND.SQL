{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_CAPITAL_EQUIPMENT_SALES_REVENUE_TREND',
    transient=false
) }}

with
Actual
as
(
select distinct
    GS_ACTUAL_FY                   as FY,
    GS_ACTUAL_FY_HALF              as FY_Half,
    SALES_ACCOUNT,
    BU_TYPE,
    sum(SALES_AMOUNT)              as Sales_Amount,
    'TEL GS Actual'                as Data_Source,
    Beginning_of_GS_Actual_FY_Half as Beginning_of_FY_Half,
    DATA_SNAPSHOT,
    row_number() over (partition by GS_ACTUAL_FY_HALF, SALES_ACCOUNT, BU_TYPE order by DATA_SNAPSHOT desc) as ROW_NO
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_ACTUAL') }}
where GS_ACTUAL_FY_HALF is not null
group by GS_ACTUAL_FY, GS_ACTUAL_FY_HALF, DATA_SNAPSHOT, Beginning_of_FY_Half, SALES_ACCOUNT, BU_TYPE
order by DATA_SNAPSHOT
),
Accounting_Actual_FY19_1H
as
(
select distinct
    ACCOUNTING_ACTUAL_FY                   as FY,
    ACCOUNTING_ACTUAL_FY_HALF              as FY_Half,
    SALES_ACCOUNT,
    BU_TYPE,
    sum(SALES_AMOUNT)                      as Sales_Amount,
    'TEL Accounting Actual'                as Data_Source,
    Beginning_of_Accounting_Actual_FY_Half as Beginning_of_FY_Half,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__ACCOUNTING_US_REVENUE_ACTUAL') }}
where ACCOUNTING_ACTUAL_FY_HALF = 'FY19 1H'
group by ACCOUNTING_ACTUAL_FY, ACCOUNTING_ACTUAL_FY_HALF, DATA_SNAPSHOT, Beginning_of_FY_Half, SALES_ACCOUNT, BU_TYPE
order by DATA_SNAPSHOT 
),
TEL_Forecast
as
(
select distinct
    GS_FORECAST_FY                      as FY,
    GS_FORECAST_FY_HALF                 as FY_HALF,
    SALES_ACCOUNT,
    BU_TYPE,
    sum(SALES_AMOUNT)                   as Sales_Amount,
    'TEL GS Forecast'                   as Data_Source,
    Beginning_of_GS_Forecast_FY_Half    as Beginning_of_FY_Half,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_FORECAST') }}
where DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) 
                       from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_FORECAST') }}
                       where GS_FORECAST_FK_DATE >= Beginning_of_Current_FY_Half
                          and GS_FORECAST_FK_DATE <= End_of_Current_FY_Half)
group by GS_FORECAST_FY, GS_FORECAST_FY_HALF, DATA_SNAPSHOT, Beginning_of_FY_Half, SALES_ACCOUNT, BU_TYPE
order by DATA_SNAPSHOT 
),
TEL_Budget
as
(
select distinct
    GS_BUDGET_FY                          as FY,
    GS_BUDGET_FY_HALF                     as FY_Half,
    budget.SALES_ACCOUNT,
    budget.BU_TYPE,
    sum(budget.SALES_AMOUNT)              as Sales_Amount,
    'TEL GS Budget'                       as Data_Source,
    budget.Beginning_of_GS_Budget_FY_Half as Beginning_of_FY_Half,
    budget.DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} budget
left outer join Actual on actual.FY_HALF = budget.GS_BUDGET_FY_HALF
left outer join TEL_Forecast forecast on forecast.FY_HALF = budget.GS_BUDGET_FY_HALF
where GS_BUDGET_FY_HALF is not null
    and actual.FY_HALF is null
    and forecast.FY_HALF is null
    and BUDGET_TYPE ilike any ('Original', 'Revised')
    and budget.DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) 
                                from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} 
                                where BUDGET_TYPE ilike any ('Original', 'Revised'))
group by GS_BUDGET_FY, GS_BUDGET_FY_HALF, budget.DATA_SNAPSHOT, budget.Beginning_of_GS_Budget_FY_Half, budget.SALES_ACCOUNT, budget.BU_TYPE
order by budget.DATA_SNAPSHOT 
),
TEL_Advance
as
(
select distinct
    GS_BUDGET_FY                          as FY,
    GS_BUDGET_FY_HALF                     as FY_Half,
    budget.SALES_ACCOUNT,
    budget.BU_TYPE,
    sum(budget.SALES_AMOUNT)              as Sales_Amount,
    'TEL GS Budget'                       as Data_Source,
    budget.Beginning_of_GS_Budget_FY_Half as Beginning_of_FY_Half,
    budget.DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} budget
where GS_BUDGET_FY_HALF is not null
    and BUDGET_TYPE ilike 'Advance'
    and budget.DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) 
                                from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }}
                                where BUDGET_TYPE ilike 'Advance')
group by GS_BUDGET_FY, GS_BUDGET_FY_HALF, budget.DATA_SNAPSHOT, budget.Beginning_of_GS_Budget_FY_Half, budget.SALES_ACCOUNT, budget.BU_TYPE
order by budget.DATA_SNAPSHOT 
),
SOURCE_DATA
as
(
select
    FY,
    FY_Half,
    SALES_ACCOUNT,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from Actual
where ROW_NO = 1

union all
select
    FY,
    FY_Half,
    SALES_ACCOUNT,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from Accounting_Actual_FY19_1H

union all
select
    FY,
    FY_Half,
    SALES_ACCOUNT,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from TEL_Forecast

union all
select
    FY,
    FY_Half,
    SALES_ACCOUNT,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from TEL_Budget

union all
select
    FY,
    FY_Half,
    SALES_ACCOUNT,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from TEL_Advance
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FY_HALF,
        SALES_ACCOUNT,
        BU_TYPE,
        SALES_AMOUNT,
        DATA_SOURCE,
        BEGINNING_OF_FY_HALF,
        DATA_SNAPSHOT
FROM SOURCE_DATA
)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        FY_HALF,
        SALES_ACCOUNT,
        BU_TYPE,
        SALES_AMOUNT,
        DATA_SOURCE,
        BEGINNING_OF_FY_HALF,
        DATA_SNAPSHOT
from transform_data
)
SELECT * FROM TYPE_DATA