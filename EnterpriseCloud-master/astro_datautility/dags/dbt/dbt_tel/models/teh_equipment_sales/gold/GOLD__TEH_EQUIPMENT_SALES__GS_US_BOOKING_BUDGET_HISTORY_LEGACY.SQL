{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='GS_US_BOOKING_BUDGET_HISTORY_LEGACY',
    	transient=false
) }}

WITH ref_cte_SALES_CRM_BUSINESS_UNIT as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_BUSINESS_UNIT') }}
),

ref_SALES_GS_BOOKING_BUDGET_HISTORY as 
(
    SELECT *
    FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SALES_OPERATIONS_SALES_GS_BOOKING_BUDGET_HISTORY') }}
),



source_data as (
select

    Report_Month,

    FY,

    Qtr,

    bu.BU,

    bu.BU_GROUP,

    bu.BU_TYPE,

    case when ORIGINAL_SUB_BU <> 'FS' then ORIGINAL_SUB_BU

        when TEL_BU = 'FS(CERTAS)' then 'FS_Certas'

        when TEL_BU = 'FS(SICEPI)' then 'FS_SiC'

        else concat('FS_', substr(TEL_BU, 4, length(TEL_BU)-3-1)) end   as Sub_BU,

    case when startswith(End_User_Name, 'NXP') then 'Regional'

        when Sales_Customer_Group = 'NXP/TI' then 'TI'

        when END_USER_NAME like 'ROBERT BOSCH%' then 'Regional'

        when Sales_Customer_Group in ('Other', 'OTHERS') then 'N/A'

        else Sales_Customer_Group end                                   as Sales_Customer_Group,

    Region,

    Customer_Name,

    End_User_Name,

    Fab,

    Baan_Fab,

    to_date(Sales_Date)         as Sales_Date,

    to_date(FCA_Date)           as FCA_Date,

    to_date(On_Dock_Date)       as On_Dock_Date,

    to_date(CST_Date)           as CST_Date,

    to_date(Booking_Date)       as Booking_Date,

    to_date(NIS_Ship_Date)      as NIS_Ship_Date,

    to_date(NIS_Move_In_Date)   as NIS_Move_In_Date,

    QUOTE_NUMBER,

    PO_NUMBER,

    PRODUCT_NAME,

    SO,

    SN,

    Confidence,

    Probability,

    Qty,

    BOOK_AMOUNT,

    Loan_Flag,

    CATEGORY_TYPE,

    Category,

    CST_Flag,

    CUSTOMER_CODE,

    END_USER_CODE,

    NIS_FAB_LINE,

    NIS_ENDUSER_AREA_CODE,

    FST_CUSTOMER_GROUP_MAPPING,

    CUSTOMER_MAPPING,

    OFFICE_MAPPING,

    MODEL_MAPPING,

    CUSTOMER_TOOL_ID,

    NIS_Flag,

    BAAN_FLAG,

    INTERNAL_FLAG,

    WAFER_SIZE,

    BAAN_FAB_CODE,

    FISCAL_YEAR,

    FISCAL_HALF,

    FISCAL_QTR,

    GS_BOOKING_MONTH,

    NIS_COMMENTS_E,

    NIS_COMMENTS_J,

    ORIGINAL_BU_CODES,

    ORIGINAL_BU,

    ORIGINAL_SUB_BU

    BUDGET_FLAG,

    ACTIVE_FLAG,

    DEVICE_NAME_LVL1,

    DEVICE_NAME_LVL2,

    to_date(REPORT_LOAD_DATE)       as REPORT_LOAD_DATE,

    SALES_REGION,

    INVESTMENT_CODE,

    POR,

    BACK_UP,

    DEGREE_OF_SALES_UNCERTAINTY,

    INVESTMENT_SUB_CODE,

    DEVICE_CODE_LVL1,

    DEVICE_CODE_LVL2,

    Level,

    Level2,

    NIS_PRODUCT_NAME

from ref_SALES_GS_BOOKING_BUDGET_HISTORY

left outer join ref_cte_SALES_CRM_BUSINESS_UNIT bu on bu.SUB_BU = case when ORIGINAL_SUB_BU <> 'FS' then ORIGINAL_SUB_BU

                                                                            when TEL_BU = 'FS(CERTAS)' then 'FS_Certas'

                                                                            when TEL_BU = 'FS(SICEPI)' then 'FS_SiC'

                                                                            else concat('FS_', substr(TEL_BU, 4, length(TEL_BU)-3-1)) end

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        REPORT_MONTH,
        FY,
        QTR,
        BU,
        BU_GROUP,
        BU_TYPE,
        SUB_BU,
        SALES_CUSTOMER_GROUP,
        REGION,
        CUSTOMER_NAME,
        END_USER_NAME,
        FAB,
        BAAN_FAB,
        SALES_DATE,
        FCA_DATE,
        ON_DOCK_DATE,
        CST_DATE,
        BOOKING_DATE,
        NIS_SHIP_DATE,
        NIS_MOVE_IN_DATE,
        QUOTE_NUMBER,
        PO_NUMBER,
        PRODUCT_NAME,
        SO,
        SN,
        CONFIDENCE,
        PROBABILITY,
        QTY,
        BOOK_AMOUNT,
        LOAN_FLAG,
        CATEGORY_TYPE,
        CATEGORY,
        CST_FLAG,
        CUSTOMER_CODE,
        END_USER_CODE,
        NIS_FAB_LINE,
        NIS_ENDUSER_AREA_CODE,
        FST_CUSTOMER_GROUP_MAPPING,
        CUSTOMER_MAPPING,
        OFFICE_MAPPING,
        MODEL_MAPPING,
        CUSTOMER_TOOL_ID,
        NIS_FLAG,
        BAAN_FLAG,
        INTERNAL_FLAG,
        WAFER_SIZE,
        BAAN_FAB_CODE,
        FISCAL_YEAR,
        FISCAL_HALF,
        FISCAL_QTR,
        GS_BOOKING_MONTH,
        NIS_COMMENTS_E,
        NIS_COMMENTS_J,
        ORIGINAL_BU_CODES,
        ORIGINAL_BU,
        BUDGET_FLAG,
        ACTIVE_FLAG,
        DEVICE_NAME_LVL1,
        DEVICE_NAME_LVL2,
        REPORT_LOAD_DATE,
        SALES_REGION,
        INVESTMENT_CODE,
        POR,
        BACK_UP,
        DEGREE_OF_SALES_UNCERTAINTY,
        INVESTMENT_SUB_CODE,
        DEVICE_CODE_LVL1,
        DEVICE_CODE_LVL2,
        LEVEL,
        LEVEL2,
        NIS_PRODUCT_NAME
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(REPORT_MONTH as VARCHAR(16777216)) as REPORT_MONTH,
        CAST(FY as VARCHAR(16777216)) as FY,
        CAST(QTR as VARCHAR(16777216)) as QTR,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(BU_TYPE as VARCHAR(16777216)) as BU_TYPE,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(SALES_CUSTOMER_GROUP as VARCHAR(16777216)) as SALES_CUSTOMER_GROUP,
        CAST(REGION as VARCHAR(16777216)) as REGION,
        CAST(CUSTOMER_NAME as VARCHAR(16777216)) as CUSTOMER_NAME,
        CAST(END_USER_NAME as VARCHAR(16777216)) as END_USER_NAME,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(BAAN_FAB as VARCHAR(16777216)) as BAAN_FAB,
        CAST(SALES_DATE as DATE) as SALES_DATE,
        CAST(FCA_DATE as DATE) as FCA_DATE,
        CAST(ON_DOCK_DATE as DATE) as ON_DOCK_DATE,
        CAST(CST_DATE as DATE) as CST_DATE,
        CAST(BOOKING_DATE as DATE) as BOOKING_DATE,
        CAST(NIS_SHIP_DATE as DATE) as NIS_SHIP_DATE,
        CAST(NIS_MOVE_IN_DATE as DATE) as NIS_MOVE_IN_DATE,
        CAST(QUOTE_NUMBER as VARCHAR(16777216)) as QUOTE_NUMBER,
        CAST(PO_NUMBER as VARCHAR(16777216)) as PO_NUMBER,
        CAST(PRODUCT_NAME as VARCHAR(16777216)) as PRODUCT_NAME,
        CAST(SO as VARCHAR(16777216)) as SO,
        CAST(SN as VARCHAR(16777216)) as SN,
        CAST(CONFIDENCE as VARCHAR(16777216)) as CONFIDENCE,
        CAST(PROBABILITY as VARCHAR(16777216)) as PROBABILITY,
        CAST(QTY as NUMBER(38,10)) as QTY,
        CAST(BOOK_AMOUNT as NUMBER(38,10)) as BOOK_AMOUNT,
        CAST(LOAN_FLAG as VARCHAR(16777216)) as LOAN_FLAG,
        CAST(CATEGORY_TYPE as VARCHAR(16777216)) as CATEGORY_TYPE,
        CAST(CATEGORY as VARCHAR(16777216)) as CATEGORY,
        CAST(CST_FLAG as VARCHAR(16777216)) as CST_FLAG,
        CAST(CUSTOMER_CODE as VARCHAR(16777216)) as CUSTOMER_CODE,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(NIS_FAB_LINE as VARCHAR(16777216)) as NIS_FAB_LINE,
        CAST(NIS_ENDUSER_AREA_CODE as VARCHAR(16777216)) as NIS_ENDUSER_AREA_CODE,
        CAST(FST_CUSTOMER_GROUP_MAPPING as VARCHAR(16777216)) as FST_CUSTOMER_GROUP_MAPPING,
        CAST(CUSTOMER_MAPPING as VARCHAR(16777216)) as CUSTOMER_MAPPING,
        CAST(OFFICE_MAPPING as VARCHAR(16777216)) as OFFICE_MAPPING,
        CAST(MODEL_MAPPING as VARCHAR(16777216)) as MODEL_MAPPING,
        CAST(CUSTOMER_TOOL_ID as VARCHAR(16777216)) as CUSTOMER_TOOL_ID,
        CAST(NIS_FLAG as VARCHAR(16777216)) as NIS_FLAG,
        CAST(BAAN_FLAG as VARCHAR(16777216)) as BAAN_FLAG,
        CAST(INTERNAL_FLAG as VARCHAR(16777216)) as INTERNAL_FLAG,
        CAST(WAFER_SIZE as VARCHAR(16777216)) as WAFER_SIZE,
        CAST(BAAN_FAB_CODE as VARCHAR(16777216)) as BAAN_FAB_CODE,
        CAST(FISCAL_YEAR as VARCHAR(16777216)) as FISCAL_YEAR,
        CAST(FISCAL_HALF as VARCHAR(16777216)) as FISCAL_HALF,
        CAST(FISCAL_QTR as VARCHAR(16777216)) as FISCAL_QTR,
        CAST(GS_BOOKING_MONTH as VARCHAR(16777216)) as GS_BOOKING_MONTH,
        CAST(NIS_COMMENTS_E as VARCHAR(16777216)) as NIS_COMMENTS_E,
        CAST(NIS_COMMENTS_J as VARCHAR(16777216)) as NIS_COMMENTS_J,
        CAST(ORIGINAL_BU_CODES as VARCHAR(16777216)) as ORIGINAL_BU_CODES,
        CAST(ORIGINAL_BU as VARCHAR(16777216)) as ORIGINAL_BU,
        CAST(BUDGET_FLAG as VARCHAR(16777216)) as BUDGET_FLAG,
        CAST(ACTIVE_FLAG as VARCHAR(16777216)) as ACTIVE_FLAG,
        CAST(DEVICE_NAME_LVL1 as VARCHAR(16777216)) as DEVICE_NAME_LVL1,
        CAST(DEVICE_NAME_LVL2 as VARCHAR(16777216)) as DEVICE_NAME_LVL2,
        CAST(REPORT_LOAD_DATE as DATE) as REPORT_LOAD_DATE,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(INVESTMENT_CODE as VARCHAR(16777216)) as INVESTMENT_CODE,
        CAST(POR as VARCHAR(16777216)) as POR,
        CAST(BACK_UP as VARCHAR(16777216)) as BACK_UP,
        CAST(DEGREE_OF_SALES_UNCERTAINTY as VARCHAR(16777216)) as DEGREE_OF_SALES_UNCERTAINTY,
        CAST(INVESTMENT_SUB_CODE as VARCHAR(16777216)) as INVESTMENT_SUB_CODE,
        CAST(DEVICE_CODE_LVL1 as VARCHAR(16777216)) as DEVICE_CODE_LVL1,
        CAST(DEVICE_CODE_LVL2 as VARCHAR(16777216)) as DEVICE_CODE_LVL2,
        CAST(LEVEL as VARCHAR(16777216)) as LEVEL,
        CAST(LEVEL2 as VARCHAR(16777216)) as LEVEL2,
        CAST(NIS_PRODUCT_NAME as VARCHAR(16777216)) as NIS_PRODUCT_NAME
from transform_data 
)
select * from type_data