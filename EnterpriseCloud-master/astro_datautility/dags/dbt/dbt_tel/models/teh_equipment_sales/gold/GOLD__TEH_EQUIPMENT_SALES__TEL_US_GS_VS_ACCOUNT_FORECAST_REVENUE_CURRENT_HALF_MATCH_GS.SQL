{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_REVENUE_CURRENT_HALF_MATCH_GS',
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
    gs.Product_Name                 AS Model, --ORDER_ITEM,
    -- gs.SALES_REPORTING_FLAG,
    gs.IS_PLACEHOLDER               AS Placeholder,
    gs.Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    gs.Sales_Month,
    gs.SALES_AMOUNT                 AS Sales_Amount_JPY,
    gs.Is_Loaner                    AS Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    gs.Data_Snapshot_GS,
    -- gs.GS_FK_Date,
    gs.GS_FY,
    gs.GS_FY_Half,
    gs.GS_FY_Q
    -- gs.Beginning_of_GS_FY_Q,
    -- gs.End_of_GS_FY_Q,
    -- gs.Beginning_of_Current_FY,
    -- gs.End_of_Current_FY,
	-- gs.Beginning_of_Current_FY_Half,
	-- gs.End_of_Current_FY_Half,
	-- gs.Beginning_of_Current_FY_Q,
	-- gs.End_of_Current_FY_Q,
    -- gs.End_User_Code
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_REVENUE_EXPANDED_CURRENT_HALF_ROLLUP') }} gs
    INNER JOIN {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_REVENUE_FORECAST_CURRENT_HALF_ROLLUP') }} crm ON crm.SALES_ORDER_NO = gs.SALES_ORDER_NO AND crm.REVENUE_RECOGNITION_CRITERIA_SHORT = gs.REVENUE_RECOGNITION_CRITERIA_SHORT
WHERE Adjusted_Confidence_Account_Short NOT IN ('C', 'D', 'L', 'G', '---', '--', '') 
    AND Adjusted_Confidence_Account_Short IS NOT NULL
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
        SERIAL_NO,
        SALES_MONTH,
        SALES_AMOUNT_JPY,
        LOANER,
        DATA_SNAPSHOT_GS,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
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
        SERIAL_NO,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(SALES_AMOUNT_JPY as NUMBER(38,0)) as SALES_AMOUNT_JPY,
        LOANER,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q
from transform_data
)
SELECT * FROM TYPE_DATA