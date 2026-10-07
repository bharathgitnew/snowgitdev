{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEL_SALES_CRM_DATA_AUDIT_REPORT_REVENUE_CURRENT_HALF_NEXT_FY',
    	transient=false
) }}

WITH ref_cte_SALES_CRM_EQUIPMENT_ACCEPTANCE_BASE_REVENUE_RECOGNITION as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_EQUIPMENT_ACCEPTANCE_BASE_REVENUE_RECOGNITION') }}
),

ref_cte_SALES_CRM_EQUIPMENT_ACCEPTANCE_BASE_REVENUE_RECOGNITION_NEXT_FY as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_EQUIPMENT_ACCEPTANCE_BASE_REVENUE_RECOGNITION_NEXT_FY') }}
),

ref_cte_SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION') }}
),

ref_cte_SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION_NEXT_FY as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION_NEXT_FY') }}
),

ref_cte_TEL_SALES_CRM_DATA_AUDIT_REPORT_REVENUE_CURRENT_HALF as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_DATA_AUDIT_REPORT_REVENUE_CURRENT_HALF') }}
),

ref_cte_SALES_DOCUMENTS as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }}
),

NEXT_FY

AS

(

--Equipment-- Using rolled up Equipment Sales Document to minimize the items to be reviewed

SELECT

    SALES_ACCOUNT

    ,END_USER

    ,FAB

    ,Sub_BU

    ,SALES_REPORTING_FLAG

    ,IS_PLACEHOLDER                                  AS BU_PLACEHOLDER

    ,SALES_CATEGORY_DISTINCT                         AS Sales_Category

    ,MATERIAL_TYPE_DISTINCT                          AS MATERIAL_TYPE

    ,CASE WHEN REVENUE_RECOGNITION_CRITERIA_SHORT = 'Acceptance' THEN 'Technical Acceptance' Else NULL END AS Rev_Rec_Criteria

    ,ORDER_ITEM_OPPORTUNITY

    ,Order_Item_Sales_Document_All

    ,OPPORTUNITY_TITLE_FREE_TEXT                     AS OPPORTUNITY_TITLE_FREE_TEXT

    ,MODEL

    ,Opportunity_ID_Distinct                         AS Opportunity_ID

    ,Sales_Document_Item_No_All                      AS Sales_Document_Item_No

    ,Project_No_Distinct                             AS Project_No

    ,Sales_Order_No_Distinct                         AS SO_No

    ,Customer_Forecast_ID_All                        AS Customer_Forecast_ID

    ,Adjusted_Serial_No_Distinct                     AS Adjusted_Serial_No

    ,CUSTOMER_TOOL_ID

    ,BOOKING_CONFIDENCE_ACCOUNT

    ,BOOKING_CONFIDENCE_BU

    ,Ship_Date_Max                                   AS Adjusted_Ship_Date

    ,Ship_Date_Plus_120_Max                          AS Ship_120_Days

    ,ACCOUNT_REVENUE_FY_HALF                         AS ACCOUNT_FY_HALF

    ,CORPORATE_BU_REVENUE_FY_HALF                    AS BU_FY_HALF                

    ,Sch_Sign_Off_Date_BU_Max                        AS Technical_Acceptance_TSR_Customer_Signature_Date

    ,END_USER_SALES_DATE_Account_Max                 AS END_USER_SALES_DATE_ACCOUNT_Max

    ,TO_VARCHAR(END_USER_SALES_DATE_Account_All)     AS END_USER_SALES_DATE_ACCOUNT_All

    ,END_USER_SALES_DATE_BU_Max                      AS END_USER_SALES_DATE_BU_Max

    ,TO_VARCHAR(END_USER_SALES_DATE_BU_All)          AS END_USER_SALES_DATE_BU_All

    ,IS_Sign_Off_Actual                              AS SignOff_Actual

    ,Revenue_Recognition_Status_Distinct             AS Revenue_Recognition_Status

    ,Revenue_Recognition_Status_All 

    ,Sales_Amount_JPY_Adjusted_Summed                AS Sales_Amount_JPY_Adjusted

    ,End_User_Sales_Amount_JPY_Summed                AS End_User_Sales_Amount_JPY

    -- ,RevRec.IS_LOANER                           AS LOANER

    -- ,RevRec.LOAN_EXPIRATION_DATE

    ,VPA

    ,QUOTE_NO

    ,PURCHASE_ORDER_NO                               AS PO_NO

    ,ACCOUNT_SALES_PERSON                            AS SALES_PERSON_ACCOUNT

    ,BU_SALES_PERSON                                 AS SALES_PERSON_BU

    ,ACCOUNT_COMMENTS

    ,BU_COMMENTS

    ,SALES_COMMENTS_TO_SAP                           AS SALES_COMMENTS_CRM_SAP

    ,ASSISTANTS_COMMENTS_FROM_SAP                    AS ASSISTANTS_COMMENTS_SAP_CRM

    ,OPPORTUNITY_TITLE

    ,CRM_URL

    ,DATA_SNAPSHOT

    ,DATA_SNAPSHOT_TIMESTAMP

    ,Sch_Sign_Off_Date_Account_Max                   AS Update_Check

FROM ref_cte_SALES_CRM_EQUIPMENT_ACCEPTANCE_BASE_REVENUE_RECOGNITION_NEXT_FY

WHERE ((END_USER_SALES_DATE_BU_MAX >= BEGINNING_OF_NEXT_FY AND END_USER_SALES_DATE_BU_MAX <= END_OF_NEXT_FY)

        OR (END_USER_SALES_DATE_ACCOUNT_MAX >= BEGINNING_OF_NEXT_FY AND END_USER_SALES_DATE_ACCOUNT_MAX <= END_OF_NEXT_FY)

        OR (Technical_Acceptance_TSR_Customer_Signature_Date >= BEGINNING_OF_NEXT_FY AND Technical_Acceptance_TSR_Customer_Signature_Date <= END_OF_NEXT_FY))

    AND REVENUE_RECOGNITION_STATUS_DISTINCT <> 'Actual' 

    -- AND END_USER_SALES_AMOUNT_JPY >= 0

    AND SALES_ACCOUNT <> 'intel'

    AND IS_LOANER = 'No'

    AND (BOOKING_CONFIDENCE_ACCOUNT NOT IN ('G : Gone', 'L : Lost to competitor')

        OR BOOKING_CONFIDENCE_ACCOUNT IS NULL)

    AND (END_USER_SALES_DATE_BU_MAX < BEGINNING_OF_CURRENT_FY_HALF OR END_USER_SALES_DATE_BU_MAX > END_OF_CURRENT_FY_HALF)

    AND (END_USER_SALES_DATE_ACCOUNT_MAX < BEGINNING_OF_CURRENT_FY_HALF OR END_USER_SALES_DATE_ACCOUNT_MAX > END_OF_CURRENT_FY_HALF)

    AND (Technical_Acceptance_TSR_Customer_Signature_Date < BEGINNING_OF_CURRENT_FY_HALF OR Technical_Acceptance_TSR_Customer_Signature_Date > END_OF_CURRENT_FY_HALF)



UNION ALL

--Equipment out Serial No

SELECT 

    SALES_ACCOUNT

    ,END_USER

    ,FAB

    ,Sub_BU

    ,SALES_REPORTING_FLAG                       AS SALES_REPORTING

    ,IS_PLACEHOLDER                             AS BU_PLACEHOLDER

    ,SALES_CATEGORY

    ,Material_Type

    ,REVENUE_RECOGNITION_CRITERIA               AS Rev_Rec_Criteria

    ,ORDER_ITEM_OPPORTUNITY

	,Order_Item_Sales_Document                  AS Order_Item_Sales_Document_All

    ,OPPORTUNITY_TITLE_FREE_TEXT

    ,MODEL

    ,OPPORTUNITY_ID

	,Sales_Document_Item_No

    ,Project_No

    ,Sales_Order_No                             AS SO_NO

    ,Customer_Forecast_ID

    ,Adjusted_Serial_No

	,CUSTOMER_TOOL_ID

    ,BOOKING_CONFIDENCE_ACCOUNT

    ,BOOKING_CONFIDENCE_BU

    ,Adjusted_Ship_Date

    ,Adjusted_Ship_Date_Plus_120                AS Ship_120_Days

    ,ACCOUNT_REVENUE_FY_HALF                    AS ACCOUNT_FY_HALF

    ,CORPORATE_BU_REVENUE_FY_HALF               AS BU_FY_HALF

    ,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE     AS Technical_Acceptance_TSR_Customer_Signature_Date

    ,End_User_Sales_Date_Account                AS End_User_Sales_Date_Account_Max

    ,TO_VARCHAR(End_User_Sales_Date_Account)    AS End_User_Sales_Date_Account_All

    ,End_User_Sales_Date_BU                     AS End_User_Sales_Date_BU_Max

    ,TO_VARCHAR(End_User_Sales_Date_BU)         AS End_User_Sales_Date_BU_All

    ,IS_SIGN_OFF_ACTUAL                         AS SignOff_Actual

    ,Revenue_Recognition_Status

    ,Revenue_Recognition_Status                 AS Revenue_Recognition_Status_All

    ,Sales_Amount_JPY_Adjusted

    ,End_User_Sales_Amount_JPY

	-- ,IS_LOANER

	-- ,LOAN_EXPIRATION_DATE

	,VPA

    ,QUOTE_NO

	,PURCHASE_ORDER_NO                          AS PO_NO

    ,ACCOUNT_SALES_PERSON                       AS SALES_PERSON_ACCOUNT

    ,BU_SALES_PERSON                            AS SALES_PERSON_BU

	,ACCOUNT_COMMENTS

    ,BU_Comments

    ,SALES_COMMENTS_TO_SAP

    ,ASSISTANTS_COMMENTS_FROM_SAP

    ,OPPORTUNITY_TITLE

    ,CRM_URL

    ,DATA_SNAPSHOT

    ,DATA_SNAPSHOT_TIMESTAMP

    ,End_User_Sales_Date_Account                AS Update_Check

FROM ref_cte_SALES_DOCUMENTS

WHERE ((END_USER_SALES_DATE_BU_MAX >= BEGINNING_OF_NEXT_FY AND END_USER_SALES_DATE_BU_MAX <= END_OF_NEXT_FY)

        OR (END_USER_SALES_DATE_ACCOUNT_MAX >= BEGINNING_OF_NEXT_FY AND END_USER_SALES_DATE_ACCOUNT_MAX <= END_OF_NEXT_FY)

        OR (Technical_Acceptance_TSR_Customer_Signature_Date >= BEGINNING_OF_NEXT_FY AND Technical_Acceptance_TSR_Customer_Signature_Date <= END_OF_NEXT_FY))

    AND REVENUE_RECOGNITION_STATUS <> 'Actual' 

    AND (SALES_AMOUNT_JPY_ADJUSTED <> 0 

              AND SALES_AMOUNT_JPY_ADJUSTED IS NOT NULL)

    AND (ADJUSTED_SERIAL_NO IS NULL

        OR ADJUSTED_SERIAL_NO = '')

    AND REVENUE_RECOGNITION_CRITERIA_SHORT = 'Acceptance'

    AND SALES_ACCOUNT <> 'intel'

    AND IS_LOANER = 'No'

    AND IS_BOOKING_ACTUAL = 'No'

    AND (CONFIDENCE_ACCOUNT_SHORT NOT IN ('G', 'L')

        OR CONFIDENCE_ACCOUNT_SHORT IS NULL)

    AND (END_USER_SALES_DATE_BU_MAX < BEGINNING_OF_CURRENT_FY_HALF OR END_USER_SALES_DATE_BU_MAX > END_OF_CURRENT_FY_HALF)

    AND (END_USER_SALES_DATE_ACCOUNT_MAX < BEGINNING_OF_CURRENT_FY_HALF OR END_USER_SALES_DATE_ACCOUNT_MAX > END_OF_CURRENT_FY_HALF)

    AND (Technical_Acceptance_TSR_Customer_Signature_Date < BEGINNING_OF_CURRENT_FY_HALF OR Technical_Acceptance_TSR_Customer_Signature_Date > END_OF_CURRENT_FY_HALF)

    

UNION ALL

--Modifications-- using Sales Document level information as each Sales Document needs to be updated for forecasting purporses

SELECT

    SALES_ACCOUNT,

    END_USER,

    FAB,

    SUB_BU,

    SALES_REPORTING_FLAG                         AS SALES_REPORTING,

    IS_PLACEHOLDER                               AS BU_PLACEHOLDER,

    SALES_CATEGORY,

    MATERIAL_TYPE_Distinct                       AS MATERIAL_TYPE,

    CASE WHEN Revenue_Recognition_Criteria_Distinct = 'TSR' THEN 'Completion of Service' Else NULL END AS Rev_Rec_Criteria,

    ORDER_ITEM_OPPORTUNITY,

    Order_Item_Sales_Document_All,

    OPPORTUNITY_TITLE_FREE_TEXT,

    MODEL,

    OPPORTUNITY_ID,

    SALES_DOCUMENT_ITEM_NO_All                   AS Sales_Document_Item_No,

    PROJECT_NO,

    Sales_Order_No_Distinct                      AS SO_NO,

    Customer_Forecast_ID_All                     AS Customer_Forecast_ID,

    SERIAL_NO                                    AS Adjusted_Serial_No,

    CUSTOMER_TOOL_ID,

    BOOKING_CONFIDENCE_ACCOUNT,

    BOOKING_CONFIDENCE_BU,

    Ship_Date_Max                                AS Adjusted_Ship_Date,

    SHIP_DATE_PLUS_120_Max                       AS Ship_120_Days,

    ACCOUNT_REVENUE_FY_HALF                      AS ACCOUNT_FY_HALF,

	CORPORATE_BU_REVENUE_FY_HALF                 AS BU_FY_HALF,

    Scheduled_Sign_Off_Date_BU                   AS Technical_Acceptance_TSR_Customer_Signature_Date,

    End_User_Sales_Date_Account_Max              AS End_User_Sales_Date_Account_Max,

    TO_VARCHAR(END_USER_SALES_DATE_ACCOUNT_All)  AS End_User_Sales_Date_Account_All,

    END_USER_SALES_DATE_BU_MAX                   AS End_User_Sales_Date_BU_Max,

    TO_VARCHAR(END_USER_SALES_DATE_BU_All)       AS End_User_Sales_Date_BU_All,

    Is_Sign_Off_Actual                           AS SignOff_Actual,

    REVENUE_RECOGNITION_STATUS_Distinct          AS REVENUE_RECOGNITION_STATUS,

    Revenue_Recognition_Status_All,

    SALES_AMOUNT_JPY_ADJUSTED_SUMMED             AS SALES_AMOUNT_JPY_ADJUSTED,

    END_USER_SALES_AMOUNT_JPY_SUMMED             AS END_USER_SALES_AMOUNT_JPY,

    -- IS_LOANER                                    AS LOANER,

    -- LOAN_EXPIRATION_DATE                         AS LOANER_EXPIRY_DATE,

    VPA,

    QUOTE_NO, 

    PURCHASE_ORDER_NO                            AS PO_NO,

    ACCOUNT_SALES_PERSON                         AS SALES_PERSON_ACCOUNT,

    BU_SALES_PERSON                              AS SALES_PERSON_BU,

    ACCOUNT_COMMENTS,

    BU_COMMENTS,

    Sales_Comments_to_SAP                        AS SALES_COMMENTS_CRM_SAP,

    Assistants_Comments_from_SAP                 AS ASSISTANTS_COMMENTS_SAP_CRM,

    OPPORTUNITY_TITLE,

    CRM_URL,

    DATA_SNAPSHOT,

    DATA_SNAPSHOT_TIMESTAMP,

    End_User_Sales_Date_Account_Max              AS Update_Check

FROM ref_cte_SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION_NEXT_FY

WHERE ((END_USER_SALES_DATE_BU_MAX >= BEGINNING_OF_NEXT_FY AND END_USER_SALES_DATE_BU_MAX <= END_OF_NEXT_FY)

        OR (END_USER_SALES_DATE_ACCOUNT_MAX >= BEGINNING_OF_NEXT_FY AND END_USER_SALES_DATE_ACCOUNT_MAX <= END_OF_NEXT_FY)

        OR (Technical_Acceptance_TSR_Customer_Signature_Date >= BEGINNING_OF_NEXT_FY AND Technical_Acceptance_TSR_Customer_Signature_Date <= END_OF_NEXT_FY))

    AND REVENUE_RECOGNITION_STATUS_DISTINCT <> 'Actual' 

    -- AND END_USER_SALES_AMOUNT_JPY >= 0

    AND (SALES_AMOUNT_JPY_ADJUSTED_SUMMED <> 0 

              AND SALES_AMOUNT_JPY_ADJUSTED_SUMMED IS NOT NULL)

    AND Is_Loaner = 'No'

       -- OR STARTS(VPA, 'Free'))

    AND REVENUE_RECOGNITION_CRITERIA_DISTINCT = 'TSR'

    AND SALES_ACCOUNT <> 'intel'

    AND (BOOKING_CONFIDENCE_ACCOUNT NOT IN ('G : Gone', 'L : Lost to competitor')

        OR BOOKING_CONFIDENCE_ACCOUNT IS NULL)

    AND (END_USER_SALES_DATE_BU_MAX < BEGINNING_OF_CURRENT_FY_HALF OR END_USER_SALES_DATE_BU_MAX > END_OF_CURRENT_FY_HALF)

    AND (END_USER_SALES_DATE_ACCOUNT_MAX < BEGINNING_OF_CURRENT_FY_HALF OR END_USER_SALES_DATE_ACCOUNT_MAX > END_OF_CURRENT_FY_HALF)

    AND (Technical_Acceptance_TSR_Customer_Signature_Date < BEGINNING_OF_CURRENT_FY_HALF OR Technical_Acceptance_TSR_Customer_Signature_Date > END_OF_CURRENT_FY_HALF)

    

