{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_MODIFICATION_SHIP_BASE_REVENUE_RECOGNITION',
    	transient=false
) }}

WITH ref_cte_CALENDARDATE as (
    select * from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
),

ref_cte_SALES_DOCUMENTS_WITH_TTCA as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }}
),



source_data as (
SELECT

    sales_document_guid

    ,Opportunity_ID

    ,Sales_Document_Item_No

    ,Project_No

    ,Sales_Order_No

    ,Customer_Forecast_ID

    ,Sales_Account

    ,Sales_Region

    ,Sold_to_Party

    ,TEL_Sold_to_Party

    ,End_User

    ,FAB

    ,BU

    ,BU_GROUP

    ,Sub_BU

    ,SALES_REPORTING_FLAG

    ,IS_PLACEHOLDER

    ,Sales_Category_Group

    ,Sales_Category

    ,Material_Type

    ,Is_Loaner

    ,Loan_Expiration_Date

    ,VPA

    ,End_User_Booking_Date_BU

    ,Is_Booking_Actual

    ,Confidence_BU_Short

    ,Quote_No

    ,Purchase_Order_No

    ,Orbit_Iraisho_No

    ,Model

    ,Serial_No

    ,Customer_Tool_ID

    ,Quantity

    ,Order_Item_Opportunity

    ,Order_Item_Sales_Document

    ,Opportunity_Title_Free_Text    

    ,Adjusted_Ship_Date

    ,Ship_Date

    ,Confirmed_Customs_Clearance_Date

    ,End_User_Sales_Date_BU

    ,End_User_Sales_Date_Account

    ,Actual_Sales_Date

    ,Sales_Amount_JPY_Adjusted

    ,End_User_Sales_Amount_JPY

    ,Revenue_Recognition_Criteria

    ,Revenue_Recognition_Flag

    ,Revenue_Recognition_Status

    ,BOOKING_SALES_STATUS

    ,BU_Comments

    ,Account_Comments

    ,Sales_Comments_to_SAP

    ,Assistants_Comments_from_SAP

    ,Account_Sales_Person

    ,BU_SALES_PERSON

    ,End_User_Sales_Date_BU                            		AS CRM_FK_Date

    ,CommonDate.fiscal_year_short_text                 		AS CRM_FY

    ,CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT   		AS CRM_FY_Half

    ,CommonDate.fiscal_year_quarter_short_text         		AS CRM_FY_Q

	,TO_DATE(CommonDate.fiscal_year_beginning_date)         AS Beginning_of_CRM_FY

    ,TO_DATE(CommonDate.fiscal_year_ending_date)            AS End_of_CRM_FY

    ,TO_DATE(CommonDate.fiscal_half_year_beginning_date)    AS Beginning_of_CRM_FY_Half

    ,TO_DATE(CommonDate.fiscal_half_year_ending_date)       AS End_of_CRM_FY_Half

    ,TO_DATE(CommonDate.fiscal_quarter_beginning_date)      AS Beginning_of_CRM_FY_Q

    ,TO_DATE(CommonDate.fiscal_quarter_ending_date)         AS End_of_CRM_FY_Q

    ,Beginning_of_Current_FY

    ,End_of_Current_FY

	,Beginning_of_Current_FY_Half

	,End_of_Current_FY_Half

	,Beginning_of_Current_FY_Q

	,End_of_Current_FY_Q

	,Beginning_of_Next_FY

	,End_of_Next_FY

	,Beginning_of_Next_FY_Half

	,End_of_Next_FY_Half

	,Beginning_of_Next_FY_Q

	,End_of_Next_FY_Q

	,End_User_Code

    ,_5_Digits_Old_End_User_Code

    ,CURRENT_DATE()                                 AS Data_Snapshot

    ,CURRENT_TimeStamp(2)                           AS Data_Snapshot_Timestamp

    ,BOOKING_CONFIDENCE_ACCOUNT

    ,BOOKING_CONFIDENCE_BU

    ,ACCOUNT_REVENUE_FY

    ,ACCOUNT_REVENUE_FY_HALF

    ,ACCOUNT_REVENUE_FY_Q

    ,CORPORATE_BU_REVENUE_FY

    ,CORPORATE_BU_REVENUE_FY_HALF

    ,CORPORATE_BU_REVENUE_FY_Q

    ,OPPORTUNITY_TITLE

    ,CRM_URL

FROM ref_cte_SALES_DOCUMENTS_WITH_TTCA sd

    LEFT OUTER JOIN ref_cte_CALENDARDATE CommonDate ON CommonDate.Calendar_Date = sd.End_User_Sales_Date_BU

WHERE Sales_Category_Group = 'Modification'

    AND Adjusted_Ship_Date >= '7/1/2020'

    AND ((Adjusted_Ship_Date >= BEGINNING_OF_CURRENT_FY_HALF

            AND Adjusted_Ship_Date <= DATEADD('month', 1, End_OF_CURRENT_FY_HALF))

    OR (End_User_Sales_Date_Account >= BEGINNING_OF_CURRENT_FY_HALF

            AND End_User_Sales_Date_Account <= DATEADD('month', 1, End_OF_CURRENT_FY_HALF))

    OR (END_USER_SALES_DATE_BU >= BEGINNING_OF_CURRENT_FY_HALF

            AND END_USER_SALES_DATE_BU <= DATEADD('month', 1, End_OF_CURRENT_FY_HALF)))

    AND (Sales_Amount_JPY_Adjusted <> 0 

              AND Sales_Amount_JPY_Adjusted IS NOT NULL)

    --    OR LABSD.Loaner = 'Yes'

    --    OR STARTSWITH(LABSD.VPA, 'Free'))

    AND Revenue_Recognition_Criteria_Short IN ('Ship', 'Delivery')  

    -- AND Sales_Reporting_Flag = 'Yes'

    AND Corporate_Revenue_Forecast_Flag = 'Yes'

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_DOCUMENT_GUID,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SALES_ORDER_NO,
        CUSTOMER_FORECAST_ID,
        SALES_ACCOUNT,
        SALES_REGION,
        SOLD_TO_PARTY,
        TEL_SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MATERIAL_TYPE,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        END_USER_BOOKING_DATE_BU,
        IS_BOOKING_ACTUAL,
        CONFIDENCE_BU_SHORT,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        ORBIT_IRAISHO_NO,
        MODEL,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUANTITY,
        ORDER_ITEM_OPPORTUNITY,
        ORDER_ITEM_SALES_DOCUMENT,
        OPPORTUNITY_TITLE_FREE_TEXT,
        ADJUSTED_SHIP_DATE,
        SHIP_DATE,
        CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        END_USER_SALES_DATE_BU,
        END_USER_SALES_DATE_ACCOUNT,
        ACTUAL_SALES_DATE,
        SALES_AMOUNT_JPY_ADJUSTED,
        END_USER_SALES_AMOUNT_JPY,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_FLAG,
        REVENUE_RECOGNITION_STATUS,
        BOOKING_SALES_STATUS,
        BU_COMMENTS,
        ACCOUNT_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
        ACCOUNT_SALES_PERSON,
        BU_SALES_PERSON,
        CRM_FK_DATE,
        CRM_FY,
        CRM_FY_HALF,
        CRM_FY_Q,
        BEGINNING_OF_CRM_FY,
        END_OF_CRM_FY,
        BEGINNING_OF_CRM_FY_HALF,
        END_OF_CRM_FY_HALF,
        BEGINNING_OF_CRM_FY_Q,
        END_OF_CRM_FY_Q,
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
        END_USER_CODE,
        _5_DIGITS_OLD_END_USER_CODE,
        DATA_SNAPSHOT,
        DATA_SNAPSHOT_TIMESTAMP,
        BOOKING_CONFIDENCE_ACCOUNT,
        BOOKING_CONFIDENCE_BU,
        ACCOUNT_REVENUE_FY,
        ACCOUNT_REVENUE_FY_HALF,
        ACCOUNT_REVENUE_FY_Q,
        CORPORATE_BU_REVENUE_FY,
        CORPORATE_BU_REVENUE_FY_HALF,
        CORPORATE_BU_REVENUE_FY_Q,
        OPPORTUNITY_TITLE,
        CRM_URL
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_DOCUMENT_GUID as VARCHAR(16777216)) as SALES_DOCUMENT_GUID,
        CAST(OPPORTUNITY_ID as VARCHAR(16777216)) as OPPORTUNITY_ID,
        CAST(SALES_DOCUMENT_ITEM_NO as VARCHAR(16777216)) as SALES_DOCUMENT_ITEM_NO,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(CUSTOMER_FORECAST_ID as VARCHAR(16777216)) as CUSTOMER_FORECAST_ID,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(SOLD_TO_PARTY as VARCHAR(16777216)) as SOLD_TO_PARTY,
        CAST(TEL_SOLD_TO_PARTY as VARCHAR(16777216)) as TEL_SOLD_TO_PARTY,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(MATERIAL_TYPE as VARCHAR(16777216)) as MATERIAL_TYPE,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        CAST(VPA as VARCHAR(16777216)) as VPA,
        CAST(END_USER_BOOKING_DATE_BU as DATE) as END_USER_BOOKING_DATE_BU,
        CAST(IS_BOOKING_ACTUAL as VARCHAR(16777216)) as IS_BOOKING_ACTUAL,
        CAST(CONFIDENCE_BU_SHORT as VARCHAR(16777216)) as CONFIDENCE_BU_SHORT,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PURCHASE_ORDER_NO as VARCHAR(16777216)) as PURCHASE_ORDER_NO,
        CAST(ORBIT_IRAISHO_NO as VARCHAR(16777216)) as ORBIT_IRAISHO_NO,
        CAST(MODEL as VARCHAR(16777216)) as MODEL,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(QUANTITY as NUMBER(38,10)) as QUANTITY,
        CAST(ORDER_ITEM_OPPORTUNITY as VARCHAR(16777216)) as ORDER_ITEM_OPPORTUNITY,
        CAST(ORDER_ITEM_SALES_DOCUMENT as VARCHAR(16777216)) as ORDER_ITEM_SALES_DOCUMENT,
        CAST(OPPORTUNITY_TITLE_FREE_TEXT as VARCHAR(16777216)) as OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(ADJUSTED_SHIP_DATE as DATE) as ADJUSTED_SHIP_DATE,
        CAST(SHIP_DATE as DATE) as SHIP_DATE,
        CAST(CONFIRMED_CUSTOMS_CLEARANCE_DATE as DATE) as CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        CAST(END_USER_SALES_DATE_BU as DATE) as END_USER_SALES_DATE_BU,
        CAST(END_USER_SALES_DATE_ACCOUNT as DATE) as END_USER_SALES_DATE_ACCOUNT,
        CAST(ACTUAL_SALES_DATE as DATE) as ACTUAL_SALES_DATE,
        CAST(SALES_AMOUNT_JPY_ADJUSTED as FLOAT) as SALES_AMOUNT_JPY_ADJUSTED,
        CAST(END_USER_SALES_AMOUNT_JPY as FLOAT) as END_USER_SALES_AMOUNT_JPY,
        CAST(REVENUE_RECOGNITION_CRITERIA as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA,
        CAST(REVENUE_RECOGNITION_FLAG as VARCHAR(16777216)) as REVENUE_RECOGNITION_FLAG,
        CAST(REVENUE_RECOGNITION_STATUS as VARCHAR(16777216)) as REVENUE_RECOGNITION_STATUS,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(BU_COMMENTS as VARCHAR(16777216)) as BU_COMMENTS,
        CAST(ACCOUNT_COMMENTS as VARCHAR(16777216)) as ACCOUNT_COMMENTS,
        CAST(SALES_COMMENTS_TO_SAP as VARCHAR(16777216)) as SALES_COMMENTS_TO_SAP,
        CAST(ASSISTANTS_COMMENTS_FROM_SAP as VARCHAR(16777216)) as ASSISTANTS_COMMENTS_FROM_SAP,
        CAST(ACCOUNT_SALES_PERSON as VARCHAR(16777216)) as ACCOUNT_SALES_PERSON,
        CAST(BU_SALES_PERSON as VARCHAR(16777216)) as BU_SALES_PERSON,
        CAST(CRM_FK_DATE as DATE) as CRM_FK_DATE,
        CAST(CRM_FY as VARCHAR(16777216)) as CRM_FY,
        CAST(CRM_FY_HALF as VARCHAR(16777216)) as CRM_FY_HALF,
        CAST(CRM_FY_Q as VARCHAR(16777216)) as CRM_FY_Q,
        CAST(BEGINNING_OF_CRM_FY as DATE) as BEGINNING_OF_CRM_FY,
        CAST(END_OF_CRM_FY as DATE) as END_OF_CRM_FY,
        CAST(BEGINNING_OF_CRM_FY_HALF as DATE) as BEGINNING_OF_CRM_FY_HALF,
        CAST(END_OF_CRM_FY_HALF as DATE) as END_OF_CRM_FY_HALF,
        CAST(BEGINNING_OF_CRM_FY_Q as DATE) as BEGINNING_OF_CRM_FY_Q,
        CAST(END_OF_CRM_FY_Q as DATE) as END_OF_CRM_FY_Q,
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
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(_5_DIGITS_OLD_END_USER_CODE as VARCHAR(16777216)) as _5_DIGITS_OLD_END_USER_CODE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_LTZ(2)) as DATA_SNAPSHOT_TIMESTAMP,
        CAST(BOOKING_CONFIDENCE_ACCOUNT as VARCHAR(16777216)) as BOOKING_CONFIDENCE_ACCOUNT,
        CAST(BOOKING_CONFIDENCE_BU as VARCHAR(16777216)) as BOOKING_CONFIDENCE_BU,
        CAST(ACCOUNT_REVENUE_FY as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY,
        CAST(ACCOUNT_REVENUE_FY_HALF as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY_HALF,
        CAST(ACCOUNT_REVENUE_FY_Q as VARCHAR(16777216)) as ACCOUNT_REVENUE_FY_Q,
        CAST(CORPORATE_BU_REVENUE_FY as VARCHAR(16777216)) as CORPORATE_BU_REVENUE_FY,
        CAST(CORPORATE_BU_REVENUE_FY_HALF as VARCHAR(16777216)) as CORPORATE_BU_REVENUE_FY_HALF,
        CAST(CORPORATE_BU_REVENUE_FY_Q as VARCHAR(16777216)) as CORPORATE_BU_REVENUE_FY_Q,
        CAST(OPPORTUNITY_TITLE as VARCHAR(16777216)) as OPPORTUNITY_TITLE,
        CAST(CRM_URL as VARCHAR(16777216)) as CRM_URL
from transform_data 
)
select * from type_data