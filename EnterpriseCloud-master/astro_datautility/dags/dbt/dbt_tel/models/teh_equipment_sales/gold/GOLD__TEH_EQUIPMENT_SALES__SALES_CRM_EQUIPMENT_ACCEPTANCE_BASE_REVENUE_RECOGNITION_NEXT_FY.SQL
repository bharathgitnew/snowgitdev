{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='SALES_CRM_EQUIPMENT_ACCEPTANCE_BASE_REVENUE_RECOGNITION_NEXT_FY',
    transient=false
) }}

with
RolledUpSN
as
(
select 
    listagg(distinct ADJUSTED_SERIAL_NO, ', ')                                                          as Adjusted_Serial_No_Distinct
    ,listagg(distinct OPPORTUNITY_ID, ', ')                                                             as Opportunity_ID_Distinct
    ,listagg(distinct SALES_ORDER_NO, ', ')                                                             as Sales_Order_No_Distinct
    ,listagg(distinct PROJECT_NO, ', ')                                                                 as Project_No_Distinct
    ,listagg(Customer_Forecast_ID, ', ') within group (order by SALES_DOCUMENT_ITEM_NO asc)             as Customer_Forecast_ID_All
    ,listagg(SALES_DOCUMENT_ITEM_NO, ', ') within group (order by SALES_DOCUMENT_ITEM_NO asc)           as Sales_Document_Item_No_All
    ,listagg(ORDER_ITEM_SALES_DOCUMENT, ', ') within group (order by SALES_DOCUMENT_ITEM_NO asc)        as Order_Item_Sales_Document_All
    ,max(ADJUSTED_SHIP_DATE)                                                                            as Ship_Date_Max
    ,max(Adjusted_Ship_Date_Plus_120)                                                                   as Ship_Date_Plus_120_Max
    ,max(SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE)                                                        as Scheduled_Sign_Off_Date_Max 
    ,listagg(distinct SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE, ', ')                                     as Scheduled_Sign_Off_Date_All
    ,max(ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE)                                                           as Actual_Sign_Off_Date_Max
    ,listagg(distinct ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE, ', ')                                        as Actual_Sign_Off_Date_All
    ,max(END_USER_SALES_DATE_BU)                                                                        as END_USER_SALES_DATE_BU_Max 
    ,listagg(distinct END_USER_SALES_DATE_BU, ', ')                                                     as END_USER_SALES_DATE_BU_All
    ,max(END_USER_SALES_DATE_ACCOUNT)                                                                   as END_USER_SALES_DATE_ACCOUNT_Max 
    ,listagg(distinct END_USER_SALES_DATE_ACCOUNT, ', ')                                                as END_USER_SALES_DATE_ACCOUNT_All
    ,max(SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE)                                                     as Scheduled_Sign_Off_DATE_WISDOM_Max
    ,max(ACTUAL_SALES_DATE)                                                                             as Actual_Sales_Date_Max
    ,listagg(distinct ACTUAL_SALES_DATE, ', ')                                                          as Actual_Sales_Date_All
    ,listagg(distinct REVENUE_RECOGNITION_STATUS, ', ')                                                 as Revenue_Recognition_Status_Distinct
    ,listagg(REVENUE_RECOGNITION_STATUS, ', ') within group (order by SALES_DOCUMENT_ITEM_NO asc)       as Revenue_Recognition_Status_All
    ,listagg(distinct SALES_CATEGORY_GROUP, ', ')                                                       as Sales_Category_Group_Distinct
    ,listagg(distinct SALES_CATEGORY, ', ') within group (order by SALES_CATEGORY asc)                  as Sales_Category_Distinct
    ,listagg(distinct MATERIAL_TYPE, ', ')                                                              as Material_Type_Distinct
    ,sum(SALES_AMOUNT_JPY_ADJUSTED)                                                                     as Sales_Amount_JPY_Adjusted_Summed
    ,sum(END_USER_SALES_AMOUNT_JPY)                                                                     as End_User_Sales_Amount_JPY_Summed
    ,case when CONTAINS(listagg(distinct SALES_CATEGORY, ', '), 'New Equipment') then 'New Equipment'
        when CONTAINS(listagg(distinct SALES_CATEGORY, ', '), 'Used Equip w/Core') then 'Used Equip w/Core'
        when CONTAINS(listagg(distinct SALES_CATEGORY, ', '), 'Used Equip w/o Core') then 'Used Equip w/o Core'
        when CONTAINS(listagg(distinct SALES_CATEGORY, ', '), 'Used Equip (as is)') then 'Used Equip (as is)'
        when CONTAINS(listagg(distinct SALES_CATEGORY, ', '), 'Chamber') then 'Chamber'
        when CONTAINS(listagg(distinct SALES_CATEGORY, ', '), 'Pre-kit') then 'Pre-kit' else '' end     as Primary_Sales_Category
    ,split_part(listagg(SALES_DOCUMENT_ITEM_NO, ',') within group (order by SALES_DOCUMENT_ITEM_NO asc), ',', 1)   as Sales_Document_Item_No_First
    -- ,concat_ws(' - ', listagg(distinct ADJUSTED_SERIAL_NO, ', '), Primary_Sales_Category)               as Acceptance_Revenue_Recognition_Key
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }} sd
WHERE IS_ACTIVE_OPP = 'Yes' 
    and IS_ACTIVE_SD = 'Yes'
    and IS_CURRENT_OPP = 'Yes'
    and SALES_DISTRICT = 'North America' 
    and IS_GENPO_BOOKING = 'No' 
    and SALES_ORGANIZATION = 'TEL'
	and SALES_CATEGORY_GROUP in ('Equipment', 'Chamber', 'Pre-kit')
	and REVENUE_RECOGNITION_CRITERIA_SHORT = 'Acceptance'
    and ((sd.END_USER_SALES_AMOUNT_JPY <> 0 and sd.END_USER_SALES_AMOUNT_JPY is not null)
        or IS_LOANER = 'Yes'
        or STARTSWITH(VPA, 'Free'))
    and SALES_REPORTING_FLAG = 'Yes'
    and IS_PLACEHOLDER = 'No'
    and ADJUSTED_SERIAL_NO is not null 
    and ADJUSTED_SERIAL_NO <> ''
    and ADJUSTED_SERIAL_NO <> 'TBD'
    and case when CONFIDENCE_BU_SHORT is null then null else CONFIDENCE_BU_SHORT end not in ('L', 'D', 'G', '--')
group by ADJUSTED_SERIAL_NO	
having max(ADJUSTED_SHIP_DATE)>= '4/1/2020'
    and (((Scheduled_Sign_Off_Date_Max >= max(BEGINNING_OF_NEXT_FY)
        and Scheduled_Sign_Off_Date_Max <= max(End_OF_NEXT_FY))
        or (Scheduled_Sign_Off_Date_Max >= '4/1/2021'
        and Scheduled_Sign_Off_Date_Max <= dateadd('day', -1,  max(BEGINNING_OF_NEXT_FY))
        and Revenue_Recognition_Status_Distinct <> 'Actual'))
    or ((END_USER_SALES_DATE_Account_Max >= max(BEGINNING_OF_NEXT_FY)
        and END_USER_SALES_DATE_Account_Max <= max(End_OF_NEXT_FY))
        or (END_USER_SALES_DATE_Account_Max >= '4/1/2021'
        and END_USER_SALES_DATE_Account_Max <= dateadd('day', -1,  max(BEGINNING_OF_NEXT_FY))
        and Revenue_Recognition_Status_Distinct <> 'Actual'))
    or ((END_USER_SALES_DATE_BU_Max >= max(BEGINNING_OF_NEXT_FY)
        and END_USER_SALES_DATE_BU_Max <= max(End_OF_NEXT_FY))
        or (END_USER_SALES_DATE_BU_Max >= '4/1/2021'
        and END_USER_SALES_DATE_BU_Max <= dateadd('day', -1,  max(BEGINNING_OF_NEXT_FY))
        and Revenue_Recognition_Status_Distinct <> 'Actual'))
    or ((Scheduled_Sign_Off_DATE_WISDOM_Max >= max(BEGINNING_OF_NEXT_FY)
        and Scheduled_Sign_Off_DATE_WISDOM_Max <= max(End_OF_NEXT_FY))
        or (Scheduled_Sign_Off_DATE_WISDOM_Max >= '4/1/2021'
        and Scheduled_Sign_Off_DATE_WISDOM_Max <= dateadd('day', -1,  max(BEGINNING_OF_NEXT_FY))
        and Revenue_Recognition_Status_Distinct <> 'Actual')))
),
SOURCE_DATA AS (
select 
    sales_document_guid,
    rusn.Opportunity_ID_Distinct,
	rusn.Sales_Document_Item_No_All,
    rusn.Project_No_Distinct,
    rusn.Sales_Order_No_Distinct,
    rusn.Customer_Forecast_ID_All,
    SALES_ACCOUNT,
    SALES_REGION,
    SOLD_TO_PARTY,
    END_USER,
    FAB,
	BU,
    BU_GROUP,
    Sub_BU,
    rusn.SALES_CATEGORY_GROUP_Distinct,
    rusn.SALES_CATEGORY_Distinct,
    rusn.Primary_Sales_Category,
    rusn.Material_Type_Distinct,
    ORDER_ITEM_OPPORTUNITY,
	rusn.Order_Item_Sales_Document_All,
    OPPORTUNITY_TITLE_FREE_TEXT,
    MODEL,
    rusn.Adjusted_Serial_No_Distinct,
    SERIAL_NO,
    PM_SERIAL_NO,
    FIRST_SERIAL_NO,
    FIRST_PM_SERIAL_NO,
	CUSTOMER_TOOL_ID,
    SALES_REPORTING_FLAG,
    IS_PLACEHOLDER,
    END_USER_BOOKING_DATE_BU,
	IS_BOOKING_ACTUAL,
	QUOTE_NO,
	PURCHASE_ORDER_NO,
	IS_LOANER,
	LOAN_EXPIRATION_DATE,
	VPA,
	QUANTITY,
	rusn.Ship_Date_Max,
    rusn.Ship_Date_Plus_120_Max,
    rusn.Scheduled_Sign_Off_Date_Max                as Sch_Sign_Off_Date_BU_Max,
    rusn.Scheduled_Sign_Off_Date_All                as Sch_Sign_Off_Date_BU_All,
    rusn.END_USER_SALES_DATE_Account_Max            as Sch_Sign_Off_Date_Account_Max,
    rusn.END_USER_SALES_DATE_Account_All            as Sch_Sign_Off_Date_Account_All,
	SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE,
    ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE,
    IS_SIGN_OFF_ACTUAL,
    IS_SIGN_OFF_WAVED,
	IS_EST                                          as EST_Flag,
    rusn.END_USER_SALES_DATE_BU_Max,
    rusn.END_USER_SALES_DATE_BU_All,
    rusn.END_USER_SALES_DATE_ACCOUNT_Max,
    rusn.END_USER_SALES_DATE_ACCOUNT_All,
    rusn.Actual_Sales_Date_Max,
    rusn.Actual_Sales_Date_All,
    rusn.Revenue_Recognition_Status_Distinct,
    rusn.Revenue_Recognition_Status_All,
    BOOKING_SALES_STATUS,
    rusn.Sales_Amount_JPY_Adjusted_Summed,
    rusn.End_User_Sales_Amount_JPY_Summed,
	REVENUE_RECOGNITION_CRITERIA_SHORT,
	ACCOUNT_SALES_PERSON,
    BU_SALES_PERSON,
    BU_COMMENTS,
	ACCOUNT_COMMENTS,
    SALES_COMMENTS_TO_SAP,
    ASSISTANTS_COMMENTS_FROM_SAP,
    rusn.Scheduled_Sign_Off_Date_Max                    as Sign_Off_FK_Date,
    CommonDate.fiscal_year_short_text                   as Sign_Off_FY,
    CommonDate.FISCAL_YEAR_HALF_YEAR_SHORT_TEXT_ALT     as Sign_Off_FY_Half,
    CommonDate.fiscal_year_quarter_short_text           as Sign_Off_FY_Q,
    TO_DATE(CommonDate.fiscal_year_beginning_date)      as Beginning_of_Sign_Off_FY,
    TO_DATE(CommonDate.fiscal_year_ending_date)         as End_of_Sign_Off_FY,
    TO_DATE(CommonDate.fiscal_half_year_beginning_date) as Beginning_of_Sign_Off_FY_Half,
    TO_DATE(CommonDate.fiscal_half_year_ending_date)    as End_of_Sign_Off_FY_Half,
    TO_DATE(CommonDate.fiscal_quarter_beginning_date)   as Beginning_of_Sign_Off_FY_Q,
    TO_DATE(CommonDate.fiscal_quarter_ending_date)      as End_of_Sign_Off_FY_Q,
    Beginning_of_Current_FY,
    End_of_Current_FY,
	Beginning_of_Current_FY_Half,
	End_of_Current_FY_Half,
	Beginning_of_Current_FY_Q,
	End_of_Current_FY_Q,
	Beginning_of_Next_FY,
	End_of_Next_FY,
	Beginning_of_Next_FY_Half,
	End_of_Next_FY_Half,
	BEGINNING_OF_NEXT_FY_Q,
	End_of_Next_FY_Q,
    END_USER_CODE,
    _5_digits_old_end_user_code,
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
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_SALES_DOCUMENTS') }} sd
    right outer join RolledUpSN rusn on rusn.Sales_Document_Item_No_First = sd.SALES_DOCUMENT_ITEM_NO
    left outer join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} CommonDate on CommonDate.Calendar_Date = rusn.Scheduled_Sign_Off_Date_Max
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_DOCUMENT_GUID,
        OPPORTUNITY_ID_DISTINCT,
        SALES_DOCUMENT_ITEM_NO_ALL,
        PROJECT_NO_DISTINCT,
        SALES_ORDER_NO_DISTINCT,
        CUSTOMER_FORECAST_ID_ALL,
        SALES_ACCOUNT,
        SALES_REGION,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        SALES_CATEGORY_GROUP_DISTINCT,
        SALES_CATEGORY_DISTINCT,
        PRIMARY_SALES_CATEGORY,
        MATERIAL_TYPE_DISTINCT,
        ORDER_ITEM_OPPORTUNITY,
        ORDER_ITEM_SALES_DOCUMENT_ALL,
        OPPORTUNITY_TITLE_FREE_TEXT,
        MODEL,
        ADJUSTED_SERIAL_NO_DISTINCT,
        SERIAL_NO,
        PM_SERIAL_NO,
        FIRST_SERIAL_NO,
        FIRST_PM_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        END_USER_BOOKING_DATE_BU,
        IS_BOOKING_ACTUAL,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        QUANTITY,
        SHIP_DATE_MAX,
        SHIP_DATE_PLUS_120_MAX,
        SCH_SIGN_OFF_DATE_BU_MAX,
        SCH_SIGN_OFF_DATE_BU_ALL,
        SCH_SIGN_OFF_DATE_ACCOUNT_MAX,
        SCH_SIGN_OFF_DATE_ACCOUNT_ALL,
        SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE,
        ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE,
        IS_SIGN_OFF_ACTUAL,
        IS_SIGN_OFF_WAVED,
        EST_FLAG,
        END_USER_SALES_DATE_BU_MAX,
        END_USER_SALES_DATE_BU_ALL,
        END_USER_SALES_DATE_ACCOUNT_MAX,
        END_USER_SALES_DATE_ACCOUNT_ALL,
        ACTUAL_SALES_DATE_MAX,
        ACTUAL_SALES_DATE_ALL,
        REVENUE_RECOGNITION_STATUS_DISTINCT,
        REVENUE_RECOGNITION_STATUS_ALL,
        BOOKING_SALES_STATUS,
        SALES_AMOUNT_JPY_ADJUSTED_SUMMED,
        END_USER_SALES_AMOUNT_JPY_SUMMED,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        ACCOUNT_SALES_PERSON,
        BU_SALES_PERSON,
        BU_COMMENTS,
        ACCOUNT_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
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
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        SALES_DOCUMENT_GUID,
        OPPORTUNITY_ID_DISTINCT,
        SALES_DOCUMENT_ITEM_NO_ALL,
        PROJECT_NO_DISTINCT,
        SALES_ORDER_NO_DISTINCT,
        CUSTOMER_FORECAST_ID_ALL,
        SALES_ACCOUNT,
        SALES_REGION,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        SALES_CATEGORY_GROUP_DISTINCT,
        SALES_CATEGORY_DISTINCT,
        PRIMARY_SALES_CATEGORY,
        MATERIAL_TYPE_DISTINCT,
        ORDER_ITEM_OPPORTUNITY,
        ORDER_ITEM_SALES_DOCUMENT_ALL,
        OPPORTUNITY_TITLE_FREE_TEXT,
        MODEL,
        ADJUSTED_SERIAL_NO_DISTINCT,
        SERIAL_NO,
        PM_SERIAL_NO,
        FIRST_SERIAL_NO,
        FIRST_PM_SERIAL_NO,
        CUSTOMER_TOOL_ID,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        CAST(END_USER_BOOKING_DATE_BU as DATE) as END_USER_BOOKING_DATE_BU,
        IS_BOOKING_ACTUAL,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        VPA,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(SHIP_DATE_MAX as DATE) as SHIP_DATE_MAX,
        CAST(SHIP_DATE_PLUS_120_MAX as DATE) as SHIP_DATE_PLUS_120_MAX,
        CAST(SCH_SIGN_OFF_DATE_BU_MAX as DATE) as SCH_SIGN_OFF_DATE_BU_MAX,
        SCH_SIGN_OFF_DATE_BU_ALL,
        CAST(SCH_SIGN_OFF_DATE_ACCOUNT_MAX as DATE) as SCH_SIGN_OFF_DATE_ACCOUNT_MAX,
        SCH_SIGN_OFF_DATE_ACCOUNT_ALL,
        CAST(SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE as DATE) as SCHEDULED_ACCEPTANCE_TSR_SIGN_OFF_DATE_FE,
        CAST(ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE as DATE) as ACTUAL_ACCEPTANCE_TSR_SIGN_OFF_DATE,
        IS_SIGN_OFF_ACTUAL,
        IS_SIGN_OFF_WAVED,
        EST_FLAG,
        CAST(END_USER_SALES_DATE_BU_MAX as DATE) as END_USER_SALES_DATE_BU_MAX,
        END_USER_SALES_DATE_BU_ALL,
        CAST(END_USER_SALES_DATE_ACCOUNT_MAX as DATE) as END_USER_SALES_DATE_ACCOUNT_MAX,
        END_USER_SALES_DATE_ACCOUNT_ALL,
        CAST(ACTUAL_SALES_DATE_MAX as DATE) as ACTUAL_SALES_DATE_MAX,
        ACTUAL_SALES_DATE_ALL,
        REVENUE_RECOGNITION_STATUS_DISTINCT,
        REVENUE_RECOGNITION_STATUS_ALL,
        BOOKING_SALES_STATUS,
        CAST(SALES_AMOUNT_JPY_ADJUSTED_SUMMED as NUMBER(38,0)) as SALES_AMOUNT_JPY_ADJUSTED_SUMMED,
        CAST(END_USER_SALES_AMOUNT_JPY_SUMMED as NUMBER(38,0)) as END_USER_SALES_AMOUNT_JPY_SUMMED,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        ACCOUNT_SALES_PERSON,
        BU_SALES_PERSON,
        BU_COMMENTS,
        ACCOUNT_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
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
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP,
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
from transform_data
)
SELECT * FROM TYPE_DATA