{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='ORDER_PROCESS_TRACKING_QUOTE',
    unique_key=[],
    transient=false    
) }} 


WITH source_data AS (
    select 
       ID,
       RFTQ_NO,
       QUOTE_NO,
       QUOTE_LINE_ITEM_NO,
       FACTORY_QUOTE_NO,
       INQUIRY_RECEIVED,
       RFTQ_SUBMITTED,
       FACTORY_QUOTE_REQUESTED,
       FACTORY_QUOTE_RECEIVED,
       QUOTE_SUBMITTED,
       QUOTE_APPROVED1,
       TEA_QUOTE_APPROVED1,
       TEA_QUOTE_APPROVED2,
       TEA_QUOTE_APPROVED3,
       TEA_QUOTE_APPROVED4,
       QUOTE_APPROVED_FINAL,
       QUOTE_ISSUED,
       QUOTE_NEEDED_BY,
       QUOTE_PRIORITY,
       ORIGINAL_RFTQ_NO,
       RFTQ_REVISION_VERSION,
       ORIGINAL_QUOTE_NO,
       QUOTE_REVISION_VERSION,
       IS_DATE_REFRESH_ONLY,
       END_USER_ADDRESS,
       END_USER_ZIP_CODE,
       CUSTOMER_NAME,
       QUOTE_CURRENCY,
       QUOTE_AMOUNT_JPY,
       QUOTE_AMOUNT_USD,
       PRODUCT_LEAD_TIME,
       QUOTE_PAYMENT_TERMS,
       SERIAL_NO,
       CUSTOMER_TOOL_ID,
       QUOTE_COMMENT,
       IS_ACTIVE_OPT_QUOTE,
       CREATED_BY_OPT_QUOTE,
       CREATED_DATETIME_OPT_QUOTE,
       UPDATED_BY_OPT_QUOTE,
       UPDATED_DATETIME_OPT_QUOTE,
       RFTQ_INITIATOR,
       QUOTE_APPROVED_BY1,
       QUOTE_APPROVED_BY_FINAL,
       QUOTE_APPROVAL_INITIATED_BY,
       IS_RFTQ,
       IS_INQUIRY
FROM  {{ ref('BRONZE__TEH_EQUIPMENT_SALES__OPT_ORDER_PROCESS_TRACKING') }}
),
transform_data AS (
       SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        To_varchar(opt.id)                       AS ID,
        -- trim(opt.TITLE)                            as QUOTE_KEY,
        -- initcap(trim(opt.OPPORTUNITY_ID))          as OPPORTUNITY_ID,
        -- initcap(trim(opt.ORIGINAL_OPPORTUNITY_ID)) as ORIGINAL_OPPORTUNITY_ID,
        -- opt.STATUS,
        -- to_date(case when opt.RECORD_CLOSED = '1/1/1900' then null
        --             else opt.RECORD_CLOSED
        --         end)                               as RECORD_CLOSED,
        -- opt.SALES_ORGANIZATION,
        -- opt.BUSINESS_ENTITY,
        -- opt.SALES_ACCOUNT,
        -- opt.END_USER,
        -- opt.FAB,
        -- opt.SUB_BU,
        -- opt.SALES_CATEGORY,
        -- nullif(opt.QUOTE_TITLE, '')                 as QUOTE_TITLE,
        NULLIF(opt.rftq_no, '')                  AS RFTQ_NO,
        NULLIF(Trim(opt.quote_no), '')           AS QUOTE_NO,
        NULLIF(Trim(opt.quote_line_item_no), '') AS QUOTE_LINE_ITEM_NO,
        NULLIF(Trim(opt.factory_quote_no), '')   AS FACTORY_QUOTE_NO,
        To_date(CASE
                  WHEN opt.inquiry_received = '1/1/1900' THEN NULL
                  ELSE opt.inquiry_received
                END)                             AS INQUIRY_RECEIVED,
        To_date(CASE
                  WHEN opt.rftq_submitted = '1/1/1900' THEN NULL
                  ELSE opt.rftq_submitted
                END)                             AS RFTQ_SUBMITTED,
        To_date(CASE
                  WHEN opt.factory_quote_requested = '1/1/1900' THEN NULL
                  ELSE opt.factory_quote_requested
                END)                             AS FACTORY_QUOTE_REQUESTED,
        To_date(CASE
                  WHEN opt.factory_quote_received = '1/1/1900' THEN NULL
                  ELSE opt.factory_quote_received
                END)                             AS FACTORY_QUOTE_RECEIVED,
        To_date(CASE
                  WHEN opt.quote_submitted = '1/1/1900' THEN NULL
                  ELSE opt.quote_submitted
                END)                             AS QUOTE_SUBMITTED,
        To_date(CASE
                  WHEN opt.quote_approved1 = '1/1/1900' THEN NULL
                  ELSE opt.quote_approved1
                END)                             AS QUOTE_APPROVED1,
        To_date(CASE
                  WHEN opt.tea_quote_approved1 = '1/1/1900' THEN NULL
                  ELSE opt.tea_quote_approved1
                END)                             AS TEA_QUOTE_APPROVED1,
        To_date(CASE
                  WHEN opt.tea_quote_approved2 = '1/1/1900' THEN NULL
                  ELSE opt.tea_quote_approved2
                END)                             AS TEA_QUOTE_APPROVED2,
        To_date(CASE
                  WHEN opt.tea_quote_approved3 = '1/1/1900' THEN NULL
                  ELSE opt.tea_quote_approved3
                END)                             AS TEA_QUOTE_APPROVED3,
        To_date(CASE
                  WHEN opt.tea_quote_approved4 = '1/1/1900' THEN NULL
                  ELSE opt.tea_quote_approved4
                END)                             AS TEA_QUOTE_APPROVED4,
        To_date(CASE
                  WHEN opt.quote_approved_final = '1/1/1900' THEN NULL
                  ELSE opt.quote_approved_final
                END)                             AS QUOTE_APPROVED_FINAL,
        To_date(CASE
                  WHEN opt.quote_issued = '1/1/1900' THEN NULL
                  ELSE opt.quote_issued
                END)                             AS QUOTE_ISSUED,
        To_date(CASE
                  WHEN opt.quote_needed_by = '1/1/1900' THEN NULL
                  ELSE opt.quote_needed_by
                END)                             AS QUOTE_NEEDED_BY,
        NULLIF(opt.quote_priority, '')           AS QUOTE_PRIORITY,
        NULLIF(opt.original_rftq_no, '')         AS ORIGINAL_RFTQ_NO,
        opt.rftq_revision_version,
        NULLIF(Trim(opt.original_quote_no), '')  AS ORIGINAL_QUOTE_NO,
        opt.quote_revision_version,
        opt.is_date_refresh_only,
        NULLIF(opt.end_user_address, '')         AS END_USER_ADDRESS,
        NULLIF(opt.end_user_zip_code, '')        AS END_USER_ZIP_CODE,
        NULLIF(opt.customer_name, '')            AS CUSTOMER_NAME,
        NULLIF(opt.quote_currency, '')           AS QUOTE_CURRENCY,
        To_number(opt.quote_amount_jpy, 38, 0)   AS QUOTE_AMOUNT_JPY,
        To_decimal(opt.quote_amount_usd, 38, 2)  AS QUOTE_AMOUNT_USD,
        NULLIF(opt.product_lead_time, '')        AS PRODUCT_LEAD_TIME,
        NULLIF(opt.quote_payment_terms, '')      AS QUOTE_PAYMENT_TERMS,
        NULLIF(opt.serial_no, '')                AS SERIAL_NO,
        NULLIF(opt.customer_tool_id, '')         AS CUSTOMER_TOOL_ID,
        NULLIF(opt.quote_comment, '')            AS QUOTE_COMMENT,
        is_active_opt_quote,
        created_by_opt_quote,
        To_timestamp(CASE
                       WHEN opt.created_datetime_opt_quote =
                            '1900-01-01 00:00:00.000'
                     THEN NULL
                       ELSE opt.created_datetime_opt_quote
                     END)                        AS CREATED_DATETIME_OPT_QUOTE,
        updated_by_opt_quote,
        To_timestamp(CASE
                       WHEN opt.updated_datetime_opt_quote =
                            '1900-01-01 00:00:00.000'
                     THEN NULL
                       ELSE opt.updated_datetime_opt_quote
                     END)                        AS UPDATED_DATETIME_OPT_QUOTE,
        rftq_initiator,
        quote_approved_by1,
        quote_approved_by_final,
        quote_approval_initiated_by,
        is_rftq,
        is_inquiry
       FROM source_data opt
),
type_data AS (
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ID,
        RFTQ_NO,
        QUOTE_NO,
        QUOTE_LINE_ITEM_NO,
        FACTORY_QUOTE_NO,
        INQUIRY_RECEIVED,
        RFTQ_SUBMITTED,
        FACTORY_QUOTE_REQUESTED,
        FACTORY_QUOTE_RECEIVED,
        QUOTE_SUBMITTED,
        QUOTE_APPROVED1,
        TEA_QUOTE_APPROVED1,
        TEA_QUOTE_APPROVED2,
        TEA_QUOTE_APPROVED3,
        TEA_QUOTE_APPROVED4,
        QUOTE_APPROVED_FINAL,
        QUOTE_ISSUED,
        QUOTE_NEEDED_BY,
        QUOTE_PRIORITY,
        ORIGINAL_RFTQ_NO,
        RFTQ_REVISION_VERSION,
        ORIGINAL_QUOTE_NO,
        QUOTE_REVISION_VERSION,
        IS_DATE_REFRESH_ONLY,
        END_USER_ADDRESS,
        END_USER_ZIP_CODE,
        CUSTOMER_NAME,
        QUOTE_CURRENCY,
        QUOTE_AMOUNT_JPY,
        QUOTE_AMOUNT_USD,
        PRODUCT_LEAD_TIME,
        QUOTE_PAYMENT_TERMS,
        SERIAL_NO,
        CUSTOMER_TOOL_ID,
        QUOTE_COMMENT,
        IS_ACTIVE_OPT_QUOTE,
        CREATED_BY_OPT_QUOTE,
        CREATED_DATETIME_OPT_QUOTE,
        UPDATED_BY_OPT_QUOTE,
        UPDATED_DATETIME_OPT_QUOTE,
        RFTQ_INITIATOR,
        QUOTE_APPROVED_BY1,
        QUOTE_APPROVED_BY_FINAL,
        QUOTE_APPROVAL_INITIATED_BY,
        IS_RFTQ,
        IS_INQUIRY
FROM transform_data
)
SELECT * FROM type_data