{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='ORDER_PROCESS_TRACKING_ORDER',
    unique_key=[],
    transient=false    
) }} 


WITH source_data AS (
    select 
       ID,
       TITLE,
       PO_NO,
       PO_LINE_ITEM_NO,
       PO_RECEIVED,
       POC_ISSUED,
       CO_RECEIVED,
       REQUESTED_DELIVERY_DATE,
       PO_CURRENCY,
       PO_AMOUNT,
       PO_INCOTERMS,
       PO_PAYMENTTERMS,
       POC_COMMENT,
       OA_NO,
       OA_SUBMITTED,
       OA_APPROVED,
       POD_RECEIVED,
       IS_ACTIVE_OPT_PO,
       CREATED_BY_OPT_PO,
       CREATED_DATETIME_OPT_PO,
       UPDATED_BY_OPT_PO,
       UPDATED_DATETIME_OPT_PO,
       PO_REVIEWED_BY,
       OA_APPROVAL_INITIATED_BY,
       OA_APPROVED_BY
    FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__OPT_ORDER_PROCESS_TRACKING') }}
),
transform_data AS (
    SELECT 
       '{{ invocation_id }}' AS _AUDIT_LOG_ID,
       SHA2('hash_me') AS _ROW_HASH,
       To_varchar(opt.id)                    AS ID,
       -- trim(opt.TITLE)                                     as QUOTE_KEY,
       NULLIF(Trim(opt.po_no), '')           AS PO_NO,
       NULLIF(Trim(opt.po_line_item_no), '') AS PO_LINE_ITEM_NO,
       -- case when nullif(trim(opt.PO_LINE_ITEM_NO), '') is null then PO_NO
       --     else concat(nullif(trim(opt.PO_NO), ''), ' Line Item', nullif(trim(opt.PO_LINE_ITEM_NO), ''))
       -- end                                                 as PO_KEY,
       -- opt.IS_SPLIT_QUOTE,
       -- opt.DUPLICATE_QUOTE_VERSION,
       To_date(CASE
                 WHEN po_received = '1/1/1900' THEN NULL
                 ELSE opt.po_received
               END)                          AS PO_RECEIVED,
       To_date(CASE
                 WHEN opt.poc_issued = '1/1/1900' THEN NULL
                 ELSE opt.poc_issued
               END)                          AS POC_ISSUED,
       To_date(CASE
                 WHEN opt.co_received = '1/1/1900' THEN NULL
                 ELSE opt.co_received
               END)                          AS CO_RECEIVED,
       To_date(CASE
                 WHEN opt.requested_delivery_date = '1/1/1900' THEN NULL
                 ELSE opt.requested_delivery_date
               END)                          AS REQUESTED_DELIVERY_DATE,
       NULLIF(opt.po_currency, '')           AS PO_CURRENCY,
       To_decimal(opt.po_amount, 38, 2)      AS PO_AMOUNT,
       NULLIF(opt.po_incoterms, '')          AS PO_INCOTERMS,
       NULLIF(opt.po_paymentterms, '')       AS PO_PAYMENT_TERMS,
       NULLIF(opt.poc_comment, '')           AS POC_COMMENT,
       NULLIF(opt.oa_no, '')                 AS OA_NO,
       To_date(CASE
                 WHEN opt.oa_submitted = '1/1/1900' THEN NULL
                 ELSE opt.oa_submitted
               END)                          AS OA_SUBMITTED,
       To_date(CASE
                 WHEN opt.oa_approved = '1/1/1900' THEN NULL
                 ELSE opt.oa_approved
               END)                          AS OA_APPROVED,
       To_date(CASE
                 WHEN opt.pod_received = '1/1/1900' THEN NULL
                 ELSE opt.pod_received
               END)                          AS POD_RECEIVED,
       is_active_opt_po,
       created_by_opt_po,
       To_timestamp(CASE
                      WHEN opt.created_datetime_opt_po =
                           '1900-01-01 00:00:00.000' THEN
                      NULL
                      ELSE opt.created_datetime_opt_po
                    END)                     AS CREATED_DATETIME_OPT_PO,
       updated_by_opt_po,
       To_timestamp(CASE
                      WHEN opt.updated_datetime_opt_po =
                           '1900-01-01 00:00:00.000' THEN
                      NULL
                      ELSE opt.updated_datetime_opt_po
                    END)                     AS UPDATED_DATETIME_OPT_PO,
       po_reviewed_by,
       oa_approval_initiated_by,
       oa_approved_by
    FROM source_data opt
),
type_data AS (
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ID,
	 PO_NO,
	 PO_LINE_ITEM_NO,
	 PO_RECEIVED,
	 POC_ISSUED,
	 CO_RECEIVED,
	 REQUESTED_DELIVERY_DATE,
	 PO_CURRENCY,
	 PO_AMOUNT,
	 PO_INCOTERMS,
	 PO_PAYMENT_TERMS,
	 POC_COMMENT,
	 OA_NO,
	 OA_SUBMITTED,
	 OA_APPROVED,
	 POD_RECEIVED,
	 IS_ACTIVE_OPT_PO,
	 CREATED_BY_OPT_PO,
	 CREATED_DATETIME_OPT_PO,
	 UPDATED_BY_OPT_PO,
	 UPDATED_DATETIME_OPT_PO,
	 PO_REVIEWED_BY,
	 OA_APPROVAL_INITIATED_BY,
	 OA_APPROVED_BY
FROM transform_data
)
SELECT * FROM type_data