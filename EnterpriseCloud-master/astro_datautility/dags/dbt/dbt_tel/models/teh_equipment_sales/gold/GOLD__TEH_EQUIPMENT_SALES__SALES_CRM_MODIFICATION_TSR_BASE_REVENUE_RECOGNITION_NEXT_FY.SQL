{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION_NEXT_FY',
    	transient=false
) }}

WITH ref_cte_CALENDARDATE as (
    select * from {{ source('STATIC_OBJECTS', 'CALENDARDATE') }}
),

ref_cte_SALES_DOCUMENTS as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }}
),

RolledUpSD

AS

(

SELECT

    Opportunity_ID

    ,LISTAGG(DISTINCT Sales_Order_No, ', ')                                                                     AS Sales_Order_No_Distinct

    ,LISTAGG(Sales_Document_Item_No,', ') WITHIN GROUP (ORDER BY Sales_Document_Item_No ASC)                    AS Sales_Document_Item_No_All

    ,LISTAGG(Customer_Forecast_ID, ', ') WITHIN GROUP (ORDER BY SALES_DOCUMENT_ITEM_NO ASC)                     AS Customer_Forecast_ID_All

    ,LISTAGG(DISTINCT Revenue_Recognition_Criteria_Short, ', ')                                                 AS Revenue_Recognition_Criteria_Distinct

    ,LISTAGG(Order_Item_Sales_Document, ', ') WITHIN GROUP (ORDER BY Sales_Document_Item_No ASC)                AS Order_Item_Sales_Document_All

    ,MAX(Adjusted_Ship_Date)                                                                                    AS Ship_Date_Max

    ,MAX(Adjusted_Ship_Date_Plus_120)                                                                           AS Ship_Date_Plus_120_Max

    ,MAX(Scheduled_Acceptance_TSR_Sign_Off_Date)                                                                AS Scheduled_TSR_Sign_Off_Date_Max

    ,MAX(End_User_Sales_Date_BU)                                                                                AS End_User_Sales_Date_BU_Max

    ,LISTAGG(End_User_Sales_Date_BU, ', ') WITHIN GROUP (ORDER BY Sales_Document_Item_No ASC)                   AS End_User_Sales_Date_BU_All

    ,MAX(END_USER_SALES_DATE_ACCOUNT)                                                                           AS End_User_Sales_Date_Account_Max

    ,LISTAGG(END_USER_SALES_DATE_ACCOUNT, ', ') WITHIN GROUP (ORDER BY Sales_Document_Item_No ASC)              AS End_User_Sales_Date_Account_All

    ,MAX(SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE)                                                             AS Scheduled_Sign_Off_DATE_WISDOM_Max

    ,MAX(Actual_Sales_Date)                                                                                     AS Actual_Sales_Date_Max

    ,LISTAGG(DISTINCT Revenue_Recognition_Status, ', ')                                                         AS Revenue_Recognition_Status_Distinct

    ,LISTAGG(Revenue_Recognition_Status, ', ') WITHIN GROUP (ORDER BY Sales_Document_Item_No ASC)               AS Revenue_Recognition_Status_All

    ,LISTAGG(DISTINCT Material_Type, ', ')                                                                      AS Material_Type_Distinct

    ,SUM(Sales_Amount_JPY_Adjusted)                                                                             AS Sales_Amount_JPY_Adjusted_Summed

    ,SUM(End_User_Sales_Amount_JPY)                                                                             AS End_User_Sales_Amount_JPY_Summed

FROM ref_cte_Sales_Documents AS LABSD

WHERE Is_Current_Opp ='Yes'

    AND Is_Active_Opp = 'Yes' 

    AND Is_Active_SD = 'Yes' 

    AND Sales_District = 'North America' 

    AND Is_Genpo_Booking = 'No' 

    AND Sales_Organization = 'TEL'

    AND Sales_Category_Group = 'Modification'

    AND Revenue_Recognition_Criteria_Short = 'TSR'  

    -- AND Sales_Reporting_Flag = 'Yes'

    AND Corporate_Revenue_Forecast_Flag = 'Yes'

    AND Sales_Amount_JPY_Adjusted > 0

GROUP BY Opportunity_ID

HAVING Ship_Date_Max >= '7/1/2020'

    AND ((Scheduled_TSR_Sign_Off_Date_Max >= MAX(BEGINNING_OF_NEXT_FY)

            AND Scheduled_TSR_Sign_Off_Date_Max <= MAX(End_OF_NEXT_FY))

        OR (Scheduled_TSR_Sign_Off_Date_Max >= '4/1/2021'

            AND Scheduled_TSR_Sign_Off_Date_Max <= DATEADD('day', -1,  MAX(BEGINNING_OF_NEXT_FY))

            AND Revenue_Recognition_Status_Distinct <> 'Actual'))

    OR ((End_User_Sales_Date_Account_Max >= MAX(BEGINNING_OF_NEXT_FY)

            AND End_User_Sales_Date_Account_Max <= MAX(End_OF_NEXT_FY))

        OR (End_User_Sales_Date_Account_Max >= '4/1/2021'

            AND End_User_Sales_Date_Account_Max <= DATEADD('day', -1,  MAX(BEGINNING_OF_NEXT_FY))

            AND Revenue_Recognition_Status_Distinct <> 'Actual'))

    OR ((END_USER_SALES_DATE_BU_Max >= MAX(BEGINNING_OF_NEXT_FY)

            AND END_USER_SALES_DATE_BU_Max <= MAX(End_OF_NEXT_FY))

        OR (END_USER_SALES_DATE_BU_Max >= '4/1/2021'

            AND END_USER_SALES_DATE_BU_Max <= DATEADD('day', -1,  MAX(BEGINNING_OF_NEXT_FY))

            AND Revenue_Recognition_Status_Distinct <> 'Actual'))

    OR ((Scheduled_Sign_Off_DATE_WISDOM_Max >= MAX(BEGINNING_OF_NEXT_FY)

            AND Scheduled_Sign_Off_DATE_WISDOM_Max <= MAX(End_OF_NEXT_FY))

        OR (Scheduled_Sign_Off_DATE_WISDOM_Max >= '4/1/2021'

            AND Scheduled_Sign_Off_DATE_WISDOM_Max <= DATEADD('day', -1,  MAX(BEGINNING_OF_NEXT_FY))

            AND Revenue_Recognition_Status_Distinct <> 'Actual'))    

),

