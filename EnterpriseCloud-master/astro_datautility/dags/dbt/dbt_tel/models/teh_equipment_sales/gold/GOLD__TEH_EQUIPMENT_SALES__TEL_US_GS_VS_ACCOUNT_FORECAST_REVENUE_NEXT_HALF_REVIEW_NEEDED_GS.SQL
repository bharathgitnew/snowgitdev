{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_REVENUE_NEXT_HALF_REVIEW_NEEDED_GS',
    transient=false
) }}

with
woSOwCriteria
AS
(
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
    Revenue_Recognition_Criteria_Short  AS Rev_Rec_Criteria,
    Product_Name,
    Is_Placeholder                      AS Placeholder,
    Serial_No,
    Is_Loaner                           AS Loaner,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing SO No' AS Note,
    GS_Budget_FY                        AS GS_FY,
    GS_Budget_FY_Half                   AS GS_FY_Half,
    GS_Budget_FY_Q                      AS GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }}
WHERE CASE WHEN MONTH(CURRENT_DATE()) IN (1, 2, 3, 4, 5, 6) THEN Budget_Type = 'Original' 
        WHEN MONTH(CURRENT_DATE()) IN (7, 8, 9, 10, 11, 12) THEN Budget_Type = 'Revised' END
    AND DATA_SNAPSHOT_GS = (SELECT MAX(DATA_SNAPSHOT_GS) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }} WHERE SALES_MONTH >= Beginning_of_Next_FY_Half AND SALES_MONTH <= End_of_Next_FY_Half)
    AND SALES_MONTH >= Beginning_of_Next_FY_Half
    AND SALES_MONTH <= End_of_Next_FY_Half
    AND (SALES_ORDER_NO IS NULL
        OR SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    AND REVENUE_RECOGNITION_CRITERIA_SHORT IS NOT NULL
    AND REVENUE_RECOGNITION_CRITERIA_SHORT <> ''
    AND Sales_Amount <> 0
    AND Sales_Amount IS NOT NULL
),
woSOwoCriteria
AS
(
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
    Revenue_Recognition_Criteria_Short                       AS Rev_Rec_Criteria,
    Product_Name,
    Is_Placeholder                                           AS Placeholder,
    Serial_No,
    Is_Loaner                                                AS Loaner,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing SO No and Rev Rec Criteria' AS Note,
    GS_Budget_FY                                             AS GS_FY,
    GS_Budget_FY_Half                                        AS GS_FY_Half,
    GS_Budget_FY_Q                                           AS GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }}
WHERE CASE WHEN MONTH(CURRENT_DATE()) IN (1, 2, 3, 4, 5, 6) THEN Budget_Type = 'Original' 
        WHEN MONTH(CURRENT_DATE()) IN (7, 8, 9, 10, 11, 12) THEN Budget_Type = 'Revised' END
    AND DATA_SNAPSHOT_GS = (SELECT MAX(DATA_SNAPSHOT_GS) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }} WHERE SALES_MONTH >= Beginning_of_Next_FY_Half AND SALES_MONTH <= End_of_Next_FY_Half)
    AND SALES_MONTH >= Beginning_of_Next_FY_Half
    AND SALES_MONTH <= End_of_Next_FY_Half
    AND (SALES_ORDER_NO IS NULL
        OR SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    AND (REVENUE_RECOGNITION_CRITERIA_SHORT IS NULL
        OR REVENUE_RECOGNITION_CRITERIA_SHORT = '')
    AND Sales_Amount <> 0
    AND Sales_Amount IS NOT NULL
),
wSOwoCriteria
AS
(
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
    Revenue_Recognition_Criteria_Short             AS Rev_Rec_Criteria,
    Product_Name,
    Is_Placeholder                                 AS Placeholder,
    Serial_No,
    Is_Loaner                                      AS Loaner,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing Rev Rec Criteria' AS Note,
    GS_Budget_FY                                   AS GS_FY,
    GS_Budget_FY_Half                              AS GS_FY_Half,
    GS_Budget_FY_Q                                 AS GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }}
WHERE CASE WHEN MONTH(CURRENT_DATE()) IN (1, 2, 3, 4, 5, 6) THEN Budget_Type = 'Original' 
        WHEN MONTH(CURRENT_DATE()) IN (7, 8, 9, 10, 11, 12) THEN Budget_Type = 'Revised' END
    AND DATA_SNAPSHOT_GS = (SELECT MAX(DATA_SNAPSHOT_GS) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_BUDGET_EXPANDED') }} WHERE SALES_MONTH >= Beginning_of_Next_FY_Half AND SALES_MONTH <= End_of_Next_FY_Half)
    AND SALES_MONTH >= Beginning_of_Next_FY_Half
    AND SALES_MONTH <= End_of_Next_FY_Half
    AND SALES_ORDER_NO IS NOT NULL
    AND SALES_ORDER_NO <> ''
    and not SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番')
    AND (REVENUE_RECOGNITION_CRITERIA_SHORT IS NULL
        OR REVENUE_RECOGNITION_CRITERIA_SHORT = '')
    AND Sales_Amount <> 0
    AND Sales_Amount IS NOT NULL
),
SOURCE_DATA AS (
SELECT * 
FROM woSOwCriteria

UNION ALL
SELECT * 
FROM woSOwoCriteria

UNION ALL
SELECT *
FROM wSOwoCriteria
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
        REV_REC_CRITERIA,
        PRODUCT_NAME,
        PLACEHOLDER,
        SERIAL_NO,
        LOANER,
        SALES_MONTH,
        SALES_AMOUNT,
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
        REV_REC_CRITERIA,
        PRODUCT_NAME,
        PLACEHOLDER,
        SERIAL_NO,
        LOANER,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(SALES_AMOUNT as NUMBER(38,0)) as SALES_AMOUNT,
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