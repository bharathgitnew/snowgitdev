{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_GS_REVENUE_BUDGET_2_FY_HALF_AWAY_CHANGED',
    transient=false
) }}

with 
GSCurrent
as
(
select
    SALES_ACCOUNT,
    SALES_REGION,
    BU,
    BU_GROUP,
    SUB_BU,
    SOLD_TO_PARTY,
    END_USER,
    FAB,
    SALES_ORDER_NO,
    -- gs.OPPORTUNITY_ID,
    -- gs.PROJECT_NO,
    SALES_CATEGORY_GROUP,
    SALES_CATEGORY,
    PRODUCT_NAME                        as Model, --ORDER_ITEM,
    REVENUE_RECOGNITION_CRITERIA_SHORT  as REVENUE_RECOGNITION_CRITERIA,
    IS_PLACEHOLDER                      as Placeholder,
    -- gs.Adjusted_Serial_No   as Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    IS_LOANER                           as Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    SALES_MONTH                         as GS_SALES_Month,
    SALES_AMOUNT                        as SALES_Amount_JPY,
    GS_FY,
    GS_FY_HALF,
    GS_FY_Q,
    DATA_SNAPSHOT_GS                    as Data_Snapshot
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_2_FY_HALF_AWAY_ROLLUP') }}
where Data_Snapshot = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_2_FY_HALF_AWAY_ROLLUP') }})
),
PreviousFlat1
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
    Opportunity_ID,
    Project_No,
    Sales_Order_No,
    Sales_Category_Group,
    Sales_Category,
    Is_Placeholder,
    ''                                  as MODEL,
    Product_Name,
    REVENUE_RECOGNITION_CRITERIA_SHORT  as REVENUE_RECOGNITION_CRITERIA,
    Opportunity_Title_Free_Text,
    Sales_Reporting_Flag,
    Serial_No,
    SALES_AMOUNT,
    SALES_Month,
    QUANTITY,
    Booking_Sales_Status,
    ''                                  as Quote_No,
    ''                                  as Purchase_Order_No,
    Is_Loaner,
    LOAN_EXPIRATION_DATE,
    ''                                  as VPA,
    DATA_SNAPSHOT_GS,
    Data_Type,
    ''                                  as Budget_Type,
    Sub_BU_Code,
    Order_Type_Code,
    Sold_to_Party_Code,
    End_User_Code,
    GS_Budget_FK_Date                   as GS_FK_Date,
    GS_Budget_FY                        as GS_FY,
    GS_Budget_FY_Half                   as GS_FY_Half,
    GS_Budget_FY_Q                      as GS_FY_Q,
    Beginning_of_GS_Budget_FY_Q         as Beginning_of_GS_FY_Q,
    End_of_GS_Budget_FY_Q               as End_of_GS_FY_Q,
	Beginning_of_Current_FY,
	End_of_Current_FY,
	Beginning_of_Current_FY_Half,
	End_of_Current_FY_Half,
	Beginning_of_Current_FY_Q,
	End_of_Current_FY_Q,
    Beginning_of_Next_FY,
	End_of_Next_FY,
	Beginning_of_Next_FY_Half,
	End_of_Next_FY_Half,
	Beginning_of_Next_FY_Q,
	End_of_Next_FY_Q,
    row_number() over (partition by SALES_ORDER_NO order by SALES_AMOUNT desc) as Row_No
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }}
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }}
        where DATA_SNAPSHOT_GS < (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }}))    
    and SALES_MONTH >= dateadd(day, 1, END_OF_NEXT_FY_HALF)
    and SALES_MONTH <= dateadd(month, 6, END_OF_NEXT_FY_HALF)
    and SALES_ORDER_NO is not null
    and not SALES_ORDER_NO ilike any ('', '0')
    and REVENUE_RECOGNITION_CRITERIA_SHORT is not null
),
PreviousFlat
as
(
select *
from PreviousFlat1
where ROW_NO = 1
),
PreviousRollup
as
(
select distinct
    Sales_Order_No,
    REVENUE_RECOGNITION_CRITERIA,
    sum(SALES_Amount)     as SALES_Amount
from PreviousFlat1
group by Sales_Order_No, REVENUE_RECOGNITION_CRITERIA
),
GSPrevious
as
(
select
    flat.SALES_ACCOUNT,
    flat.SALES_REGION,
    flat.BU,
    flat.BU_GROUP,
    flat.SUB_BU,
    flat.SOLD_TO_PARTY,
    flat.END_USER,
    flat.FAB,
    rollup.SALES_ORDER_NO,
    -- gs.OPPORTUNITY_ID,
    -- gs.PROJECT_NO,
    flat.SALES_CATEGORY_GROUP,
    flat.SALES_CATEGORY,
    flat.PRODUCT_NAME             as Model, --ORDER_ITEM,
    rollup.REVENUE_RECOGNITION_CRITERIA,
    flat.IS_PLACEHOLDER           as Placeholder,
    -- gs.Adjusted_Serial_No   as Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    flat.IS_LOANER                as Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    flat.SALES_MONTH              as GS_SALES_Month,
    rollup.SALES_AMOUNT             as SALES_Amount_JPY,
    flat.GS_FY,
    flat.GS_FY_HALF,
    flat.GS_FY_Q,
    flat.DATA_SNAPSHOT_GS         as Data_Snapshot
from PreviousRollup rollup
left outer join PreviousFlat flat on flat.SALES_ORDER_NO = rollup.SALES_ORDER_NO and flat.REVENUE_RECOGNITION_CRITERIA = rollup.REVENUE_RECOGNITION_CRITERIA
),
Changed
as
(
select
    curr.SALES_ACCOUNT,
    curr.SALES_REGION,
    curr.BU,
    curr.BU_GROUP,
    curr.SUB_BU,
    curr.SOLD_TO_PARTY,
    curr.END_USER,
    curr.FAB,
    curr.SALES_ORDER_NO,
    curr.SALES_CATEGORY_GROUP,
    curr.SALES_CATEGORY,
    curr.Model,
    curr.REVENUE_RECOGNITION_CRITERIA,
    curr.PLACEHOLDER,
    curr.LOANER,
    prev.GS_SALES_Month      as Previous_GS_SALES_Month,
    curr.GS_SALES_Month      as Latest_GS_SALES_Month,
    prev.SALES_Amount_JPY    as Previous_SALES_Amount_JPY,
    curr.SALES_Amount_JPY    as Latest_SALES_Amount_JPY,
    curr.GS_FY,
    curr.GS_FY_HALF,
    curr.GS_FY_Q,
    case when prev.GS_SALES_Month <> curr.GS_SALES_Month then 1 else 0 end as SALES_Month_Changed,
    case when prev.SALES_Amount_JPY <> curr.SALES_Amount_JPY then 1 else 0 end as SALES_Amount_Changed,
    case when SALES_Month_Changed = 1 and SALES_Amount_Changed = 1 then 'Sales Month and Amount changed'
        when SALES_Month_Changed = 1 then 'Sales Month changed'
        when SALES_Amount_Changed = 1 then 'Sales Amount changed'
        else null
        end                  as Change_Type,
    prev.DATA_SNAPSHOT       as Previous_Data_Snapshot,
    curr.DATA_SNAPSHOT       as Latest_Data_Snapshot
from GSCurrent curr
left outer join GSPrevious prev on prev.SALES_ORDER_NO = curr.SALES_ORDER_NO and prev.REVENUE_RECOGNITION_CRITERIA = curr.REVENUE_RECOGNITION_CRITERIA
where curr.SALES_Amount_JPY >= 75000000
    and (Previous_GS_SALES_Month <> Latest_GS_SALES_Month
        or Previous_SALES_Amount_JPY <> Latest_SALES_Amount_JPY)
),
Added
as
(
select
    curr.SALES_ACCOUNT,
    curr.SALES_REGION,
    curr.BU,
    curr.BU_GROUP,
    curr.SUB_BU,
    curr.SOLD_TO_PARTY,
    curr.END_USER,
    curr.FAB,
    curr.SALES_ORDER_NO,
    curr.SALES_CATEGORY_GROUP,
    curr.SALES_CATEGORY,
    curr.Model,
    curr.REVENUE_RECOGNITION_CRITERIA,
    curr.PLACEHOLDER,
    curr.LOANER,
    prev.GS_SALES_Month      as Previous_GS_SALES_Month,
    curr.GS_SALES_Month      as Latest_GS_SALES_Month,
    prev.SALES_Amount_JPY    as Previous_SALES_Amount_JPY,
    curr.SALES_Amount_JPY    as Latest_SALES_Amount_JPY,
    curr.GS_FY,
    curr.GS_FY_HALF,
    curr.GS_FY_Q,
    0                        as SALES_Month_Changed,
    0                        as SALES_Amount_Changed,
    'Added'                  as Change_Type,
    prev.DATA_SNAPSHOT       as Previous_Data_Snapshot,
    curr.DATA_SNAPSHOT       as Latest_Data_Snapshot
from GSCurrent curr
left outer join GSPrevious prev on prev.SALES_ORDER_NO = curr.SALES_ORDER_NO and prev.REVENUE_RECOGNITION_CRITERIA = curr.REVENUE_RECOGNITION_CRITERIA
where curr.SALES_Amount_JPY >= 75000000
    and prev.SALES_ORDER_NO is null 
    and prev.REVENUE_RECOGNITION_CRITERIA is null
),
Removed
as
(
select
    prev.SALES_ACCOUNT,
    prev.SALES_REGION,
    prev.BU,
    prev.BU_GROUP,
    prev.SUB_BU,
    prev.SOLD_TO_PARTY,
    prev.END_USER,
    prev.FAB,
    prev.SALES_ORDER_NO,
    prev.SALES_CATEGORY_GROUP,
    prev.SALES_CATEGORY,
    prev.Model,
    prev.REVENUE_RECOGNITION_CRITERIA,
    prev.PLACEHOLDER,
    prev.LOANER,
    prev.GS_SALES_Month      as Previous_GS_SALES_Month,
    curr.GS_SALES_Month      as Latest_GS_SALES_Month,
    prev.SALES_Amount_JPY    as Previous_SALES_Amount_JPY,
    curr.SALES_Amount_JPY    as Latest_SALES_Amount_JPY,
    prev.GS_FY,
    prev.GS_FY_HALF,
    prev.GS_FY_Q,
    0                        as SALES_Month_Changed,
    0                        as SALES_Amount_Changed,
    'Removed'                as Change_Type,
    prev.DATA_SNAPSHOT       as Previous_Data_Snapshot,
    curr.DATA_SNAPSHOT       as Latest_Data_Snapshot
from GSPrevious prev
left outer join GSCurrent curr on curr.SALES_ORDER_NO = prev.SALES_ORDER_NO and curr.REVENUE_RECOGNITION_CRITERIA = prev.REVENUE_RECOGNITION_CRITERIA
where prev.SALES_Amount_JPY >= 75000000
    and curr.SALES_ORDER_NO is null 
    and curr.REVENUE_RECOGNITION_CRITERIA is null
),
SOURCE_DATA AS (
select *
from Changed

union all
select *
from Added

union all
select *
from Removed
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        BU,
        BU_GROUP,
        SUB_BU,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        REVENUE_RECOGNITION_CRITERIA,
        PLACEHOLDER,
        LOANER,
        PREVIOUS_GS_SALES_MONTH,
        LATEST_GS_SALES_MONTH,
        PREVIOUS_SALES_AMOUNT_JPY,
        LATEST_SALES_AMOUNT_JPY,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        SALES_MONTH_CHANGED,
        SALES_AMOUNT_CHANGED,
        CHANGE_TYPE,
        PREVIOUS_DATA_SNAPSHOT,
        LATEST_DATA_SNAPSHOT
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
        BU_GROUP,
        SUB_BU,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        REVENUE_RECOGNITION_CRITERIA,
        PLACEHOLDER,
        LOANER,
        CAST(PREVIOUS_GS_SALES_MONTH as DATE) as PREVIOUS_GS_SALES_MONTH,
        CAST(LATEST_GS_SALES_MONTH as DATE) as LATEST_GS_SALES_MONTH,
        CAST(PREVIOUS_SALES_AMOUNT_JPY as NUMBER(38,0)) as PREVIOUS_SALES_AMOUNT_JPY,
        CAST(LATEST_SALES_AMOUNT_JPY as NUMBER(38,0)) as LATEST_SALES_AMOUNT_JPY,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        CAST(SALES_MONTH_CHANGED as NUMBER(38,0)) as SALES_MONTH_CHANGED,
        CAST(SALES_AMOUNT_CHANGED as NUMBER(38,0)) as SALES_AMOUNT_CHANGED,
        CHANGE_TYPE,
        CAST(PREVIOUS_DATA_SNAPSHOT as DATE) as PREVIOUS_DATA_SNAPSHOT,
        CAST(LATEST_DATA_SNAPSHOT as DATE) as LATEST_DATA_SNAPSHOT
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA