{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_REVENUE_CURRENT_HALF_RISKS',
    transient=false
) }}

with
GSwSO
AS
(
SELECT *
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_CURRENT_HALF_ROLLUP') }}
-- where SALES_ORDER_NO is not null
--     and SALES_ORDER_NO <> ''
--     and not SALES_ORDER_NO in ('0', '取得中', 'バルク')
),
AccountwSO
AS
(
SELECT *
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_FORECAST_CURRENT_HALF_ROLLUP') }}
WHERE Adjusted_Confidence_Account_Short NOT IN ('C', 'D', 'L', 'G', '---', '--', '') 
    AND Adjusted_Confidence_Account_Short IS NOT NULL
    AND SALES_ACCOUNT NOT ILIKE 'Intel'

union all
select *
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_FORECAST_CURRENT_HALF_ROLLUP') }}
where Adjusted_Confidence_Account_Short not in ('D', 'L', 'G', '---', '--', '') 
    and Adjusted_Confidence_Account_Short is not null
    and SALES_ACCOUNT ilike 'Intel'
),
CRMRollup
AS
(
SELECT
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
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_RECORDS_ROLLUP') }}
),
SOURCE_DATA AS (
SELECT
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
    gs.Revenue_Recognition_Criteria_Short			AS Rev_Rec_Criteria,
    gs.Product_Name                                 AS Model, --ORDER_ITEM,
    -- gs.SALES_REPORTING_FLAG,
    gs.IS_PLACEHOLDER                               AS Placeholder,
    crm.Adjusted_Confidence_Account_Short           AS Account_Confidence,
    crm.Confidence_BU_Short                         AS BU_Confidence,
    gs.Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    gs.Is_Loaner                                    AS Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    crm.Adjusted_Ship_Date, 
    crm.Scheduled_Acceptance_TSR_Sign_Off_Date      AS Sign_Off_Date,
	crm.Adjusted_End_User_Sales_Date_Account        AS Sales_Date_Account,
    crm.End_User_Sales_Date_BU                      AS Sales_Date_BU,
    gs.Sales_Month									AS GS_Sales_Month,
    gs.SALES_AMOUNT                                 AS Sales_Amount_JPY,
    gs.GS_FY,
    gs.GS_FY_Half,
    gs.GS_FY_Q,
    crm.Data_Snapshot_Timestamp                     AS Data_Snapshot_Timestamp_CRM,
    gs.Data_Snapshot_GS,
    gs.Data_Type,
    CASE WHEN CONCAT(MONTH(Sales_Date_Account), ', ', YEAR(Sales_Date_Account)) <> CONCAT(MONTH(GS_Sales_Month), ', ',YEAR(GS_Sales_Month)) THEN 1 ELSE 0 END AS Account_Month_Conflict,
    CASE WHEN CONCAT(MONTH(Sales_Date_BU), ', ', YEAR(Sales_Date_BU)) <> CONCAT(MONTH(GS_Sales_Month), ', ',YEAR(GS_Sales_Month)) THEN 1 ELSE 0 END AS BU_Month_Conflict
FROM GSwSO gs
    LEFT OUTER JOIN AccountwSO acct ON acct.Sales_Order_No = gs.Sales_Order_No AND acct.REVENUE_RECOGNITION_CRITERIA_SHORT = gs.REVENUE_RECOGNITION_CRITERIA_SHORT
    LEFT OUTER JOIN CRMRollup crm ON crm.Sales_Order_No = gs.Sales_Order_No AND crm.REVENUE_RECOGNITION_CRITERIA_SHORT = gs.REVENUE_RECOGNITION_CRITERIA_SHORT
WHERE acct.Sales_Order_No IS NULL
    AND Sales_Amount_JPY <> 0
    AND Sales_Amount_JPY IS NOT NULL
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