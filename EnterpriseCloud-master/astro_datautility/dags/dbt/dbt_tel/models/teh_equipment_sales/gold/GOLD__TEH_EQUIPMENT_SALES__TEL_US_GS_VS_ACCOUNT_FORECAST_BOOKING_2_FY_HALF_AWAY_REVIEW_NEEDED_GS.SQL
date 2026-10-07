{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_BOOKING_2_FY_HALF_AWAY_REVIEW_NEEDED_GS',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select 
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
    Product_Name,
    Is_Placeholder                      as Placeholder,
    Serial_No,
    Is_Loaner                           as Loaner,
    Booking_Month,
    Booking_Amount,
    'Can not be matched, Missing SO No' as Note,
    GS_Budget_FY                        as GS_FY,
    GS_Budget_FY_Half                   as GS_FY_Half,
    GS_Budget_FY_Q                      as GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    Budget_Type
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_BUDGET_EXPANDED') }}
where case when month(CURRENT_DATE()) in (1, 2, 3, 4, 5, 6) then Budget_Type = 'Original' 
        when month(CURRENT_DATE()) in (7, 8, 9, 10, 11, 12) then Budget_Type = 'Revised' end
    and DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__US_GS_BOOKING_BUDGET_EXPANDED') }} where BOOKING_MONTH >= dateadd(day, 1, END_of_Next_FY_Half) and BOOKING_MONTH <= End_of_Next_FY)
    and BOOKING_MONTH >= dateadd(day, 1, END_of_Next_FY_Half)
    and BOOKING_MONTH <= End_of_Next_FY
    and (SALES_ORDER_NO is null
        or SALES_ORDER_NO = ''
        or SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    and BOOKING_Amount <> 0
    and BOOKING_Amount is not null
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
        PRODUCT_NAME,
        PLACEHOLDER,
        SERIAL_NO,
        LOANER,
        BOOKING_MONTH,
        BOOKING_AMOUNT,
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
        PRODUCT_NAME,
        PLACEHOLDER,
        SERIAL_NO,
        LOANER,
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(BOOKING_AMOUNT as NUMBER(38,0)) as BOOKING_AMOUNT,
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