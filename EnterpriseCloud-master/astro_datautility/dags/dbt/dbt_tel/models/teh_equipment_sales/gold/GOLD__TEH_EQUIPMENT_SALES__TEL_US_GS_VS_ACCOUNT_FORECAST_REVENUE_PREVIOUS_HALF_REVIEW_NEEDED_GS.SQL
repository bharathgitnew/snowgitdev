{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_US_GS_VS_ACCOUNT_FORECAST_REVENUE_PREVIOUS_HALF_REVIEW_NEEDED_GS',
    transient=false
) }}

with
woSOwCriteria
as
(
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
    Revenue_Recognition_Criteria_Short  as Rev_Rec_Criteria,
    Product_Name,
    Is_Placeholder                      as Placeholder,
    Serial_No,
    Is_Loaner                           as Loaner,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing SO No' as Note,
    GS_Forecast_FY                      as GS_FY,
    GS_Forecast_FY_Half                 as GS_FY_Half,
    GS_Forecast_FY_Q                    as GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    ''                                  as Budget_Type
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_REVENUE_FORECAST_EXPANDED') }}
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_REVENUE_FORECAST_EXPANDED') }} where SALES_MONTH >= Beginning_of_Previous_FY_Half and SALES_MONTH <= End_of_Previous_FY_Half)
    and SALES_MONTH >= Beginning_of_Previous_FY_Half 
    and SALES_MONTH <= End_of_Previous_FY_Half
    and (SALES_ORDER_NO is null
        or SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    and REVENUE_RECOGNITION_CRITERIA_SHORT is not null
    and REVENUE_RECOGNITION_CRITERIA_SHORT <> ''
    and Sales_Amount <> 0
    and Sales_Amount is not null 
),
woSOwoCriteria
as
(
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
    Revenue_Recognition_Criteria_Short                       as Rev_Rec_Criteria,
    Product_Name,
    Is_Placeholder                                           as Placeholder,
    Serial_No,
    Is_Loaner                                                as Loaner,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing SO No and Rev Rec Criteria' as Note,
    GS_Forecast_FY                                           as GS_FY,
    GS_Forecast_FY_Half                                      as GS_FY_Half,
    GS_Forecast_FY_Q                                         as GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    ''                                                       as Budget_Type
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_REVENUE_FORECAST_EXPANDED') }}
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_REVENUE_FORECAST_EXPANDED') }} where SALES_MONTH >= Beginning_of_Previous_FY_Half and SALES_MONTH <= End_of_Previous_FY_Half)
    and SALES_MONTH >= Beginning_of_Previous_FY_Half 
    and SALES_MONTH <= End_of_Previous_FY_Half
    and (SALES_ORDER_NO is null
        or SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番'))
    and (REVENUE_RECOGNITION_CRITERIA_SHORT is null
        or REVENUE_RECOGNITION_CRITERIA_SHORT = '')
    and Sales_Amount <> 0
    and Sales_Amount is not null
),
wSOwoCriteria
as
(
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
    Revenue_Recognition_Criteria_Short              as Rev_Rec_Criteria,
    Product_Name,
    Is_Placeholder                                  as Placeholder,
    Serial_No,
    Is_Loaner                                       as Loaner,
    Sales_Month,
    Sales_Amount,
    'Can not be matched, Missing Rev Rec Criteria'  as Note,
    GS_Forecast_FY                                  as GS_FY,
    GS_Forecast_FY_Half                             as GS_FY_Half,
    GS_Forecast_FY_Q                                as GS_FY_Q,
    Data_Snapshot_GS,
    Data_Type,
    ''                                              as Budget_Type
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_REVENUE_FORECAST_EXPANDED') }}
where DATA_SNAPSHOT_GS = (select max(DATA_SNAPSHOT_GS) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_GS_REVENUE_FORECAST_EXPANDED') }} where SALES_MONTH >= Beginning_of_Previous_FY_Half and SALES_MONTH <= End_of_Previous_FY_Half)
    and SALES_MONTH >= Beginning_of_Previous_FY_Half 
    and SALES_MONTH <= End_of_Previous_FY_Half
    and SALES_ORDER_NO is not null
    and SALES_ORDER_NO <> ''
    and not SALES_ORDER_NO in ('', '0', '取得中', 'バルク', '未採番')
    and (REVENUE_RECOGNITION_CRITERIA_SHORT is null
        or REVENUE_RECOGNITION_CRITERIA_SHORT = '')
    and Sales_Amount <> 0
    and Sales_Amount is not null
),
SOURCE_DATA AS (
select * 
from woSOwCriteria

union all
select * 
from woSOwoCriteria

union all
select *
from wSOwoCriteria
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
        CAST(BUDGET_TYPE as VARCHAR(1)) as BUDGET_TYPE
FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA