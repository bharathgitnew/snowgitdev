{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='TEL_GS_BUDGET_REVENUE_BOOKING_STACKED',
    transient=false
) }}

WITH
SOURCE_DATA AS (

select
    GS_BUDGET_FY,
    GS_BUDGET_FY_Half,
    GS_BUDGET_FY_Q,
    'Booking'                           as REPORT_GROUP,
    Data_Type                           as REPORT_TYPE,
    BUDGET_TYPE,
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
    GS_BUDGET_FK_Date,
    DATA_SNAPSHOT,
    END_USER_CODE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }}
where
    (
    --Previous FY 1H Original
    Budget_Type = 'Original' 
        and BOOKING_MONTH >= BEGINNING_OF_PREVIOUS_FY 
        and BOOKING_MONTH <= dateadd(month, -6, END_OF_PREVIOUS_FY) 
        and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} where Budget_Type = 'Original' 
                                                                                                            and BOOKING_MONTH >= BEGINNING_OF_PREVIOUS_FY 
                                                                                                            and BOOKING_MONTH <= dateadd(month, -6, END_OF_PREVIOUS_FY))
    or    
    --Previous FY 2H Original
    Budget_Type = 'Original' 
        and BOOKING_MONTH >= dateadd(month, 6, BEGINNING_OF_PREVIOUS_FY)
        and BOOKING_MONTH <= END_OF_PREVIOUS_FY
        and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} where Budget_Type = 'Original' 
                                                                                                            and BOOKING_MONTH >= dateadd(month, 6, BEGINNING_OF_PREVIOUS_FY) 
                                                                                                            and BOOKING_MONTH <= END_OF_PREVIOUS_FY)
    or 
    --Previous FY 2H Revised
    Budget_Type = 'Revised' 
        and BOOKING_MONTH >= dateadd(month, 6, BEGINNING_OF_PREVIOUS_FY) 
        and BOOKING_MONTH <= END_OF_PREVIOUS_FY 
        and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} where Budget_Type = 'Revised'                                                                                                         
                                                                                                            and BOOKING_MONTH >= dateadd(month, 6, BEGINNING_OF_PREVIOUS_FY)
                                                                                                            and BOOKING_MONTH <= END_OF_PREVIOUS_FY)
    )
    or
    --Current full FY Original
    case when month(DATA_SNAPSHOT) in (1, 2, 3, 4) then Budget_Type = 'Original' 
            and BOOKING_MONTH >= BEGINNING_OF_CURRENT_FY 
            and BOOKING_MONTH <= END_OF_CURRENT_FY 
            and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} where Budget_Type = 'Original' 
                                                                                                                and BOOKING_MONTH >= BEGINNING_OF_CURRENT_FY 
                                                                                                                and BOOKING_MONTH <= END_OF_CURRENT_FY)
    --Current FY 2H Revised
        when month(DATA_SNAPSHOT) in (7, 8, 9, 10) then Budget_Type = 'Revised' 
            and BOOKING_MONTH >= dateadd(month, 6, BEGINNING_OF_CURRENT_FY)
            and BOOKING_MONTH <= END_OF_CURRENT_FY 
            and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} where Budget_Type = 'Revised'
                                                                                                                and BOOKING_MONTH >= dateadd(month, 6, BEGINNING_OF_CURRENT_FY) 
                                                                                                                and BOOKING_MONTH <= END_OF_CURRENT_FY) 
    end
    or
    --Next full FY Original
    case when month(DATA_SNAPSHOT) IN (1, 2, 3, 4) then Budget_Type = 'Original' 
            and BOOKING_MONTH >= BEGINNING_OF_NEXT_FY 
            and BOOKING_MONTH <= END_OF_NEXT_FY 
            and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} where Budget_Type = 'Original' 
                                                                                                                and BOOKING_MONTH >= BEGINNING_OF_NEXT_FY 
                                                                                                                and BOOKING_MONTH <= END_OF_NEXT_FY)
    --Next FY 2H Revised
        when month(DATA_SNAPSHOT) IN (7, 8, 9, 10) then Budget_Type = 'Revised' 
            and BOOKING_MONTH >= dateadd(month, 6, BEGINNING_OF_NEXT_FY)
            and BOOKING_MONTH <= END_OF_NEXT_FY 
            and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_BOOKING_BUDGET') }} where Budget_Type = 'Revised'
                                                                                                                and BOOKING_MONTH >= dateadd(month, 6, BEGINNING_OF_NEXT_FY) 
                                                                                                                and BOOKING_MONTH <= END_OF_NEXT_FY) 
    end
            
union all
select
    GS_BUDGET_FY,
    GS_BUDGET_FY_Half,
    GS_BUDGET_FY_Q,
    'Revenue'                           as REPORT_GROUP,
    Data_Type                           as REPORT_TYPE,
    BUDGET_TYPE,
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
    GS_BUDGET_FK_Date,
    DATA_SNAPSHOT,
    END_USER_CODE
from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }}
where
    (
    --Previous FY 1H Original
    Budget_Type = 'Original' 
        and SALES_MONTH >= BEGINNING_OF_PREVIOUS_FY 
        and SALES_MONTH <= dateadd(month, -6, END_OF_PREVIOUS_FY) 
        and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} where Budget_Type = 'Original' 
                                                                                                            and SALES_MONTH >= BEGINNING_OF_PREVIOUS_FY 
                                                                                                            and SALES_MONTH <= dateadd(month, -6, END_OF_PREVIOUS_FY))
    or    
    --Previous FY 2H Original
    Budget_Type = 'Original' 
        and SALES_MONTH >= dateadd(month, 6, BEGINNING_OF_PREVIOUS_FY)
        and SALES_MONTH <= END_OF_PREVIOUS_FY
        and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} where Budget_Type = 'Original' 
                                                                                                            and SALES_MONTH >= dateadd(month, 6, BEGINNING_OF_PREVIOUS_FY) 
                                                                                                            and SALES_MONTH <= END_OF_PREVIOUS_FY)
    or 
    --Previous FY 2H Revised
    Budget_Type = 'Revised' 
        and SALES_MONTH >= dateadd(month, 6, BEGINNING_OF_PREVIOUS_FY) 
        and SALES_MONTH <= END_OF_PREVIOUS_FY 
        and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} where Budget_Type = 'Revised'                                                                                                         
                                                                                                            and SALES_MONTH >= dateadd(month, 6, BEGINNING_OF_PREVIOUS_FY)
                                                                                                            and SALES_MONTH <= END_OF_PREVIOUS_FY)
    )
    or
    --Current full FY Original
    case when month(DATA_SNAPSHOT) in (1, 2, 3, 4) then Budget_Type = 'Original' 
            and SALES_MONTH >= BEGINNING_OF_CURRENT_FY 
            and SALES_MONTH <= END_OF_CURRENT_FY 
            and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} where Budget_Type = 'Original' 
                                                                                                                and SALES_MONTH >= BEGINNING_OF_CURRENT_FY 
                                                                                                                and SALES_MONTH <= END_OF_CURRENT_FY)
    --Current FY 2H Revised
        when month(DATA_SNAPSHOT) in (7, 8, 9, 10) then Budget_Type = 'Revised' 
            and SALES_MONTH >= dateadd(month, 6, BEGINNING_OF_CURRENT_FY)
            and SALES_MONTH <= END_OF_CURRENT_FY 
            and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} where Budget_Type = 'Revised'
                                                                                                                and SALES_MONTH >= dateadd(month, 6, BEGINNING_OF_CURRENT_FY) 
                                                                                                                and SALES_MONTH <= END_OF_CURRENT_FY) 
    end
    or
    --Next full FY Original
    case when month(DATA_SNAPSHOT) IN (1, 2, 3, 4) then Budget_Type = 'Original' 
            and SALES_MONTH >= BEGINNING_OF_NEXT_FY 
            and SALES_MONTH <= END_OF_NEXT_FY 
            and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} where Budget_Type = 'Original' 
                                                                                                                and SALES_MONTH >= BEGINNING_OF_NEXT_FY 
                                                                                                                and SALES_MONTH <= END_OF_NEXT_FY)
    --Next FY 2H Revised
        when month(DATA_SNAPSHOT) IN (7, 8, 9, 10) then Budget_Type = 'Revised' 
            and SALES_MONTH >= dateadd(month, 6, BEGINNING_OF_NEXT_FY)
            and SALES_MONTH <= END_OF_NEXT_FY 
            and DATA_SNAPSHOT = (select max(DATA_SNAPSHOT) from {{ ref('GOLD__TEH_EQUIPMENT_SALES__GS_US_REVENUE_BUDGET') }} where Budget_Type = 'Revised'
                                                                                                                and SALES_MONTH >= dateadd(month, 6, BEGINNING_OF_NEXT_FY) 
                                                                                                                and SALES_MONTH <= END_OF_NEXT_FY) 
    end
),
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        GS_BUDGET_FY,
        GS_BUDGET_FY_HALF,
        GS_BUDGET_FY_Q,
        REPORT_GROUP,
        REPORT_TYPE,
        BUDGET_TYPE,
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
        GS_BUDGET_FK_DATE,
        DATA_SNAPSHOT,
        END_USER_CODE
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        GS_BUDGET_FY,
        GS_BUDGET_FY_HALF,
        GS_BUDGET_FY_Q,
        REPORT_GROUP,
        REPORT_TYPE,
        BUDGET_TYPE,
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
        CAST(GS_BUDGET_FK_DATE as DATE) as GS_BUDGET_FK_DATE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        END_USER_CODE
from transform_data
)
SELECT * FROM TYPE_DATA