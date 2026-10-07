{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEL_GS_BOOKING_FORECAST_EXPANDED',
    	transient=false
) }}

WITH ref_cte_GS_US_BOOKING_FORECAST as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_FORECAST') }}
),

ref_cte_SALES_CRM_OPPORTUNITIES as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_OPPORTUNITIES') }}
),

ref_cte_WISDOM_GLOBAL_MACHINES as (
	select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__WISDOM_GLOBAL_MACHINES') }}
),
MachineData

AS

(

select distinct

	listagg(distinct SERIAL_NUMBER, ', ')              as SERIAL_NUMBER,

	listagg(distinct CUSTOMER_TOOL_ID, ', ')           as CUSTOMER_TOOL_ID,

	listagg(distinct WISDOM_BU, ', ')                  as TEL_BU,

    listagg(distinct TEL_MODEL, ', ')                  as MODEL,

	listagg(distinct MACHINE_HISTORY_REASON, ', ')     as SYSTEM_STATUS,

	max(TEL_SHIP_DATE)                                 as SHIP_DATE,

	listagg(distinct PO_NO, ', ')                      as CUSTOMER_PURCHASE_ORDER,

	listagg(distinct right(TEL_SALES_ORDER, 9), ', ')  as SALES_ORDER_NO

from ref_cte_WISDOM_GLOBAL_MACHINES

where TEL_REGION = 'North America'

    and ACTIVE_FLAG = 'Active'

    and WISDOM_BU not in ('FSI', 'Epion')

    and TEL_SHIP_DATE >= '4/1/2020'

    and TEL_SALES_ORDER is not null

group by right(TEL_SALES_ORDER, 9)

),

source_data as (
SELECT gs.Sales_Account,

    gs.Sales_Region,

    gs.BU,

    gs.BU_Group,

    gs.Sub_BU,

    case when opp.Sold_to_Party is not null then opp.Sold_to_Party

        else gs.Sold_to_Party end               as Sold_to_Party,

    case when opp.End_User is not null then opp.End_User

        else gs.End_User end                    as End_User,

    case when opp.FAB is not null then opp.FAB

        else gs.FAB end                         as FAB,

    gs.Sales_Order_No,

    opp.OPPORTUNITY_ID,

    opp.PROJECT_NO,

    gs.Sales_Category_Group,

    gs.Sales_Category,

    opp.MODEL,

    gs.Product_Name,

    opp.ORDER_ITEM,

    opp.OPPORTUNITY_TITLE_FREE_TEXT,

    opp.SALES_REPORTING_FLAG,

    case when opp.IS_PLACEHOLDER is not null then opp.IS_PLACEHOLDER

        else gs.IS_PLACEHOLDER end              as Is_Placeholder,

    opp.CONFIDENCE_BU_SHORT,

    opp.CONFIDENCE_ACCOUNT_SHORT,

    gs.Serial_No                                as GS_Serial_No,

    opp.ADJUSTED_SERIAL_NO                      as CRM_Serial_No,

    machine.SERIAL_NUMBER                       as WISDOM_Serial_No,

    case when gs.SALES_CATEGORY = 'Chamber' and CRM_Serial_No is not null and CRM_Serial_No <> '' and CRM_Serial_No not ilike 'TBD' and CRM_Serial_No not ilike 'NONE' then CRM_Serial_No

        when gs.SALES_CATEGORY = 'Chamber' and (CRM_Serial_No IS null or CRM_Serial_No = '' or CRM_Serial_No ilike 'TBD' or CRM_Serial_No ilike 'NONE') then WISDOM_Serial_No

        when GS_Serial_No is not null and GS_Serial_No <> '' and GS_Serial_No not ilike 'TBD' and GS_Serial_No not ilike 'NONE' and GS_Serial_No <> '0' then GS_Serial_No

        when CRM_Serial_No is not null and CRM_Serial_No <> '' and CRM_Serial_No not ilike 'TBD' and CRM_Serial_No not ilike 'NONE' then CRM_Serial_No

        else WISDOM_Serial_No end               as Serial_No,

    opp.CUSTOMER_TOOL_ID,

    opp.QUOTE_NO,

    opp.PURCHASE_ORDER_NO,

    gs.Booking_Month,

    opp.END_USER_BOOKING_DATE_BU,

    opp.ADJUSTED_BOOKING_DATE_ACCOUNT,

    opp.ACTUAL_BOOKING_DATE,

    opp.IS_BOOKING_ACTUAL,

    opp.BOOKING_SALES_STATUS,

    opp.SHIP_DATE,

    opp.SHIP_DATE_PLUS_120,

    gs.Booking_Amount,

    gs.QUANTITY,

    gs.Sales_Date,

    case when gs.Is_Loaner is not null then gs.Is_Loaner

        else opp.IS_LOANER  end                 as Is_Loaner,

    opp.LOAN_EXPIRATION_DATE,

    opp.VPA,

    gs.Revenue_Recognition_Criteria,

    gs.Revenue_Recognition_Criteria_Short,

    gs.Data_Snapshot                            as DATA_SNAPSHOT_GS,

    opp.Data_Snapshot                           as DATA_SNAPSHOT_CRM,

    opp.DATA_SNAPSHOT_TIMESTAMP                 as DATA_SNAPSHOT_TIMESTAMP_CRM,

    gs.Data_Type,

    opp.ACCOUNT_COMMENTS,

    opp.SALES_COMMENTS_TO_SAP,

    GS_Forecast_FK_Date,

    GS_Forecast_FY,

    GS_Forecast_FY_Half,

    GS_Forecast_FY_Q,

    Beginning_of_GS_Forecast_FY_Q,

    End_of_GS_Forecast_FY_Q,

    gs.Beginning_of_Current_FY,

    gs.End_of_Current_FY,

	gs.Beginning_of_Current_FY_Half,

	gs.End_of_Current_FY_Half,

	gs.Beginning_of_Current_FY_Q,

	gs.End_of_Current_FY_Q,

    gs.Beginning_of_Previous_FY,

    gs.End_of_Previous_FY,

	gs.Beginning_of_Previous_FY_Half,

	gs.End_of_Previous_FY_Half,

	gs.Beginning_of_Previous_FY_Q,

	gs.End_of_Previous_FY_Q,

	gs.Beginning_of_Next_FY,

	gs.End_of_Next_FY,

	gs.Beginning_of_Next_FY_Half,

	gs.End_of_Next_FY_Half,

	gs.Beginning_of_Next_FY_Q,

	gs.End_of_Next_FY_Q,

	-- gs.Beginning_of_2_FY_Ago,

	-- gs.End_of_2_FY_Ahead,

    gs.SOLD_TO_PARTY_CODE,

    gs.End_User_Code,

    gs.Sub_BU_Code,

    gs.Order_Type_Code

from ref_cte_GS_US_BOOKING_FORECAST gs

    left outer join ref_cte_SALES_CRM_OPPORTUNITIES opp on opp.SALES_ORDER_NO = gs.SALES_ORDER_NO

    left outer join MachineData machine on machine.Sales_Order_No = gs.Sales_Order_No

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        BU,
        BU_GROUP,
        SUB_BU,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        OPPORTUNITY_ID,
        PROJECT_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        PRODUCT_NAME,
        ORDER_ITEM,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        CONFIDENCE_BU_SHORT,
        CONFIDENCE_ACCOUNT_SHORT,
        GS_SERIAL_NO,
        CRM_SERIAL_NO,
        WISDOM_SERIAL_NO,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        BOOKING_MONTH,
        END_USER_BOOKING_DATE_BU,
        ADJUSTED_BOOKING_DATE_ACCOUNT,
        ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        SHIP_DATE,
        SHIP_DATE_PLUS_120,
        BOOKING_AMOUNT,
        QUANTITY,
        SALES_DATE,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        REVENUE_RECOGNITION_CRITERIA,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        DATA_SNAPSHOT_GS,
        DATA_SNAPSHOT_CRM,
        DATA_SNAPSHOT_TIMESTAMP_CRM,
        DATA_TYPE,
        ACCOUNT_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        GS_FORECAST_FK_DATE,
        GS_FORECAST_FY,
        GS_FORECAST_FY_HALF,
        GS_FORECAST_FY_Q,
        BEGINNING_OF_GS_FORECAST_FY_Q,
        END_OF_GS_FORECAST_FY_Q,
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
        BEGINNING_OF_NEXT_FY,
        END_OF_NEXT_FY,
        BEGINNING_OF_NEXT_FY_HALF,
        END_OF_NEXT_FY_HALF,
        BEGINNING_OF_NEXT_FY_Q,
        END_OF_NEXT_FY_Q,
        SOLD_TO_PARTY_CODE,
        END_USER_CODE,
        SUB_BU_CODE,
        ORDER_TYPE_CODE
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(SOLD_TO_PARTY as VARCHAR(16777216)) as SOLD_TO_PARTY,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(OPPORTUNITY_ID as VARCHAR(16777216)) as OPPORTUNITY_ID,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(MODEL as VARCHAR(16777216)) as MODEL,
        CAST(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        CAST(ORDER_ITEM as VARCHAR(16777216)) as ORDER_ITEM,
        CAST(OPPORTUNITY_TITLE_FREE_TEXT as VARCHAR(16777216)) as OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(CONFIDENCE_BU_SHORT as VARCHAR(16777216)) as CONFIDENCE_BU_SHORT,
        CAST(CONFIDENCE_ACCOUNT_SHORT as VARCHAR(16777216)) as CONFIDENCE_ACCOUNT_SHORT,
        CAST(GS_SERIAL_NO as VARCHAR(16777216)) as GS_SERIAL_NO,
        CAST(CRM_SERIAL_NO as VARCHAR(16777216)) as CRM_SERIAL_NO,
        CAST(WISDOM_SERIAL_NO as VARCHAR(16777216)) as WISDOM_SERIAL_NO,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PURCHASE_ORDER_NO as VARCHAR(16777216)) as PURCHASE_ORDER_NO,
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(END_USER_BOOKING_DATE_BU as DATE) as END_USER_BOOKING_DATE_BU,
        CAST(ADJUSTED_BOOKING_DATE_ACCOUNT as DATE) as ADJUSTED_BOOKING_DATE_ACCOUNT,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        CAST(IS_BOOKING_ACTUAL as VARCHAR(16777216)) as IS_BOOKING_ACTUAL,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(SHIP_DATE as DATE) as SHIP_DATE,
        CAST(SHIP_DATE_PLUS_120 as TIMESTAMP_NTZ(9)) as SHIP_DATE_PLUS_120,
        CAST(BOOKING_AMOUNT as NUMBER(38,0)) as BOOKING_AMOUNT,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        CAST(VPA as VARCHAR(16777216)) as VPA,
        CAST(REVENUE_RECOGNITION_CRITERIA as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA,
        CAST(REVENUE_RECOGNITION_CRITERIA_SHORT as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        CAST(DATA_SNAPSHOT_CRM as DATE) as DATA_SNAPSHOT_CRM,
        CAST(DATA_SNAPSHOT_TIMESTAMP_CRM as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP_CRM,
        CAST(DATA_TYPE as VARCHAR(16777216)) as DATA_TYPE,
        CAST(ACCOUNT_COMMENTS as VARCHAR(16777216)) as ACCOUNT_COMMENTS,
        CAST(SALES_COMMENTS_TO_SAP as VARCHAR(16777216)) as SALES_COMMENTS_TO_SAP,
        CAST(GS_FORECAST_FK_DATE as DATE) as GS_FORECAST_FK_DATE,
        CAST(GS_FORECAST_FY as VARCHAR(16777216)) as GS_FORECAST_FY,
        CAST(GS_FORECAST_FY_HALF as VARCHAR(16777216)) as GS_FORECAST_FY_HALF,
        CAST(GS_FORECAST_FY_Q as VARCHAR(16777216)) as GS_FORECAST_FY_Q,
        CAST(BEGINNING_OF_GS_FORECAST_FY_Q as DATE) as BEGINNING_OF_GS_FORECAST_FY_Q,
        CAST(END_OF_GS_FORECAST_FY_Q as DATE) as END_OF_GS_FORECAST_FY_Q,
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
        CAST(BEGINNING_OF_NEXT_FY as DATE) as BEGINNING_OF_NEXT_FY,
        CAST(END_OF_NEXT_FY as DATE) as END_OF_NEXT_FY,
        CAST(BEGINNING_OF_NEXT_FY_HALF as DATE) as BEGINNING_OF_NEXT_FY_HALF,
        CAST(END_OF_NEXT_FY_HALF as DATE) as END_OF_NEXT_FY_HALF,
        CAST(BEGINNING_OF_NEXT_FY_Q as DATE) as BEGINNING_OF_NEXT_FY_Q,
        CAST(END_OF_NEXT_FY_Q as DATE) as END_OF_NEXT_FY_Q,
        CAST(SOLD_TO_PARTY_CODE as VARCHAR(16777216)) as SOLD_TO_PARTY_CODE,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(SUB_BU_CODE as VARCHAR(16777216)) as SUB_BU_CODE,
        CAST(ORDER_TYPE_CODE as VARCHAR(16777216)) as ORDER_TYPE_CODE
from transform_data 
)
select * from type_data