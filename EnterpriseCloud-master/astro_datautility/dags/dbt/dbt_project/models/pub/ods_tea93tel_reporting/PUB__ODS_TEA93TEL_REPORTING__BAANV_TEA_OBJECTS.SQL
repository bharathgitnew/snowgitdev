/************
Model file generated from dbtGeneratePubViews: 10.03.2022.08.31.45"
*************/

{{ config(
      materialized='view',
      alias='BAANV_TEA_OBJECTS',
      transient=false
) }}

with source_data as (
    SELECT
        CONFIGURATION,
        OBJECT,
        SERIAL_NUMBER,
        CUSTOMERS_INSTALLATION_CODE,
        TEL_BU,
        TEA_BU,
        SOLDTO_BP,
        BP_NAME,
        CUSTOMER_SITE,
        WTY,
        WTY_DESCRIPTION,
        TERMID,
        TEL_WTY_CHANGE_APPROVAL,
        USED_EQUIPMENT,
        EVALUATION_TOOL,
        SYSTEM_STATUS_CODE,
        SYSTEM_STATUS,
        FINAL_MACHINE_SPEC_DT,
        ACT_INSPECTION_DT,
        ACT_EXIT_FACTORY_DT,
        ACT_FOB_DT,
        SCH_ON_DOCK_DT,
        SCH_INSTALLATION_ST_DT,
        SCH_INSTALLATION_END_DT,
        SCH_SL1_END_DT,
        SCH_SL2_END_DT,
        SCH_HW_STARTUP_ST_DT,
        SCH_HW_STARTUP_END_DT,
        SCH_TEL_PROC_QUALS_ST_DT,
        SCH_TEL_PROC_QUALS_END_DT,
        SCH_CUST_PROC_QUALS_ST_DT,
        SCH_SETUP_TESTING_END_DT,
        SCH_SYSTEM_ACCEPT_DT,
        SCH_WTY_ST_DT,
        SCH_WTY_END_DT,
        ACT_ON_DOCK_DT,
        ACT_ON_SITE_DT,
        ACT_INSTALLATION_ST_DT,
        ACT_INSTALLATION_END_DT,
        ACT_SL1_END_DT,
        ACT_SL2_END_DT,
        ACT_HW_STARTUP_ST_DT,
        ACT_HW_STARTUP_END_DT,
        ACT_TEL_PROC_QUALS_ST_DT,
        ACT_TEL_PROC_QUALS_END_DT,
        ACT_PRE_WTY_ST_DT,
        ACT_PRE_WTY_END_DT,
        ACT_SETUP_TESTING_END_DT,
        ACT_SYSTEM_ACCEPT_DT,
        ACT_CONDITIONAL_ACCEPT_DT,
        ACT_APPROVAL_DT,
        ACT_WARR_START_DT,
        ACT_WARR_END_DT,
        ACT_MACHINE_RETIRED_DT,
        ACT_ACCEPTANCE_DATE_LOCAL,
        TRAINING_CREDITS_SOLD,
        TRAINING_CREDITS_AVAIL,
        CUSTOMER_PURCHASE_ORDER,
        TEL_SALES_ORDER_NO,
        MACHINE_SPEC_NO,
        MACHINE_HISTORY_REASON,
        BUSINESS_INQUIRY_NO,
        BUILD_NO,
        WAFER_SIZE,
        PROCESS,
        REASON_ACCEPTANCE_DELAY_CODE,
        REASON_ACCEPTANCE_DELAY_TEXT,
        REASON_MACHINE_RELOCATED,
        EMPLOYEE_NO,
        COMMENTS,
        FACTORY,
        DIMENSION_CODE,
        Case When DIMENSION_CODE='6131' Then 'Albany, NY'
            When DIMENSION_CODE='6140' Then 'Burlington, VT'
        Else DIMENSION_DESCRIPTION
        End As DIMENSION_DESCRIPTION,
        EXPIRED,
        EXPIRED_DATE,
        CHILD_OBJECT,
        PARENT_OBJECT_SN,
        SWLH_MODEL,
        OBJECT_TYPE,
        FRF_FLAG,
        ACCEPTANCE_DELAY_COMMENTS
    from {{ ref('ODS__TEA93TEL_REPORTING__BAANV_TEA_OBJECTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data