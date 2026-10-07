{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEL_GS_FORECAST_REVENUE_BOOKING_STACKED',
    	transient=false
) }}

WITH src_cte_GS_US_BOOKING_FORECAST as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_FORECAST') }}
),
src_cte_GS_US_REVENUE_FORECAST as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_FORECAST') }}
),


source_data as (
select

    GS_Forecast_FY,

    GS_Forecast_FY_Half,

    GS_Forecast_FY_Q,

    'Booking'                           as REPORT_GROUP,

    Data_Type                           as REPORT_TYPE,

    SALES_ACCOUNT,

    SALES_REGION,

    BU,

    BU_GROUP,

    BU_TYPE,

    SUB_BU,

    END_USER,

    FAB,

    SALES_CATEGORY_GROUP,

    SALES_CATEGORY,

    SALES_ORDER_NO,

    PRODUCT_NAME,

    Serial_No,

    Revenue_Recognition_Criteria_Short,

    BOOKING_MONTH,

    null                                as SALES_MONTH,

    QUANTITY,

    Booking_Amount                      as AMOUNT,

    GS_Forecast_FK_Date,

    DATA_SNAPSHOT,

    END_USER_CODE

from src_cte_GS_US_BOOKING_FORECAST

where Data_Snapshot = (select max(Data_Snapshot) from src_cte_GS_US_BOOKING_FORECAST)

    or Data_Snapshot = (select max(Data_Snapshot) from src_cte_GS_US_BOOKING_FORECAST where Data_Snapshot < BEGINNING_OF_CURRENT_FY_HALF)



union all

select

    GS_Forecast_FY,

    GS_Forecast_FY_Half,

    GS_Forecast_FY_Q,

    'Revenue'                           as REPORT_GROUP,

    Data_Type                           as REPORT_TYPE,

    SALES_ACCOUNT,

    SALES_REGION,

    BU,

    BU_GROUP,

    BU_TYPE,

    SUB_BU,

    END_USER,

    FAB,

    SALES_CATEGORY_GROUP,

    SALES_CATEGORY,

    SALES_ORDER_NO,

    PRODUCT_NAME,

    Serial_No,

    Revenue_Recognition_Criteria_Short,

    null                                as BOOKING_MONTH,

    SALES_MONTH,

    QUANTITY,

    SALES_AMOUNT                        as AMOUNT,

    GS_Forecast_FK_Date,

    DATA_SNAPSHOT,

    END_USER_CODE

from src_cte_GS_US_REVENUE_FORECAST

where Data_Snapshot = (select max(Data_Snapshot) from src_cte_GS_US_REVENUE_FORECAST)

    or Data_Snapshot = (select max(Data_Snapshot) from src_cte_GS_US_REVENUE_FORECAST where Data_Snapshot < BEGINNING_OF_CURRENT_FY_HALF)   

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        GS_FORECAST_FY,
        GS_FORECAST_FY_HALF,
        GS_FORECAST_FY_Q,
        REPORT_GROUP,
        REPORT_TYPE,
        SALES_ACCOUNT,
        SALES_REGION,
        BU,
        BU_GROUP,
        BU_TYPE,
        SUB_BU,
        END_USER,
        FAB,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        SALES_ORDER_NO,
        PRODUCT_NAME,
        SERIAL_NO,
        REVENUE_RECOGNITION_CRITERIA_SHORT,
        BOOKING_MONTH,
        SALES_MONTH,
        QUANTITY,
        AMOUNT,
        GS_FORECAST_FK_DATE,
        DATA_SNAPSHOT,
        END_USER_CODE
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(GS_FORECAST_FY as VARCHAR(16777216)) as GS_FORECAST_FY,
        CAST(GS_FORECAST_FY_HALF as VARCHAR(16777216)) as GS_FORECAST_FY_HALF,
        CAST(GS_FORECAST_FY_Q as VARCHAR(16777216)) as GS_FORECAST_FY_Q,
        CAST(REPORT_GROUP as VARCHAR(16777216)) as REPORT_GROUP,
        CAST(REPORT_TYPE as VARCHAR(16777216)) as REPORT_TYPE,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(BU_TYPE as VARCHAR(16777216)) as BU_TYPE,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(SALES_CATEGORY_GROUP as VARCHAR(16777216)) as SALES_CATEGORY_GROUP,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        CAST(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(REVENUE_RECOGNITION_CRITERIA_SHORT as VARCHAR(16777216)) as REVENUE_RECOGNITION_CRITERIA_SHORT,
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(AMOUNT as NUMBER(38,0)) as AMOUNT,
        CAST(GS_FORECAST_FK_DATE as DATE) as GS_FORECAST_FK_DATE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE
from transform_data 
)
select * from type_data