source_data as (
SELECT sales_document_guid

    ,RUSD.Opportunity_ID

    ,RUSD.Sales_Document_Item_No_All

    ,Project_No

    ,RUSD.Sales_Order_No_Distinct

    ,RUSD.Customer_Forecast_ID_All

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

    ,RUSD.Material_Type_Distinct

    ,Is_Loaner

    ,Loan_Expiration_Date

    ,VPA

    ,End_User_Booking_Date_BU

    ,Is_Booking_Actual

    ,Confidence_BU_Short

    ,Quote_No

    ,Purchase_Order_No

    -- ,''                                         AS Mod_Labor_PO_No -- Check to see if this can be brought once R2 happens

    ,Orbit_Iraisho_No

    ,Model

    ,Serial_No

    ,Customer_Tool_ID

    ,Quantity

    ,Order_Item_Opportunity

    ,RUSD.Order_Item_Sales_Document_All

    ,Opportunity_Title_Free_Text    

    ,RUSD.Ship_Date_Max

    ,RUSD.Ship_Date_Plus_120_Max

	,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE         AS Scheduled_Sign_Off_Date_BU

    -- ,RUSD.Scheduled_TSR_Sign_Off_Date_Max       AS Scheduled_Sign_Off_Date_BU_Max

    ,RUSD.End_User_Sales_Date_Account_Max           AS Scheduled_Sign_Off_Date_Account_Max

    ,RUSD.End_User_Sales_Date_Account_All           AS Scheduled_Sign_Off_Date_Account_All

    ,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE      AS Scheduled_Sign_Off_Date_WISDOM

    ,ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE            AS Actual_TSR_Sign_Off_Date

	,Is_Sign_Off_Actual

    ,Is_Sign_Off_Waved

	,IS_EST

    ,PO_INCLUDE_LABOR

    ,Mod_Labor_Type

    ,Updated_Work_Order_No_Sales_CRM                AS Work_Order_No_Sales_CRM

    ,Work_Order_Sales_CRM_Issue_Date

    ,Work_Order_No_Service_CRM

    ,Work_Order_Service_CRM_Issue_Date

    ,RUSD.End_User_Sales_Date_BU_Max

    ,RUSD.End_User_Sales_Date_BU_All

    ,RUSD.End_User_Sales_Date_Account_Max

    ,RUSD.End_User_Sales_Date_Account_All

    ,RUSD.Actual_Sales_Date_Max

    ,RUSD.Sales_Amount_JPY_Adjusted_Summed

    ,RUSD.End_User_Sales_Amount_JPY_Summed

    ,RUSD.Revenue_Recognition_Criteria_Distinct

    ,Revenue_Recognition_Flag

    ,RUSD.Revenue_Recognition_Status_Distinct

    ,RUSD.Revenue_Recognition_Status_All

    ,BOOKING_SALES_STATUS

    ,BU_Comments

    ,Account_Comments

    ,Sales_Comments_to_SAP

    ,Assistants_Comments_from_SAP

    ,Account_Sales_Person

    ,BU_SALES_PERSON

    ,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE            AS Sign_Off_FK_Date

    ,CommonDate.fiscal_year_short_text                 AS Sign_Off_FY

    ,CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT   AS Sign_Off_FY_Half

    ,CommonDate.fiscal_year_quarter_short_text         AS Sign_Off_FY_Q

    ,TO_DATE(CommonDate.quarter_beginning_date)        AS Beginning_of_Sign_Off_FY_Q

    ,TO_DATE(CommonDate.quarter_ending_date)           AS End_of_Sign_Off_FY_Q

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

FROM ref_cte_Sales_Documents sd

    RIGHT OUTER JOIN RolledUpSD RUSD ON RUSD.Opportunity_ID = sd.Opportunity_ID   

    LEFT OUTER JOIN ref_cte_CALENDARDATE CommonDate ON CommonDate.Calendar_Date = Sign_Off_FK_Date

WHERE Revenue_Recognition_Flag = 'Yes'

    -- AND ((LABSD.Sales_Amount_JPY <> 0 

    --           AND LABSD.Sales_Amount_JPY IS NOT NULL)

    --    OR LABSD.Loaner = 'Yes'

    --    OR STARTSWITH(LABSD.VPA, 'Free'))

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_DOCUMENT_GUID,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO_ALL,
        PROJECT_NO,
        SALES_ORDER_NO_DISTINCT,
        CUSTOMER_FORECAST_ID_ALL,
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
        MATERIAL_TYPE_DISTINCT,
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
        ORDER_ITEM_SALES_DOCUMENT_ALL,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SHIP_DATE_MAX,
        SHIP_DATE_PLUS_120_MAX,
        SCHEDULED_SIGN_OFF_DATE_BU,
        SCHEDULED_SIGN_OFF_DATE_ACCOUNT_MAX,
        SCHEDULED_SIGN_OFF_DATE_ACCOUNT_ALL,
        SCHEDULED_SIGN_OFF_DATE_WISDOM,
        ACTUAL_TSR_SIGN_OFF_DATE,
        IS_SIGN_OFF_ACTUAL,
        IS_SIGN_OFF_WAVED,
        IS_EST,
        PO_INCLUDE_LABOR,
        MOD_LABOR_TYPE,
        WORK_ORDER_NO_SALES_CRM,
        WORK_ORDER_SALES_CRM_ISSUE_DATE,
        WORK_ORDER_NO_SERVICE_CRM,
        WORK_ORDER_SERVICE_CRM_ISSUE_DATE,
        END_USER_SALES_DATE_BU_MAX,
        END_USER_SALES_DATE_BU_ALL,
        END_USER_SALES_DATE_ACCOUNT_MAX,
        END_USER_SALES_DATE_ACCOUNT_ALL,
        ACTUAL_SALES_DATE_MAX,
        SALES_AMOUNT_JPY_ADJUSTED_SUMMED,
        END_USER_SALES_AMOUNT_JPY_SUMMED,
        REVENUE_RECOGNITION_CRITERIA_DISTINCT,
        REVENUE_RECOGNITION_FLAG,
        REVENUE_RECOGNITION_STATUS_DISTINCT,
        REVENUE_RECOGNITION_STATUS_ALL,
        BOOKING_SALES_STATUS,
        BU_COMMENTS,
        ACCOUNT_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
        ACCOUNT_SALES_PERSON,
        BU_SALES_PERSON,
        SIGN_OFF_FK_DATE,
        SIGN_OFF_FY,
        SIGN_OFF_FY_HALF,
        SIGN_OFF_FY_Q,
        BEGINNING_OF_SIGN_OFF_FY_Q,
        END_OF_SIGN_OFF_FY_Q,
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
        CAST(SALES_DOCUMENT_ITEM_NO_ALL as VARCHAR(16777216)) as SALES_DOCUMENT_ITEM_NO_ALL,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(SALES_ORDER_NO_DISTINCT as VARCHAR(16777216)) as SALES_ORDER_NO_DISTINCT,
        CAST(CUSTOMER_FORECAST_ID_ALL as VARCHAR(16777216)) as CUSTOMER_FORECAST_ID_ALL,
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
        CAST(MATERIAL_TYPE_DISTINCT as VARCHAR(16777216)) as MATERIAL_TYPE_DISTINCT,
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
        CAST(ORDER_ITEM_SALES_DOCUMENT_ALL as VARCHAR(16777216)) as ORDER_ITEM_SALES_DOCUMENT_ALL,
        CAST(OPPORTUNITY_TITLE_FREE_TEXT as VARCHAR(16777216)) as OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(SHIP_DATE_MAX as DATE) as SHIP_DATE_MAX,
        CAST(SHIP_DATE_PLUS_120_MAX as DATE) as SHIP_DATE_PLUS_120_MAX,
        CAST(SCHEDULED_SIGN_OFF_DATE_BU as DATE) as SCHEDULED_SIGN_OFF_DATE_BU,
        CAST(SCHEDULED_SIGN_OFF_DATE_ACCOUNT_MAX as DATE) as SCHEDULED_SIGN_OFF_DATE_ACCOUNT_MAX,
        CAST(SCHEDULED_SIGN_OFF_DATE_ACCOUNT_ALL as VARCHAR(16777216)) as SCHEDULED_SIGN_OFF_DATE_ACCOUNT_ALL,
        CAST(SCHEDULED_SIGN_OFF_DATE_WISDOM as DATE) as SCHEDULED_SIGN_OFF_DATE_WISDOM,
        CAST(ACTUAL_TSR_SIGN_OFF_DATE as DATE) as ACTUAL_TSR_SIGN_OFF_DATE,
        CAST(IS_SIGN_OFF_ACTUAL as VARCHAR(16777216)) as IS_SIGN_OFF_ACTUAL,
        CAST(IS_SIGN_OFF_WAVED as VARCHAR(16777216)) as IS_SIGN_OFF_WAVED,
        CAST(IS_EST as VARCHAR(16777216)) as IS_EST,
        CAST(PO_INCLUDE_LABOR as VARCHAR(16777216)) as PO_INCLUDE_LABOR,
        CAST(MOD_LABOR_TYPE as VARCHAR(16777216)) as MOD_LABOR_TYPE,
        CAST(WORK_ORDER_NO_SALES_CRM as VARCHAR(16777216)) as WORK_ORDER_NO_SALES_CRM,
        CAST(WORK_ORDER_SALES_CRM_ISSUE_DATE as DATE) as WORK_ORDER_SALES_CRM_ISSUE_DATE,
        CAST(WORK_ORDER_NO_SERVICE_CRM as VARCHAR(16777216)) as WORK_ORDER_NO_SERVICE_CRM,
        CAST(WORK_ORDER_SERVICE_CRM_ISSUE_DATE as VARCHAR(16777216)) as WORK_ORDER_SERVICE_CRM_ISSUE_DATE,
        CAST(END_USER_SALES_DATE_BU_MAX as DATE) as END_USER_SALES_DATE_BU_MAX,
        CAST(END_USER_SALES_DATE_BU_ALL as VARCHAR(16777216)) as END_USER_SALES_DATE_BU_ALL,
        CAST(END_USER_SALES_DATE_ACCOUNT_MAX as DATE) as END_USER_SALES_DATE_ACCOUNT_MAX,
        CAST(END_USER_SALES_DATE_ACCOUNT_ALL as VARCHAR(16777216)) as END_USER_SALES_DATE_ACCOUNT_ALL,
        CAST(ACTUAL_SALES_DATE_MAX as DATE) as ACTUAL_SALES_DATE_MAX,
        CAST(SALES_AMOUNT_JPY_ADJUSTED_SUMMED as NUMBER(38,10)) as SALES_AMOUNT_JPY_ADJUSTED_SUMMED,
        CAST(END_USER_SALES_AMOUNT_JPY_SUMMED as NUMBER(38,10)) as END_USER_SALES_AMOUNT_JPY_SUMMED,
        CAST(REVENUE_RECOGNITION_CRITERIA_DISTINCT as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_DISTINCT,
        CAST(REVENUE_RECOGNITION_FLAG as VARCHAR(16777216)) as REVENUE_RECOGNITION_FLAG,
        CAST(REVENUE_RECOGNITION_STATUS_DISTINCT as VARCHAR(16777216)) as REVENUE_RECOGNITION_STATUS_DISTINCT,
        CAST(REVENUE_RECOGNITION_STATUS_ALL as VARCHAR(16777216)) as REVENUE_RECOGNITION_STATUS_ALL,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(BU_COMMENTS as VARCHAR(16777216)) as BU_COMMENTS,
        CAST(ACCOUNT_COMMENTS as VARCHAR(16777216)) as ACCOUNT_COMMENTS,
        CAST(SALES_COMMENTS_TO_SAP as VARCHAR(16777216)) as SALES_COMMENTS_TO_SAP,
        CAST(ASSISTANTS_COMMENTS_FROM_SAP as VARCHAR(16777216)) as ASSISTANTS_COMMENTS_FROM_SAP,
        CAST(ACCOUNT_SALES_PERSON as VARCHAR(16777216)) as ACCOUNT_SALES_PERSON,
        CAST(BU_SALES_PERSON as VARCHAR(16777216)) as BU_SALES_PERSON,
        CAST(SIGN_OFF_FK_DATE as DATE) as SIGN_OFF_FK_DATE,
        CAST(SIGN_OFF_FY as VARCHAR(16777216)) as SIGN_OFF_FY,
        CAST(SIGN_OFF_FY_HALF as VARCHAR(16777216)) as SIGN_OFF_FY_HALF,
        CAST(SIGN_OFF_FY_Q as VARCHAR(16777216)) as SIGN_OFF_FY_Q,
        CAST(BEGINNING_OF_SIGN_OFF_FY_Q as DATE) as BEGINNING_OF_SIGN_OFF_FY_Q,
        CAST(END_OF_SIGN_OFF_FY_Q as DATE) as END_OF_SIGN_OFF_FY_Q,
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