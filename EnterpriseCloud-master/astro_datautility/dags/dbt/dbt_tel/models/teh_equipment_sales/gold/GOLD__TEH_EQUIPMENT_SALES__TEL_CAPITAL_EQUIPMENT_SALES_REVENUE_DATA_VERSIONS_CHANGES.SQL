{{ config(
    	materialized='tel_incremental',
       incremental_strategy='insert_overwrite',
    	alias='TEL_CAPITAL_EQUIPMENT_SALES_REVENUE_DATA_VERSIONS_CHANGES',
    	transient=false
) }}

WITH src_cte_GS_US_REVENUE_BUDGET_HISTORY_ALL as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET_HISTORY_ALL') }}
),

src_cte_GS_US_REVENUE_FORECAST as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_FORECAST') }}
),

Budget

as

(

select

    GS_Budget_FY                                                                   as FY,

    GS_Budget_FY_HALF                                                              as FY_Half,

    SALES_ACCOUNT,

    sum(SALES_AMOUNT)                                                              as Sales_Amount,

    BUDGET_TYPE                                                                    as Budget_Type,

    'GS Budget'                                                                    as Data_Source,

    Beginning_of_GS_Budget_FY_Half                                                 as Beginning_of_FY_Half,

    DATA_SNAPSHOT

from src_cte_GS_US_Revenue_Budget_History_All

where case when endswith(GS_BUDGET_FY_HALF, '2H') then BUDGET_TYPE = 'Revised' else BUDGET_TYPE = 'Original' end

    and GS_BUDGET_FK_DATE >= Beginning_of_Current_FY_Half

    and GS_BUDGET_FK_DATE <= End_of_Current_FY_Half

group by DATA_SNAPSHOT, GS_Budget_FY, GS_BUDGET_FY_HALF, BUDGET_TYPE, BEGINNING_OF_FY_HALF, SALES_ACCOUNT

order by DATA_SNAPSHOT asc, SALES_ACCOUNT asc

),

Forecast

as

(

select

    GS_FORECAST_FY                      as FY,

    GS_FORECAST_FY_HALF                 as FY_HALF,

    SALES_ACCOUNT,

    sum(SALES_AMOUNT)                   as Sales_Amount,

    ''                                  as Budget_Type,

    'GS Forecast'                       as Data_Source,

    Beginning_of_GS_Forecast_FY_Half    as Beginning_of_FY_Half,

    DATA_SNAPSHOT

from src_cte_GS_US_REVENUE_FORECAST

where GS_FORECAST_FK_DATE >= Beginning_of_Current_FY_Half

    and GS_FORECAST_FK_DATE <= End_of_Current_FY_Half

group by DATA_SNAPSHOT, GS_FORECAST_FY, GS_FORECAST_FY_HALF, BEGINNING_OF_FY_HALF, SALES_ACCOUNT

order by DATA_SNAPSHOT asc, SALES_ACCOUNT asc

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

from Budget



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
FROM source_data
),

type_data as (

select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(FY as VARCHAR(16777216)) as FY,
        CAST(FY_HALF as VARCHAR(16777216)) as FY_HALF,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
        CAST(BUDGET_TYPE as VARCHAR(16777216)) as BUDGET_TYPE,
        CAST(DATA_SOURCE as VARCHAR(16777216)) as DATA_SOURCE,
        CAST(BEGINNING_OF_FY_HALF as DATE) as BEGINNING_OF_FY_HALF,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT
from transform_data
)
select * from type_data