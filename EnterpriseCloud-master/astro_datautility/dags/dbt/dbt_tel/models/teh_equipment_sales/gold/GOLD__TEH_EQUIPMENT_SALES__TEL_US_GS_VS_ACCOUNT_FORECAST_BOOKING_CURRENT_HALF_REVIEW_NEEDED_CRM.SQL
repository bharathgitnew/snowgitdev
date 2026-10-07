{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_BOOKING_CURRENT_HALF_REVIEW_NEEDED_CRM',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
    Sales_Account,
    Sales_Region,
    BU, 
    BU_Group,
    Sub_BU,
    TEL_Sold_to_Party,
    End_User,
    FAB,
    Opportunity_ID,
    Project_No,
    Sales_Order_No,
    Customer_Forecast_ID,
    Sales_Category_Group,
    Sales_Category,
    Model, 
    Order_Item,
    Opportunity_Title_Free_Text,
    Sales_Reporting_Flag,
    Is_Placeholder                      as Placeholder,
	Adjusted_Confidence_Account_Short   as Account_Confidence,
    CONFIDENCE_BU_SHORT                 as BU_Confidence,
    Adjusted_Serial_No                  as Serial_No,
    Customer_Tool_ID,
    Quote_No,
    Purchase_Order_No                   as PO_No,
    Quantity,
    Is_Loaner                           as Loaner,
    -- Loan_Expiration_Date,
    -- VPA,
    Adjusted_Booking_Date_Account       as Booking_Date_Account,
    PO_RECEIPT_DATE,
    END_USER_BOOKING_DATE_BU            as Booking_Date_BU,
    END_USER_BOOKING_AMOUNT_JPY         as Booking_Amount_JPY,
    Actual_Booking_Date,    
    Is_Booking_Actual,
    BOOKING_SALES_STATUS,
    'Can not be matched, Missing SO No' as Note,
    Account_Booking_FY,   
    Account_Booking_FY_Half,  
    Account_Booking_FY_Q,
    Data_Snapshot_Timestamp,
    case when concat(month(Booking_Date_Account), ', ', year(Booking_Date_Account)) <> concat(month(Booking_Date_BU), ', ', year(Booking_Date_BU)) then 1 else 0 end as Account_Month_Conflict
    -- Account_Booking_Beginning_of_FY_Q,  
    -- Account_Booking_End_of_FY_Q 
	-- Beginning_of_Next_FY,
	-- End_of_Next_FY,
	-- Beginning_of_Next_FY_Half,
	-- End_of_Next_FY_Half,
	-- Beginning_of_Next_FY_Q,
	-- End_of_Next_FY_Q
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_ACCOUNT_BOOKING_FORECAST') }}
where Adjusted_Booking_Date_Account >= Beginning_of_Current_FY_Half
    and Adjusted_Booking_Date_Account <= End_of_Current_FY_Half
    and Adjusted_Confidence_Account_Short not in ('C', 'D', 'L', 'G', '---', '--', '') 
    and Adjusted_Confidence_Account_Short is not null
    and (SALES_ORDER_NO is null
        or SALES_ORDER_NO = '')
    and Booking_Amount_JPY <> 0
    and Booking_Amount_JPY is not null
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
        NOTE,
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
        NOTE,
        ACCOUNT_BOOKING_FY,
        ACCOUNT_BOOKING_FY_HALF,
        ACCOUNT_BOOKING_FY_Q,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP,
        CAST(ACCOUNT_MONTH_CONFLICT as NUMBER(38,0)) as ACCOUNT_MONTH_CONFLICT
from transform_data
)
SELECT * FROM TYPE_DATA