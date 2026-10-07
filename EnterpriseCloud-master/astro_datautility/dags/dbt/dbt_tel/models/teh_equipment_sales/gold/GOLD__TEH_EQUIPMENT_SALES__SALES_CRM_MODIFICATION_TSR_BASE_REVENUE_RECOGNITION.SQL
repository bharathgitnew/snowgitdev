{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION',
    transient=false
) }}

with 
RolledUpSD
as
(
select
    Opportunity_ID
    ,listagg(distinct Sales_Order_No, ', ')                                                                     as Sales_Order_No_Distinct
    ,listagg(Sales_Document_Item_No,', ') within group (order by Sales_Document_Item_No asc)                    as Sales_Document_Item_No_All
    ,listagg(Customer_Forecast_ID, ', ') within group (order by SALES_DOCUMENT_ITEM_NO asc)                     as Customer_Forecast_ID_All
    ,listagg(distinct Revenue_Recognition_Criteria_Short, ', ')                                                 as Revenue_Recognition_Criteria_Distinct
    ,listagg(Order_Item_Sales_Document, ', ') within group (order by Sales_Document_Item_No asc)                as Order_Item_Sales_Document_All
    ,max(Adjusted_Ship_Date)                                                                                    as Ship_Date_Max
    ,max(Adjusted_Ship_Date_Plus_120)                                                                           as Ship_Date_Plus_120_Max
    ,max(Scheduled_Acceptance_TSR_Sign_Off_Date)                                                                as Scheduled_TSR_Sign_Off_Date_Max
    ,max(End_User_Sales_Date_BU)                                                                                as End_User_Sales_Date_BU_Max
    ,listagg(End_User_Sales_Date_BU, ', ') within group (order by Sales_Document_Item_No asc)                   as End_User_Sales_Date_BU_All
    ,max(END_USER_SALES_DATE_ACCOUNT)                                                                           as End_User_Sales_Date_Account_Max
    ,listagg(END_USER_SALES_DATE_ACCOUNT, ', ') within group (order by Sales_Document_Item_No asc)              as End_User_Sales_Date_Account_All
    ,max(SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE)                                                             as Scheduled_Sign_Off_DATE_WISDOM_Max
    ,max(Actual_Sales_Date)                                                                                     as Actual_Sales_Date_Max
    ,listagg(distinct Revenue_Recognition_Status, ', ')                                                         as Revenue_Recognition_Status_Distinct
    ,listagg(Revenue_Recognition_Status, ', ') within group (order by Sales_Document_Item_No asc)               as Revenue_Recognition_Status_All
    ,listagg(distinct Material_Type, ', ')                                                                      as Material_Type_Distinct
    ,sum(Sales_Amount_JPY_Adjusted)                                                                             as Sales_Amount_JPY_Adjusted_Summed
    ,sum(End_User_Sales_Amount_JPY)                                                                             as End_User_Sales_Amount_JPY_Summed
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }} LABSD
where Is_Current_Opp ='Yes'
    and Is_Active_Opp = 'Yes' 
    and Is_Active_SD = 'Yes' 
    and Sales_District = 'North America' 
    and Is_Genpo_Booking = 'No' 
    and Sales_Organization = 'TEL'
    and Sales_Category_Group = 'Modification'
    and Revenue_Recognition_Criteria_Short = 'TSR'  
    -- and Sales_Reporting_Flag = 'Yes'
    and Corporate_Revenue_Forecast_Flag = 'Yes'
    and Sales_Amount_JPY_Adjusted > 0
