{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='US_GS_REVENUE_EXPANDED_CURRENT_HALF_ROLLUP',
    transient=false
) }}

with
Budget_SOExpanded1
as
(
select
    Sales_Account,
    Sales_Region,
    BU,
    Sub_BU,
    BU_Group,
    Sold_to_Party,
    End_User,
    FAB,
    Sales_Order_No,
    Sales_Category_Group,
    Sales_Category,
    Is_Placeholder,
    Product_Name,
    Serial_No,
    Sales_Month,
    Sales_Amount,
    QUANTITY,
    Sales_Date,
    Is_Loaner,
    Revenue_Recognition_Criteria_Short,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type,
    End_User_Code,
    GS_Budget_FK_Date             as GS_FK_Date,
    GS_Budget_FY                  as GS_FY,
    GS_Budget_FY_Half             as GS_FY_Half,
    GS_Budget_FY_Q                as GS_FY_Q,
    Beginning_of_GS_Budget_FY_Q   as Beginning_of_GS_FY_Q,
    End_of_GS_Budget_FY_Q         as End_of_GS_FY_Q,
	Beginning_of_Current_FY,
	End_of_Current_FY,
	Beginning_of_Current_FY_Half,
	End_of_Current_FY_Half,
	Beginning_of_Current_FY_Q,
	End_of_Current_FY_Q,
    Beginning_of_Previous_FY,
	End_of_Previous_FY,
	Beginning_of_Previous_FY_Half,
	End_of_Previous_FY_Half,
    Beginning_of_Previous_FY_Q,
	End_of_Previous_FY_Q,
    Beginning_of_Next_FY,
	End_of_Next_FY,
	Beginning_of_Next_FY_Half,
	End_of_Next_FY_Half,
	Beginning_of_Next_FY_Q,
	End_of_Next_FY_Q,
    concat(SALES_ORDER_NO, '-', Revenue_Recognition_Criteria_Short)     as GSKey,
    row_number() over (partition by GSKey order by Sales_Amount desc)   as Row_No
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }}
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }})
    and SALES_MONTH >= Beginning_of_Current_FY_Half
    and SALES_MONTH <= End_of_Current_FY_Half
    and SALES_ORDER_NO is not null
    and not SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番')
    and REVENUE_RECOGNITION_CRITERIA_SHORT is not null
    and REVENUE_RECOGNITION_CRITERIA_SHORT <> ''
),
Budget_SOExpanded
as
(
select *
from Budget_SOExpanded1
where Row_No = 1
),        
Budget_wSORollup
as
(
select distinct
    Sales_Order_No, 
    listagg(Serial_No, ', ')                                            as Serial_No,
    REVENUE_RECOGNITION_CRITERIA_SHORT,
    max(Sales_Month)                                                    as Sales_Month,
    sum(Sales_Amount)                                                   as Sales_Amount,
    concat(Sales_Order_No, '-', REVENUE_RECOGNITION_CRITERIA_SHORT)     as GSKey
from Budget_SOExpanded1
group by Sales_Order_No, REVENUE_RECOGNITION_CRITERIA_SHORT
),
Forecast_SOExpanded1
as
(
select
    Sales_Account,
    Sales_Region,
    BU,
    Sub_BU,
    BU_Group,
    Sold_to_Party,
    End_User,
    FAB,
    Sales_Order_No,
    Sales_Category_Group,
    Sales_Category,
    Is_Placeholder,
    Product_Name,
    Serial_No,
    Sales_Month,
    Sales_Amount,
    QUANTITY,
    Sales_Date,
    Is_Loaner,
    Revenue_Recognition_Criteria_Short,
    Data_Snapshot_GS,
    Data_Type,
    ''                                as Budget_Type,
    End_User_Code,
    GS_Forecast_FK_Date               as GS_FK_Date,
    GS_Forecast_FY                    as GS_FY,
    GS_Forecast_FY_Half               as GS_FY_Half,
    GS_Forecast_FY_Q                  as GS_FY_Q,
    Beginning_of_GS_Forecast_FY_Q     as Beginning_of_GS_FY_Q,
    End_of_GS_Forecast_FY_Q           as End_of_GS_FY_Q,
	Beginning_of_Current_FY,
	End_of_Current_FY,
	Beginning_of_Current_FY_Half,
	End_of_Current_FY_Half,
	Beginning_of_Current_FY_Q,
	End_of_Current_FY_Q,
    Beginning_of_Previous_FY,
	End_of_Previous_FY,
	Beginning_of_Previous_FY_Half,
	End_of_Previous_FY_Half,
    Beginning_of_Previous_FY_Q,
	End_of_Previous_FY_Q,
    Beginning_of_Next_FY,
	End_of_Next_FY,
	Beginning_of_Next_FY_Half,
	End_of_Next_FY_Half,
	Beginning_of_Next_FY_Q,
	End_of_Next_FY_Q,
    concat(SALES_ORDER_NO, '-', Revenue_Recognition_Criteria_Short)     as GSKey,
    row_number() over (partition by GSKey order by Sales_Amount desc)   as Row_No
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_REVENUE_FORECAST_EXPANDED') }}
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_REVENUE_FORECAST_EXPANDED') }})
    and SALES_MONTH >= Beginning_of_Current_FY_Half
    and SALES_MONTH <= End_of_Current_FY_Half
    and SALES_ORDER_NO is not null
    and not SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番')
    and REVENUE_RECOGNITION_CRITERIA_SHORT is not null
    and REVENUE_RECOGNITION_CRITERIA_SHORT <> ''
),
Forecast_SOExpanded
as
(
select *
from Forecast_SOExpanded1
where Row_No = 1
),        
Forecast_wSORollup
as
(
select distinct
    Sales_Order_No, 
    listagg(Serial_No, ', ')                                            as Serial_No,
    REVENUE_RECOGNITION_CRITERIA_SHORT,
    max(Sales_Month)                                                    as Sales_Month,
    sum(Sales_Amount)                                                   as Sales_Amount,
    concat(Sales_Order_No, '-', REVENUE_RECOGNITION_CRITERIA_SHORT)     as GSKey
from Forecast_SOExpanded1
group by Sales_Order_No, REVENUE_RECOGNITION_CRITERIA_SHORT
),
Merged
as
(
select
    flat.Sales_Account,
    flat.Sales_Region,
    flat.BU,
    flat.Sub_BU,
    flat.BU_Group,
    flat.Sold_to_Party,
    flat.End_User,
    flat.FAB,
    rollup.Sales_Order_No,
    flat.Sales_Category_Group,
    flat.Sales_Category,
    flat.Is_Placeholder,
    flat.Product_Name,
    rollup.Serial_No,
    rollup.Sales_Month,
    rollup.Sales_Amount,
    flat.Is_Loaner,
    rollup.Revenue_Recognition_Criteria_Short,
    flat.Data_Snapshot_GS,
    flat.Data_Type,
    flat.Budget_Type,
    flat.End_User_Code,
    flat.GS_FK_Date,
    flat.GS_FY,
    flat.GS_FY_Half,
    flat.GS_FY_Q,
    flat.Beginning_of_GS_FY_Q,
    flat.End_of_GS_FY_Q,
    flat.Beginning_of_Current_FY,
	flat.End_of_Current_FY,
	flat.Beginning_of_Current_FY_Half,
	flat.End_of_Current_FY_Half,
	flat.Beginning_of_Current_FY_Q,
	flat.End_of_Current_FY_Q,
    flat.Beginning_of_Previous_FY,
	flat.End_of_Previous_FY,
	flat.Beginning_of_Previous_FY_Half,
	flat.End_of_Previous_FY_Half,
	flat.Beginning_of_Previous_FY_Q,
	flat.End_of_Previous_FY_Q,
	flat.Beginning_of_Next_FY,
	flat.End_of_Next_FY,
	flat.Beginning_of_Next_FY_Half,
	flat.End_of_Next_FY_Half,
	flat.Beginning_of_Next_FY_Q,
	flat.End_of_Next_FY_Q
from Budget_wSORollup rollup
    left outer join Budget_SOExpanded flat on flat.GSKey = rollup.GSKey

union all
select
    flat.Sales_Account,
    flat.Sales_Region,
    flat.BU,
    flat.Sub_BU,
    flat.BU_Group,
    flat.Sold_to_Party,
    flat.End_User,
    flat.FAB,
    rollup.Sales_Order_No,
    flat.Sales_Category_Group,
    flat.Sales_Category,
    flat.Is_Placeholder,
    flat.Product_Name,
    rollup.Serial_No,
    rollup.Sales_Month,
    rollup.Sales_Amount,
    flat.Is_Loaner,
    rollup.Revenue_Recognition_Criteria_Short,
    flat.Data_Snapshot_GS,
    flat.Data_Type,
    flat.Budget_Type,
    flat.End_User_Code,
    flat.GS_FK_Date,
    flat.GS_FY,
    flat.GS_FY_Half,
    flat.GS_FY_Q,
    flat.Beginning_of_GS_FY_Q,
    flat.End_of_GS_FY_Q,
    flat.Beginning_of_Current_FY,
	flat.End_of_Current_FY,
	flat.Beginning_of_Current_FY_Half,
	flat.End_of_Current_FY_Half,
	flat.Beginning_of_Current_FY_Q,
	flat.End_of_Current_FY_Q,
    flat.Beginning_of_Previous_FY,
	flat.End_of_Previous_FY,
	flat.Beginning_of_Previous_FY_Half,
	flat.End_of_Previous_FY_Half,
	flat.Beginning_of_Previous_FY_Q,
	flat.End_of_Previous_FY_Q,
	flat.Beginning_of_Next_FY,
	flat.End_of_Next_FY,
	flat.Beginning_of_Next_FY_Half,
	flat.End_of_Next_FY_Half,
	flat.Beginning_of_Next_FY_Q,
	flat.End_of_Next_FY_Q
from Forecast_wSORollup rollup
    left outer join Forecast_SOExpanded flat on flat.GSKey = rollup.GSKey
),
SOURCE_DATA AS (
select * 
from Merged
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from Merged)
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        BU,
        SUB_BU,
        BU_GROUP,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        IS_PLACEHOLDER,
        PRODUCT_NAME,
        SERIAL_NO,
        SALES_MONTH,
        SALES_AMOUNT,
        IS_LOANER,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        DATA_SNAPSHOT_GS,
        DATA_TYPE,
        BUDGET_TYPE,
        END_USER_CODE,
        GS_FK_DATE,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        BEGINNING_OF_GS_FY_Q,
        END_OF_GS_FY_Q,
        BEGINNING_OF_CURRENT_FY,
        END_OF_CURRENT_FY,
        BEGINNING_OF_CURRENT_FY_HALF,
        END_OF_CURRENT_FY_HALF,
        BEGINNING_OF_CURRENT_FY_Q,
        END_OF_CURRENT_FY_Q,
        BEGINNING_OF_PREVIOUS_FY,
        END_OF_PREVIOUS_FY,
        BEGINNING_OF_PREVIOUS_FY_HALF,
        END_OF_PREVIOUS_FY_HALF,
        BEGINNING_OF_PREVIOUS_FY_Q,
        END_OF_PREVIOUS_FY_Q,
        BEGINNING_OF_NEXT_FY,
        END_OF_NEXT_FY,
        BEGINNING_OF_NEXT_FY_HALF,
        END_OF_NEXT_FY_HALF,
        BEGINNING_OF_NEXT_FY_Q,
        END_OF_NEXT_FY_Q
FROM SOURCE_DATA
)

,
TYPE_DATA AS (
SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        BU,
        SUB_BU,
        BU_GROUP,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        IS_PLACEHOLDER,
        PRODUCT_NAME,
        SERIAL_NO,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
        IS_LOANER,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        DATA_TYPE,
        BUDGET_TYPE,
        END_USER_CODE,
        CAST(GS_FK_DATE as DATE) as GS_FK_DATE,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        CAST(BEGINNING_OF_GS_FY_Q as DATE) as BEGINNING_OF_GS_FY_Q,
        CAST(END_OF_GS_FY_Q as DATE) as END_OF_GS_FY_Q,
        CAST(BEGINNING_OF_CURRENT_FY as DATE) as BEGINNING_OF_CURRENT_FY,
        CAST(END_OF_CURRENT_FY as DATE) as END_OF_CURRENT_FY,
        CAST(BEGINNING_OF_CURRENT_FY_HALF as DATE) as BEGINNING_OF_CURRENT_FY_HALF,
        CAST(END_OF_CURRENT_FY_HALF as DATE) as END_OF_CURRENT_FY_HALF,
        CAST(BEGINNING_OF_CURRENT_FY_Q as DATE) as BEGINNING_OF_CURRENT_FY_Q,
        CAST(END_OF_CURRENT_FY_Q as DATE) as END_OF_CURRENT_FY_Q,
        CAST(BEGINNING_OF_PREVIOUS_FY as DATE) as BEGINNING_OF_PREVIOUS_FY,
        CAST(END_OF_PREVIOUS_FY as DATE) as END_OF_PREVIOUS_FY,
        CAST(BEGINNING_OF_PREVIOUS_FY_HALF as DATE) as BEGINNING_OF_PREVIOUS_FY_HALF,
        CAST(END_OF_PREVIOUS_FY_HALF as DATE) as END_OF_PREVIOUS_FY_HALF,
        CAST(BEGINNING_OF_PREVIOUS_FY_Q as DATE) as BEGINNING_OF_PREVIOUS_FY_Q,
        CAST(END_OF_PREVIOUS_FY_Q as DATE) as END_OF_PREVIOUS_FY_Q,
        CAST(BEGINNING_OF_NEXT_FY as DATE) as BEGINNING_OF_NEXT_FY,
        CAST(END_OF_NEXT_FY as DATE) as END_OF_NEXT_FY,
        CAST(BEGINNING_OF_NEXT_FY_HALF as DATE) as BEGINNING_OF_NEXT_FY_HALF,
        CAST(END_OF_NEXT_FY_HALF as DATE) as END_OF_NEXT_FY_HALF,
        CAST(BEGINNING_OF_NEXT_FY_Q as DATE) as BEGINNING_OF_NEXT_FY_Q,
        CAST(END_OF_NEXT_FY_Q as DATE) as END_OF_NEXT_FY_Q
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA