{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TEL_SALES_CRM_ACTUAL_REVENUE_BOOKING_STACKED',
    	transient=false
) }}

WITH ref_cte_TEL_SALES_CRM_BOOKING_ACTUAL as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_BOOKING_ACTUAL') }}
),

ref_cte_TEL_SALES_CRM_REVENUE_ACTUAL as (
    select * from {{ ref('GOLD__TEH_EQUIPMENT_SALES__TEL_SALES_CRM_REVENUE_ACTUAL') }}
),



source_data as (
select

    Actual_BOOKING_FY                       as Actual_FY,

    Actual_BOOKING_FY_Half                  as Actual_FY_Half,

    Actual_BOOKING_FY_Q                     as Actual_FY_Q,

    'Booking'                               as REPORT_GROUP,

    'Actual'                                as REPORT_TYPE,

    SALES_ACCOUNT,

    SALES_REGION,

    SALES_ACCOUNT_REGION,

    END_USER,

    FAB,

    BU,

    BU_TYPE,

    BU_GROUP,

    SUB_BU,

    SALES_CATEGORY,

    ''                                      as REV_REC_CRITERIA,

    ORDER_ITEM,

    SERIAL_NO,

    ''                                      as SALES_DOCUMENT_ITEM_NO,

    OPPORTUNITY_ID,

    SO_NO,

    PROJECT_NO,

    QUOTE_NO, 

    PO_NO,

    BOOKING_SALES_STATUS,

    ''                                      as REVREC_STATUS,

    ACTUAL_BOOKING_DATE,

    null                                    as ACTUAL_SALES_DATE,

    END_USER_BOOKING_AMOUNT_JPY             as AMOUNT,

    END_USER_CODE,

    Actual_FK_Date,

    DATA_SNAPSHOT,

    DATA_SNAPSHOT_TIMESTAMP

from ref_cte_TEL_SALES_CRM_BOOKING_ACTUAL

where ACTUAL_FK_DATE >=  BEGINNING_OF_PREVIOUS_FY

    and ACTUAL_FK_DATE <= current_date()

    

union

select

    Actual_Revenue_FY,

    Actual_Revenue_FY_Half,

    Actual_Revenue_FY_Q,

    'Revenue'                               as REPORT_GROUP,

    'Actual'                                as REPORT_TYPE,

    SALES_ACCOUNT,

    SALES_REGION,

    SALES_ACCOUNT_REGION,

    END_USER,

    FAB,

    BU,

    BU_TYPE,

    BU_GROUP,

    SUB_BU,

    SALES_CATEGORY,

    REV_REC_CRITERIA,

    ORDER_ITEM,

    ADJUSTED_SERIAL_NO                      as SERIAL_NO,

    SALES_DOCUMENT_ITEM_NO,

    OPPORTUNITY_ID,

    SO_NO,

    PROJECT_NO,

    QUOTE_NO, 

    PO_NO,

    BOOKING_SALES_STATUS,

    REVREC_STATUS,

    null                                    as ACTUAL_BOOKING_DATE,

    ACTUAL_SALES_DATE,

    END_USER_SALES_AMOUNT_JPY               as AMOUNT,

    END_USER_CODE,

    Actual_FK_Date,

    DATA_SNAPSHOT,

    DATA_SNAPSHOT_TIMESTAMP

from ref_cte_TEL_SALES_CRM_REVENUE_ACTUAL

where ACTUAL_FK_DATE >=  BEGINNING_OF_PREVIOUS_FY

    and ACTUAL_FK_DATE <= current_date()

),

transform_data as (
select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ACTUAL_FY,
        ACTUAL_FY_HALF,
        ACTUAL_FY_Q,
        REPORT_GROUP,
        REPORT_TYPE,
        SALES_ACCOUNT,
        SALES_REGION,
        SALES_ACCOUNT_REGION,
        END_USER,
        FAB,
        BU,
        BU_TYPE,
        BU_GROUP,
        SUB_BU,
        SALES_CATEGORY,
        REV_REC_CRITERIA,
        ORDER_ITEM,
        SERIAL_NO,
        SALES_DOCUMENT_ITEM_NO,
        OPPORTUNITY_ID,
        SO_NO,
        PROJECT_NO,
        QUOTE_NO,
        PO_NO,
        BOOKING_SALES_STATUS,
        REVREC_STATUS,
        ACTUAL_BOOKING_DATE,
        ACTUAL_SALES_DATE,
        AMOUNT,
        END_USER_CODE,
        ACTUAL_FK_DATE,
        DATA_SNAPSHOT,
        DATA_SNAPSHOT_TIMESTAMP
from source_data
),

type_data as (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(ACTUAL_FY as VARCHAR(16777216)) as ACTUAL_FY,
        CAST(ACTUAL_FY_HALF as VARCHAR(16777216)) as ACTUAL_FY_HALF,
        CAST(ACTUAL_FY_Q as VARCHAR(16777216)) as ACTUAL_FY_Q,
        CAST(REPORT_GROUP as VARCHAR(16777216)) as REPORT_GROUP,
        CAST(REPORT_TYPE as VARCHAR(16777216)) as REPORT_TYPE,
        CAST(SALES_ACCOUNT as VARCHAR(16777216)) as SALES_ACCOUNT,
        CAST(SALES_REGION as VARCHAR(16777216)) as SALES_REGION,
        CAST(SALES_ACCOUNT_REGION as VARCHAR(16777216)) as SALES_ACCOUNT_REGION,
        CAST(END_USER as VARCHAR(16777216)) as END_USER,
        CAST(FAB as VARCHAR(16777216)) as FAB,
        CAST(BU as VARCHAR(16777216)) as BU,
        CAST(BU_TYPE as VARCHAR(16777216)) as BU_TYPE,
        CAST(BU_GROUP as VARCHAR(16777216)) as BU_GROUP,
        CAST(SUB_BU as VARCHAR(16777216)) as SUB_BU,
        CAST(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        CAST(REV_REC_CRITERIA as VARCHAR(16777216)) as REV_REC_CRITERIA,
        CAST(ORDER_ITEM as VARCHAR(16777216)) as ORDER_ITEM,
        CAST(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        CAST(SALES_DOCUMENT_ITEM_NO as VARCHAR(16777216)) as SALES_DOCUMENT_ITEM_NO,
        CAST(OPPORTUNITY_ID as VARCHAR(16777216)) as OPPORTUNITY_ID,
        CAST(SO_NO as VARCHAR(16777216)) as SO_NO,
        CAST(PROJECT_NO as VARCHAR(16777216)) as PROJECT_NO,
        CAST(QUOTE_NO as VARCHAR(16777216)) as QUOTE_NO,
        CAST(PO_NO as VARCHAR(16777216)) as PO_NO,
        CAST(BOOKING_SALES_STATUS as VARCHAR(16777216)) as BOOKING_SALES_STATUS,
        CAST(REVREC_STATUS as VARCHAR(16777216)) as REVREC_STATUS,
        CAST(ACTUAL_BOOKING_DATE as DATE) as ACTUAL_BOOKING_DATE,
        CAST(ACTUAL_SALES_DATE as DATE) as ACTUAL_SALES_DATE,
        CAST(AMOUNT as FLOAT) as AMOUNT,
        CAST(END_USER_CODE as VARCHAR(16777216)) as END_USER_CODE,
        CAST(ACTUAL_FK_DATE as DATE) as ACTUAL_FK_DATE,
        CAST(DATA_SNAPSHOT as DATE) as DATA_SNAPSHOT,
        CAST(DATA_SNAPSHOT_TIMESTAMP as TIMESTAMP_NTZ(9)) as DATA_SNAPSHOT_TIMESTAMP
from transform_data 
)
select * from type_data