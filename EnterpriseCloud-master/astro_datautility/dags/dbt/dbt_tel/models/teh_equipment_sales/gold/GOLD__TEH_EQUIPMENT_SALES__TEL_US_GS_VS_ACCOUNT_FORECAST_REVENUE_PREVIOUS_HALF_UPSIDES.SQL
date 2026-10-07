{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEL_US_GS_VS_ACCOUNT_FORECAST_REVENUE_PREVIOUS_HALF_UPSIDES',
    	transient=false
) }}

WITH ref_cte_SALES_CRM_ACCOUNT_REVENUE_FORECAST_PREVIOUS_HALF_ROLLUP as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_FORECAST_PREVIOUS_HALF_ROLLUP') }}
),

ref_cte_US_GS_REVENUE_EXPANDED_PREVIOUS_HALF_ROLLUP as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_PREVIOUS_HALF_ROLLUP') }}
),

GSwSO

AS

(

SELECT *

FROM ref_cte_US_GS_REVENUE_EXPANDED_PREVIOUS_HALF_ROLLUP

WHERE SALES_ACCOUNT NOT ILIKE 'Intel'

),

AccountwSO

AS

(

SELECT *

FROM ref_cte_Sales_CRM_Account_Revenue_Forecast_Previous_HALF_Rollup

WHERE Adjusted_Confidence_Account_Short NOT IN ('C', 'D', 'L', 'G', '---', '--', '') 

    AND Adjusted_Confidence_Account_Short IS NOT NULL

    AND SALES_ACCOUNT NOT ILIKE 'Intel'

),

source_data as (
SELECT

    crm.Sales_Account,

    crm.Sales_Region,

    crm.TEL_Sold_to_Party,

    crm.End_User,

    crm.FAB,

    crm.BU, 

    crm.BU_Group,

    crm.Sub_BU,

    crm.Opportunity_ID,

    crm.Project_No,

    crm.Sales_Order_No,

	crm.Customer_Forecast_ID,

    crm.Sales_Category_Group,

    crm.Sales_Category,

    crm.Model, 

    crm.Order_Item_Opportunity,

	crm.Order_Item_Sales_Document,

    crm.Opportunity_Title_Free_Text,

    crm.Sales_Reporting_Flag,

    crm.Is_Placeholder                              AS Placeholder,

	crm.Adjusted_Confidence_Account_Short           AS Account_Confidence,

    crm.Confidence_BU_Short                         AS BU_Confidence,

    crm.Adjusted_Serial_No                          AS Serial_No, 

    crm.Customer_Tool_ID,

    crm.Quote_No,

    crm.Purchase_Order_No                           AS PO_No,

    crm.Quantity,

    crm.Is_Loaner                                   AS Loaner,

    -- crm.Loan_Expiration_Date,

    -- crm.VPA,

    crm.Adjusted_Ship_Date, 

    crm.Scheduled_Acceptance_TSR_Sign_Off_Date      AS Sign_Off_Date,

	crm.Adjusted_End_User_Sales_Date_Account        AS Sales_Date_Account,

    crm.End_User_Sales_Date_BU                      AS Sales_Date_BU,

    gs.Sales_Month                                  AS GS_Sales_Month,

	crm.Actual_Acceptance_TSR_Sign_Off_Date         AS Actual_Signoff_Date,

	crm.Is_Sign_Off_Actual,

	-- Sales_Amount_JPY_Adjusted, --TEL's Sales Amount after adjustments

	crm.End_User_Sales_Amount_JPY                   AS Sales_Amount_JPY,  --Sales Amount to the customer

	crm.Revenue_Recognition_Criteria_Short          AS Rev_Rec_Criteria,

	crm.Revenue_Recognition_Status                  AS Rev_Rec_Status,

	crm.Booking_Sales_Status,

	crm.Actual_Sales_Date,

	crm.Account_Revenue_FY,   

	crm.Account_Revenue_FY_Half,  

	crm.Account_Revenue_FY_Q,

    crm.Data_Snapshot_Timestamp,

    CASE WHEN CONCAT(MONTH(Sales_Date_Account), ', ', YEAR(Sales_Date_Account)) <> CONCAT(MONTH(Sales_Date_BU), ', ',YEAR(Sales_Date_BU)) THEN 1 ELSE 0 END AS Account_Month_Conflict  

	-- crm.Account_Revenue_Beginning_of_FY_Q,  

	-- crm.Account_Revenue_End_of_FY_Q,

	-- crm.Beginning_of_Next_FY,

	-- crm.End_of_Next_FY,

	-- crm.Beginning_of_Next_FY_Half,

	-- crm.End_of_Next_FY_Half,

	-- crm.Beginning_of_Next_FY_Q,

	-- crm.End_of_Next_FY_Q,

	-- crm.End_User_Code,

FROM AccountwSO crm

    LEFT OUTER JOIN GSwSO gs ON gs.Sales_Order_No = crm.Sales_Order_No AND gs.REVENUE_RECOGNITION_CRITERIA_SHORT = crm.REVENUE_RECOGNITION_CRITERIA_SHORT

WHERE gs.Sales_Order_No IS NULL

    AND Sales_Amount_JPY <> 0

    AND Sales_Amount_JPY IS NOT NULL

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        TEL_SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        OPPORTUNITY_ID,
        PROJECT_NO,
        SALES_ORDER_NO,
        CUSTOMER_FORECAST_ID,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        ORDER_ITEM_OPPORTUNITY,
        ORDER_ITEM_SALES_DOCUMENT,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        PLACEHOLDER,
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PO_NO,
        QUANTITY,
        LOANER,
        ADJUSTED_SHIP_DATE,
        SIGN_OFF_DATE,
        SALES_DATE_ACCOUNT,
        SALES_DATE_BU,
        GS_SALES_MONTH,
        ACTUAL_SIGNOFF_DATE,
        IS_SIGN_OFF_ACTUAL,
        SALES_AMOUNT_JPY,
        REV_REC_CRITERIA,
        REV_REC_STATUS,
        BOOKING_SALES_STATUS,
        ACTUAL_SALES_DATE,
        ACCOUNT_REVENUE_FY,
        ACCOUNT_REVENUE_FY_HALF,
        ACCOUNT_REVENUE_FY_Q,
        DATA_SNAPSHOT_TIMESTAMP,
        ACCOUNT_MONTH_CONFLICT
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(TEL_SOLD_TO_PARTY as VARCHAR(16777216)) as TEL_SOLD_TO_PARTY,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(OPPORTUNITY_ID as VARCHAR(16777216)) as OPPORTUNITY_ID,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(CUSTOMER_FORECAST_ID as VARCHAR(16777216)) as CUSTOMER_FORECAST_ID,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(MODEL as VARCHAR(16777216)) as MODEL,
        CAST(ORDER_ITEM_OPPORTUNITY as VARCHAR(16777216)) as ORDER_ITEM_OPPORTUNITY,
        CAST(ORDER_ITEM_SALES_DOCUMENT as VARCHAR(16777216)) as ORDER_ITEM_SALES_DOCUMENT,
        CAST(OPPORTUNITY_TITLE_FREE_TEXT as VARCHAR(16777216)) as OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        CAST(PLACEHOLDER as VARCHAR(16777216)) as PLACEHOLDER,
        CAST(ACCOUNT_CONFIDENCE as VARCHAR(16777216)) as ACCOUNT_CONFIDENCE,
        CAST(BU_CONFIDENCE as VARCHAR(16777216)) as BU_CONFIDENCE,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PO_NO as VARCHAR(16777216)) as PO_NO,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(LOANER as VARCHAR(16777216)) as LOANER,
        CAST(ADJUSTED_SHIP_DATE as DATE) as ADJUSTED_SHIP_DATE,
        CAST(SIGN_OFF_DATE as DATE) as SIGN_OFF_DATE,
        CAST(SALES_DATE_ACCOUNT as DATE) as SALES_DATE_ACCOUNT,
        CAST(SALES_DATE_BU as DATE) as SALES_DATE_BU,
        CAST(GS_SALES_MONTH as DATE) as GS_SALES_MONTH,
        CAST(ACTUAL_SIGNOFF_DATE as DATE) as ACTUAL_SIGNOFF_DATE,
        CAST(IS_SIGN_OFF_ACTUAL as VARCHAR(16777216)) as IS_SIGN_OFF_ACTUAL,
        CAST(SALES_AMOUNT_JPY as NUMBER(38,0)) as SALES_AMOUNT_JPY,
        CAST(REV_REC_CRITERIA as VARCHAR(16777216)) as REV_REC_CRITERIA,
        CAST(REV_REC_STATUS as VARCHAR(16777216)) as REV_REC_STATUS,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(ACTUAL_SALES_DATE as DATE) as ACTUAL_SALES_DATE,
        CAST(ACCOUNT_REVENUE_FY as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY,
        CAST(ACCOUNT_REVENUE_FY_HALF as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY_HALF,
        CAST(ACCOUNT_REVENUE_FY_Q as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY_Q,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP,
        CAST(ACCOUNT_MONTH_CONFLICT as NUMBER(38,0)) as ACCOUNT_MONTH_CONFLICT
from transform_data 
)
select * from type_data