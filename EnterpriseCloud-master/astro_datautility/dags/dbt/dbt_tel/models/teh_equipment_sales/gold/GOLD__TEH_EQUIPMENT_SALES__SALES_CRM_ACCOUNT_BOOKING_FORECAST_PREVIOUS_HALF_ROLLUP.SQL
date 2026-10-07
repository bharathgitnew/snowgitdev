{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='SALES_CRM_ACCOUNT_BOOKING_FORECAST_PREVIOUS_HALF_ROLLUP',
    	transient=false
) }}

WITH ref_cte_TEL_SALES_CRM_ACCOUNT_BOOKING_FORECAST as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_ACCOUNT_BOOKING_FORECAST') }}
),

Rollup

as

(

select distinct

    Sales_Order_No,

    listagg(Project_No, ', ')           as Project_No,

    listagg(Opportunity_ID, ', ')       as Opportunity_ID,

    listagg(Customer_Forecast_ID, ', ') as Customer_Forecast_ID,

    listagg(Booking_Currency, ', ')     as Booking_Currency,

    sum(BOOKING_AMOUNT)                 as BOOKING_AMOUNT,

    sum(END_USER_BOOKING_AMOUNT_JPY)    as END_USER_BOOKING_AMOUNT_JPY

from ref_cte_TEL_SALES_CRM_ACCOUNT_BOOKING_FORECAST  

where Account_Booking_Forecast_FK_Date >= Beginning_of_Previous_FY_Half

    and Account_Booking_Forecast_FK_Date <= End_of_Previous_FY_Half

	and Sales_Order_No is not null

    and Sales_Order_No <> ''

group by Sales_Order_No

),

source_data as (
SELECT flat.Sales_Account,

    flat.Sales_Region,

    flat.TEL_Sold_to_Party,

    flat.End_User,

    flat.FAB,

    flat.BU, 

    flat.BU_Group,

    flat.Sub_BU,

    Rollup.Opportunity_ID,

    Rollup.Project_No,

    Rollup.Sales_Order_No,

    Rollup.Customer_Forecast_ID,

    flat.Sales_Category_Group,

    flat.Sales_Category,

    flat.Model, 

    flat.Order_Item,

    flat.Opportunity_Title_Free_Text,

    flat.Sales_Reporting_Flag,

    flat.Is_Placeholder,

	flat.Adjusted_Confidence_Account_Short,

    flat.Confidence_BU_Short,

    flat.Adjusted_Serial_No, 

    flat.First_Serial_No,

    flat.First_PM_Serial_No,

    flat.Customer_Tool_ID,

    flat.Quote_No,

    flat.Purchase_Order_No,

    flat.Quantity,

    flat.Is_Loaner,

    flat.Loan_Expiration_Date,

    flat.VPA,

    flat.Adjusted_Booking_Date_Account,

    flat.PO_Receipt_Date,

    flat.END_USER_BOOKING_DATE_BU,

    flat.Actual_Booking_Date,    

    flat.Is_Booking_Actual,

    flat.BOOKING_SALES_STATUS,

    flat.Ship_Date,

    rollup.Booking_Currency,

    rollup.Booking_Amount,

    case when rollup.Booking_Currency = 'USD' then rollup.Booking_Amount*115 else rollup.Booking_Amount end as Booking_Amount_JPY,

    rollup.END_USER_BOOKING_AMOUNT_JPY,

    flat.BU_Sales_Person,

    flat.Account_Sales_Person,

    flat.BU_Comments,

	flat.Account_Comments,

	flat.Sales_Comments_to_SAP,

	flat.Assistants_Comments_from_SAP,

    flat.BU_Account_Difference_Reason,

    flat.Account_Booking_FY,   

    flat.Account_Booking_FY_Half,  

    flat.Account_Booking_FY_Q,

	flat.Account_Booking_Beginning_of_FY,

    flat.Account_Booking_End_of_FY,

    flat.Account_Booking_Beginning_of_FY_Half,

    flat.Account_Booking_End_of_FY_Half,  

    flat.Account_Booking_Beginning_of_FY_Q,  

    flat.Account_Booking_End_of_FY_Q,  

    flat.Beginning_of_Current_FY,

	flat.End_of_Current_FY,

	flat.Beginning_of_Current_FY_Half,

	flat.End_of_Current_FY_Half,

	flat.Beginning_of_Current_FY_Q,

	flat.End_of_Current_FY_Q,

    flat.Beginning_of_Previous_FY,

	flat.End_of_Previous_FY,

	flat.Beginning_of_Previous_FY_Half,

	flat.End_of_Previous_FY_Half,

	flat.Beginning_of_Previous_FY_Q,

	flat.End_of_Previous_FY_Q,

	flat.Account_Booking_Forecast_FK_Date,     

    flat.Account_Booking_Forecast_Flag,  

    flat.End_User_Code,

    flat.Data_Snapshot,

    flat.Data_Snapshot_Timestamp

from ref_cte_TEL_SALES_CRM_ACCOUNT_BOOKING_FORECAST flat

    left outer join Rollup on Rollup.Sales_Order_No = flat.Sales_Order_No

where Account_Booking_Forecast_FK_Date >= Beginning_of_Previous_FY_Half

    and Account_Booking_Forecast_FK_Date <= End_of_Previous_FY_Half

	and flat.Sales_Order_No is not null

    and flat.Sales_Order_No <> ''

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
        ORDER_ITEM,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        ADJUSTED_CONFIDENCE_ACCOUNT_SHORT,
        CONFIDENCE_BU_SHORT,
        ADJUSTED_SERIAL_NO,
        FIRST_SERIAL_NO,
        FIRST_PM_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        QUANTITY,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        ADJUSTED_BOOKING_DATE_ACCOUNT,
        PO_RECEIPT_DATE,
        END_USER_BOOKING_DATE_BU,
        ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        SHIP_DATE,
        BOOKING_CURRENCY,
        BOOKING_AMOUNT,
        BOOKING_AMOUNT_JPY,
        END_USER_BOOKING_AMOUNT_JPY,
        BU_SALES_PERSON,
        ACCOUNT_SALES_PERSON,
        BU_COMMENTS,
        ACCOUNT_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
        BU_ACCOUNT_DIFFERENCE_REASON,
        ACCOUNT_BOOKING_FY,
        ACCOUNT_BOOKING_FY_HALF,
        ACCOUNT_BOOKING_FY_Q,
        ACCOUNT_BOOKING_BEGINNING_OF_FY,
        ACCOUNT_BOOKING_END_OF_FY,
        ACCOUNT_BOOKING_BEGINNING_OF_FY_HALF,
        ACCOUNT_BOOKING_END_OF_FY_HALF,
        ACCOUNT_BOOKING_BEGINNING_OF_FY_Q,
        ACCOUNT_BOOKING_END_OF_FY_Q,
        BEGINNING_OF_CURRENT_FY,
        END_OF_CURRENT_FY,
        BEGINNING_OF_CURRENT_FY_HALF,
        END_OF_CURRENT_FY_HALF,
        BEGINNING_OF_CURRENT_FY_Q,
        END_OF_CURRENT_FY_Q,
        BEGINNING_OF_PREVIOUS_FY,
        END_OF_PREVIOUS_FY,
        BEGINNING_OF_PREVIOUS_FY_HALF,
        END_OF_PREVIOUS_FY_HALF,
        BEGINNING_OF_PREVIOUS_FY_Q,
        END_OF_PREVIOUS_FY_Q,
        ACCOUNT_BOOKING_FORECAST_FK_DATE,
        ACCOUNT_BOOKING_FORECAST_FLAG,
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
        CAST(ORDER_ITEM as VARCHAR(16777216)) as ORDER_ITEM,
        CAST(OPPORTUNITY_TITLE_FREE_TEXT as VARCHAR(16777216)) as OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(ADJUSTED_CONFIDENCE_ACCOUNT_SHORT as VARCHAR(16777216)) as ADJUSTED_CONFIDENCE_ACCOUNT_SHORT,
        CAST(CONFIDENCE_BU_SHORT as VARCHAR(16777216)) as CONFIDENCE_BU_SHORT,
        CAST(ADJUSTED_SERIAL_NO as VARCHAR(16777216)) as ADJUSTED_SERIAL_NO,
        CAST(FIRST_SERIAL_NO as VARCHAR(16777216)) as FIRST_SERIAL_NO,
        CAST(FIRST_PM_SERIAL_NO as VARCHAR(16777216)) as FIRST_PM_SERIAL_NO,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PURCHASE_ORDER_NO as VARCHAR(16777216)) as PURCHASE_ORDER_NO,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        CAST(VPA as VARCHAR(16777216)) as VPA,
        CAST(ADJUSTED_BOOKING_DATE_ACCOUNT as DATE) as ADJUSTED_BOOKING_DATE_ACCOUNT,
        CAST(PO_RECEIPT_DATE as DATE) as PO_RECEIPT_DATE,
        CAST(END_USER_BOOKING_DATE_BU as DATE) as END_USER_BOOKING_DATE_BU,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        CAST(IS_BOOKING_ACTUAL as VARCHAR(16777216)) as IS_BOOKING_ACTUAL,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(SHIP_DATE as DATE) as SHIP_DATE,
        CAST(BOOKING_CURRENCY as VARCHAR(16777216)) as BOOKING_CURRENCY,
        CAST(BOOKING_AMOUNT as NUMBER(38,10)) as BOOKING_AMOUNT,
        CAST(BOOKING_AMOUNT_JPY as NUMBER(38,10)) as BOOKING_AMOUNT_JPY,
        CAST(END_USER_BOOKING_AMOUNT_JPY as NUMBER(38,10)) as END_USER_BOOKING_AMOUNT_JPY,
        CAST(BU_SALES_PERSON as VARCHAR(16777216)) as BU_SALES_PERSON,
        CAST(ACCOUNT_SALES_PERSON as VARCHAR(16777216)) as ACCOUNT_SALES_PERSON,
        CAST(BU_COMMENTS as VARCHAR(16777216)) as BU_COMMENTS,
        CAST(ACCOUNT_COMMENTS as VARCHAR(16777216)) as ACCOUNT_COMMENTS,
        CAST(SALES_COMMENTS_TO_SAP as VARCHAR(16777216)) as SALES_COMMENTS_TO_SAP,
        CAST(ASSISTANTS_COMMENTS_FROM_SAP as VARCHAR(16777216)) as ASSISTANTS_COMMENTS_FROM_SAP,
        CAST(BU_ACCOUNT_DIFFERENCE_REASON as VARCHAR(16777216)) as BU_ACCOUNT_DIFFERENCE_REASON,
        CAST(ACCOUNT_BOOKING_FY as VARCHAR(16777216)) as ACCOUNT_BOOKING_FY,
        CAST(ACCOUNT_BOOKING_FY_HALF as VARCHAR(16777216)) as ACCOUNT_BOOKING_FY_HALF,
        CAST(ACCOUNT_BOOKING_FY_Q as VARCHAR(16777216)) as ACCOUNT_BOOKING_FY_Q,
        CAST(ACCOUNT_BOOKING_BEGINNING_OF_FY as DATE) as ACCOUNT_BOOKING_BEGINNING_OF_FY,
        CAST(ACCOUNT_BOOKING_END_OF_FY as DATE) as ACCOUNT_BOOKING_END_OF_FY,
        CAST(ACCOUNT_BOOKING_BEGINNING_OF_FY_HALF as DATE) as ACCOUNT_BOOKING_BEGINNING_OF_FY_HALF,
        CAST(ACCOUNT_BOOKING_END_OF_FY_HALF as DATE) as ACCOUNT_BOOKING_END_OF_FY_HALF,
        CAST(ACCOUNT_BOOKING_BEGINNING_OF_FY_Q as DATE) as ACCOUNT_BOOKING_BEGINNING_OF_FY_Q,
        CAST(ACCOUNT_BOOKING_END_OF_FY_Q as DATE) as ACCOUNT_BOOKING_END_OF_FY_Q,
        CAST(BEGINNING_OF_CURRENT_FY as DATE) as BEGINNING_OF_CURRENT_FY,
        CAST(END_OF_CURRENT_FY as DATE) as END_OF_CURRENT_FY,
        CAST(BEGINNING_OF_CURRENT_FY_HALF as DATE) as BEGINNING_OF_CURRENT_FY_HALF,
        CAST(END_OF_CURRENT_FY_HALF as DATE) as END_OF_CURRENT_FY_HALF,
        CAST(BEGINNING_OF_CURRENT_FY_Q as DATE) as BEGINNING_OF_CURRENT_FY_Q,
        CAST(END_OF_CURRENT_FY_Q as DATE) as END_OF_CURRENT_FY_Q,
        CAST(BEGINNING_OF_PREVIOUS_FY as DATE) as BEGINNING_OF_PREVIOUS_FY,
        CAST(END_OF_PREVIOUS_FY as DATE) as END_OF_PREVIOUS_FY,
        CAST(BEGINNING_OF_PREVIOUS_FY_HALF as DATE) as BEGINNING_OF_PREVIOUS_FY_HALF,
        CAST(END_OF_PREVIOUS_FY_HALF as DATE) as END_OF_PREVIOUS_FY_HALF,
        CAST(BEGINNING_OF_PREVIOUS_FY_Q as DATE) as BEGINNING_OF_PREVIOUS_FY_Q,
        CAST(END_OF_PREVIOUS_FY_Q as DATE) as END_OF_PREVIOUS_FY_Q,
        CAST(ACCOUNT_BOOKING_FORECAST_FK_DATE as DATE) as ACCOUNT_BOOKING_FORECAST_FK_DATE,
        CAST(ACCOUNT_BOOKING_FORECAST_FLAG as VARCHAR(16777216)) as ACCOUNT_BOOKING_FORECAST_FLAG,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP
from transform_data 
)
select * from type_data