{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='TEL_SALES_CRM_ACCOUNT_BOOKING_EXPECTED',
      transient=false
) }}

with source_data as
(
    SELECT *
    FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_EXPECTED_ACTUAL') }}
    UNION ALL
    SELECT *
    FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_EXPECTED_PENDING_WO_PO') }}
	UNION ALL
    SELECT *
    FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__SALES_CRM_ACCOUNT_BOOKING_EXPECTED_PENDING_W_PO') }}
)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_ACCOUNT,
        SALES_REGION,
        SOLD_TO_PARTY,
        END_USER,
        FAB,
        BU,
        BU_GROUP,
        SUB_BU,
        OPPORTUNITY_ID,
        PROJECT_NO,
        SALES_ORDER_NO,
        SALES_CATEGORY_GROUP,
        SALES_CATEGORY,
        MODEL,
        PRODUCT_NAME,
        OPPORTUNITY_TITLE_FREE_TEXT,
        SALES_REPORTING_FLAG,
        IS_PLACEHOLDER,
        CONFIDENCE,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUANTITY,
        IS_LOANER,
        LOAN_EXPIRATION_DATE,
        VPA,
        BOOKING_DATE,
        ACTUAL_BOOKING_DATE,
        IS_BOOKING_ACTUAL,
        BOOKING_SALES_STATUS,
        BOOKING_STATUS,
        BOOKING_AMOUNT,
        BOOKING_AMOUNT_CALCULATED,
        PO_NO,
        QUOTE_NO,
        BU_SALES_PERSON,
        ACCOUNT_SALES_PERSON,
        BU_COMMENTS,
        ACCOUNT_COMMENTS,
        SALES_COMMENTS_TO_SAP,
        ASSISTANTS_COMMENTS_FROM_SAP,
        BOOKING_FY,
        BOOKING_FY_HALF,
        BOOKING_FY_Q,
        BEGINNING_OF_BOOKING_FY_Q,
        END_OF_BOOKING_FY_Q,
        BEGINNING_OF_CURRENT_FY,
        END_OF_CURRENT_FY,
        BEGINNING_OF_CURRENT_FY_HALF,
        END_OF_CURRENT_FY_HALF,
        BEGINNING_OF_CURRENT_FY_Q,
        END_OF_CURRENT_FY_Q,
        BOOKING_FORECAST_FK_DATE,
        END_USER_CODE,
        DATA_SOURCE,
        GS_DATA_SNAPSHOT,
        CRM_DATA_SNAPSHOT,
        CRM_DATA_SNAPSHOT_TIMESTAMP
FROM source_data
) --COMMENT='Created 11/3/2022 Masami Hollingsworth'

select * from transform_data