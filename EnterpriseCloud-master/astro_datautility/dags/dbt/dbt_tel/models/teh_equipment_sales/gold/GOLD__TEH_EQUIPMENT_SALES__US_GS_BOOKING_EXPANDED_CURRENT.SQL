{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='US_GS_BOOKING_EXPANDED_CURRENT',
    	transient=false
) }}

WITH ref_cte_TEL_GS_BOOKING_FORECAST_EXPANDED as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_BOOKING_FORECAST_EXPANDED') }}
),

ref_cte_US_GS_BOOKING_BUDGET_EXPANDED as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_BUDGET_EXPANDED') }}
),

GSData

as

(

--Forecast--

select

    Sales_Account,

    Sales_Region,

    BU,

    Sub_BU,

    BU_Group,

    Sold_to_Party,

    End_User,

    FAB,

    OPPORTUNITY_ID,

    PROJECT_NO,

    Sales_Order_No,

    Sales_Category_Group,

    Sales_Category,

    Is_Placeholder,

    MODEL,

    Product_Name,

    OPPORTUNITY_TITLE_FREE_TEXT,

    SALES_REPORTING_FLAG,

    Serial_No,

    Booking_Month,

    Booking_Amount,

    QUANTITY,

    IS_BOOKING_ACTUAL,

    BOOKING_SALES_STATUS,

    ACTUAL_BOOKING_DATE,

    QUOTE_NO,

    PURCHASE_ORDER_NO,

    Is_Loaner,

    LOAN_EXPIRATION_DATE,

    VPA,

    DATA_SNAPSHOT_GS,

    DATA_SNAPSHOT_CRM,

    DATA_SNAPSHOT_TIMESTAMP_CRM,

    Data_Type,

    ''                              as Budget_Type,

    Sub_BU_Code,

    Order_Type_Code,

    Sold_to_Party_Code,

    End_User_Code,

    GS_Forecast_FK_Date             as GS_FK_Date,

    GS_Forecast_FY                  as GS_FY,

    GS_Forecast_FY_Half             as GS_FY_Half,

    GS_Forecast_FY_Q                as GS_FY_Q,

    Beginning_of_GS_Forecast_FY_Q   as Beginning_of_GS_FY_Q,

    End_of_GS_Forecast_FY_Q         as End_of_GS_FY_Q,

	Beginning_of_Current_FY,

	End_of_Current_FY,

	Beginning_of_Current_FY_Half,

	End_of_Current_FY_Half,

	Beginning_of_Current_FY_Q,

	End_of_Current_FY_Q,

    Beginning_of_Previous_FY,

	End_of_Previous_FY,

	Beginning_of_Previous_FY_Half,

	End_of_Previous_FY_Half,

	Beginning_of_Previous_FY_Q,

	End_of_Previous_FY_Q,

	Beginning_of_Next_FY,

	End_of_Next_FY,

	Beginning_of_Next_FY_Half,

	End_of_Next_FY_Half,

	Beginning_of_Next_FY_Q,

	End_of_Next_FY_Q

	-- Beginning_of_2_FY_Ago,

	-- End_of_2_FY_Ahead

from ref_cte_TEL_GS_BOOKING_FORECAST_EXPANDED

where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from ref_cte_TEL_GS_BOOKING_FORECAST_EXPANDED)

    and BOOKING_MONTH >= BEGINNING_OF_CURRENT_FY_HALF 

    and BOOKING_MONTH <= END_OF_CURRENT_FY_HALF

    

union all

--Budget--

select

    Sales_Account,

    Sales_Region,

    BU,

    Sub_BU,

    BU_Group,

    Sold_to_Party,

    End_User,

    FAB,

    OPPORTUNITY_ID,

    PROJECT_NO,

    Sales_Order_No,

    Sales_Category_Group,

    Sales_Category,

    Is_Placeholder,

    MODEL,

    Product_Name,

    OPPORTUNITY_TITLE_FREE_TEXT,

    SALES_REPORTING_FLAG,

    Serial_No,

    Booking_Month,

    Booking_Amount,

    QUANTITY,

    IS_BOOKING_ACTUAL,

    BOOKING_SALES_STATUS,

    ACTUAL_BOOKING_DATE,

    QUOTE_NO,

    PURCHASE_ORDER_NO,

    Is_Loaner,

    LOAN_EXPIRATION_DATE,

    VPA,

    DATA_SNAPSHOT_GS,

    DATA_SNAPSHOT_CRM,

    DATA_SNAPSHOT_TIMESTAMP_CRM,

    Data_Type,

    Budget_Type,

    Sub_BU_Code,

    Order_Type_Code,

    Sold_to_Party_Code,

    End_User_Code,

    GS_Budget_FK_Date               as GS_FK_Date,

    GS_Budget_FY                    as GS_FY,

    GS_Budget_FY_Half               as GS_FY_Half,

    GS_Budget_FY_Q                  as GS_FY_Q,

    Beginning_of_GS_Budget_FY_Q     as Beginning_of_GS_FY_Q,

    End_of_GS_Budget_FY_Q           as End_of_GS_FY_Q,

	Beginning_of_Current_FY,

	End_of_Current_FY,

	Beginning_of_Current_FY_Half,

	End_of_Current_FY_Half,

	Beginning_of_Current_FY_Q,

	End_of_Current_FY_Q,

    Beginning_of_Previous_FY,

	End_of_Previous_FY,

	Beginning_of_Previous_FY_Half,

	End_of_Previous_FY_Half,

	Beginning_of_Previous_FY_Q,

	End_of_Previous_FY_Q,

	Beginning_of_Next_FY,

	End_of_Next_FY,

	Beginning_of_Next_FY_Half,

	End_of_Next_FY_Half,

	Beginning_of_Next_FY_Q,

	End_of_Next_FY_Q

	-- Beginning_of_2_FY_Ago,

	-- End_of_2_FY_Ahead

from ref_cte_US_GS_BOOKING_BUDGET_EXPANDED gs

where case when MONTH(CURRENT_DATE()) in (1, 2, 3, 4, 5, 6) then Budget_Type = 'Original' 

        when MONTH(CURRENT_DATE()) in (7, 8, 9, 10, 11, 12) then Budget_Type = 'Revised' end

    and DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from ref_cte_US_GS_BOOKING_BUDGET_EXPANDED)

    and BOOKING_MONTH >= BEGINNING_OF_CURRENT_FY_HALF 

    and BOOKING_MONTH <= END_OF_CURRENT_FY_HALF

),

source_data as (
SELECT *

from GSData

where Data_Snapshot_GS = (select max(DATA_SNAPSHOT_GS) from GSData)

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        BU,
        SUB_BU,
        BU_GROUP,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        OPPORTUNITY_ID,
        PROJECT_NO,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        IS_PLACEHOLDER,
        MODEL,
        PRODUCT_NAME,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        SERIAL_NO,
        BOOKING_MONTH,
        BOOKING_AMOUNT,
        QUANTITY,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        ACTUAL_BOOKING_DATE,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        DATA_SNAPSHOT_GS,
        DATA_SNAPSHOT_CRM,
        DATA_SNAPSHOT_TIMESTAMP_CRM,
        DATA_TYPE,
        BUDGET_TYPE,
        SUB_BU_CODE,
        ORDER_TYPE_CODE,
        SOLD_TO_PARTY_CODE,
        END_USER_CODE,
        GS_FK_DATE,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        BEGINNING_OF_GS_FY_Q,
        END_OF_GS_FY_Q,
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
        END_OF_NEXT_FY_Q
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(SOLD_TO_PARTY as VARCHAR(16777216)) as SOLD_TO_PARTY,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(OPPORTUNITY_ID as VARCHAR(16777216)) as OPPORTUNITY_ID,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(MODEL as VARCHAR(16777216)) as MODEL,
        CAST(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        CAST(OPPORTUNITY_TITLE_FREE_TEXT as VARCHAR(16777216)) as OPPORTUNITY_TITLE_FREE_TEXT,
        CAST(SALES_REPORTING_FLAG as VARCHAR(16777216)) as SALES_REPORTING_FLAG,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(BOOKING_AMOUNT as NUMBER(38,0)) as BOOKING_AMOUNT,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(IS_BOOKING_ACTUAL as VARCHAR(16777216)) as IS_BOOKING_ACTUAL,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PURCHASE_ORDER_NO as VARCHAR(16777216)) as PURCHASE_ORDER_NO,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(LOAN_EXPIRATION_DATE as DATE) as LOAN_EXPIRATION_DATE,
        CAST(VPA as VARCHAR(16777216)) as VPA,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        CAST(DATA_SNAPSHOT_CRM as DATE) as DATA_SNAPSHOT_CRM,
        CAST(DATA_SNAPSHOT_TIMESTAMP_CRM as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP_CRM,
        CAST(DATA_TYPE as VARCHAR(16777216)) as DATA_TYPE,
        CAST(BUDGET_TYPE as VARCHAR(16777216)) as BUDGET_TYPE,
        CAST(SUB_BU_CODE as VARCHAR(16777216)) as SUB_BU_CODE,
        CAST(ORDER_TYPE_CODE as VARCHAR(16777216)) as ORDER_TYPE_CODE,
        CAST(SOLD_TO_PARTY_CODE as VARCHAR(16777216)) as SOLD_TO_PARTY_CODE,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(GS_FK_DATE as DATE) as GS_FK_DATE,
        CAST(GS_FY as VARCHAR(16777216)) as GS_FY,
        CAST(GS_FY_HALF as VARCHAR(16777216)) as GS_FY_HALF,
        CAST(GS_FY_Q as VARCHAR(16777216)) as GS_FY_Q,
        CAST(BEGINNING_OF_GS_FY_Q as DATE) as BEGINNING_OF_GS_FY_Q,
        CAST(END_OF_GS_FY_Q as DATE) as END_OF_GS_FY_Q,
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
        CAST(END_OF_NEXT_FY_Q as DATE) as END_OF_NEXT_FY_Q
from transform_data 
)
select * from type_data