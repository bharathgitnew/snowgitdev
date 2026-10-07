{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_REVENUE_2_FY_HALF_AWAY_RISKS',
    transient=false
) }}

with
GSwSO
as
(
select *
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_2_FY_HALF_AWAY_ROLLUP') }}
-- where SALES_ORDER_NO is not null
--     and not SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番')
),
AccountwSO
as
(
select *
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_FORECAST_2_FY_HALF_AWAY_ROLLUP') }}
where Adjusted_Confidence_Account_Short not in ('C', 'D', 'L', 'G', '---', '--', '') 
    and Adjusted_Confidence_Account_Short is not null
    and SALES_ACCOUNT not ilike 'Intel'

union all
select *
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_FORECAST_2_FY_HALF_AWAY_ROLLUP') }}
where Adjusted_Confidence_Account_Short not in ('D', 'L', 'G', '---', '--', '') 
    and Adjusted_Confidence_Account_Short is not null
    and SALES_ACCOUNT ilike 'Intel'
),
CRMRollup
as
(
select
    Sales_Order_No,
    REVENUE_RECOGNITION_CRITERIA_SHORT,
    Adjusted_Confidence_Account_Short,
    Confidence_BU_Short,
    Adjusted_Ship_Date,
    Scheduled_Acceptance_TSR_Sign_Off_Date,
    Adjusted_End_User_Sales_Date_Account,
    End_User_Sales_Date_BU,
    Account_Revenue_FY,   
	Account_Revenue_FY_Half,  
	Account_Revenue_FY_Q,
    Data_Snapshot_Timestamp,
    OPPORTUNITY_ID
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_RECORDS_ROLLUP') }}
),
SOURCE_DATA AS (
select
    gs.Sales_Account,
    gs.Sales_Region,
    gs.BU,
    gs.BU_Group,
    gs.Sub_BU,
    gs.Sold_to_Party,
    gs.End_User,
    gs.FAB,
    gs.Sales_Order_No,
    crm.OPPORTUNITY_ID,
    -- gs.PROJECT_NO,
    gs.Sales_Category_Group,
    gs.Sales_Category,
    gs.Revenue_Recognition_Criteria_Short			as Rev_Rec_Criteria,
    gs.Product_Name                                 as Model, --ORDER_ITEM,
    -- gs.SALES_REPORTING_FLAG,
    gs.IS_PLACEHOLDER                               as Placeholder,
    crm.Adjusted_Confidence_Account_Short           as Account_Confidence,
    crm.Confidence_BU_Short                         as BU_Confidence,
    gs.Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    gs.Is_Loaner                                    as Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    crm.Adjusted_Ship_Date, 
    crm.Scheduled_Acceptance_TSR_Sign_Off_Date      as Sign_Off_Date,
	crm.Adjusted_End_User_Sales_Date_Account        as Sales_Date_Account,
    crm.End_User_Sales_Date_BU                      as Sales_Date_BU,
    gs.Sales_Month									as GS_Sales_Month,
    gs.SALES_AMOUNT                                 as Sales_Amount_JPY,
    crm.Account_Revenue_FY,   
	crm.Account_Revenue_FY_Half,  
	crm.Account_Revenue_FY_Q,
    gs.GS_FY,
    gs.GS_FY_Half,
    gs.GS_FY_Q,
    crm.Data_Snapshot_Timestamp                     as Data_Snapshot_Timestamp_CRM,
    gs.Data_Snapshot_GS,
    gs.Data_Type,
    case when concat(month(Sales_Date_Account), ', ', year(Sales_Date_Account)) <> concat(month(GS_Sales_Month), ', ',year(GS_Sales_Month)) then 1 else 0 end as Account_Month_Conflict,
    case when concat(month(Sales_Date_BU), ', ', year(Sales_Date_BU)) <> concat(month(GS_Sales_Month), ', ',year(GS_Sales_Month)) then 1 else 0 end as BU_Month_Conflict
from GSwSO gs
    left outer join AccountwSO acct on acct.Sales_Order_No = gs.Sales_Order_No and acct.REVENUE_RECOGNITION_CRITERIA_SHORT = gs.REVENUE_RECOGNITION_CRITERIA_SHORT
    left outer join CRMRollup crm on crm.Sales_Order_No = gs.Sales_Order_No and crm.REVENUE_RECOGNITION_CRITERIA_SHORT = gs.REVENUE_RECOGNITION_CRITERIA_SHORT
where acct.Sales_Order_No is null
    and Sales_Amount_JPY <> 0
    and Sales_Amount_JPY is not null
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
        OPPORTUNITY_ID,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        REV_REC_CRITERIA,
        MODEL,
        PLACEHOLDER,
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        SERIAL_NO,
        LOANER,
        ADJUSTED_SHIP_DATE,
        SIGN_OFF_DATE,
        SALES_DATE_ACCOUNT,
        SALES_DATE_BU,
        GS_SALES_MONTH,
        SALES_AMOUNT_JPY,
        ACCOUNT_REVENUE_FY,
        ACCOUNT_REVENUE_FY_HALF,
        ACCOUNT_REVENUE_FY_Q,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        DATA_SNAPSHOT_TIMESTAMP_CRM,
        DATA_SNAPSHOT_GS,
        DATA_TYPE,
        ACCOUNT_MONTH_CONFLICT,
        BU_MONTH_CONFLICT
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
        OPPORTUNITY_ID,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        REV_REC_CRITERIA,
        MODEL,
        PLACEHOLDER,
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        SERIAL_NO,
        LOANER,
        CAST(ADJUSTED_SHIP_DATE as DATE) as ADJUSTED_SHIP_DATE,
        CAST(SIGN_OFF_DATE as DATE) as SIGN_OFF_DATE,
        CAST(SALES_DATE_ACCOUNT as DATE) as SALES_DATE_ACCOUNT,
        CAST(SALES_DATE_BU as DATE) as SALES_DATE_BU,
        CAST(GS_SALES_MONTH as DATE) as GS_SALES_MONTH,
        CAST(SALES_AMOUNT_JPY as NUMBER(38,0)) as SALES_AMOUNT_JPY,
        ACCOUNT_REVENUE_FY,
        ACCOUNT_REVENUE_FY_HALF,
        ACCOUNT_REVENUE_FY_Q,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        CAST(DATA_SNAPSHOT_TIMESTAMP_CRM as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP_CRM,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        DATA_TYPE,
        CAST(ACCOUNT_MONTH_CONFLICT as NUMBER(38,0)) as ACCOUNT_MONTH_CONFLICT,
        CAST(BU_MONTH_CONFLICT as NUMBER(38,0)) as BU_MONTH_CONFLICT
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA