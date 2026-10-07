{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_BOOKING_CURRENT_HALF_REVIEW_NEEDED_GS',
    transient=false
) }}

WITH
SOURCE_DATA AS (

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
    -- Opportunity_ID,
    -- Project_No,
    Sales_Category_Group,
    Sales_Category,
    MODEL,
    Product_Name,
    Opportunity_Title_Free_Text,
    Sales_Reporting_Flag,
    Is_Placeholder                      AS Placeholder,
    -- Serial_No,
    Quote_No,
    Purchase_Order_No,
    QUANTITY,
    Is_Loaner                           AS Loaner,
    -- Loan_Expiration_Date,
    -- VPA,
    Booking_Month,
    BOOKING_AMOUNT,
    Is_Booking_Actual,
    Booking_Sales_Status,
    Actual_Booking_Date, 
    'Can not be matched, Missing SO No' AS Note,
    GS_FY,
    GS_FY_Half,
    GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_EXPANDED_CURRENT') }}
WHERE DATA_SNAPSHOT_GS = (SELECT MAX(DATA_SNAPSHOT_GS) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_EXPANDED_CURRENT') }} WHERE BOOKING_MONTH >= Beginning_of_Current_FY_Half AND BOOKING_MONTH <= End_of_Current_FY_Half)
    AND BOOKING_MONTH >= Beginning_of_Current_FY_Half
    AND BOOKING_MONTH <= End_of_Current_FY_Half
    AND (SALES_ORDER_NO IS NULL
        or SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    AND Booking_Amount <> 0
    AND Booking_Amount IS NOT NULL
),
TRANSFORM_DATA AS (
SELECT
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
        MODEL,
        PRODUCT_NAME,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        PLACEHOLDER,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        QUANTITY,
        LOANER,
        BOOKING_MONTH,
        BOOKING_AMOUNT,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        ACTUAL_BOOKING_DATE,
        NOTE,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        DATA_SNAPSHOT_GS,
        DATA_TYPE,
        BUDGET_TYPE
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
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
        MODEL,
        PRODUCT_NAME,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        PLACEHOLDER,
        QUOTE_NO,
        PURCHASE_ORDER_NO,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        LOANER,
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(BOOKING_AMOUNT as NUMBER(38,0)) as BOOKING_AMOUNT,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        NOTE,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        DATA_TYPE,
        BUDGET_TYPE
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA