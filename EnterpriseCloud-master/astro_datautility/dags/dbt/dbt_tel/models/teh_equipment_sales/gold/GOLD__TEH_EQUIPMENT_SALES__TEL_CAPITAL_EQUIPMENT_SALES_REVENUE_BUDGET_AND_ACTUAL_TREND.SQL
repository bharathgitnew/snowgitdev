{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEL_CAPITAL_EQUIPMENT_SALES_REVENUE_BUDGET_AND_ACTUAL_TREND',
    	transient=false
) }}

WITH ref_cte_GS_US_REVENUE_ACTUAL as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_ACTUAL') }}
),

ref_cte_GS_US_REVENUE_BUDGET_HISTORY_ALL as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET_HISTORY_ALL') }}
),

ref_cte_GS_US_REVENUE_FORECAST as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_FORECAST') }}
),

ref_cte_TEL_SALES_CRM_REVENUE_ACTUAL as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_REVENUE_ACTUAL') }}
),

Latest

as

(

select distinct

    GS_Budget_FY                                                                   as FY,

    GS_Budget_FY_HALF                                                              as FY_Half,

    SALES_ACCOUNT,

    sum(SALES_AMOUNT)                                                              as Sales_Amount,

    BUDGET_TYPE                                                                    as Budget_Type,

    'GS Budget'                                                                    as Data_Source,

    Beginning_of_GS_Budget_FY_Half                                                 as Beginning_of_FY_Half,

    DATA_SNAPSHOT,

    row_number() over (partition by GS_BUDGET_FY_HALF, SALES_ACCOUNT order by DATA_SNAPSHOT desc) as Row_No

from ref_cte_GS_US_Revenue_Budget_History_All

where case when endswith(GS_BUDGET_FY_HALF, '2H') then BUDGET_TYPE = 'Revised' else BUDGET_TYPE = 'Original' end

group by GS_Budget_FY, GS_BUDGET_FY_HALF, DATA_SNAPSHOT, BUDGET_TYPE, BEGINNING_OF_FY_HALF, SALES_ACCOUNT

order by GS_BUDGET_FY_HALF asc, Data_Source desc

),

Latest2H

as

(

select distinct

    GS_Budget_FY                                                                   as FY,

    GS_Budget_FY_HALF                                                              as FY_Half,

    SALES_ACCOUNT,

    sum(SALES_AMOUNT)                                                              as Sales_Amount,

    BUDGET_TYPE                                                                    as Budget_Type,

    'GS Budget'                                                                    as Data_Source,

    Beginning_of_GS_Budget_FY_Half                                                 as Beginning_of_FY_Half,

    DATA_SNAPSHOT,

    row_number() over (partition by GS_BUDGET_FY_HALF, SALES_ACCOUNT order by DATA_SNAPSHOT desc) as Row_No

from ref_cte_GS_US_Revenue_Budget_History_All

where BUDGET_TYPE = 'Original'

    and endswith(GS_BUDGET_FY_HALF, '2H') 

group by GS_Budget_FY, GS_BUDGET_FY_HALF, DATA_SNAPSHOT, BUDGET_TYPE, BEGINNING_OF_FY_HALF, SALES_ACCOUNT

order by GS_BUDGET_FY_HALF asc, Data_Source desc

),

Actual

AS

(

select distinct 

    GS_ACTUAL_FY                                                                   as FY,

    GS_ACTUAL_FY_HALF                                                              as FY_Half,

    SALES_ACCOUNT,

    sum(SALES_AMOUNT)                                                              as Sales_Amount,

    ''                                                                             as Budget_Type,

    'GS Actual'                                                                    as Data_Source,

    Beginning_of_GS_Actual_FY_Half                                                 as Beginning_of_FY_Half,

    DATA_SNAPSHOT,

    row_number() over (partition by GS_ACTUAL_FY_HALF, SALES_ACCOUNT order by DATA_SNAPSHOT desc) as Row_No

from ref_cte_GS_US_REVENUE_ACTUAL

where GS_ACTUAL_FY_HALF is not null

group by GS_ACTUAL_FY, GS_ACTUAL_FY_HALF, DATA_SNAPSHOT, BEGINNING_OF_FY_HALF, SALES_ACCOUNT

order by GS_ACTUAL_FY_HALF asc, Data_Source desc

),

Forecast

as

(

select distinct 

    GS_FORECAST_FY                      as FY,

    GS_FORECAST_FY_HALF                 as FY_HALF,

    SALES_ACCOUNT,

    sum(SALES_AMOUNT)                   as Sales_Amount,

    ''                                  as Budget_Type,

    'GS Forecast'                       as Data_Source,

    Beginning_of_GS_Forecast_FY_Half    as Beginning_of_FY_Half,

    DATA_SNAPSHOT

from ref_cte_GS_US_Revenue_Forecast

where Data_Snapshot = (select MAX(Data_Snapshot) from ref_cte_GS_US_Revenue_Forecast)

group by GS_FORECAST_FY, GS_FORECAST_FY_HALF, DATA_SNAPSHOT, BEGINNING_OF_FY_HALF, SALES_ACCOUNT

order by GS_FORECAST_FY_HALF asc, Data_Source desc

),

Preliminary_Actual

as

(

select distinct 

    ACTUAL_REVENUE_FY                       as FY,

    ACTUAL_REVENUE_FY_HALF                  as FY_HALF,

    SALES_ACCOUNT,

    sum(END_USER_SALES_AMOUNT_JPY)          as Sales_Amount,

    ''                                      as Budget_Type,

    'CRM Actual'                            as Data_Source,

    Actual_Revenue_Beginning_of_FY_Half     as Beginning_of_FY_Half,

    MAX(DATA_SNAPSHOT)                      as Data_Snapshot

from ref_cte_TEL_SALES_CRM_REVENUE_ACTUAL

where dateadd(month, -6, Beginning_of_Current_FY_Half) <= ACTUAL_SALES_DATE

    and dateadd(month, -6, End_of_Current_FY_Half) >= ACTUAL_SALES_DATE

group by ACTUAL_REVENUE_FY, ACTUAL_REVENUE_FY_HALF, BEGINNING_OF_FY_HALF, SALES_ACCOUNT

order by ACTUAL_REVENUE_FY_HALF asc

),

source_data as (
SELECT FY,

FY_Half,

SALES_ACCOUNT,

Sales_Amount,

Budget_Type,

Data_Source,

Beginning_of_FY_Half,

Data_Snapshot

from Latest

where Row_No = 1



union all

select

FY,

FY_Half,

SALES_ACCOUNT,

Sales_Amount,

Budget_Type,

Data_Source,

Beginning_of_FY_Half,

Data_Snapshot

from Latest2H

where Row_No = 1



union all

select

FY,

FY_Half,

SALES_ACCOUNT,

Sales_Amount,

Budget_Type,

Data_Source,

Beginning_of_FY_Half,

Data_Snapshot

from Actual

where Row_No = 1



union all

select

FY,

FY_Half,

SALES_ACCOUNT,

Sales_Amount,

Budget_Type,

Data_Source,

Beginning_of_FY_Half,

Data_Snapshot

from Forecast



union all

select

FY,

FY_Half,

SALES_ACCOUNT,

Sales_Amount,

Budget_Type,

Data_Source,

Beginning_of_FY_Half,

Data_Snapshot

from Preliminary_Actual

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FY,
        FY_HALF,
        SALES_ACCOUNT,
        SALES_AMOUNT,
        BUDGET_TYPE,
        DATA_SOURCE,
        BEGINNING_OF_FY_HALF,
        DATA_SNAPSHOT
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(FY as VARCHAR(16777216)) as FY,
        CAST(FY_HALF as VARCHAR(16777216)) as FY_HALF,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_AMOUNT as FLOAT) as SALES_AMOUNT,
        CAST(BUDGET_TYPE as VARCHAR(16777216)) as BUDGET_TYPE,
        CAST(DATA_SOURCE as VARCHAR(16777216)) as DATA_SOURCE,
        CAST(BEGINNING_OF_FY_HALF as DATE) as BEGINNING_OF_FY_HALF,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT
from transform_data 
)
select * from type_data