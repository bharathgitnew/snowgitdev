{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_BOOKING_PREVIOUS_HALF_MATCH_GS',
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
    gs.Product_Name                         AS Model, --ORDER_ITEM,
    -- gs.SALES_REPORTING_FLAG,
    gs.IS_PLACEHOLDER                       AS Placeholder,
    crm.Adjusted_Confidence_Account_Short   AS Account_Confidence,
    crm.Confidence_BU_Short                 AS BU_Confidence,
    -- gs.Adjusted_Serial_No                      AS Serial_No,
    -- gs.CUSTOMER_TOOL_ID,
    crm.Adjusted_Booking_Date_Account       AS Booking_Date_Account,
    crm.End_User_Booking_Date_BU            AS Booking_Date_BU,
    gs.Booking_Month                        AS GS_Booking_Month,
    gs.Booking_Amount                       AS Booking_Amount_JPY,
    gs.Is_Loaner                            AS Loaner,
    -- gs.LOAN_EXPIRATION_DATE,
    -- gs.VPA,
    crm.Account_Booking_FY,   
    crm.Account_Booking_FY_Half,  
    crm.Account_Booking_FY_Q,
    gs.GS_FY,
    gs.GS_FY_Half,
    gs.GS_FY_Q,
    crm.Data_Snapshot_Timestamp,
    gs.Data_Snapshot_GS,
    gs.Data_Type
	-- gs.Beginning_of_GS_FY_Q,
	-- gs.End_of_GS_FY_Q,
	-- gs.Beginning_of_Next_FY,
	-- gs.End_of_Next_FY,
	-- gs.Beginning_of_Next_FY_Half,
	-- gs.End_of_Next_FY_Half,
	-- gs.Beginning_of_Next_FY_Q,
	-- gs.End_of_Next_FY_Q
FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_EXPANDED_PREVIOUS_HALF_ROLLUP') }} gs
    INNER JOIN {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_FORECAST_PREVIOUS_HALF_ROLLUP') }} crm ON crm.Sales_Order_No = gs.Sales_Order_No
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
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        BOOKING_DATE_ACCOUNT,
        BOOKING_DATE_BU,
        GS_BOOKING_MONTH,
        BOOKING_AMOUNT_JPY,
        LOANER,
        ACCOUNT_BOOKING_FY,
        ACCOUNT_BOOKING_FY_HALF,
        ACCOUNT_BOOKING_FY_Q,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        DATA_SNAPSHOT_TIMESTAMP,
        DATA_SNAPSHOT_GS,
        DATA_TYPE
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
        ACCOUNT_CONFIDENCE,
        BU_CONFIDENCE,
        CAST(BOOKING_DATE_ACCOUNT as DATE) as BOOKING_DATE_ACCOUNT,
        CAST(BOOKING_DATE_BU as DATE) as BOOKING_DATE_BU,
        CAST(GS_BOOKING_MONTH as DATE) as GS_BOOKING_MONTH,
        CAST(BOOKING_AMOUNT_JPY as NUMBER(38,0)) as BOOKING_AMOUNT_JPY,
        LOANER,
        ACCOUNT_BOOKING_FY,
        ACCOUNT_BOOKING_FY_HALF,
        ACCOUNT_BOOKING_FY_Q,
        GS_FY,
        GS_FY_HALF,
        GS_FY_Q,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP,
        CAST(DATA_SNAPSHOT_GS as DATE) as DATA_SNAPSHOT_GS,
        DATA_TYPE
from transform_data
)
SELECT * FROM TYPE_DATA