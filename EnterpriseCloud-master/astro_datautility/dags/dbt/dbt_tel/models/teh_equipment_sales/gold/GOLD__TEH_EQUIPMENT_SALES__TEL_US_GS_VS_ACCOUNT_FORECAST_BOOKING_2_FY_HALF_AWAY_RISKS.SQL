{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_BOOKING_2_FY_HALF_AWAY_RISKS',
    transient=false
) }}

with 
GSwSO
AS
(
SELECT *
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_EXPANDED_2_FY_HALF_AWAY_ROLLUP') }}
-- where SALES_ORDER_NO is not null
--     and not SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番')
),
AccountwSO
AS
(
SELECT *
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_FORECAST_2_FY_HALF_AWAY_ROLLUP') }}
WHERE Adjusted_Confidence_Account_Short NOT IN ('C', 'D', 'L', 'G', '---', '--', '') 
    AND Adjusted_Confidence_Account_Short IS NOT NULL
    AND SALES_ACCOUNT NOT ILIKE 'Intel'

union all
select *
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_FORECAST_2_FY_HALF_AWAY_ROLLUP') }}
where Adjusted_Confidence_Account_Short not in ('D', 'L', 'G', '---', '--', '') 
    and Adjusted_Confidence_Account_Short is not null
    and SALES_ACCOUNT ilike 'Intel'
),
CRMRollup
AS
(
SELECT
    Sales_Order_No,
    Adjusted_Confidence_Account_Short,
    Confidence_BU_Short,
    Adjusted_Booking_Date_Account,
    End_User_Booking_Date_BU,
    Account_Booking_FY,   
    Account_Booking_FY_Half,  
    Account_Booking_FY_Q,
    Data_Snapshot_Timestamp,
    OPPORTUNITY_ID
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_RECORDS_ROLLUP') }}
),
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
    crm.OPPORTUNITY_ID,
    -- gs.PROJECT_NO,
    gs.Sales_Category_Group,
    gs.Sales_Category,
    gs.Product_Name                         AS Model, --ORDER_ITEM,
    -- gs.SALES_REPORTING_FLAG,
    gs.IS_PLACEHOLDER                       AS Placeholder,
    crm.Adjusted_Confidence_Account_Short   AS Account_Confidence,
    crm.Confidence_BU_Short                 AS BU_Confidence,
    -- gs.Adjusted_Serial_No                      AS Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    gs.Is_Loaner                            AS Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    crm.Adjusted_Booking_Date_Account       AS Booking_Date_Account,
    crm.End_User_Booking_Date_BU            AS Booking_Date_BU,
    gs.Booking_Month                        AS GS_Booking_Month,
    gs.Booking_Amount                       AS Booking_Amount_JPY,
    crm.Account_Booking_FY,   
    crm.Account_Booking_FY_Half,  
    crm.Account_Booking_FY_Q,
    gs.GS_FY,
    gs.GS_FY_Half,
    gs.GS_FY_Q,
    crm.Data_Snapshot_Timestamp             AS Data_Snapshot_Timestamp_CRM,
    gs.Data_Snapshot_GS,
    gs.Data_Type,
    CASE WHEN CONCAT(MONTH(Booking_Date_Account), ', ', YEAR(Booking_Date_Account)) <> CONCAT(MONTH(GS_Booking_Month), ', ',YEAR(GS_Booking_Month)) THEN 1 ELSE 0 END AS Account_Month_Conflict,
    CASE WHEN CONCAT(MONTH(Booking_Date_BU), ', ', YEAR(Booking_Date_BU)) <> CONCAT(MONTH(GS_Booking_Month), ', ',YEAR(GS_Booking_Month)) THEN 1 ELSE 0 END AS BU_Month_Conflict
FROM GSwSO gs
    LEFT OUTER JOIN AccountwSO acct ON acct.Sales_Order_No = gs.Sales_Order_No
    LEFT OUTER JOIN CRMRollup crm ON crm.Sales_Order_No = gs.Sales_Order_No
WHERE acct.Sales_Order_No IS NULL
    -- AND Booking_Amount_JPY <> 0
    -- AND Booking_Amount_JPY IS NOT NULL
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
        OPPORTUNITY_ID,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        PLACEHOLDER,
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        LOANER,
        BOOKING_DATE_ACCOUNT,
        BOOKING_DATE_BU,
        GS_BOOKING_MONTH,
        BOOKING_AMOUNT_JPY,
        ACCOUNT_BOOKING_FY,
        ACCOUNT_BOOKING_FY_HALF,
        ACCOUNT_BOOKING_FY_Q,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        DATA_SNAPSHOT_TIMESTAMP_CRM,
        DATA_SNAPSHOT_GS,
        DATA_TYPE,
        ACCOUNT_MONTH_CONFLICT,
        BU_MONTH_CONFLICT
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
        OPPORTUNITY_ID,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        PLACEHOLDER,
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        LOANER,
        CAST(BOOKING_DATE_ACCOUNT as DATE) as BOOKING_DATE_ACCOUNT,
        CAST(BOOKING_DATE_BU as DATE) as BOOKING_DATE_BU,
        CAST(GS_BOOKING_MONTH as DATE) as GS_BOOKING_MONTH,
        CAST(BOOKING_AMOUNT_JPY as NUMBER(38,0)) as BOOKING_AMOUNT_JPY,
        ACCOUNT_BOOKING_FY,
        ACCOUNT_BOOKING_FY_HALF,
        ACCOUNT_BOOKING_FY_Q,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        CAST(DATA_SNAPSHOT_TIMESTAMP_CRM as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP_CRM,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        DATA_TYPE,
        CAST(ACCOUNT_MONTH_CONFLICT as NUMBER(38,0)) as ACCOUNT_MONTH_CONFLICT,
        CAST(BU_MONTH_CONFLICT as NUMBER(38,0)) as BU_MONTH_CONFLICT
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA