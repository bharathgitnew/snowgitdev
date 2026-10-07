/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.06"
*************/

{{ config(
      materialized='view',
      alias='PURCHASE_ORDER_CHANGE_ORDER',
      transient=false
) }}

with source_data as (
    SELECT
        PURCHASE_ORDER_LINE_ID,
        PURCHASE_ORDER_NUMBER,
        PURCHASE_ORDER_LINE_NUMBER,
        REVISION_NUMBER,
        REVISION_DESC_ORDER,
        ITEM_NUMBER,
        QUOTE_NUMBER,
        RECORD_TYPE_SHORT_TEXT,
        RECORD_TYPE,
        PURCHASE_ORDER_TIMESTAMP,
        LOAD_TIMESTAMP,
        REVISION_TIMESTAMP,
        PURCHASE_ORDER_TYPE,
        PURCHASE_TYPE,
        NET_TERMS_DAYS,
        PERCENT_DUE,
        REQUESTED_QTY,
        UNIT_OF_MEASURE,
        FREIGHT_ON_BOARD,
        INCO_TERM,
        CURRENCY,
        REQUESTED_UNIT_PRICE,
        LINE_AMOUNT,
        TOTAL_AMOUNT,
        TAX_EXEMPT,
        TAX_EXEMPT_CODE,
        CUSTOMER_ITEM_NUMBER,
        ACCOUNT_NUMBER,
        QUOTE_ID,
        ITEM_DESCRIPTION,
        QRF_QUOTE_ID,
        COMMENTS,
        COMMENTS_FILTERED,
        PURCHASE_ORDER_LINE_STATUS,
        HEADER_PROV_STATUS,
        OVERALL_STATUS,
        LINE_PROV_STATUS,
        TEL_LINE_STATUS,
        HEADER_REASON,
        LINE_REASON,
        BUSINESS_UNIT,
        CATEGORY_SHORT_TEXT,
        CATEGORY,
        SITE,
        MODEL,
        COPY_EXACT_ID,
        ENTITY,
        PROCESS,
        SHIPPING_TO_NAME,
        SHIPPING_SERVICE_LEVEL_CODE,
        SHIP_TO_COUNTRY,
        SHIP_TO_REGION,
        SHIP_TO_CITY,
        SHIPPING_CONDITION,
        SHIP_TO_ADDRESS,
        SPECIAL_HANDLING_INSTRUCTION,
        BILL_TO_NAME,
        BILL_TO_COUNTRY,
        BILL_TO_REGION,
        BILL_TO_CITY,
        BILL_TO_LOCATION_ID,
        BILL_TO_ADDRESS,
        PURCHASE_ORDER_ACCEPTANCE_DATETIME,
        PURCHASE_ORDER_ACCEPTANCE_DATE,
        PURCHASE_ORDER_ACCEPTANCE_REVISION_NUMBER,
        IS_PART_ORDER,
        TEL_HEADER_STATUS,
        REQUESTED_TENDER_DATE,
        ORIGINAL_BUSINESS_UNIT,
        SUB_BUSINESS_UNIT,
        PURCHASE_ORDER_REV_ACTION_TIMESTAMP,
        REQUESTED_DATE,
        NET_TERMS_DAYS2,
        PERCENT_DUE2
    from {{ ref('COMMON__TELCUSTOMER__PURCHASE_ORDER_CHANGE_ORDER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data