{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='ORDER_PROCESS_TRACKING_OPPORTUNITY',
    unique_key=[],
    transient=false    
) }} 


WITH source_data AS (
    select 
        _FILEDATE,
        ID, 
        OPPORTUNITY_ID, 
        TITLE, 
        PO_LINE_ITEM_NO, 
        PO_NO, 
        ORIGINAL_OPPORTUNITY_ID, 
        STATUS, 
        POD_RECEIVED, 
        OA_APPROVED, 
        CO_RECEIVED,
        OA_SUBMITTED, 
        PO_RECEIVED, 
        QUOTE_ISSUED, 
        QUOTE_APPROVED_FINAL, 
        QUOTE_SUBMITTED, 
        RFTQ_SUBMITTED, 
        QUOTE_NO, 
        RFTQ_NO, 
        SALES_ORGANIZATION, 
        BUSINESS_ENTITY, 
        SALES_ACCOUNT, 
        END_USER, 
        FAB, 
        SUB_BU, 
        SALES_CATEGORY, 
        QUOTE_TITLE, 
        IS_SPLIT_QUOTE, 
        DUPLICATE_QUOTE_VERSION, 
        RECORD_CLOSED, 
        IS_ACTIVE_HEADER, 
        CREATED_DATETIME_HEADER, 
        UPDATED_DATETIME_HEADER,
        TEA_SALES, 
        CREATED_BY_HEADER, 
        UPDATED_BY_HEADER, 
        END_USER_ADDRESS, 
        END_USER_COUNTRY, 
        END_USER_ZIP_CODE
    FROM  {{ ref('BRONZE__TEH_EQUIPMENT_SALES__OPT_ORDER_PROCESS_TRACKING') }}
),
transform_data AS (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
       To_varchar(opt.id) AS id,
       CASE
              WHEN NULLIF(Initcap(Trim(opt.opportunity_id)), '') IS NULL THEN Trim(opt.title)
              ELSE Concat(NULLIF(Initcap(Trim(opt.opportunity_id)), ''), ' ', Trim(opt.title))
       END             AS opt_key,
       Trim(opt.title) AS quote_key,
       CASE
              WHEN NULLIF(Trim(opt.po_line_item_no), '') IS NULL THEN NULLIF(Trim(opt.po_no), '')
              ELSE Concat(NULLIF(Trim(opt.po_no), ''), ' Line Item', NULLIF(Trim(opt.po_line_item_no), ''))
       END                                        AS po_key,
       Initcap(Trim(opt.opportunity_id))          AS opportunity_id,
       Initcap(Trim(opt.original_opportunity_id)) AS original_opportunity_id,
       CASE
              WHEN opt.status ilike 'PO Canceled' THEN 'PO Canceled'
              WHEN opt.status ilike 'PO on Hold' THEN 'PO on Hold'
              WHEN opt.status ilike 'Closed'
              AND    opt.pod_received IS NOT NULL THEN 'POD Received'
              WHEN opt.status ilike 'Closed'
              AND    opt.oa_approved IS NOT NULL
              AND    opt.pod_received IS NULL THEN 'OA Approved'
              WHEN opt.status ilike 'Closed'
              AND    opt.oa_submitted IS NOT NULL
              AND    opt.oa_approved IS NULL THEN 'OA Created'
              WHEN opt.status ilike 'Closed'
              AND    opt.po_received IS NOT NULL
              AND    opt.co_received IS NOT NULL
              AND    opt.oa_submitted IS NULL THEN 'CO Received'
              WHEN opt.status ilike 'Closed'
              AND    opt.po_received IS NOT NULL
              AND    opt.oa_submitted IS NULL THEN 'PO Received'
              WHEN opt.status ilike 'Closed'
              AND    opt.quote_issued IS NOT NULL
              AND    opt.po_received IS NULL THEN 'Quote Issued'
              WHEN opt.status ilike 'Closed'
              AND    opt.quote_approved_final IS NOT NULL
              AND    opt.quote_issued IS NULL THEN 'Quote Approved'
              WHEN opt.status ilike 'Closed'
              AND    opt.quote_submitted IS NOT NULL
              AND    opt.quote_approved_final IS NULL THEN 'Quote Submitted'
              WHEN opt.status ilike 'Closed'
              AND    opt.rftq_submitted IS NOT NULL
              AND    opt.quote_submitted IS NULL THEN 'RFTQ Submitted'
              WHEN opt.status ilike 'Closed'
              AND    opt.quote_no IS NOT NULL
              AND    opt.po_received IS NULL THEN 'Quote Issued'
              WHEN opt.status ilike 'Closed'
              AND    opt.rftq_no IS NOT NULL
              AND    opt.quote_issued IS NULL THEN 'RFTQ Submitted'
              WHEN opt.status ilike 'PO Processed' THEN 'PO Received'
              ELSE opt.status
       END AS status,
       CASE
              WHEN opt.status ilike 'Closed' THEN 'Yes'
              ELSE 'No'
       END AS is_closed,
       -- opt.SALES_DISTRICT,
       opt.sales_organization,
       opt.business_entity,
       opt.sales_account,
       -- opt.SALES_REGION,
       upper(trim(opt.end_user)) AS end_user,
       CASE
              WHEN position('_', opt.fab) = 0 THEN opt.fab
              ELSE split_part(opt.fab, '_', 1)
       END AS fab,
       opt.sub_bu,
       opt.sales_category,
       NULLIF(opt.quote_title, '') AS quote_title,
       opt.is_split_quote,
       opt.duplicate_quote_version,
       NULLIF(to_date(opt.record_closed), '1/1/1900') AS record_closed,
       is_active_header,
       NULLIF(to_timestamp(opt.created_datetime_header), '1900-01-01 00:00:00.000')                                       AS created_datetime_header,
       NULLIF(to_timestamp(opt.updated_datetime_header), '1900-01-01 00:00:00.000')                                       AS updated_datetime_header,
              concat(split_part(NULLIF(opt.tea_sales, ''), ' ', -2), ' ', split_part(NULLIF(opt.tea_sales, ''), ' ', -1)) AS tea_sales,
       created_by_header,
       updated_by_header,
       CASE
              WHEN trim(end_user_address) = 'NanoFab 300 South, 255 Fuller Road, Suite 244' THEN '255 Fuller Road, Suite 244'
              ELSE NULLIF(trim(end_user_address), '')
       END                                                                                  AS end_user_address,
       NULLIF(trim(end_user_country), '')                                                   AS end_user_country,
       NULLIF(trim(end_user_zip_code), '')                                                  AS end_user_zip_code,
       to_varchar(convert_timezone('America/Chicago', opt._filedate), 'YYYY-MM-DD HH24:MI') AS data_snapshot_timestamp,
       to_date(convert_timezone('America/Chicago', opt._filedate))                          AS data_snapshot
    FROM source_data opt
),
type_data AS (
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ID,
	 OPT_KEY,
	 QUOTE_KEY,
	 PO_KEY,
	 OPPORTUNITY_ID,
	 ORIGINAL_OPPORTUNITY_ID,
	 STATUS,
	 IS_CLOSED,
	 SALES_ORGANIZATION,
	 BUSINESS_ENTITY,
	 SALES_ACCOUNT,
	 END_USER,
	 FAB,
	 SUB_BU,
	 SALES_CATEGORY,
	 QUOTE_TITLE,
	 IS_SPLIT_QUOTE,
	 DUPLICATE_QUOTE_VERSION,
	 RECORD_CLOSED,
	 IS_ACTIVE_HEADER,
	 CREATED_DATETIME_HEADER,
	 UPDATED_DATETIME_HEADER,
	 TEA_SALES,
	 CREATED_BY_HEADER,
	 UPDATED_BY_HEADER,
	 END_USER_ADDRESS,
	 END_USER_COUNTRY,
	 END_USER_ZIP_CODE,
	 DATA_SNAPSHOT_TIMESTAMP,
	 DATA_SNAPSHOT
FROM transform_data
)
SELECT * FROM type_data