UNION ALL

-- Ship base Revenue Recognition both before and after the booking 

SELECT

    SALES_ACCOUNT

    ,END_USER

    ,FAB

    ,Sub_BU

    ,SALES_REPORTING_FLAG                       AS SALES_REPORTING

    ,IS_PLACEHOLDER                             AS BU_PLACEHOLDER

    ,SALES_CATEGORY

    ,Material_Type

    ,REVENUE_RECOGNITION_CRITERIA               AS Rev_Rec_Criteria

    ,ORDER_ITEM_OPPORTUNITY

	,Order_Item_Sales_Document                  AS Order_Item_Sales_Document_All

    ,OPPORTUNITY_TITLE_FREE_TEXT

    ,MODEL

    ,OPPORTUNITY_ID

	,Sales_Document_Item_No

    ,Project_No

    ,Sales_Order_No                             AS SO_NO

    ,Customer_Forecast_ID

    ,Adjusted_Serial_No

	,CUSTOMER_TOOL_ID

    ,BOOKING_CONFIDENCE_ACCOUNT

    ,BOOKING_CONFIDENCE_BU

    ,Adjusted_Ship_Date

    ,Adjusted_Ship_Date_Plus_120                AS Ship_120_Days

    ,ACCOUNT_REVENUE_FY_HALF                    AS ACCOUNT_FY_HALF

    ,CORPORATE_BU_REVENUE_FY_HALF               AS BU_FY_HALF

    ,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE     AS Technical_Acceptance_TSR_Customer_Signature_Date

    ,End_User_Sales_Date_Account                AS End_User_Sales_Date_Account_Max

    ,TO_VARCHAR(End_User_Sales_Date_Account)    AS End_User_Sales_Date_Account_All

    ,End_User_Sales_Date_BU                     AS End_User_Sales_Date_BU_Max

    ,TO_VARCHAR(End_User_Sales_Date_BU)         AS End_User_Sales_Date_BU_All

    ,IS_SIGN_OFF_ACTUAL                         AS SignOff_Actual

    ,Revenue_Recognition_Status

    ,Revenue_Recognition_Status                 AS Revenue_Recognition_Status_All

    ,Sales_Amount_JPY_Adjusted

    ,End_User_Sales_Amount_JPY

	-- ,IS_LOANER

	-- ,LOAN_EXPIRATION_DATE

	,VPA

    ,QUOTE_NO

	,PURCHASE_ORDER_NO                          AS PO_NO

    ,ACCOUNT_SALES_PERSON                       AS SALES_PERSON_ACCOUNT

    ,BU_SALES_PERSON                            AS SALES_PERSON_BU

	,ACCOUNT_COMMENTS

    ,BU_Comments

    ,SALES_COMMENTS_TO_SAP

    ,ASSISTANTS_COMMENTS_FROM_SAP

    ,OPPORTUNITY_TITLE

    ,CRM_URL

    ,DATA_SNAPSHOT

    ,DATA_SNAPSHOT_TIMESTAMP

    ,End_User_Sales_Date_Account                AS Update_Check

FROM ref_cte_SALES_DOCUMENTS

WHERE ((END_USER_SALES_DATE_BU_MAX >= BEGINNING_OF_NEXT_FY AND END_USER_SALES_DATE_BU_MAX <= END_OF_NEXT_FY)

        OR (END_USER_SALES_DATE_ACCOUNT_MAX >= BEGINNING_OF_NEXT_FY AND END_USER_SALES_DATE_ACCOUNT_MAX <= END_OF_NEXT_FY)

        OR (Adjusted_Ship_Date >= BEGINNING_OF_NEXT_FY AND Adjusted_Ship_Date <= END_OF_NEXT_FY))

    AND REVENUE_RECOGNITION_STATUS <> 'Actual' 

    AND (SALES_AMOUNT_JPY_ADJUSTED <> 0 

              AND SALES_AMOUNT_JPY_ADJUSTED IS NOT NULL)

    AND REVENUE_RECOGNITION_CRITERIA_SHORT IN ('Ship', 'Delivery')

    AND SALES_ACCOUNT <> 'intel'

    AND IS_LOANER = 'No'

    -- AND IS_BOOKING_ACTUAL = 'No'

    AND (CONFIDENCE_ACCOUNT_SHORT NOT IN ('G', 'L')

        OR CONFIDENCE_ACCOUNT_SHORT IS NULL)

    AND (END_USER_SALES_DATE_BU_MAX < BEGINNING_OF_CURRENT_FY_HALF OR END_USER_SALES_DATE_BU_MAX > END_OF_CURRENT_FY_HALF)

    AND (END_USER_SALES_DATE_ACCOUNT_MAX < BEGINNING_OF_CURRENT_FY_HALF OR END_USER_SALES_DATE_ACCOUNT_MAX > END_OF_CURRENT_FY_HALF)

    AND (Technical_Acceptance_TSR_Customer_Signature_Date < BEGINNING_OF_CURRENT_FY_HALF OR Technical_Acceptance_TSR_Customer_Signature_Date > END_OF_CURRENT_FY_HALF)

),

CURRENT_HALF --ref_cte_TEL_SALES_CRM_DATA_AUDIT_REPORT_REVENUE_CURRENT_HALF

AS

(

--Equipment-- Using rolled up Equipment Sales Document to minimize the items to be reviewed

SELECT

    SALES_ACCOUNT

    ,END_USER

    ,FAB

    ,Sub_BU

    ,SALES_REPORTING_FLAG

    ,IS_PLACEHOLDER                                  AS BU_PLACEHOLDER

    ,SALES_CATEGORY_DISTINCT                         AS Sales_Category

    ,MATERIAL_TYPE_DISTINCT                          AS MATERIAL_TYPE

    ,CASE WHEN REVENUE_RECOGNITION_CRITERIA_SHORT = 'Acceptance' THEN 'Technical Acceptance' Else NULL END AS Rev_Rec_Criteria

    ,ORDER_ITEM_OPPORTUNITY

    ,Order_Item_Sales_Document_All

    ,OPPORTUNITY_TITLE_FREE_TEXT                     AS OPPORTUNITY_TITLE_FREE_TEXT

    ,MODEL

    ,Opportunity_ID_Distinct                         AS Opportunity_ID

    ,Sales_Document_Item_No_All                      AS Sales_Document_Item_No

    ,Project_No_Distinct                             AS Project_No

    ,Sales_Order_No_Distinct                         AS SO_No

    ,Customer_Forecast_ID_All                        AS Customer_Forecast_ID

    ,Adjusted_Serial_No_Distinct                     AS Adjusted_Serial_No

    ,CUSTOMER_TOOL_ID

    ,BOOKING_CONFIDENCE_ACCOUNT

    ,BOOKING_CONFIDENCE_BU

    ,Ship_Date_Max                                   AS Adjusted_Ship_Date

    ,Ship_Date_Plus_120_Max                          AS Ship_120_Days

    ,ACCOUNT_REVENUE_FY_HALF                         AS ACCOUNT_FY_HALF

    ,CORPORATE_BU_REVENUE_FY_HALF                    AS BU_FY_HALF                

    ,Sch_Sign_Off_Date_BU_Max                        AS Technical_Acceptance_TSR_Customer_Signature_Date

    ,END_USER_SALES_DATE_Account_Max                 AS END_USER_SALES_DATE_ACCOUNT_Max

    ,TO_VARCHAR(END_USER_SALES_DATE_Account_All)     AS END_USER_SALES_DATE_ACCOUNT_All

    ,END_USER_SALES_DATE_BU_Max                      AS END_USER_SALES_DATE_BU_Max

    ,TO_VARCHAR(END_USER_SALES_DATE_BU_All)          AS END_USER_SALES_DATE_BU_All

    ,IS_Sign_Off_Actual                              AS SignOff_Actual

    ,Revenue_Recognition_Status_Distinct             AS Revenue_Recognition_Status

    ,Revenue_Recognition_Status_All 

    ,Sales_Amount_JPY_Adjusted_Summed                AS Sales_Amount_JPY_Adjusted

    ,End_User_Sales_Amount_JPY_Summed                AS End_User_Sales_Amount_JPY

    -- ,RevRec.IS_LOANER                           AS LOANER

    -- ,RevRec.LOAN_EXPIRATION_DATE

    ,VPA

    ,QUOTE_NO

    ,PURCHASE_ORDER_NO                               AS PO_NO

    ,ACCOUNT_SALES_PERSON                            AS SALES_PERSON_ACCOUNT

    ,BU_SALES_PERSON                                 AS SALES_PERSON_BU

    ,ACCOUNT_COMMENTS

    ,BU_COMMENTS

    ,SALES_COMMENTS_TO_SAP                           AS SALES_COMMENTS_CRM_SAP

    ,ASSISTANTS_COMMENTS_FROM_SAP                    AS ASSISTANTS_COMMENTS_SAP_CRM

    ,OPPORTUNITY_TITLE

    ,CRM_URL

    ,DATA_SNAPSHOT

    ,DATA_SNAPSHOT_TIMESTAMP

    ,Sch_Sign_Off_Date_Account_Max                   AS Update_Check

FROM ref_cte_SALES_CRM_EQUIPMENT_ACCEPTANCE_BASE_REVENUE_RECOGNITION

WHERE ((END_USER_SALES_DATE_BU_MAX >= BEGINNING_OF_CURRENT_FY_HALF AND END_USER_SALES_DATE_BU_MAX <= END_OF_CURRENT_FY_HALF)

        OR (END_USER_SALES_DATE_ACCOUNT_MAX >= BEGINNING_OF_CURRENT_FY_HALF AND END_USER_SALES_DATE_ACCOUNT_MAX <= END_OF_CURRENT_FY_HALF)

        OR (Technical_Acceptance_TSR_Customer_Signature_Date >= BEGINNING_OF_CURRENT_FY_HALF AND Technical_Acceptance_TSR_Customer_Signature_Date <= END_OF_CURRENT_FY_HALF))

    AND REVENUE_RECOGNITION_STATUS_DISTINCT <> 'Actual' 

    -- AND END_USER_SALES_AMOUNT_JPY >= 0

    AND SALES_ACCOUNT <> 'intel'

    AND IS_LOANER = 'No'

    AND (BOOKING_CONFIDENCE_ACCOUNT NOT IN ('G : Gone', 'L : Lost to competitor')

        OR BOOKING_CONFIDENCE_ACCOUNT IS NULL)



UNION ALL

--Equipment out Serial No

SELECT 

    SALES_ACCOUNT

    ,END_USER

    ,FAB

    ,Sub_BU

    ,SALES_REPORTING_FLAG                       AS SALES_REPORTING

    ,IS_PLACEHOLDER                             AS BU_PLACEHOLDER

    ,SALES_CATEGORY

    ,Material_Type

    ,REVENUE_RECOGNITION_CRITERIA               AS Rev_Rec_Criteria

    ,ORDER_ITEM_OPPORTUNITY

	,Order_Item_Sales_Document                  AS Order_Item_Sales_Document_All

    ,OPPORTUNITY_TITLE_FREE_TEXT

    ,MODEL

    ,OPPORTUNITY_ID

	,Sales_Document_Item_No

    ,Project_No

    ,Sales_Order_No                             AS SO_NO

    ,Customer_Forecast_ID

    ,Adjusted_Serial_No

	,CUSTOMER_TOOL_ID

    ,BOOKING_CONFIDENCE_ACCOUNT

    ,BOOKING_CONFIDENCE_BU

    ,Adjusted_Ship_Date

    ,Adjusted_Ship_Date_Plus_120                AS Ship_120_Days

    ,ACCOUNT_REVENUE_FY_HALF                    AS ACCOUNT_FY_HALF

    ,CORPORATE_BU_REVENUE_FY_HALF               AS BU_FY_HALF

    ,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE     AS Technical_Acceptance_TSR_Customer_Signature_Date

    ,End_User_Sales_Date_Account                AS End_User_Sales_Date_Account_Max

    ,TO_VARCHAR(End_User_Sales_Date_Account)    AS End_User_Sales_Date_Account_All

    ,End_User_Sales_Date_BU                     AS End_User_Sales_Date_BU_Max

    ,TO_VARCHAR(End_User_Sales_Date_BU)         AS End_User_Sales_Date_BU_All

    ,IS_SIGN_OFF_ACTUAL                         AS SignOff_Actual

    ,Revenue_Recognition_Status

    ,Revenue_Recognition_Status                 AS Revenue_Recognition_Status_All

    ,Sales_Amount_JPY_Adjusted

    ,End_User_Sales_Amount_JPY

	-- ,IS_LOANER

	-- ,LOAN_EXPIRATION_DATE

	,VPA

    ,QUOTE_NO

	,PURCHASE_ORDER_NO                          AS PO_NO

    ,ACCOUNT_SALES_PERSON                       AS SALES_PERSON_ACCOUNT

    ,BU_SALES_PERSON                            AS SALES_PERSON_BU

	,ACCOUNT_COMMENTS

    ,BU_Comments

    ,SALES_COMMENTS_TO_SAP

    ,ASSISTANTS_COMMENTS_FROM_SAP

    ,OPPORTUNITY_TITLE

    ,CRM_URL

    ,DATA_SNAPSHOT

    ,DATA_SNAPSHOT_TIMESTAMP

    ,End_User_Sales_Date_Account                AS Update_Check

FROM ref_cte_SALES_DOCUMENTS

WHERE ((End_User_Sales_Date_BU_Max >= BEGINNING_OF_CURRENT_FY_HALF AND End_User_Sales_Date_BU_Max <= END_OF_CURRENT_FY_HALF)

        OR (End_User_Sales_Date_Account_Max >= BEGINNING_OF_CURRENT_FY_HALF AND End_User_Sales_Date_Account_Max <= END_OF_CURRENT_FY_HALF)

        OR (Technical_Acceptance_TSR_Customer_Signature_Date >= BEGINNING_OF_CURRENT_FY_HALF AND Technical_Acceptance_TSR_Customer_Signature_Date <= END_OF_CURRENT_FY_HALF))

    AND REVENUE_RECOGNITION_STATUS <> 'Actual' 

    AND (SALES_AMOUNT_JPY_ADJUSTED <> 0 

              AND SALES_AMOUNT_JPY_ADJUSTED IS NOT NULL)

    AND (ADJUSTED_SERIAL_NO IS NULL

        OR ADJUSTED_SERIAL_NO = '')

    AND REVENUE_RECOGNITION_CRITERIA_SHORT = 'Acceptance'

    AND SALES_ACCOUNT <> 'intel'

    AND IS_LOANER = 'No'

    AND IS_BOOKING_ACTUAL = 'No'

    AND (CONFIDENCE_ACCOUNT_SHORT NOT IN ('G', 'L')

        OR CONFIDENCE_ACCOUNT_SHORT IS NULL)

        -- AND (CONFIDENCE_BU_SHORT NOT IN  ('D', 'G', 'L', '--') 

        --   OR CONFIDENCE_BU_SHORT IS NOT NULL)) --removed 8/8/22 per Alison



UNION ALL

--Modifications-- using Sales Document level information as each Sales Document needs to be updated for forecasting purporses

SELECT

    SALES_ACCOUNT,

    END_USER,

    FAB,

    SUB_BU,

    SALES_REPORTING_FLAG                         AS SALES_REPORTING,

    IS_PLACEHOLDER                               AS BU_PLACEHOLDER,

    SALES_CATEGORY,

    MATERIAL_TYPE_Distinct                       AS MATERIAL_TYPE,

    CASE WHEN Revenue_Recognition_Criteria_Distinct = 'TSR' THEN 'Completion of Service' Else NULL END AS Rev_Rec_Criteria,

    ORDER_ITEM_OPPORTUNITY,

    Order_Item_Sales_Document_All,

    OPPORTUNITY_TITLE_FREE_TEXT,

    MODEL,

    OPPORTUNITY_ID,

    SALES_DOCUMENT_ITEM_NO_All                   AS Sales_Document_Item_No,

    PROJECT_NO,

    Sales_Order_No_Distinct                      AS SO_NO,

    Customer_Forecast_ID_ALL                     AS Customer_Forecast_ID,

    SERIAL_NO                                    AS Adjusted_Serial_No,

    CUSTOMER_TOOL_ID,

    BOOKING_CONFIDENCE_ACCOUNT,

    BOOKING_CONFIDENCE_BU,

    Ship_Date_Max                                AS Adjusted_Ship_Date,

    SHIP_DATE_PLUS_120_Max                       AS Ship_120_Days,

    ACCOUNT_REVENUE_FY_HALF                      AS ACCOUNT_FY_HALF,

	CORPORATE_BU_REVENUE_FY_HALF                 AS BU_FY_HALF,

    Scheduled_Sign_Off_Date_BU                   AS Technical_Acceptance_TSR_Customer_Signature_Date,

    End_User_Sales_Date_Account_Max              AS End_User_Sales_Date_Account_Max,

    TO_VARCHAR(END_USER_SALES_DATE_ACCOUNT_All)  AS End_User_Sales_Date_Account_All,

    END_USER_SALES_DATE_BU_MAX                   AS End_User_Sales_Date_BU_Max,

    TO_VARCHAR(END_USER_SALES_DATE_BU_All)       AS End_User_Sales_Date_BU_All,

    Is_Sign_Off_Actual                           AS SignOff_Actual,

    REVENUE_RECOGNITION_STATUS_Distinct          AS REVENUE_RECOGNITION_STATUS,

    Revenue_Recognition_Status_All,

    SALES_AMOUNT_JPY_ADJUSTED_SUMMED             AS SALES_AMOUNT_JPY_ADJUSTED,

    END_USER_SALES_AMOUNT_JPY_SUMMED             AS END_USER_SALES_AMOUNT_JPY,

    -- IS_LOANER                                    AS LOANER,

    -- LOAN_EXPIRATION_DATE                         AS LOANER_EXPIRY_DATE,

    VPA,

    QUOTE_NO, 

    PURCHASE_ORDER_NO                            AS PO_NO,

    ACCOUNT_SALES_PERSON                         AS SALES_PERSON_ACCOUNT,

    BU_SALES_PERSON                              AS SALES_PERSON_BU,

    ACCOUNT_COMMENTS,

    BU_COMMENTS,

    Sales_Comments_to_SAP                        AS SALES_COMMENTS_CRM_SAP,

    Assistants_Comments_from_SAP                 AS ASSISTANTS_COMMENTS_SAP_CRM,

    OPPORTUNITY_TITLE,

    CRM_URL,

    DATA_SNAPSHOT,

    DATA_SNAPSHOT_TIMESTAMP,

    End_User_Sales_Date_Account_Max              AS Update_Check

FROM ref_cte_SALES_CRM_MODIFICATION_TSR_BASE_REVENUE_RECOGNITION

WHERE ((END_USER_SALES_DATE_BU_MAX >= BEGINNING_OF_CURRENT_FY_HALF AND END_USER_SALES_DATE_BU_MAX <= END_OF_CURRENT_FY_HALF)

        OR (END_USER_SALES_DATE_ACCOUNT_MAX >= BEGINNING_OF_CURRENT_FY_HALF AND END_USER_SALES_DATE_ACCOUNT_MAX <= END_OF_CURRENT_FY_HALF)

        OR (Technical_Acceptance_TSR_Customer_Signature_Date >= BEGINNING_OF_CURRENT_FY_HALF AND Technical_Acceptance_TSR_Customer_Signature_Date <= END_OF_CURRENT_FY_HALF))

    AND REVENUE_RECOGNITION_STATUS_DISTINCT <> 'Actual' 

    -- AND END_USER_SALES_AMOUNT_JPY >= 0

    AND (SALES_AMOUNT_JPY_ADJUSTED_SUMMED <> 0 

              AND SALES_AMOUNT_JPY_ADJUSTED_SUMMED IS NOT NULL)

    AND Is_Loaner = 'No'

       -- OR STARTS(VPA, 'Free'))

    AND REVENUE_RECOGNITION_CRITERIA_DISTINCT = 'TSR'

    AND SALES_ACCOUNT <> 'intel'

    AND (BOOKING_CONFIDENCE_ACCOUNT NOT IN ('G : Gone', 'L : Lost to competitor')

        OR BOOKING_CONFIDENCE_ACCOUNT IS NULL)



UNION ALL

-- Ship base Revenue Recognition both before and after the booking 

SELECT

    SALES_ACCOUNT

    ,END_USER

    ,FAB

    ,Sub_BU

    ,SALES_REPORTING_FLAG                       AS SALES_REPORTING

    ,IS_PLACEHOLDER                             AS BU_PLACEHOLDER

    ,SALES_CATEGORY

    ,Material_Type

    ,REVENUE_RECOGNITION_CRITERIA               AS Rev_Rec_Criteria

    ,ORDER_ITEM_OPPORTUNITY

	,Order_Item_Sales_Document                  AS Order_Item_Sales_Document_All

    ,OPPORTUNITY_TITLE_FREE_TEXT

    ,MODEL

    ,OPPORTUNITY_ID

	,Sales_Document_Item_No

    ,Project_No

    ,Sales_Order_No                             AS SO_NO

    ,Customer_Forecast_ID

    ,Adjusted_Serial_No

	,CUSTOMER_TOOL_ID

    ,BOOKING_CONFIDENCE_ACCOUNT

    ,BOOKING_CONFIDENCE_BU

    ,Adjusted_Ship_Date

    ,Adjusted_Ship_Date_Plus_120                AS Ship_120_Days

    ,ACCOUNT_REVENUE_FY_HALF                    AS ACCOUNT_FY_HALF

    ,CORPORATE_BU_REVENUE_FY_HALF               AS BU_FY_HALF

    ,SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE     AS Technical_Acceptance_TSR_Customer_Signature_Date

    ,End_User_Sales_Date_Account                AS End_User_Sales_Date_Account_Max

    ,TO_VARCHAR(End_User_Sales_Date_Account)    AS End_User_Sales_Date_Account_All

    ,End_User_Sales_Date_BU                     AS End_User_Sales_Date_BU_Max

    ,TO_VARCHAR(End_User_Sales_Date_BU)         AS End_User_Sales_Date_BU_All

    ,IS_SIGN_OFF_ACTUAL                         AS SignOff_Actual

    ,Revenue_Recognition_Status

    ,Revenue_Recognition_Status                 AS Revenue_Recognition_Status_All

    ,Sales_Amount_JPY_Adjusted

    ,End_User_Sales_Amount_JPY

	-- ,IS_LOANER

	-- ,LOAN_EXPIRATION_DATE

	,VPA

    ,QUOTE_NO

	,PURCHASE_ORDER_NO                          AS PO_NO

    ,ACCOUNT_SALES_PERSON                       AS SALES_PERSON_ACCOUNT

    ,BU_SALES_PERSON                            AS SALES_PERSON_BU

	,ACCOUNT_COMMENTS

    ,BU_Comments

    ,SALES_COMMENTS_TO_SAP

    ,ASSISTANTS_COMMENTS_FROM_SAP

    ,OPPORTUNITY_TITLE

    ,CRM_URL

    ,DATA_SNAPSHOT

    ,DATA_SNAPSHOT_TIMESTAMP

    ,End_User_Sales_Date_Account                AS Update_Check

FROM ref_cte_SALES_DOCUMENTS

WHERE ((END_USER_SALES_DATE_BU_MAX >= BEGINNING_OF_CURRENT_FY_HALF AND END_USER_SALES_DATE_BU_MAX <= END_OF_CURRENT_FY_HALF)

        OR (END_USER_SALES_DATE_ACCOUNT_MAX >= BEGINNING_OF_CURRENT_FY_HALF AND END_USER_SALES_DATE_ACCOUNT_MAX <= END_OF_CURRENT_FY_HALF)

        OR (Adjusted_Ship_Date >= BEGINNING_OF_CURRENT_FY_HALF AND Adjusted_Ship_Date <= END_OF_CURRENT_FY_HALF))

    AND REVENUE_RECOGNITION_STATUS <> 'Actual' 

    AND (SALES_AMOUNT_JPY_ADJUSTED <> 0 

              AND SALES_AMOUNT_JPY_ADJUSTED IS NOT NULL)

    AND REVENUE_RECOGNITION_CRITERIA_SHORT IN ('Ship', 'Delivery')

    AND SALES_ACCOUNT <> 'intel'

    AND IS_LOANER = 'No'

    -- AND IS_BOOKING_ACTUAL = 'No'

    AND (CONFIDENCE_ACCOUNT_SHORT NOT IN ('G', 'L')

        OR CONFIDENCE_ACCOUNT_SHORT IS NULL)

    -- AND (CONFIDENCE_BU_SHORT NOT IN  ('D', 'G', 'L', '--') 

    --     OR CONFIDENCE_BU_SHORT IS NOT NULL)) --removed 8/8/22 per Alison

),

source_data as (
SELECT *

FROM NEXT_FY



UNION ALL

SELECT *

FROM CURRENT_HALF

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        END_USER,
        FAB,
        SUB_BU,
        SALES_REPORTING_FLAG,
        BU_PLACEHOLDER,
        SALES_CATEGORY,
        MATERIAL_TYPE,
        REV_REC_CRITERIA,
        ORDER_ITEM_OPPORTUNITY,
        ORDER_ITEM_SALES_DOCUMENT_ALL,
        OPPORTUNITY_TITLE_FREE_TEXT,
        MODEL,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SO_NO,
        CUSTOMER_FORECAST_ID,
        ADJUSTED_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        BOOKING_CONFIDENCE_ACCOUNT,
        BOOKING_CONFIDENCE_BU,
        ADJUSTED_SHIP_DATE,
        SHIP_120_DAYS,
        ACCOUNT_FY_HALF,
        BU_FY_HALF,
        TECHNICAL_ACCEPTANCE_TSR_CUSTOMER_SIGNATURE_DATE,
        END_USER_SALES_DATE_ACCOUNT_MAX,
        END_USER_SALES_DATE_ACCOUNT_ALL,
        END_USER_SALES_DATE_BU_MAX,
        END_USER_SALES_DATE_BU_ALL,
        SIGNOFF_ACTUAL,
        REVENUE_RECOGNITION_STATUS,
        REVENUE_RECOGNITION_STATUS_ALL,
        SALES_AMOUNT_JPY_ADJUSTED,
        END_USER_SALES_AMOUNT_JPY,
        VPA,
        QUOTE_NO,
        PO_NO,
        SALES_PERSON_ACCOUNT,
        SALES_PERSON_BU,
        ACCOUNT_COMMENTS,
        BU_COMMENTS,
        SALES_COMMENTS_CRM_SAP,
        ASSISTANTS_COMMENTS_SAP_CRM,
        OPPORTUNITY_TITLE,
        CRM_URL,
        DATA_SNAPSHOT,
        DATA_SNAPSHOT_TIMESTAMP,
        UPDATE_CHECK
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        CAST(BU_PLACEHOLDER as VARCHAR(16777216)) as BU_PLACEHOLDER,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(MATERIAL_TYPE as VARCHAR(16777216)) as MATERIAL_TYPE,
        CAST(REV_REC_CRITERIA as VARCHAR(16777216)) as REV_REC_CRITERIA,
        CAST(ORDER_ITEM_OPPORTUNITY as VARCHAR(16777216)) as ORDER_ITEM_OPPORTUNITY,
        CAST(ORDER_ITEM_SALES_DOCUMENT_ALL as VARCHAR(16777216)) as ORDER_ITEM_SALES_DOCUMENT_ALL,
        CAST(OPPORTUNITY_TITLE_FREE_TEXT as VARCHAR(16777216)) as OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(MODEL as VARCHAR(16777216)) as MODEL,
        CAST(OPPORTUNITY_ID as VARCHAR(16777216)) as OPPORTUNITY_ID,
        CAST(SALES_DOCUMENT_ITEM_NO as VARCHAR(16777216)) as SALES_DOCUMENT_ITEM_NO,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(SO_NO as VARCHAR(16777216)) as SO_NO,
        CAST(CUSTOMER_FORECAST_ID as VARCHAR(16777216)) as CUSTOMER_FORECAST_ID,
        CAST(ADJUSTED_SERIAL_NO as VARCHAR(16777216)) as ADJUSTED_SERIAL_NO,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(BOOKING_CONFIDENCE_ACCOUNT as VARCHAR(16777216)) as BOOKING_CONFIDENCE_ACCOUNT,
        CAST(BOOKING_CONFIDENCE_BU as VARCHAR(16777216)) as BOOKING_CONFIDENCE_BU,
        CAST(ADJUSTED_SHIP_DATE as DATE) as ADJUSTED_SHIP_DATE,
        CAST(SHIP_120_DAYS as DATE) as SHIP_120_DAYS,
        CAST(ACCOUNT_FY_HALF as VARCHAR(16777216)) as ACCOUNT_FY_HALF,
        CAST(BU_FY_HALF as VARCHAR(16777216)) as BU_FY_HALF,
        CAST(TECHNICAL_ACCEPTANCE_TSR_CUSTOMER_SIGNATURE_DATE as DATE) as TECHNICAL_ACCEPTANCE_TSR_CUSTOMER_SIGNATURE_DATE,
        CAST(END_USER_SALES_DATE_ACCOUNT_MAX as DATE) as END_USER_SALES_DATE_ACCOUNT_MAX,
        CAST(END_USER_SALES_DATE_ACCOUNT_ALL as VARCHAR(16777216)) as END_USER_SALES_DATE_ACCOUNT_ALL,
        CAST(END_USER_SALES_DATE_BU_MAX as DATE) as END_USER_SALES_DATE_BU_MAX,
        CAST(END_USER_SALES_DATE_BU_ALL as VARCHAR(16777216)) as END_USER_SALES_DATE_BU_ALL,
        CAST(SIGNOFF_ACTUAL as VARCHAR(16777216)) as SIGNOFF_ACTUAL,
        CAST(REVENUE_RECOGNITION_STATUS as VARCHAR(16777216)) as REVENUE_RECOGNITION_STATUS,
        CAST(REVENUE_RECOGNITION_STATUS_ALL as VARCHAR(16777216)) as REVENUE_RECOGNITION_STATUS_ALL,
        CAST(SALES_AMOUNT_JPY_ADJUSTED as NUMBER(38,10)) as SALES_AMOUNT_JPY_ADJUSTED,
        CAST(END_USER_SALES_AMOUNT_JPY as NUMBER(38,10)) as END_USER_SALES_AMOUNT_JPY,
        CAST(VPA as VARCHAR(16777216)) as VPA,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PO_NO as VARCHAR(16777216)) as PO_NO,
        CAST(SALES_PERSON_ACCOUNT as VARCHAR(16777216)) as SALES_PERSON_ACCOUNT,
        CAST(SALES_PERSON_BU as VARCHAR(16777216)) as SALES_PERSON_BU,
        CAST(ACCOUNT_COMMENTS as VARCHAR(16777216)) as ACCOUNT_COMMENTS,
        CAST(BU_COMMENTS as VARCHAR(16777216)) as BU_COMMENTS,
        CAST(SALES_COMMENTS_CRM_SAP as VARCHAR(16777216)) as SALES_COMMENTS_CRM_SAP,
        CAST(ASSISTANTS_COMMENTS_SAP_CRM as VARCHAR(16777216)) as ASSISTANTS_COMMENTS_SAP_CRM,
        CAST(OPPORTUNITY_TITLE as VARCHAR(16777216)) as OPPORTUNITY_TITLE,
        CAST(CRM_URL as VARCHAR(16777216)) as CRM_URL,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_LTZ(9)) as DATA_SNAPSHOT_TIMESTAMP,
        CAST(UPDATE_CHECK as DATE) as UPDATE_CHECK
from transform_data 
)
select * from type_data