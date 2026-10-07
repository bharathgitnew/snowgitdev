{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_GS_BOOKING_FORECAST_CURRENT_HALF_CHANGED',
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
    PRODUCT_NAME               as Model, --ORDER_ITEM,
    IS_PLACEHOLDER             as Placeholder,
    -- gs.Adjusted_Serial_No   as Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    IS_LOANER                  as Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    BOOKING_MONTH              as GS_Booking_Month,
    BOOKING_AMOUNT             as Booking_Amount_JPY,
    GS_FY,
    GS_FY_HALF,
    GS_FY_Q,
    DATA_SNAPSHOT_GS           as Data_Snapshot
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_EXPANDED_CURRENT_HALF_ROLLUP') }}
where Data_Snapshot = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_EXPANDED_CURRENT_HALF_ROLLUP') }} where DATA_TYPE not ilike 'Budget')
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
    MODEL,
    Product_Name,
    Opportunity_Title_Free_Text,
    Sales_Reporting_Flag,
    Serial_No,
    BOOKING_AMOUNT,
    Booking_Month,
    QUANTITY,
    Is_Booking_Actual,
    Booking_Sales_Status,
    Actual_Booking_Date, 
    Quote_No,
    Purchase_Order_No,
    Is_Loaner,
    Loan_Expiration_Date,
    VPA,
    Data_Snapshot_GS,
    Data_Type,
    ''                              as Budget_Type,
    Sub_BU_Code,
    Order_Type_Code,
    Sold_to_Party_Code,
    End_User_Code,
    GS_Forecast_FK_Date             as GS_FK_Date,
    GS_Forecast_FY                  as GS_FY,
    GS_Forecast_FY_Half             as GS_FY_Half,
    GS_Forecast_FY_Q                as GS_FY_Q,
    Beginning_of_GS_Forecast_FY_Q   as Beginning_of_GS_FY_Q,
    End_of_GS_Forecast_FY_Q         as End_of_GS_FY_Q,
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
    row_number() over (partition by SALES_ORDER_NO order by BOOKING_AMOUNT desc)   as Row_No
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_BOOKING_FORECAST_EXPANDED') }}
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_BOOKING_FORECAST_EXPANDED') }}
        where DATA_SNAPSHOT_GS < (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_BOOKING_FORECAST_EXPANDED') }}))    
    and BOOKING_MONTH >= BEGINNING_OF_CURRENT_FY_HALF
    and BOOKING_MONTH <= END_OF_CURRENT_FY_HALF
    and SALES_ORDER_NO is not null
    and not SALES_ORDER_NO ilike any ('', '0')
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
    sum(Booking_Amount)  as Booking_Amount
from PreviousFlat1
group by Sales_Order_No
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
    flat.PRODUCT_NAME               as Model, --ORDER_ITEM,
    flat.IS_PLACEHOLDER             as Placeholder,
    -- gs.Adjusted_Serial_No   as Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    flat.IS_LOANER                  as Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    flat.BOOKING_MONTH              as GS_Booking_Month,
    rollup.BOOKING_AMOUNT           as Booking_Amount_JPY,
    flat.GS_FY,
    flat.GS_FY_HALF,
    flat.GS_FY_Q,
    flat.DATA_SNAPSHOT_GS           as Data_Snapshot
from PreviousRollup rollup
left outer join PreviousFlat flat on flat.SALES_ORDER_NO = rollup.SALES_ORDER_NO
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
    curr.PLACEHOLDER,
    curr.LOANER,
    prev.GS_Booking_Month      as Previous_GS_Booking_Month,
    curr.GS_Booking_Month      as Latest_GS_Booking_Month,
    prev.Booking_Amount_JPY    as Previous_Booking_Amount_JPY,
    curr.Booking_Amount_JPY    as Latest_Booking_Amount_JPY,
    curr.GS_FY,
    curr.GS_FY_HALF,
    curr.GS_FY_Q,
    case when prev.GS_Booking_Month <> curr.GS_Booking_Month then 1 
        else 0 
    end                         as Booking_Month_Changed,
    case when prev.Booking_Amount_JPY <> curr.Booking_Amount_JPY then 1 
        else 0 
    end                         as Booking_Amount_Changed,
    case when Booking_Month_Changed = 1 and Booking_Amount_Changed = 1 then 'Booking Month and Amount changed'
        when Booking_Month_Changed = 1 then 'Booking Month changed'
        when Booking_Amount_Changed = 1 then 'Booking Amount changed'
        else null
    end                         as Change_Type, 
    prev.DATA_SNAPSHOT          as Previous_Data_Snapshot,
    curr.DATA_SNAPSHOT          as Latest_Data_Snapshot     
from GSCurrent curr
left outer join GSPrevious prev on prev.SALES_ORDER_NO = curr.SALES_ORDER_NO
where curr.Booking_Amount_JPY >= 75000000
    and (Previous_GS_Booking_Month <> Latest_GS_Booking_Month
        or Previous_Booking_Amount_JPY <> Latest_Booking_Amount_JPY)
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
    curr.PLACEHOLDER,
    curr.LOANER,
    prev.GS_Booking_Month      as Previous_GS_Booking_Month,
    curr.GS_Booking_Month      as Latest_GS_Booking_Month,
    prev.Booking_Amount_JPY    as Previous_Booking_Amount_JPY,
    curr.Booking_Amount_JPY    as Latest_Booking_Amount_JPY,
    curr.GS_FY,
    curr.GS_FY_HALF,
    curr.GS_FY_Q,
    0                          as Booking_Month_Changed,
    0                          as Booking_Amount_Changed,
    'Added'                    as Change_Type,
    prev.DATA_SNAPSHOT         as Previous_Data_Snapshot,
    curr.DATA_SNAPSHOT         as Latest_Data_Snapshot
from GSCurrent curr
left outer join GSPrevious prev on prev.SALES_ORDER_NO = curr.SALES_ORDER_NO
where curr.Booking_Amount_JPY >= 75000000
    and prev.SALES_ORDER_NO is null
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
    prev.PLACEHOLDER,
    prev.LOANER,
    prev.GS_Booking_Month      as Previous_GS_Booking_Month,
    curr.GS_Booking_Month      as Latest_GS_Booking_Month,
    prev.Booking_Amount_JPY    as Previous_Booking_Amount_JPY,
    curr.Booking_Amount_JPY    as Latest_Booking_Amount_JPY,
    prev.GS_FY,
    prev.GS_FY_HALF,
    prev.GS_FY_Q,
    0                          as Booking_Month_Changed,
    0                          as Booking_Amount_Changed,
    'Removed'                  as Change_Type,
    prev.DATA_SNAPSHOT         as Previous_Data_Snapshot,
    curr.DATA_SNAPSHOT         as Latest_Data_Snapshot
from GSPrevious prev 
left outer join GSCurrent curr on curr.SALES_ORDER_NO = prev.SALES_ORDER_NO 
where prev.Booking_Amount_JPY >= 75000000
    and curr.SALES_ORDER_NO is null
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
        PLACEHOLDER,
        LOANER,
        PREVIOUS_GS_BOOKING_MONTH,
        LATEST_GS_BOOKING_MONTH,
        PREVIOUS_BOOKING_AMOUNT_JPY,
        LATEST_BOOKING_AMOUNT_JPY,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        BOOKING_MONTH_CHANGED,
        BOOKING_AMOUNT_CHANGED,
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
        PLACEHOLDER,
        LOANER,
        CAST(PREVIOUS_GS_BOOKING_MONTH as DATE) as PREVIOUS_GS_BOOKING_MONTH,
        CAST(LATEST_GS_BOOKING_MONTH as DATE) as LATEST_GS_BOOKING_MONTH,
        CAST(PREVIOUS_BOOKING_AMOUNT_JPY as NUMBER(38,0)) as PREVIOUS_BOOKING_AMOUNT_JPY,
        CAST(LATEST_BOOKING_AMOUNT_JPY as NUMBER(38,0)) as LATEST_BOOKING_AMOUNT_JPY,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        CAST(BOOKING_MONTH_CHANGED as NUMBER(38,0)) as BOOKING_MONTH_CHANGED,
        CAST(BOOKING_AMOUNT_CHANGED as NUMBER(38,0)) as BOOKING_AMOUNT_CHANGED,
        CHANGE_TYPE,
        CAST(PREVIOUS_DATA_SNAPSHOT as DATE) as PREVIOUS_DATA_SNAPSHOT,
        CAST(LATEST_DATA_SNAPSHOT as DATE) as LATEST_DATA_SNAPSHOT
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA