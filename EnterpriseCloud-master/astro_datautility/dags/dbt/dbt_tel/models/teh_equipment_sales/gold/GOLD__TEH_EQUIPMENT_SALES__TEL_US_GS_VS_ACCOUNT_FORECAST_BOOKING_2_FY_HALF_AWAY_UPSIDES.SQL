{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_BOOKING_2_FY_HALF_AWAY_UPSIDES',
    transient=false
) }}

with 
GSwSO
AS
(
SELECT *
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_EXPANDED_2_FY_HALF_AWAY_ROLLUP') }}
),
AccountwSO
AS
(
SELECT *
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_FORECAST_2_FY_HALF_AWAY_ROLLUP') }}
WHERE Adjusted_Confidence_Account_Short NOT IN ('C', 'D', 'L', 'G', '---', '--', '') 
    AND Adjusted_Confidence_Account_Short IS NOT NULL
    AND SALES_ACCOUNT NOT ILIKE 'Intel'

union all
select *
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_FORECAST_2_FY_HALF_AWAY_ROLLUP') }}
where Adjusted_Confidence_Account_Short not in ('D', 'L', 'G', '---', '--', '') 
    and Adjusted_Confidence_Account_Short is not null
    and SALES_ACCOUNT ilike 'Intel'
),
SOURCE_DATA AS (
SELECT
    crm.Sales_Account,
    crm.Sales_Region,
    crm.BU, 
    crm.BU_Group,
    crm.Sub_BU,
    crm.TEL_Sold_to_Party,
    crm.End_User,
    crm.FAB,
    crm.Opportunity_ID,
    crm.Project_No,
    crm.Sales_Order_No,
	crm.Customer_Forecast_ID,
    crm.Sales_Category_Group,
    crm.Sales_Category,
    crm.Model, 
    crm.Order_Item,
    crm.Opportunity_Title_Free_Text,
    crm.Sales_Reporting_Flag,
    crm.Is_Placeholder                      AS Placeholder,
	crm.Adjusted_Confidence_Account_Short   AS Account_Confidence,
    crm.Confidence_BU_Short                 AS BU_Confidence,
    crm.Adjusted_Serial_No                  AS Serial_No, 
    crm.Customer_Tool_ID,
    crm.Quote_No,
    crm.Purchase_Order_No                   AS PO_No,
    crm.Quantity,
    crm.Is_Loaner							AS Loaner,
    -- crm.Loan_Expiration_Date,
    -- crm.VPA,
    crm.Adjusted_Booking_Date_Account       AS Booking_Date_Account,
	crm.PO_RECEIPT_DATE,
    crm.End_User_Booking_Date_BU            AS Booking_Date_BU,
    crm.END_USER_BOOKING_AMOUNT_JPY         AS Booking_Amount_JPY,
    crm.Actual_Booking_Date,    
    crm.Is_Booking_Actual,
    crm.BOOKING_SALES_STATUS,
    crm.Account_Booking_FY,   
    crm.Account_Booking_FY_Half,  
    crm.Account_Booking_FY_Q,
    crm.Data_Snapshot_Timestamp,
    CASE WHEN CONCAT(MONTH(Booking_Date_Account), ', ', YEAR(Booking_Date_Account)) <> CONCAT(MONTH(Booking_Date_BU), ', ',YEAR(Booking_Date_BU)) THEN 1 ELSE 0 END AS Account_Month_Conflict  
	-- crm.Account_Booking_Beginning_of_FY_Q,  
	-- crm.Account_Booking_End_of_FY_Q,  
	-- crm.Beginning_of_Next_FY,
	-- crm.End_of_Next_FY,
	-- crm.Beginning_of_Next_FY_Half,
	-- crm.End_of_Next_FY_Half,
	-- crm.Beginning_of_Next_FY_Q,
	-- crm.End_of_Next_FY_Q
FROM AccountwSO crm
    LEFT OUTER JOIN GSwSO gs ON gs.Sales_Order_No = crm.Sales_Order_No
WHERE gs.Sales_Order_No IS NULL
    AND Booking_Amount_JPY <> 0
    AND Booking_Amount_JPY IS NOT NULL
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
        TEL_SOLD_TO_PARTY,
        END_USER,
        FAB,
        OPPORTUNITY_ID,
        PROJECT_NO,
        SALES_ORDER_NO,
        CUSTOMER_FORECAST_ID,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        ORDER_ITEM,
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
        BOOKING_DATE_ACCOUNT,
        PO_RECEIPT_DATE,
        BOOKING_DATE_BU,
        BOOKING_AMOUNT_JPY,
        ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        ACCOUNT_BOOKING_FY,
        ACCOUNT_BOOKING_FY_HALF,
        ACCOUNT_BOOKING_FY_Q,
        DATA_SNAPSHOT_TIMESTAMP,
        ACCOUNT_MONTH_CONFLICT
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
        TEL_SOLD_TO_PARTY,
        END_USER,
        FAB,
        OPPORTUNITY_ID,
        PROJECT_NO,
        SALES_ORDER_NO,
        CUSTOMER_FORECAST_ID,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        ORDER_ITEM,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        PLACEHOLDER,
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PO_NO,
        CAST(QUANTITY as NUMBER(38,10)) as QUANTITY,
        LOANER,
        CAST(BOOKING_DATE_ACCOUNT as DATE) as BOOKING_DATE_ACCOUNT,
        CAST(PO_RECEIPT_DATE as DATE) as PO_RECEIPT_DATE,
        CAST(BOOKING_DATE_BU as DATE) as BOOKING_DATE_BU,
        CAST(BOOKING_AMOUNT_JPY as FLOAT) as BOOKING_AMOUNT_JPY,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        ACCOUNT_BOOKING_FY,
        ACCOUNT_BOOKING_FY_HALF,
        ACCOUNT_BOOKING_FY_Q,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP,
        CAST(ACCOUNT_MONTH_CONFLICT as NUMBER(38,0)) as ACCOUNT_MONTH_CONFLICT
from transform_data
)
SELECT * FROM TYPE_DATA