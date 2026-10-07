{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_CAPITAL_EQUIPMENT_SALES_REVENUE_TREND_BU',
    transient=false
) }}

with
Actual
as
(
select distinct 
    GS_ACTUAL_FY_HALF                                                              as FY_Half,
    BU_TYPE,
    sum(SALES_AMOUNT)                                                              as Sales_Amount,
    'TEL GS Actual'                                                                as Data_Source,
    Beginning_of_GS_Actual_FY_Half                                                 as Beginning_of_FY_Half,
    DATA_SNAPSHOT,
    row_number() over (partition by GS_ACTUAL_FY_HALF, BU_TYPE order by DATA_SNAPSHOT desc) as ROW_NO
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_ACTUAL') }}
where GS_ACTUAL_FY_HALF is not null
group by GS_ACTUAL_FY_HALF, DATA_SNAPSHOT, Beginning_of_FY_Half, BU_TYPE
order by  DATA_SNAPSHOT
),
Accounting_Actual_FY19_1H
as
(
select distinct 
    ACCOUNTING_ACTUAL_FY_HALF                                                              as FY_Half,
    BU_TYPE,
    sum(SALES_AMOUNT)                                                                      as Sales_Amount,
    'TEL Accounting Actual'                                                                as Data_Source,
    Beginning_of_Accounting_Actual_FY_Half                                                 as Beginning_of_FY_Half,
    DATA_SNAPSHOT,
    row_number() over (partition by ACCOUNTING_ACTUAL_FY_HALF, BU_TYPE order by DATA_SNAPSHOT desc) as ROW_NO
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__ACCOUNTING_US_REVENUE_ACTUAL') }}
where ACCOUNTING_ACTUAL_FY_HALF = 'FY19 1H'
group by ACCOUNTING_ACTUAL_FY_HALF, DATA_SNAPSHOT, Beginning_of_FY_Half, BU_TYPE
order by DATA_SNAPSHOT 
),
TEL_Forecast
as
(
select distinct 
    GS_FORECAST_FY_HALF                 as FY_HALF,
    BU_TYPE,
    sum(SALES_AMOUNT)                   as Sales_Amount,
    'TEL GS Forecast'                   as Data_Source,
    Beginning_of_GS_Forecast_FY_Half    as Beginning_of_FY_Half,
    DATA_SNAPSHOT
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_FORECAST') }}
where Data_Snapshot = (SELECT MAX(Data_Snapshot) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_FORECAST') }})
group by GS_FORECAST_FY_HALF, DATA_SNAPSHOT, Beginning_of_FY_Half, BU_TYPE
order by DATA_SNAPSHOT 
),
TEL_Budget
as
(
select distinct GS_BUDGET_FY_HALF                                                         as FY_Half,
    budget.BU_TYPE,
    sum(budget.SALES_AMOUNT)                                                              as Sales_Amount,
    'TEL GS Budget'                                                                       as Data_Source,
    budget.Beginning_of_GS_Budget_FY_Half                                                 as Beginning_of_FY_Half,
    budget.DATA_SNAPSHOT,
    row_number() over (partition by GS_BUDGET_FY_HALF, budget.BU_TYPE order by budget.DATA_SNAPSHOT desc) as ROW_NO
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} budget
    left outer join Actual on actual.FY_HALF = budget.GS_BUDGET_FY_HALF
    left outer join TEL_Forecast forecast on forecast.FY_HALF = budget.GS_BUDGET_FY_HALF
where GS_BUDGET_FY_HALF is not null
    and actual.FY_HALF is null
    and forecast.FY_HALF is null
group by GS_BUDGET_FY_HALF, budget.DATA_SNAPSHOT, budget.Beginning_of_GS_Budget_FY_Half, budget.BU_TYPE
order by budget.DATA_SNAPSHOT 
),
SOURCE_DATA AS (
select
    FY_Half,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from Actual
where ROW_NO = 1

union all
select
    FY_Half,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from Accounting_Actual_FY19_1H

union all
select
    FY_Half,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from TEL_Forecast

union all
select
    FY_Half,
    BU_TYPE,
    Sales_Amount,
    Data_Source,
    Beginning_of_FY_Half,
    Data_Snapshot
from TEL_Budget
where Row_No = 1
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FY_HALF,
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
        BU_TYPE,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
        DATA_SOURCE,
        CAST(BEGINNING_OF_FY_HALF as DATE) as BEGINNING_OF_FY_HALF,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT
from transform_data
)
SELECT * FROM TYPE_DATA