{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_REVENUE_CURRENT_HALF_REVIEW_NEEDED_GS',
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
    Product_Name                        AS Model,
    Is_Placeholder                      AS Placeholder,
    Is_Loaner                           AS Loaner,
    Serial_No,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing SO No' AS Note,
    GS_FY,
    GS_FY_Half,
    GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_CURRENT') }}
WHERE DATA_SNAPSHOT_GS = (SELECT MAX(DATA_SNAPSHOT_GS) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_CURRENT') }} WHERE SALES_MONTH >= Beginning_of_Current_FY_Half AND SALES_MONTH <= End_of_Current_FY_Half)
    AND SALES_MONTH >= Beginning_of_Current_FY_Half
    AND SALES_MONTH <= End_of_Current_FY_Half
    AND (SALES_ORDER_NO IS NULL
        or SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    AND REVENUE_RECOGNITION_CRITERIA_SHORT IS NOT NULL
    AND REVENUE_RECOGNITION_CRITERIA_SHORT <> ''
    AND SALES_AMOUNT <> 0
    AND SALES_AMOUNT IS NOT NULL
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
    Product_Name                                             AS Model,
    Is_Placeholder                                           AS Placeholder,
    Is_Loaner                                                AS Loaner,
    Serial_No,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing SO No and Rev Rec Criteria' AS Note,
    GS_FY,
    GS_FY_Half,
    GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_CURRENT') }}
WHERE DATA_SNAPSHOT_GS = (SELECT MAX(DATA_SNAPSHOT_GS) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_CURRENT') }} WHERE SALES_MONTH >= Beginning_of_Current_FY_Half AND SALES_MONTH <= End_of_Current_FY_Half)
    AND SALES_MONTH >= Beginning_of_Current_FY_Half
    AND SALES_MONTH <= End_of_Current_FY_Half
    AND (SALES_ORDER_NO IS NULL
        or SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    AND (REVENUE_RECOGNITION_CRITERIA_SHORT IS NULL
        OR REVENUE_RECOGNITION_CRITERIA_SHORT = '')
    AND SALES_AMOUNT <> 0
    AND SALES_AMOUNT IS NOT NULL
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
    Revenue_Recognition_Criteria_Short              AS Rev_Rec_Criteria,
    Product_Name                                    AS Model,
    Is_Placeholder                                  AS Placeholder,
    Is_Loaner                                       AS Loaner,
    Serial_No,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing Rev Rec Criteria'  AS Note,
    GS_FY,
    GS_FY_Half,
    GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_CURRENT') }}
WHERE DATA_SNAPSHOT_GS = (SELECT MAX(DATA_SNAPSHOT_GS) FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_CURRENT') }} WHERE SALES_MONTH >= Beginning_of_Current_FY_Half AND SALES_MONTH <= End_of_Current_FY_Half)
    AND SALES_MONTH >= Beginning_of_Current_FY_Half
    AND SALES_MONTH <= End_of_Current_FY_Half
    AND SALES_ORDER_NO IS NOT NULL
    and not SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番')
    AND (REVENUE_RECOGNITION_CRITERIA_SHORT IS NULL
        OR REVENUE_RECOGNITION_CRITERIA_SHORT = '')
    AND SALES_AMOUNT <> 0
    AND SALES_AMOUNT IS NOT NULL
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
        MODEL,
        PLACEHOLDER,
        LOANER,
        SERIAL_NO,
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
        MODEL,
        PLACEHOLDER,
        LOANER,
        SERIAL_NO,
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