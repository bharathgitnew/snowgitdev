{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='SALES_CRM_ACCOUNT_FORECAST_REVENUE_BOOKING_ROLLUP_STACKED',
    transient=false
) }}


with
RevenueRollup
as
(
select distinct
    Revenue_Recognition_Criteria_Short,
    listagg(distinct Sales_Order_No, ', ')                          as Sales_Order_No,
    listagg(distinct Project_No, ', ')                              as Project_No,
    Opportunity_ID                                                  as Opportunity_ID,
	listagg(distinct Customer_Forecast_ID, ', ') 					as Customer_Forecast_ID,
	case when contains(listagg(distinct SALES_CATEGORY, ', '), 'New Equipment') then 'New Equipment'
        when contains(listagg(distinct SALES_CATEGORY, ', '), 'Used Equip w/Core') then 'Used Equip w/Core'
        when contains(listagg(distinct SALES_CATEGORY, ', '), 'Used Equip w/o Core') then 'Used Equip w/o Core'
        when contains(listagg(distinct SALES_CATEGORY, ', '), 'Used Equip (as is)') then 'Used Equip (as is)'
        when contains(listagg(distinct SALES_CATEGORY, ', '), 'Chamber') then 'Chamber'
        when contains(listagg(distinct SALES_CATEGORY, ', '), 'Pre-kit') then 'Pre-kit'
		when contains(listagg(distinct SALES_CATEGORY, ', '), 'Start Up') then 'Start Up'
		when contains(listagg(distinct SALES_CATEGORY, ', '), 'On-site Mod') then 'On-site Mod'
		when contains(listagg(distinct SALES_CATEGORY, ', '), 'In-house Mod') then 'In-house Mod'
        when contains(listagg(distinct SALES_CATEGORY, ', '), 'Option') then 'Option'
        else ''
    end                                                             as Primary_Sales_Category,
    listagg(distinct SALES_CATEGORY, ', ')                          as SALES_CATEGORY,
    listagg(distinct Sales_Document_Item_No, ', ')                  as Sales_Document_Item_No,
    listagg(distinct Model, ', ')                                   as Model,
    listagg(distinct Order_Item_Opportunity, ', ')                  as Order_Item_Opportunity,
    listagg(distinct Opportunity_Title_Free_Text, ', ')             as Opportunity_Title_Free_Text,
    listagg(distinct ADJUSTED_CONFIDENCE_ACCOUNT_SHORT, ', ')       as ADJUSTED_CONFIDENCE_ACCOUNT_SHORT,
    listagg(distinct ADJUSTED_SERIAL_NO, ', ')                      as ADJUSTED_SERIAL_NO,
    listagg(distinct SALES_REPORTING_FLAG, ', ')                    as SALES_REPORTING_FLAG,
    listagg(distinct IS_PLACEHOLDER, ', ')                          as IS_PLACEHOLDER,
    listagg(distinct IS_LOANER, ', ')                               as IS_LOANER,
    max(LOAN_EXPIRATION_DATE)                                       as LOAN_EXPIRATION_DATE,
    listagg(distinct VPA, ', ')                                     as VPA,
    max(Adjusted_Ship_Date)                                         as Adjusted_Ship_Date,
    max(Adjusted_End_User_Sales_Date_Account)                       as Adjusted_End_User_Sales_Date_Account,
    sum(End_User_Sales_Amount_JPY)                                  as End_User_Sales_Amount_JPY,
    listagg(distinct Revenue_Recognition_Status, ', ')              as Revenue_Recognition_Status,
    listagg(distinct Booking_Sales_Status, ', ')                    as Booking_Sales_Status,
    max(ACCOUNT_REVENUE_FORECAST_FK_DATE)                           as ACCOUNT_REVENUE_FORECAST_FK_DATE,
    max(BEGINNING_OF_PREVIOUS_FY)                                   as BEGINNING_OF_PREVIOUS_FY,
    max(ACCOUNT_REVENUE_FORECAST_FK_DATE)                           as ACCOUNT_REVENUE_FORECAST_FK_DATE,
    max(END_OF_NEXT_FY)                                             as END_OF_NEXT_FY
        FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_ACCOUNT_REVENUE_FORECAST') }}
where REVENUE_RECOGNITION_CRITERIA_SHORT is not null
    and REVENUE_RECOGNITION_CRITERIA_SHORT <> ''
    and ADJUSTED_CONFIDENCE_ACCOUNT_SHORT is not null
    and case when SALES_ACCOUNT ilike 'Intel' then ADJUSTED_CONFIDENCE_ACCOUNT_SHORT not in ('L', 'G', 'D', '--')
            else ADJUSTED_CONFIDENCE_ACCOUNT_SHORT not in ('L', 'G', '--')
        end
    and End_User_Sales_Amount_JPY <> 0
    and End_User_Sales_Amount_JPY is not null
group by OPPORTUNITY_ID, REVENUE_RECOGNITION_CRITERIA_SHORT
having max(ACCOUNT_REVENUE_FORECAST_FK_DATE) >= max(BEGINNING_OF_PREVIOUS_FY)
    and max(ACCOUNT_REVENUE_FORECAST_FK_DATE) <= max(END_OF_NEXT_FY)
),
Flat1
as
(
select *,
    row_number() over (partition by OPPORTUNITY_ID, REVENUE_RECOGNITION_CRITERIA_SHORT order by End_User_Sales_Amount_JPY desc)   as Row_No
        FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_ACCOUNT_REVENUE_FORECAST') }}
where ACCOUNT_REVENUE_FORECAST_FK_DATE >= BEGINNING_OF_PREVIOUS_FY
    and ACCOUNT_REVENUE_FORECAST_FK_DATE <= END_OF_NEXT_FY
    and REVENUE_RECOGNITION_CRITERIA_SHORT is not null
    and REVENUE_RECOGNITION_CRITERIA_SHORT <> ''
    and case when SALES_ACCOUNT ilike 'Intel' then ADJUSTED_CONFIDENCE_ACCOUNT_SHORT not in ('L', 'G', 'D', '--')
        else ADJUSTED_CONFIDENCE_ACCOUNT_SHORT not in ('L', 'G', '--')
    end
),
FlatRevenue
as
(
select *
from Flat1
where Row_No = 1
),
BookingRollup
as
(
select distinct
    listagg(Sales_Order_No, ', ')           as Sales_Order_No,
    listagg(Project_No, ', ')               as Project_No,
    Opportunity_ID                          as Opportunity_ID,
    listagg(Customer_Forecast_ID, ', ')     as Customer_Forecast_ID,
    listagg(Booking_Currency, ', ')         as Booking_Currency,
    sum(BOOKING_AMOUNT)                     as BOOKING_AMOUNT,
    sum(END_USER_BOOKING_AMOUNT_JPY)        as END_USER_BOOKING_AMOUNT_JPY,
    max(Account_Booking_Forecast_FK_Date)   as Account_Booking_Forecast_FK_Date,
    max(BEGINNING_OF_PREVIOUS_FY)           as BEGINNING_OF_PREVIOUS_FY,
    max(Account_Booking_Forecast_FK_Date)   as Account_Booking_Forecast_FK_Date,
    max(END_OF_NEXT_FY)                     as END_OF_NEXT_FY
        FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_ACCOUNT_BOOKING_FORECAST') }}
where case when SALES_ACCOUNT ilike 'Intel' then ADJUSTED_CONFIDENCE_ACCOUNT_SHORT not in ('L', 'G', 'D', '--')
        else ADJUSTED_CONFIDENCE_ACCOUNT_SHORT not in ('L', 'G', '--')
    end
group by OPPORTUNITY_ID
having max(Account_Booking_Forecast_FK_Date) >= max(BEGINNING_OF_PREVIOUS_FY)
    and max(Account_Booking_Forecast_FK_Date) <= max(END_OF_NEXT_FY)
),
FlatBooking
as
(
select *
        FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_ACCOUNT_BOOKING_FORECAST') }}
where Account_Booking_Forecast_FK_Date >= BEGINNING_OF_PREVIOUS_FY
    and Account_Booking_Forecast_FK_Date <= END_OF_NEXT_FY
    and case when SALES_ACCOUNT ilike 'Intel' then ADJUSTED_CONFIDENCE_ACCOUNT_SHORT not in ('L', 'G', 'D', '--')
        else ADJUSTED_CONFIDENCE_ACCOUNT_SHORT not in ('L', 'G', '--')
    end
),

