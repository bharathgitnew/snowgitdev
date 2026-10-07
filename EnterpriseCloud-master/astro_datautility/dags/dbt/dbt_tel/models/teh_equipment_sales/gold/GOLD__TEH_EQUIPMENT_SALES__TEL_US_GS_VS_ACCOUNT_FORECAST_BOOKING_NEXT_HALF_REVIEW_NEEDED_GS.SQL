{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_BOOKING_NEXT_HALF_REVIEW_NEEDED_GS',
    transient=false
) }}

WITH
SOURCE_DATA AS (

SELECT 
    gs.Sales_Account,
    gs.Sales_Region,
    gs.BU,
    gs.BU_Group,
    gs.Sub_BU,
    gs.Sold_to_Party,
    gs.End_User,
    gs.FAB,
    gs.Sales_Order_No,
    -- gs.OPPORTUNITY_ID,
    -- gs.PROJECT_NO,
    gs.Sales_Category_Group,
    gs.Sales_Category,
    gs.Product_Name                     AS Model, --ORDER_ITEM,
    -- gs.SALES_REPORTING_FLAG,
    gs.IS_PLACEHOLDER                   AS Placeholder,
    -- gs.Adjusted_Serial_No                      AS Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    gs.Is_Loaner                        AS Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    gs.Booking_Month,
    gs.Booking_Amount                   AS Booking_Amount_JPY,
    'Can not be matched, Missing SO No' AS Note,
    GS_Budget_FY                        AS GS_FY,
    GS_Budget_FY_Half                   AS GS_FY_Half,
    GS_Budget_FY_Q                      AS GS_FY_Q,
    gs.Data_Snapshot_GS,
    gs.Data_Type
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_BUDGET_EXPANDED') }} gs
WHERE CASE WHEN MONTH(CURRENT_DATE()) IN (1, 2, 3, 4, 5, 6) THEN Budget_Type = 'Original' 
        WHEN MONTH(CURRENT_DATE()) IN (7, 8, 9, 10, 11, 12) THEN Budget_Type = 'Revised' END
    AND DATA_SNAPSHOT_GS = (SELECT MAX(DATA_SNAPSHOT_GS) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_BUDGET_EXPANDED') }} WHERE BOOKING_MONTH >= Beginning_of_Next_FY_Half AND BOOKING_MONTH <= End_of_Next_FY_Half)
    AND BOOKING_MONTH >= Beginning_of_Next_FY_Half
    AND BOOKING_MONTH <= End_of_Next_FY_Half
    AND (gs.SALES_ORDER_NO IS NULL
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
        BU_GROUP,
        SUB_BU,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        PLACEHOLDER,
        LOANER,
        BOOKING_MONTH,
        BOOKING_AMOUNT_JPY,
        NOTE,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        DATA_SNAPSHOT_GS,
        DATA_TYPE
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
        BU_GROUP,
        SUB_BU,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        PLACEHOLDER,
        LOANER,
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(BOOKING_AMOUNT_JPY as NUMBER(38,0)) as BOOKING_AMOUNT_JPY,
        NOTE,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        DATA_TYPE
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA