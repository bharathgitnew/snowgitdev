{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='GS_EQUIPMENT_ACCEPTANCE_REVENUE_RECOGNITION_CURRENT_FLAT',
    	transient=false
) }}

WITH ref_cte_GS_US_REVENUE_BUDGET as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }}
),

ref_cte_GS_US_REVENUE_FORECAST as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_FORECAST') }}
),

GSData

AS

(

--Forecast--

SELECT

    Sales_Account,

    Sales_Region,

    BU,

    Sub_BU,

    BU_Group,

    Sold_to_Party,

    End_User,

    FAB,

    Sales_Order_No,

    Sales_Category_Group,

    Sales_Category,

    Is_Placeholder,

    Product_Name,

    Serial_No,

    FIRST_SERIAL_NO,

    Sales_Month,

    Sales_Amount,

    QUANTITY,

    Customs_Clearance_Date,

    On_Dock_Date,

    Sales_Date,

    Is_Loaner,

    -- Revenue_Recognition_Criteria,

    Revenue_Recognition_Criteria_Short,

    Data_Snapshot,

    Data_Type,

    '' AS Budget_Type,

    BU_Code,

    Sub_BU_Code,

    Order_Type_Code,

    Sold_to_Party_Code,

    End_User_Code_Mixed,

    _5_DIGIT_END_USER_CODE,

    End_User_Code,

    GS_Forecast_FK_Date             AS GS_FK_Date,

    GS_Forecast_FY                  AS GS_FY,

    GS_Forecast_FY_Half             AS GS_FY_Half,

    GS_Forecast_FY_Q                AS GS_FY_Q,

    Beginning_of_GS_Forecast_FY_Q   AS Beginning_of_GS_FY_Q,

    End_of_GS_Forecast_FY_Q         AS End_of_GS_FY_Q,

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

	Beginning_of_Next_FY_Q,

	End_of_Next_FY_Q,

	Beginning_of_2_FY_Ago,

	End_of_2_FY_Ahead

FROM ref_cte_GS_US_REVENUE_FORECAST gs

WHERE DATA_SNAPSHOT = (SELECT MAX(DATA_SNAPSHOT) FROM ref_cte_GS_US_REVENUE_FORECAST)

    AND SALES_MONTH >= Beginning_of_Current_FY_Half AND SALES_MONTH <= End_of_Current_FY_Half

    AND REVENUE_RECOGNITION_CRITERIA_SHORT = 'Acceptance'

    

UNION ALL

--Budget--

SELECT

    Sales_Account,

    Sales_Region,

    BU,

    Sub_BU,

    BU_Group,

    Sold_to_Party,

    End_User,

    FAB,

    Sales_Order_No,

    Sales_Category_Group,

    Sales_Category,

    Is_Placeholder,

    Product_Name,

    Serial_No,

    FIRST_SERIAL_NO,

    Sales_Month,

    Sales_Amount,

    QUANTITY,

    Customs_Clearance_Date,

    On_Dock_Date,

    Sales_Date,

    Is_Loaner,

    -- Revenue_Recognition_Criteria,

    Revenue_Recognition_Criteria_Short,

    Data_Snapshot,

    Data_Type,

    Budget_Type,

    BU_Code,

    Sub_BU_Code,

    Order_Type_Code,

    Sold_to_Party_Code,

    End_User_Code_Mixed,

    _5_DIGIT_END_USER_CODE,

    End_User_Code,

    GS_Budget_FK_Date               AS GS_FK_Date,

    GS_Budget_FY                    AS GS_FY,

    GS_Budget_FY_Half               AS GS_FY_Half,

    GS_Budget_FY_Q                  AS GS_FY_Q,

    Beginning_of_GS_Budget_FY_Q     AS Beginning_of_GS_FY_Q,

    End_of_GS_Budget_FY_Q           AS End_of_GS_FY_Q,

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

	Beginning_of_Next_FY_Q,

	End_of_Next_FY_Q,

	Beginning_of_2_FY_Ago,

	End_of_2_FY_Ahead

FROM ref_cte_GS_US_REVENUE_BUDGET gs

WHERE CASE WHEN MONTH(CURRENT_DATE()) IN (4, 5, 6, 7, 8, 9) THEN Budget_Type = 'Original' 

        WHEN MONTH(CURRENT_DATE()) IN (10, 11, 12, 1, 2, 3) THEN Budget_Type = 'Revised' END

    AND DATA_SNAPSHOT = (SELECT MAX(DATA_SNAPSHOT) FROM ref_cte_GS_US_REVENUE_BUDGET)

    AND SALES_MONTH >= Beginning_of_Current_FY_Half AND SALES_MONTH <= End_of_Current_FY_Half

    AND REVENUE_RECOGNITION_CRITERIA_SHORT = 'Acceptance'

),

source_data as (
SELECT *

FROM GSData

WHERE Data_Snapshot = (SELECT MAX(DATA_SNAPSHOT) FROM GSData)

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
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        IS_PLACEHOLDER,
        PRODUCT_NAME,
        SERIAL_NO,
        FIRST_SERIAL_NO,
        SALES_MONTH,
        SALES_AMOUNT,
        QUANTITY,
        CUSTOMS_CLEARANCE_DATE,
        ON_DOCK_DATE,
        SALES_DATE,
        IS_LOANER,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        DATA_SNAPSHOT,
        DATA_TYPE,
        BUDGET_TYPE,
        BU_CODE,
        SUB_BU_CODE,
        ORDER_TYPE_CODE,
        SOLD_TO_PARTY_CODE,
        END_USER_CODE_MIXED,
        _5_DIGIT_END_USER_CODE,
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
        BEGINNING_OF_NEXT_FY,
        END_OF_NEXT_FY,
        BEGINNING_OF_NEXT_FY_HALF,
        END_OF_NEXT_FY_HALF,
        BEGINNING_OF_NEXT_FY_Q,
        END_OF_NEXT_FY_Q,
        BEGINNING_OF_2_FY_AGO,
        END_OF_2_FY_AHEAD
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
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(IS_PLACEHOLDER as VARCHAR(16777216)) as IS_PLACEHOLDER,
        CAST(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(FIRST_SERIAL_NO as VARCHAR(16777216)) as FIRST_SERIAL_NO,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(CUSTOMS_CLEARANCE_DATE as DATE) as CUSTOMS_CLEARANCE_DATE,
        CAST(ON_DOCK_DATE as DATE) as ON_DOCK_DATE,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        CAST(IS_LOANER as VARCHAR(16777216)) as IS_LOANER,
        CAST(REVENUE_RECOGNITION_CRITERIA_SHORT as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_TYPE as VARCHAR(16777216)) as DATA_TYPE,
        CAST(BUDGET_TYPE as VARCHAR(16777216)) as BUDGET_TYPE,
        CAST(BU_CODE as VARCHAR(16777216)) as BU_CODE,
        CAST(SUB_BU_CODE as VARCHAR(16777216)) as SUB_BU_CODE,
        CAST(ORDER_TYPE_CODE as VARCHAR(16777216)) as ORDER_TYPE_CODE,
        CAST(SOLD_TO_PARTY_CODE as VARCHAR(16777216)) as SOLD_TO_PARTY_CODE,
        CAST(END_USER_CODE_MIXED as VARCHAR(16777216)) as END_USER_CODE_MIXED,
        CAST(_5_DIGIT_END_USER_CODE as VARCHAR(16777216)) as _5_DIGIT_END_USER_CODE,
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
        CAST(BEGINNING_OF_NEXT_FY as DATE) as BEGINNING_OF_NEXT_FY,
        CAST(END_OF_NEXT_FY as DATE) as END_OF_NEXT_FY,
        CAST(BEGINNING_OF_NEXT_FY_HALF as DATE) as BEGINNING_OF_NEXT_FY_HALF,
        CAST(END_OF_NEXT_FY_HALF as DATE) as END_OF_NEXT_FY_HALF,
        CAST(BEGINNING_OF_NEXT_FY_Q as DATE) as BEGINNING_OF_NEXT_FY_Q,
        CAST(END_OF_NEXT_FY_Q as DATE) as END_OF_NEXT_FY_Q,
        CAST(BEGINNING_OF_2_FY_AGO as DATE) as BEGINNING_OF_2_FY_AGO,
        CAST(END_OF_2_FY_AHEAD as DATE) as END_OF_2_FY_AHEAD
from transform_data 
)
select * from type_data