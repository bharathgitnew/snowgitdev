{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_REVENUE_NEXT_HALF_MATCH_GS',
    transient=false
) }}

WITH
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
    -- gs.OPPORTUNITY_ID,
    -- gs.PROJECT_NO,
    gs.Sales_Category_Group,
    gs.Sales_Category,
    gs.Product_Name                                 AS Model, --ORDER_ITEM,
    -- gs.SALES_REPORTING_FLAG,
    gs.IS_PLACEHOLDER                               AS Placeholder,
    crm.Adjusted_Confidence_Account_Short           AS Account_Confidence,
    crm.Confidence_BU_Short                         AS BU_Confidence,
    gs.Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    crm.Adjusted_Ship_Date, 
    crm.Scheduled_Acceptance_TSR_Sign_Off_Date      AS Sign_Off_Date,
	crm.Adjusted_End_User_Sales_Date_Account        AS Sales_Date_Account,
    crm.End_User_Sales_Date_BU                      AS Sales_Date_BU,
    gs.Sales_Month									AS GS_Sales_Month,
    gs.SALES_AMOUNT                                 AS Sales_Amount_JPY,
    gs.Revenue_Recognition_Criteria_Short			AS Rev_Rec_Criteria,
    gs.Is_Loaner                                    AS Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    gs.Data_Snapshot_GS,
    gs.GS_FY,
    gs.GS_FY_Half,
    gs.GS_FY_Q
	-- gs.Beginning_of_GS_FY_Q,
	-- gs.End_of_GS_FY_Q,
	-- gs.Beginning_of_Next_FY,
	-- gs.End_of_Next_FY,
	-- gs.Beginning_of_Next_FY_Half,
	-- gs.End_of_Next_FY_Half,
	-- gs.Beginning_of_Next_FY_Q,
	-- gs.End_of_Next_FY_Q
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_NEXT_HALF_ROLLUP') }} gs
    INNER JOIN {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_FORECAST_NEXT_HALF_ROLLUP') }} crm ON crm.Sales_Order_No = gs.Sales_Order_No AND crm.REVENUE_RECOGNITION_CRITERIA_SHORT = gs.REVENUE_RECOGNITION_CRITERIA_SHORT
WHERE Adjusted_Confidence_Account_Short NOT IN ('C', 'D', 'L', 'G', '---', '--', '') 
    AND Adjusted_Confidence_Account_Short IS NOT NULL
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
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        SERIAL_NO,
        ADJUSTED_SHIP_DATE,
        SIGN_OFF_DATE,
        SALES_DATE_ACCOUNT,
        SALES_DATE_BU,
        GS_SALES_MONTH,
        SALES_AMOUNT_JPY,
        REV_REC_CRITERIA,
        LOANER,
        DATA_SNAPSHOT_GS,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
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
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        SERIAL_NO,
        CAST(ADJUSTED_SHIP_DATE as DATE) as ADJUSTED_SHIP_DATE,
        CAST(SIGN_OFF_DATE as DATE) as SIGN_OFF_DATE,
        CAST(SALES_DATE_ACCOUNT as DATE) as SALES_DATE_ACCOUNT,
        CAST(SALES_DATE_BU as DATE) as SALES_DATE_BU,
        CAST(GS_SALES_MONTH as DATE) as GS_SALES_MONTH,
        CAST(SALES_AMOUNT_JPY as NUMBER(38,0)) as SALES_AMOUNT_JPY,
        REV_REC_CRITERIA,
        LOANER,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q
from transform_data
)
SELECT * FROM TYPE_DATA