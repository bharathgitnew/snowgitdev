{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_GS_ACTUAL_REVENUE_BOOKING_STACKED',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
    GS_ACTUAL_FY,
    GS_ACTUAL_FY_Half,
    GS_ACTUAL_FY_Q,
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
    GS_ACTUAL_FK_Date,
    DATA_SNAPSHOT,
    END_USER_CODE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_ACTUAL') }}
where Data_Snapshot = (select max(Data_Snapshot) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_ACTUAL') }})
    or Data_Snapshot = (select max(Data_Snapshot) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_ACTUAL') }} where Data_Snapshot < BEGINNING_OF_CURRENT_FY_HALF)

union all
select
    GS_ACTUAL_FY,
    GS_ACTUAL_FY_Half,
    GS_ACTUAL_FY_Q,
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
    GS_ACTUAL_FK_Date,
    DATA_SNAPSHOT,
    END_USER_CODE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_ACTUAL') }}
where Data_Snapshot = (select max(Data_Snapshot) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_ACTUAL') }})
    or Data_Snapshot = (select max(Data_Snapshot) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_ACTUAL') }} where Data_Snapshot < BEGINNING_OF_CURRENT_FY_HALF)   
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        GS_ACTUAL_FY,
        GS_ACTUAL_FY_HALF,
        GS_ACTUAL_FY_Q,
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
        GS_ACTUAL_FK_DATE,
        DATA_SNAPSHOT,
        END_USER_CODE
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        GS_ACTUAL_FY,
        GS_ACTUAL_FY_HALF,
        GS_ACTUAL_FY_Q,
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
        CAST(BOOKING_MONTH as DATE) as BOOKING_MONTH,
        CAST(SALES_MONTH as DATE) as SALES_MONTH,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(AMOUNT as NUMBER(38,0)) as AMOUNT,
        CAST(GS_ACTUAL_FK_DATE as DATE) as GS_ACTUAL_FK_DATE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        END_USER_CODE
from transform_data
)
SELECT * FROM TYPE_DATA