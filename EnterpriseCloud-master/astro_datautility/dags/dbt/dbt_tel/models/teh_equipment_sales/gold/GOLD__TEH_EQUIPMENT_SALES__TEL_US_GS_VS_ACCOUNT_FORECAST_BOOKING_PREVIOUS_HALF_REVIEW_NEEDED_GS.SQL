{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_BOOKING_PREVIOUS_HALF_REVIEW_NEEDED_GS',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select 
    SALES_ACCOUNT,
    SALES_REGION,
    BU,
    SUB_BU,
    BU_GROUP,
    SOLD_TO_PARTY,
    END_USER,
    FAB,
    SALES_ORDER_NO,
    -- Opportunity_ID,
    -- Project_No,
    SALES_CATEGORY_GROUP,
    SALES_CATEGORY,
    MODEL,
    PRODUCT_NAME,
    OPPORTUNITY_TITLE_FREE_TEXT,
    SALES_REPORTING_FLAG,
    IS_PLACEHOLDER                      as Placeholder,
    -- Serial_No,
    QUOTE_NO,
    PURCHASE_ORDER_NO,
    QUANTITY,
    IS_LOANER                           as Loaner,
    -- Loan_Expiration_Date,
    -- VPA,
    BOOKING_MONTH,
    BOOKING_AMOUNT,
    IS_BOOKING_ACTUAL,
    BOOKING_SALES_STATUS,
    ACTUAL_BOOKING_DATE,
    'Can not be matched, Missing SO No' as Note,
    GS_FORECAST_FY                      as GS_FY,
    GS_FORECAST_FY_HALF                 as GS_FY_Half,
    GS_FORECAST_FY_Q                    as GS_FY_Q,
    DATA_SNAPSHOT_GS,
    DATA_TYPE,
    ''                                  as Budget_Type
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_BOOKING_FORECAST_EXPANDED') }}
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_BOOKING_FORECAST_EXPANDED') }} where BOOKING_MONTH >= BEGINNING_OF_PREVIOUS_FY_HALF and BOOKING_MONTH <= END_OF_PREVIOUS_FY_HALF)
    and BOOKING_MONTH >= BEGINNING_OF_PREVIOUS_FY_HALF
    and BOOKING_MONTH <= END_OF_PREVIOUS_FY_HALF
    and (SALES_ORDER_NO is null
        or SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    and BOOKING_AMOUNT <> 0
    and BOOKING_AMOUNT is not null
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
        CAST(BUDGET_TYPE as VARCHAR(1)) as BUDGET_TYPE
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA