{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_ACCOUNT_REVENUE_UNFORECASTED_RECORDS_ROLLUP',
    	transient=false
) }}

WITH ref_cte_SALES_CRM_SALES_DOCUMENTS as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }}
),

Rollup

AS

(

SELECT DISTINCT

    Revenue_Recognition_Criteria_Short, 

    Sales_Order_No,

    LISTAGG(DISTINCT Project_No, ', ')                              AS Project_No,

    LISTAGG(DISTINCT Opportunity_ID, ', ')                          AS Opportunity_ID,

	LISTAGG(DISTINCT Customer_Forecast_ID, ', ') 					AS Customer_Forecast_ID,

	CASE WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'New Equipment') THEN 'New Equipment'

        WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'Used Equip w/Core') THEN 'Used Equip w/Core'

        WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'Used Equip w/o Core') THEN 'Used Equip w/o Core'

        WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'Used Equip (as is)') THEN 'Used Equip (as is)'

        WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'Chamber') THEN 'Chamber'

        WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'Pre-kit') THEN 'Pre-kit'

        WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'Start Up') THEN 'Start Up'

		WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'On-site Mod') THEN 'On-site Mod'

		WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'In-house Mod') THEN 'In-house Mod'

        WHEN CONTAINS(LISTAGG(DISTINCT SALES_CATEGORY, ', '), 'Option') THEN 'Option'

        ELSE '' END                                                 AS Primary_Sales_Category,

    LISTAGG(DISTINCT Sales_Document_Item_No, ', ')                  AS Sales_Document_Item_No,

    LISTAGG(DISTINCT Model, ', ')                                   AS Model,

    LISTAGG(DISTINCT Order_Item_Opportunity, ', ')                  AS Order_Item_Opportunity,

    LISTAGG(DISTINCT Opportunity_Title_Free_Text, ', ')             AS Opportunity_Title_Free_Text,

    LISTAGG(DISTINCT ADJUSTED_CONFIDENCE_ACCOUNT_SHORT, ', ')       AS ADJUSTED_CONFIDENCE_ACCOUNT_SHORT,

    LISTAGG(DISTINCT ADJUSTED_SERIAL_NO, ', ')                      AS ADJUSTED_SERIAL_NO,

    LISTAGG(DISTINCT SALES_REPORTING_FLAG, ', ')                    AS SALES_REPORTING_FLAG,

    LISTAGG(DISTINCT IS_PLACEHOLDER, ', ')                          AS IS_PLACEHOLDER,

    LISTAGG(DISTINCT IS_LOANER, ', ')                               AS IS_LOANER,

    MAX(LOAN_EXPIRATION_DATE)                                       AS LOAN_EXPIRATION_DATE,

    LISTAGG(DISTINCT VPA, ', ')                                     AS VPA,

    MAX(Adjusted_Ship_Date)                                         AS Adjusted_Ship_Date,

	MAX(Actual_Ship_Date)                                         	AS Actual_Ship_Date,

    MAX(Adjusted_End_User_Sales_Date_Account)                       AS Adjusted_End_User_Sales_Date_Account,

	MAX(Adjusted_End_User_Sales_Date_Account_Ship)                  AS Adjusted_End_User_Sales_Date_Account_Ship,

    SUM(End_User_Sales_Amount_JPY)                                  AS End_User_Sales_Amount_JPY,

    LISTAGG(DISTINCT Revenue_Recognition_Status, ', ')              AS Revenue_Recognition_Status,

    LISTAGG(DISTINCT Booking_Sales_Status, ', ')                    AS Booking_Sales_Status

FROM ref_cte_SALES_CRM_SALES_DOCUMENTS

WHERE ((ACCOUNT_REVENUE_FORECAST_FK_DATE >= Beginning_of_Previous_FY

		AND (Adjusted_Confidence_Account_Short IN ('C', 'D', 'L', 'G', '--', '---') 

			OR  Adjusted_Confidence_Account_Short IS NULL))

		OR ADJUSTED_ACCOUNT_REVENUE_FORECAST_FK_DATE IS NULL)

	AND Sales_Order_No IS NOT NULL

    AND Sales_Order_No <> ''

    AND Revenue_Recognition_Criteria_Short IS NOT NULL

    AND Revenue_Recognition_Criteria_Short <> '' 

GROUP BY Sales_Order_No, Revenue_Recognition_Criteria_Short

),

Flat1

AS

(

SELECT *,

    row_number() over (partition by SALES_ORDER_NO, Revenue_Recognition_Criteria_Short order by End_User_Sales_Amount_JPY desc)   AS Row_No

FROM ref_cte_SALES_CRM_SALES_DOCUMENTS

WHERE ((ACCOUNT_REVENUE_FORECAST_FK_DATE >= Beginning_of_Previous_FY

		AND (Adjusted_Confidence_Account_Short IN ('C', 'D', 'L', 'G', '--', '---') 

			OR  Adjusted_Confidence_Account_Short IS NULL))

		OR ACCOUNT_REVENUE_FORECAST_FK_DATE IS NULL)

	AND Sales_Order_No IS NOT NULL

    AND Sales_Order_No <> ''

    AND Revenue_Recognition_Criteria_Short IS NOT NULL

    AND Revenue_Recognition_Criteria_Short <> ''

),

Flat

AS

(

SELECT *

FROM Flat1

WHERE Row_No = 1

),

source_data as (
SELECT flat.Sales_Account,

	flat.Sales_Account_Region,

	flat.Sales_Region,

	flat.TEL_Sold_to_Party,

	flat.End_User,

	flat.FAB,

	flat.BU, 

	flat.BU_Group,

	flat.Sub_BU,

    rollup.Sales_Document_Item_No,

	rollup.Opportunity_ID,

	rollup.Project_No,

	rollup.Sales_Order_No,

	rollup.Customer_Forecast_ID,

	flat.Sales_Category_Group,

	rollup.Primary_Sales_Category 			AS Sales_Category,

	rollup.Model, 

	rollup.Order_Item_Opportunity,

	flat.Order_Item_Sales_Document,

	rollup.Opportunity_Title_Free_Text,

	rollup.Sales_Reporting_Flag,

	rollup.Is_Placeholder,

	rollup.Adjusted_Confidence_Account_Short,

	flat.Confidence_BU_Short,

	rollup.Adjusted_Serial_No, 

	flat.Customer_Tool_ID,

	flat.Quote_No,

	flat.Purchase_Order_No,

	flat.Quantity,

	rollup.Is_Loaner,

	rollup.Loan_Expiration_Date,

	rollup.VPA,

	flat.Adjusted_Booking_Date_Account,

	flat.PO_Receipt_Date, 

	flat.Actual_Booking_Date,    

	flat.Is_Booking_Actual,

	flat.Customer_Requested_Delivery_Date,

	rollup.Adjusted_Ship_Date,

	rollup.Actual_Ship_Date, 

	rollup.Adjusted_End_User_Sales_Date_Account,

	rollup.Adjusted_End_User_Sales_Date_Account_Ship,

	flat.End_User_Sales_Date_BU,

    flat.Scheduled_Acceptance_TSR_Sign_Off_Date,

	flat.Actual_Acceptance_TSR_Sign_Off_Date,

	flat.Is_Sign_Off_Actual,

	-- Sales_Amount_JPY_Adjusted, --TEL's Sales Amount after adjustments

	rollup.End_User_Sales_Amount_JPY,  --Sales Amount to the customer

	rollup.Revenue_Recognition_Criteria_Short,

	rollup.Revenue_Recognition_Status,

	rollup.Booking_Sales_Status,

	flat.Actual_Sales_Date,

    flat.ACCOUNT_REVENUE_FORECAST_FK_DATE,

	flat.Account_Revenue_FY,   

	flat.Account_Revenue_FY_Half,  

	flat.Account_Revenue_FY_Q,

	flat.Account_Revenue_Beginning_of_FY,

	flat.Account_Revenue_End_of_FY,

	flat.Account_Revenue_Beginning_of_FY_Half,

	flat.Account_Revenue_End_of_FY_Half, 

	flat.Account_Revenue_Beginning_of_FY_Q,  

	flat.Account_Revenue_End_of_FY_Q,  

	flat.Beginning_of_Current_FY,

	flat.End_of_Current_FY,

	flat.Beginning_of_Current_FY_Half,

	flat.End_of_Current_FY_Half,

	flat.Beginning_of_Current_FY_Q,

	flat.End_of_Current_FY_Q,

	flat.Beginning_of_NEXT_FY,

	flat.End_of_NEXT_FY,

	flat.Beginning_of_NEXT_FY_Half,

	flat.End_of_NEXT_FY_Half,

    flat.BEGINNING_OF_NEXT_FY_Q,

	flat.END_OF_NEXT_FY_Q,

    flat.Beginning_of_Previous_FY,

	flat.End_of_Previous_FY,

	flat.Beginning_of_Previous_FY_Half,

	flat.End_of_Previous_FY_Half,

    flat.BEGINNING_OF_PREVIOUS_FY_Q,

	flat.END_OF_PREVIOUS_FY_Q,

	flat.End_User_Code,

	flat.Data_Snapshot,

	flat.Data_Snapshot_Timestamp

FROM Rollup

    LEFT OUTER JOIN Flat ON flat.Sales_Order_No = rollup.Sales_Order_No AND flat.REVENUE_RECOGNITION_CRITERIA_SHORT = rollup.REVENUE_RECOGNITION_CRITERIA_SHORT

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_ACCOUNT_REGION,
        SALES_REGION,
        TEL_SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        SALES_DOCUMENT_ITEM_NO,
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
        IS_PLACEHOLDER,
        ADJUSTED_CONFIDENCE_ACCOUNT_SHORT,
        CONFIDENCE_BU_SHORT,
        ADJUSTED_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        QUANTITY,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        ADJUSTED_BOOKING_DATE_ACCOUNT,
        PO_RECEIPT_DATE,
        ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        CUSTOMER_REQUESTED_DELIVERY_DATE,
        ADJUSTED_SHIP_DATE,
        ACTUAL_SHIP_DATE,
        ADJUSTED_END_USER_SALES_DATE_ACCOUNT,
        ADJUSTED_END_USER_SALES_DATE_ACCOUNT_SHIP,
        END_USER_SALES_DATE_BU,
        SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE,
        ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE,
        IS_SIGN_OFF_ACTUAL,
        END_USER_SALES_AMOUNT_JPY,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        REVENUE_RECOGNITION_STATUS,
        BOOKING_SALES_STATUS,
        ACTUAL_SALES_DATE,
        ACCOUNT_REVENUE_FORECAST_FK_DATE,
        ACCOUNT_REVENUE_FY,
        ACCOUNT_REVENUE_FY_HALF,
        ACCOUNT_REVENUE_FY_Q,
        ACCOUNT_REVENUE_BEGINNING_OF_FY,
        ACCOUNT_REVENUE_END_OF_FY,
        ACCOUNT_REVENUE_BEGINNING_OF_FY_HALF,
        ACCOUNT_REVENUE_END_OF_FY_HALF,
        ACCOUNT_REVENUE_BEGINNING_OF_FY_Q,
        ACCOUNT_REVENUE_END_OF_FY_Q,
        BEGINNING_OF_CURRENT_FY,
        END_OF_CURRENT_FY,
        BEGINNING_OF_CURRENT_FY_HALF,
        END_OF_CURRENT_FY_HALF,
        BEGINNING_OF_CURRENT_FY_Q,
        END_OF_CURRENT_FY_Q,
        BEGINNING_OF_NEXT_FY,
        END_OF_NEXT_FY,
        BEGINNING_OF_NEXT_FY_HALF,
        END_OF_NEXT_FY_HALF,
        BEGINNING_OF_NEXT_FY_Q,
        END_OF_NEXT_FY_Q,
        BEGINNING_OF_PREVIOUS_FY,
        END_OF_PREVIOUS_FY,
        BEGINNING_OF_PREVIOUS_FY_HALF,
        END_OF_PREVIOUS_FY_HALF,
        BEGINNING_OF_PREVIOUS_FY_Q,
        END_OF_PREVIOUS_FY_Q,
        END_USER_CODE,
        DATA_SNAPSHOT,
        DATA_SNAPSHOT_TIMESTAMP
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_ACCOUNT_REGION as VARCHAR(16777216)) as SALES_ACCOUNT_REGION,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(TEL_SOLD_TO_PARTY as VARCHAR(16777216)) as TEL_SOLD_TO_PARTY,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(SALES_DOCUMENT_ITEM_NO as VARCHAR(16777216)) as SALES_DOCUMENT_ITEM_NO,
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
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(ADJUSTED_CONFIDENCE_ACCOUNT_SHORT as VARCHAR(16777216)) as ADJUSTED_CONFIDENCE_ACCOUNT_SHORT,
        CAST(CONFIDENCE_BU_SHORT as VARCHAR(16777216)) as CONFIDENCE_BU_SHORT,
        CAST(ADJUSTED_SERIAL_NO as VARCHAR(16777216)) as ADJUSTED_SERIAL_NO,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PURCHASE_ORDER_NO as VARCHAR(16777216)) as PURCHASE_ORDER_NO,
        CAST(QUANTITY as NUMBER(38,10)) as QUANTITY,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        CAST(VPA as VARCHAR(16777216)) as VPA,
        CAST(ADJUSTED_BOOKING_DATE_ACCOUNT as DATE) as ADJUSTED_BOOKING_DATE_ACCOUNT,
        CAST(PO_RECEIPT_DATE as DATE) as PO_RECEIPT_DATE,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        CAST(IS_BOOKING_ACTUAL as VARCHAR(16777216)) as IS_BOOKING_ACTUAL,
        CAST(CUSTOMER_REQUESTED_DELIVERY_DATE as DATE) as CUSTOMER_REQUESTED_DELIVERY_DATE,
        CAST(ADJUSTED_SHIP_DATE as DATE) as ADJUSTED_SHIP_DATE,
        CAST(ACTUAL_SHIP_DATE as DATE) as ACTUAL_SHIP_DATE,
        CAST(ADJUSTED_END_USER_SALES_DATE_ACCOUNT as DATE) as ADJUSTED_END_USER_SALES_DATE_ACCOUNT,
        CAST(ADJUSTED_END_USER_SALES_DATE_ACCOUNT_SHIP as DATE) as ADJUSTED_END_USER_SALES_DATE_ACCOUNT_SHIP,
        CAST(END_USER_SALES_DATE_BU as DATE) as END_USER_SALES_DATE_BU,
        CAST(SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE as DATE) as SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE,
        CAST(ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE as DATE) as ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE,
        CAST(IS_SIGN_OFF_ACTUAL as VARCHAR(16777216)) as IS_SIGN_OFF_ACTUAL,
        CAST(END_USER_SALES_AMOUNT_JPY as FLOAT) as END_USER_SALES_AMOUNT_JPY,
        CAST(REVENUE_RECOGNITION_CRITERIA_SHORT as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(REVENUE_RECOGNITION_STATUS as VARCHAR(16777216)) as REVENUE_RECOGNITION_STATUS,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(ACTUAL_SALES_DATE as DATE) as ACTUAL_SALES_DATE,
        CAST(ACCOUNT_REVENUE_FORECAST_FK_DATE as DATE) as ACCOUNT_REVENUE_FORECAST_FK_DATE,
        CAST(ACCOUNT_REVENUE_FY as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY,
        CAST(ACCOUNT_REVENUE_FY_HALF as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY_HALF,
        CAST(ACCOUNT_REVENUE_FY_Q as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY_Q,
        CAST(ACCOUNT_REVENUE_BEGINNING_OF_FY as DATE) as ACCOUNT_REVENUE_BEGINNING_OF_FY,
        CAST(ACCOUNT_REVENUE_END_OF_FY as DATE) as ACCOUNT_REVENUE_END_OF_FY,
        CAST(ACCOUNT_REVENUE_BEGINNING_OF_FY_HALF as DATE) as ACCOUNT_REVENUE_BEGINNING_OF_FY_HALF,
        CAST(ACCOUNT_REVENUE_END_OF_FY_HALF as DATE) as ACCOUNT_REVENUE_END_OF_FY_HALF,
        CAST(ACCOUNT_REVENUE_BEGINNING_OF_FY_Q as DATE) as ACCOUNT_REVENUE_BEGINNING_OF_FY_Q,
        CAST(ACCOUNT_REVENUE_END_OF_FY_Q as DATE) as ACCOUNT_REVENUE_END_OF_FY_Q,
        CAST(BEGINNING_OF_CURRENT_FY as DATE) as BEGINNING_OF_CURRENT_FY,
        CAST(END_OF_CURRENT_FY as DATE) as END_OF_CURRENT_FY,
        CAST(BEGINNING_OF_CURRENT_FY_HALF as DATE) as BEGINNING_OF_CURRENT_FY_HALF,
        CAST(END_OF_CURRENT_FY_HALF as DATE) as END_OF_CURRENT_FY_HALF,
        CAST(BEGINNING_OF_CURRENT_FY_Q as DATE) as BEGINNING_OF_CURRENT_FY_Q,
        CAST(END_OF_CURRENT_FY_Q as DATE) as END_OF_CURRENT_FY_Q,
        CAST(BEGINNING_OF_NEXT_FY as DATE) as BEGINNING_OF_NEXT_FY,
        CAST(END_OF_NEXT_FY as DATE) as END_OF_NEXT_FY,
        CAST(BEGINNING_OF_NEXT_FY_HALF as DATE) as BEGINNING_OF_NEXT_FY_HALF,
        CAST(END_OF_NEXT_FY_HALF as DATE) as END_OF_NEXT_FY_HALF,
        CAST(BEGINNING_OF_NEXT_FY_Q as DATE) as BEGINNING_OF_NEXT_FY_Q,
        CAST(END_OF_NEXT_FY_Q as DATE) as END_OF_NEXT_FY_Q,
        CAST(BEGINNING_OF_PREVIOUS_FY as DATE) as BEGINNING_OF_PREVIOUS_FY,
        CAST(END_OF_PREVIOUS_FY as DATE) as END_OF_PREVIOUS_FY,
        CAST(BEGINNING_OF_PREVIOUS_FY_HALF as DATE) as BEGINNING_OF_PREVIOUS_FY_HALF,
        CAST(END_OF_PREVIOUS_FY_HALF as DATE) as END_OF_PREVIOUS_FY_HALF,
        CAST(BEGINNING_OF_PREVIOUS_FY_Q as DATE) as BEGINNING_OF_PREVIOUS_FY_Q,
        CAST(END_OF_PREVIOUS_FY_Q as DATE) as END_OF_PREVIOUS_FY_Q,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP
from transform_data 
)
select * from type_data