SOURCE_DATA AS (
select
	'Revenue'                                   as Report_Type,
    rollup.Opportunity_ID,
    rollup.Sales_Document_Item_No,
    rollup.Project_No,
	rollup.Sales_Order_No,
	rollup.Customer_Forecast_ID,
    -- flat.Account_Revenue_Forecast_Flag,
    flat.Account_Revenue_FY                     as Account_Forecast_FY,
	flat.Account_Revenue_FY_Half                as Account_Forecast_FY_Half,
	flat.Account_Revenue_FY_Q                   as Account_Forecast_FY_Q,
    flat.Sales_Account,
	flat.Sales_Region,
	flat.End_User,
	flat.FAB,
	flat.BU,
	flat.BU_Group,
	flat.Sub_BU,
    flat.Sales_Category_Group,
	rollup.Primary_Sales_Category 		        as Sales_Category,
    rollup.Adjusted_Confidence_Account_Short    as CONFIDENCE,
    rollup.Order_Item_Opportunity               as Product_Name,
	flat.Order_Item_Sales_Document              as SD_Order_Item,
    rollup.Adjusted_Serial_No                   as SERIAL_NO,
	flat.Customer_Tool_ID,
	flat.Quote_No,
	flat.Purchase_Order_No                      as PO_NO,
    flat.Adjusted_Booking_Date_Account          as Booking_Date,
	flat.PO_Receipt_Date,
	flat.Actual_Booking_Date,
	flat.Is_Booking_Actual,
	rollup.Adjusted_Ship_Date                   as SHIP_DATE,
    rollup.Adjusted_End_User_Sales_Date_Account as SALES_DATE,
    rollup.Revenue_Recognition_Status,
    flat.Quantity,
    -- Sales_Amount_JPY_Adjusted, --TEL's Sales Amount after adjustments
	rollup.End_User_Sales_Amount_JPY            as AMOUNT,  --Sales Amount to the customer
	rollup.Revenue_Recognition_Criteria_Short   as REVENUE_RECOGNITION_CRITERIA,
    flat.ACCOUNT_REVENUE_FORECAST_FK_DATE       as ACCOUNT_FORECAST_FK_DATE,
    flat.Data_Snapshot,
	flat.Data_Snapshot_Timestamp,
    flat.End_User_Code
from RevenueRollup rollup
left outer join FlatRevenue flat on flat.Opportunity_ID = rollup.Opportunity_ID and flat.REVENUE_RECOGNITION_CRITERIA_SHORT = rollup.REVENUE_RECOGNITION_CRITERIA_SHORT

union all
--Booking
select
    'Booking'                           as Report_Type,
    Rollup.Opportunity_ID,
    ''                                  as Sales_Document_Item_No,
    Rollup.Project_No,
    Rollup.Sales_Order_No,
    Rollup.Customer_Forecast_ID,
    flat.Account_Booking_FY             as Account_Forecast_FY,
    flat.Account_Booking_FY_Half        as Account_Forecast_FY_Half,
    flat.Account_Booking_FY_Q           as Account_Forecast_FY_Q,
    flat.Sales_Account,
    flat.Sales_Region,
    flat.End_User,
    flat.FAB,
    flat.BU,
    flat.BU_Group,
    flat.Sub_BU,
    flat.SALES_CATEGORY_GROUP,
    flat.Sales_Category,
    flat.Adjusted_Confidence_Account_Short  as CONFIDENCE,
    flat.Order_Item                         as Product_Name,
    ''                                      as SD_Order_Item,
    flat.Adjusted_Serial_No                 as SERIAL_No,
    flat.Customer_Tool_ID,
    flat.Quote_No,
    flat.Purchase_Order_No                  as PO_No,
    flat.Adjusted_Booking_Date_Account      as Booking_Date,
    flat.PO_Receipt_Date,
    flat.Actual_Booking_Date,
    flat.Is_Booking_Actual,
    flat.Ship_Date,
    null                                    as SALES_DATE,
    ''                                      as Revenue_Recognition_Status,
    flat.Quantity,
    rollup.END_USER_BOOKING_AMOUNT_JPY      as AMOUNT,
    ''                                      as Revenue_Recognition_Criteria,
    flat.Account_Booking_Forecast_FK_Date   as ACCOUNT_FORECAST_FK_DATE,
    flat.Data_Snapshot,
    flat.Data_Snapshot_Timestamp,
    flat.End_User_Code
from FlatBooking flat
    left outer join BookingRollup rollup on rollup.Opportunity_ID = flat.Opportunity_ID
),

TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        REPORT_TYPE,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SALES_ORDER_NO,
        CUSTOMER_FORECAST_ID,
        ACCOUNT_FORECAST_FY,
        ACCOUNT_FORECAST_FY_HALF,
        ACCOUNT_FORECAST_FY_Q,
        SALES_ACCOUNT,
        SALES_REGION,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        CONFIDENCE,
        PRODUCT_NAME,
        SD_ORDER_ITEM,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PO_NO,
        BOOKING_DATE,
        PO_RECEIPT_DATE,
        ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        SHIP_DATE,
        SALES_DATE,
        REVENUE_RECOGNITION_STATUS,
        QUANTITY,
        AMOUNT,
        REVENUE_RECOGNITION_CRITERIA,
        ACCOUNT_FORECAST_FK_DATE,
        DATA_SNAPSHOT,
        DATA_SNAPSHOT_TIMESTAMP,
        END_USER_CODE
FROM SOURCE_DATA
),

TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        REPORT_TYPE,
        OPPORTUNITY_ID,
        SALES_DOCUMENT_ITEM_NO,
        PROJECT_NO,
        SALES_ORDER_NO,
        CUSTOMER_FORECAST_ID,
        ACCOUNT_FORECAST_FY,
        ACCOUNT_FORECAST_FY_HALF,
        ACCOUNT_FORECAST_FY_Q,
        SALES_ACCOUNT,
        SALES_REGION,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        CONFIDENCE,
        PRODUCT_NAME,
        SD_ORDER_ITEM,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PO_NO,
        CAST(BOOKING_DATE as DATE) as BOOKING_DATE,
        CAST(PO_RECEIPT_DATE as DATE) as PO_RECEIPT_DATE,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        CAST(SHIP_DATE as DATE) as SHIP_DATE,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        REVENUE_RECOGNITION_STATUS,
        CAST(QUANTITY as NUMBER(38,10)) as QUANTITY,
        CAST(AMOUNT as FLOAT) as AMOUNT,
        REVENUE_RECOGNITION_CRITERIA,
        CAST(ACCOUNT_FORECAST_FK_DATE as DATE) as ACCOUNT_FORECAST_FK_DATE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP,
        END_USER_CODE
from transform_data
)

SELECT * FROM TYPE_DATA