group by Opportunity_ID
having Ship_Date_Max >= '7/1/2020'
    and ((Scheduled_TSR_Sign_Off_Date_Max >= max(BEGINNING_OF_CURRENT_FY_HALF)
            and Scheduled_TSR_Sign_Off_Date_Max <= dateadd('month', 6, max(End_OF_CURRENT_FY_HALF))
        or (Scheduled_TSR_Sign_Off_Date_Max >= '4/1/2021'
            and Scheduled_TSR_Sign_Off_Date_Max <= dateadd('day', -1,  max(BEGINNING_OF_CURRENT_FY_HALF))
            and Revenue_Recognition_Status_Distinct <> 'Actual'))
    or (End_User_Sales_Date_Account_Max >= max(BEGINNING_OF_CURRENT_FY_HALF)
            and End_User_Sales_Date_Account_Max <= dateadd('month', 6, max(End_OF_CURRENT_FY_HALF))
        or (End_User_Sales_Date_Account_Max >= '4/1/2021'
            and End_User_Sales_Date_Account_Max <= dateadd('day', -1,  max(BEGINNING_OF_CURRENT_FY_HALF))
            and Revenue_Recognition_Status_Distinct <> 'Actual'))
    or (END_USER_SALES_DATE_BU_Max >= max(BEGINNING_OF_CURRENT_FY_HALF)
            and END_USER_SALES_DATE_BU_Max <= dateadd('month', 6, max(End_OF_CURRENT_FY_HALF))
        or (END_USER_SALES_DATE_BU_Max >= '4/1/2021'
            and END_USER_SALES_DATE_BU_Max <= dateadd('day', -1,  max(BEGINNING_OF_CURRENT_FY_HALF))
            and Revenue_Recognition_Status_Distinct <> 'Actual'))
    -- or (Scheduled_Sign_Off_DATE_WISDOM_Max >= dateadd('month', -6, max(BEGINNING_OF_CURRENT_FY_HALF))
    --         and Scheduled_Sign_Off_DATE_WISDOM_Max <= dateadd('month', 6, max(End_OF_CURRENT_FY_HALF))
    --     or (Scheduled_Sign_Off_DATE_WISDOM_Max >= '4/1/2021'
    --         and Scheduled_Sign_Off_DATE_WISDOM_Max <= dateadd('day', -1,  max(BEGINNING_OF_CURRENT_FY_HALF))
    --         and Revenue_Recognition_Status_Distinct <> 'Actual'))    
        )
),
SOURCE_DATA AS (
select
    sales_document_guid
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
    -- ,''                                         as Mod_Labor_PO_No -- Check to see if this can be brought once R2 happens
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
	,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE         as Scheduled_Sign_Off_Date_BU
    -- ,RUSD.Scheduled_TSR_Sign_Off_Date_Max       as Scheduled_Sign_Off_Date_BU_Max
    ,RUSD.End_User_Sales_Date_Account_Max           as Scheduled_Sign_Off_Date_Account_Max
    ,RUSD.End_User_Sales_Date_Account_All           as Scheduled_Sign_Off_Date_Account_All
    ,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE      as Scheduled_Sign_Off_Date_WISDOM
    ,ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE            as Actual_TSR_Sign_Off_Date
	,Is_Sign_Off_Actual
    ,Is_Sign_Off_Waved
	,IS_EST
    ,PO_INCLUDE_LABOR
    ,Mod_Labor_Type
    ,Updated_Work_Order_No_Sales_CRM                as Work_Order_No_Sales_CRM
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
    ,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE                 as Sign_Off_FK_Date
    ,CommonDate.fiscal_year_short_text                      as Sign_Off_FY
    ,CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT        as Sign_Off_FY_Half
    ,CommonDate.fiscal_year_quarter_short_text              as Sign_Off_FY_Q
    ,to_date(CommonDate.fiscal_year_beginning_date)         as Beginning_of_Sign_Off_FY
    ,to_date(CommonDate.fiscal_year_ending_date)            as End_of_Sign_Off_FY
    ,to_date(CommonDate.fiscal_half_year_beginning_date)    as Beginning_of_Sign_Off_FY_Half
    ,to_date(CommonDate.fiscal_half_year_ending_date)       as End_of_Sign_Off_FY_Half
    ,to_date(CommonDate.fiscal_quarter_beginning_date)      as Beginning_of_Sign_Off_FY_Q
    ,to_date(CommonDate.fiscal_quarter_ending_date)         as End_of_Sign_Off_FY_Q
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
    ,current_date()                                 as Data_Snapshot
    ,current_timestamp(2)                           as Data_Snapshot_Timestamp
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
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }} sd
    right outer join RolledUpSD RUSD on RUSD.Opportunity_ID = sd.Opportunity_ID   
    left outer join Pub.Common_System.CALENDARDATE CommonDate on CommonDate.Calendar_Date = sd.SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE
where Revenue_Recognition_Flag = 'Yes'
    -- and ((LABSD.Sales_Amount_JPY <> 0 
    --           and LABSD.Sales_Amount_JPY IS NOT NULL)
    --    or LABSD.Loaner = 'Yes'
    --    or STARTSWITH(LABSD.VPA, 'Free'))
),
TRANSFORM_DATA AS (
SELECT
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
        BEGINNING_OF_SIGN_OFF_FY,
        END_OF_SIGN_OFF_FY,
        BEGINNING_OF_SIGN_OFF_FY_HALF,
        END_OF_SIGN_OFF_FY_HALF,
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
FROM SOURCE_DATA
)

,
TYPE_DATA AS (
SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
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
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        VPA,
        CAST(END_USER_BOOKING_DATE_BU as DATE) as END_USER_BOOKING_DATE_BU,
        IS_BOOKING_ACTUAL,
        CONFIDENCE_BU_SHORT,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        ORBIT_IRAISHO_NO,
        MODEL,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        CAST(QUANTITY as NUMBER(38,10)) as QUANTITY,
        ORDER_ITEM_OPPORTUNITY,
        ORDER_ITEM_SALES_DOCUMENT_ALL,
        OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(SHIP_DATE_MAX as DATE) as SHIP_DATE_MAX,
        CAST(SHIP_DATE_PLUS_120_MAX as DATE) as SHIP_DATE_PLUS_120_MAX,
        CAST(SCHEDULED_SIGN_OFF_DATE_BU as DATE) as SCHEDULED_SIGN_OFF_DATE_BU,
        CAST(SCHEDULED_SIGN_OFF_DATE_ACCOUNT_MAX as DATE) as SCHEDULED_SIGN_OFF_DATE_ACCOUNT_MAX,
        SCHEDULED_SIGN_OFF_DATE_ACCOUNT_ALL,
        CAST(SCHEDULED_SIGN_OFF_DATE_WISDOM as DATE) as SCHEDULED_SIGN_OFF_DATE_WISDOM,
        CAST(ACTUAL_TSR_SIGN_OFF_DATE as DATE) as ACTUAL_TSR_SIGN_OFF_DATE,
        IS_SIGN_OFF_ACTUAL,
        IS_SIGN_OFF_WAVED,
        IS_EST,
        PO_INCLUDE_LABOR,
        MOD_LABOR_TYPE,
        WORK_ORDER_NO_SALES_CRM,
        CAST(WORK_ORDER_SALES_CRM_ISSUE_DATE as DATE) as WORK_ORDER_SALES_CRM_ISSUE_DATE,
        WORK_ORDER_NO_SERVICE_CRM,
        CAST(WORK_ORDER_SERVICE_CRM_ISSUE_DATE as DATE) as WORK_ORDER_SERVICE_CRM_ISSUE_DATE,
        CAST(END_USER_SALES_DATE_BU_MAX as DATE) as END_USER_SALES_DATE_BU_MAX,
        END_USER_SALES_DATE_BU_ALL,
        CAST(END_USER_SALES_DATE_ACCOUNT_MAX as DATE) as END_USER_SALES_DATE_ACCOUNT_MAX,
        END_USER_SALES_DATE_ACCOUNT_ALL,
        CAST(ACTUAL_SALES_DATE_MAX as DATE) as ACTUAL_SALES_DATE_MAX,
        CAST(SALES_AMOUNT_JPY_ADJUSTED_SUMMED as FLOAT) as SALES_AMOUNT_JPY_ADJUSTED_SUMMED,
        CAST(END_USER_SALES_AMOUNT_JPY_SUMMED as FLOAT) as END_USER_SALES_AMOUNT_JPY_SUMMED,
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
        CAST(SIGN_OFF_FK_DATE as DATE) as SIGN_OFF_FK_DATE,
        SIGN_OFF_FY,
        SIGN_OFF_FY_HALF,
        SIGN_OFF_FY_Q,
        CAST(BEGINNING_OF_SIGN_OFF_FY as DATE) as BEGINNING_OF_SIGN_OFF_FY,
        CAST(END_OF_SIGN_OFF_FY as DATE) as END_OF_SIGN_OFF_FY,
        CAST(BEGINNING_OF_SIGN_OFF_FY_HALF as DATE) as BEGINNING_OF_SIGN_OFF_FY_HALF,
        CAST(END_OF_SIGN_OFF_FY_HALF as DATE) as END_OF_SIGN_OFF_FY_HALF,
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
        END_USER_CODE,
        _5_DIGITS_OLD_END_USER_CODE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_LTZ(2)) as DATA_SNAPSHOT_TIMESTAMP,
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
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA