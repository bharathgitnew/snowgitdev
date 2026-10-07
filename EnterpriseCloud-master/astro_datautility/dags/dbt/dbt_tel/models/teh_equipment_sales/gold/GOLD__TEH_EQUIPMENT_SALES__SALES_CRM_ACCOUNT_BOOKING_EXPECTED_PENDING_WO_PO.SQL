{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_ACCOUNT_BOOKING_EXPECTED_PENDING_WO_PO',
    	transient=false
) }}

WITH ref_cte_SALES_CRM_ACCOUNT_BOOKING_FORECAST_CURRENT_HALF_ROLLUP as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_FORECAST_CURRENT_HALF_ROLLUP') }}
),



source_data as (
SELECT

    Sales_Account,

    Sales_Region,

    TEL_Sold_to_Party                   AS Sold_to_Party,

    End_User,

    FAB,

    BU, 

    BU_Group,

    Sub_BU,

    Opportunity_ID,

    Project_No,

    Sales_Order_No,

    Sales_Category_Group,

    Sales_Category,

    Model, 

    Order_Item                          AS Product_Name,

    Opportunity_Title_Free_Text,

    Sales_Reporting_Flag,

    Is_Placeholder,

	Adjusted_Confidence_Account_Short   AS Confidence,

    Adjusted_Serial_No                  AS Serial_No, 

    Customer_Tool_ID,

    Quantity,

    Is_Loaner,

    Loan_Expiration_Date,

    VPA,

    Adjusted_Booking_Date_Account       AS Booking_Date, 

    Actual_Booking_Date,    

    Is_Booking_Actual,

    BOOKING_SALES_STATUS,

    'Pending wo PO'                     AS Booking_Status,

    END_USER_BOOKING_AMOUNT_JPY         AS Booking_Amount,

    BOOKING_AMOUNT_JPY                  AS Booking_Amount_Calculated,

    PURCHASE_ORDER_NO                   AS PO_No,

    Quote_No,

    BU_Sales_Person,

    Account_Sales_Person,

    BU_Comments,

	Account_Comments,

	Sales_Comments_to_SAP,

	Assistants_Comments_from_SAP,

    Account_Booking_FY                  	AS Booking_FY,   

    Account_Booking_FY_Half             	AS Booking_FY_Half,  

    Account_Booking_FY_Q                	AS Booking_FY_Q,

	Account_Booking_Beginning_of_FY   		AS Beginning_of_Booking_FY,

    Account_Booking_End_of_FY    			AS END_of_Booking_FY,

    Account_Booking_Beginning_of_FY_Half	AS Beginning_of_Booking_FY_Half,

    Account_Booking_End_of_FY_Half    		AS END_of_Booking_FY_Half,

    Account_Booking_Beginning_of_FY_Q   	AS Beginning_of_Booking_FY_Q,  

    Account_Booking_End_of_FY_Q         	AS END_of_Booking_FY_Q,  

    Beginning_of_Current_FY,

	End_of_Current_FY,

	Beginning_of_Current_FY_Half,

	End_of_Current_FY_Half,

	Beginning_of_Current_FY_Q,

	End_of_Current_FY_Q,

	Account_Booking_Forecast_FK_Date    AS Booking_Forecast_FK_Date,      

    End_User_Code,

    'Account Forecast'                  AS Data_Source,

    NULL                                AS GS_Data_Snapshot,

    Data_Snapshot                       AS CRM_Data_Snapshot,

    Data_Snapshot_Timestamp             AS CRM_Data_Snapshot_Timestamp

FROM ref_cte_SALES_CRM_ACCOUNT_BOOKING_FORECAST_CURRENT_HALF_ROLLUP

WHERE IS_BOOKING_ACTUAL = 'No'

    AND DATE_TRUNC('MONTH', ADD_MONTHS(CURRENT_DATE(), -1)) <= ADJUSTED_BOOKING_DATE_ACCOUNT

    AND LAST_DAY(CURRENT_DATE(), MONTH) >= ADJUSTED_BOOKING_DATE_ACCOUNT

    AND PURCHASE_ORDER_NO IS NULL

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        OPPORTUNITY_ID,
        PROJECT_NO,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        PRODUCT_NAME,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        CONFIDENCE,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUANTITY,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        BOOKING_DATE,
        ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        BOOKING_STATUS,
        BOOKING_AMOUNT,
        BOOKING_AMOUNT_CALCULATED,
        PO_NO,
        QUOTE_NO,
        BU_SALES_PERSON,
        ACCOUNT_SALES_PERSON,
        BU_COMMENTS,
        ACCOUNT_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
        BOOKING_FY,
        BOOKING_FY_HALF,
        BOOKING_FY_Q,
        BEGINNING_OF_BOOKING_FY,
        END_OF_BOOKING_FY,
        BEGINNING_OF_BOOKING_FY_HALF,
        END_OF_BOOKING_FY_HALF,
        BEGINNING_OF_BOOKING_FY_Q,
        END_OF_BOOKING_FY_Q,
        BEGINNING_OF_CURRENT_FY,
        END_OF_CURRENT_FY,
        BEGINNING_OF_CURRENT_FY_HALF,
        END_OF_CURRENT_FY_HALF,
        BEGINNING_OF_CURRENT_FY_Q,
        END_OF_CURRENT_FY_Q,
        BOOKING_FORECAST_FK_DATE,
        END_USER_CODE,
        DATA_SOURCE,
        GS_DATA_SNAPSHOT,
        CRM_DATA_SNAPSHOT,
        CRM_DATA_SNAPSHOT_TIMESTAMP
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(SOLD_TO_PARTY as VARCHAR(16777216)) as SOLD_TO_PARTY,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(OPPORTUNITY_ID as VARCHAR(16777216)) as OPPORTUNITY_ID,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(MODEL as VARCHAR(16777216)) as MODEL,
        CAST(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        CAST(OPPORTUNITY_TITLE_FREE_TEXT as VARCHAR(16777216)) as OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(CONFIDENCE as VARCHAR(16777216)) as CONFIDENCE,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        CAST(VPA as VARCHAR(16777216)) as VPA,
        CAST(BOOKING_DATE as DATE) as BOOKING_DATE,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        CAST(IS_BOOKING_ACTUAL as VARCHAR(16777216)) as IS_BOOKING_ACTUAL,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(BOOKING_STATUS as VARCHAR(16777216)) as BOOKING_STATUS,
        CAST(BOOKING_AMOUNT as NUMBER(38,10)) as BOOKING_AMOUNT,
        CAST(BOOKING_AMOUNT_CALCULATED as NUMBER(38,10)) as BOOKING_AMOUNT_CALCULATED,
        CAST(PO_NO as VARCHAR(16777216)) as PO_NO,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(BU_SALES_PERSON as VARCHAR(16777216)) as BU_SALES_PERSON,
        CAST(ACCOUNT_SALES_PERSON as VARCHAR(16777216)) as ACCOUNT_SALES_PERSON,
        CAST(BU_COMMENTS as VARCHAR(16777216)) as BU_COMMENTS,
        CAST(ACCOUNT_COMMENTS as VARCHAR(16777216)) as ACCOUNT_COMMENTS,
        CAST(SALES_COMMENTS_TO_SAP as VARCHAR(16777216)) as SALES_COMMENTS_TO_SAP,
        CAST(ASSISTANTS_COMMENTS_FROM_SAP as VARCHAR(16777216)) as ASSISTANTS_COMMENTS_FROM_SAP,
        CAST(BOOKING_FY as VARCHAR(16777216)) as BOOKING_FY,
        CAST(BOOKING_FY_HALF as VARCHAR(16777216)) as BOOKING_FY_HALF,
        CAST(BOOKING_FY_Q as VARCHAR(16777216)) as BOOKING_FY_Q,
        CAST(BEGINNING_OF_BOOKING_FY as DATE) as BEGINNING_OF_BOOKING_FY,
        CAST(END_OF_BOOKING_FY as DATE) as END_OF_BOOKING_FY,
        CAST(BEGINNING_OF_BOOKING_FY_HALF as DATE) as BEGINNING_OF_BOOKING_FY_HALF,
        CAST(END_OF_BOOKING_FY_HALF as DATE) as END_OF_BOOKING_FY_HALF,
        CAST(BEGINNING_OF_BOOKING_FY_Q as DATE) as BEGINNING_OF_BOOKING_FY_Q,
        CAST(END_OF_BOOKING_FY_Q as DATE) as END_OF_BOOKING_FY_Q,
        CAST(BEGINNING_OF_CURRENT_FY as DATE) as BEGINNING_OF_CURRENT_FY,
        CAST(END_OF_CURRENT_FY as DATE) as END_OF_CURRENT_FY,
        CAST(BEGINNING_OF_CURRENT_FY_HALF as DATE) as BEGINNING_OF_CURRENT_FY_HALF,
        CAST(END_OF_CURRENT_FY_HALF as DATE) as END_OF_CURRENT_FY_HALF,
        CAST(BEGINNING_OF_CURRENT_FY_Q as DATE) as BEGINNING_OF_CURRENT_FY_Q,
        CAST(END_OF_CURRENT_FY_Q as DATE) as END_OF_CURRENT_FY_Q,
        CAST(BOOKING_FORECAST_FK_DATE as DATE) as BOOKING_FORECAST_FK_DATE,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(DATA_SOURCE as VARCHAR(16777216)) as DATA_SOURCE,
        CAST(GS_DATA_SNAPSHOT as VARCHAR(16777216)) as GS_DATA_SNAPSHOT,
        CAST(CRM_DATA_SNAPSHOT as DATE) as CRM_DATA_SNAPSHOT,
        CAST(CRM_DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as CRM_DATA_SNAPSHOT_TIMESTAMP
from transform_data 
)
select * from type_data