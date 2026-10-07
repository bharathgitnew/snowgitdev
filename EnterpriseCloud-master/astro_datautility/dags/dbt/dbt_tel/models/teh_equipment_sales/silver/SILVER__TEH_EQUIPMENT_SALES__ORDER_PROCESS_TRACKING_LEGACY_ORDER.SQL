{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='ORDER_PROCESS_TRACKING_LEGACY_ORDER',
    unique_key=[],
    transient=false    
) }} 


WITH source_data AS (
    SELECT
        concat('SP_', opt.SP_OPT_ID)            as ID,
	    -- case when length(split_part(replace(replace(trim(opt.OPPORTUNITY_ID), ' ', ','), '+', ','), ',', 1)) = 0 then trim(opt.TITLE) -- null or empty
	    --     when length(split_part(replace(replace(trim(opt.OPPORTUNITY_ID), ' ', ','), '+', ','), ',', 1)) is null then trim(opt.TITLE)
	    --     else concat(split_part(replace(replace(trim(opt.OPPORTUNITY_ID), ' ', ','), '+', ','), ',', 1), ', ', trim(opt.TITLE))
	    -- end                                     as OPT_KEY,
	    -- trim(opt.TITLE)                         as QUOTE_KEY,
	    nullif(trim(opt.PO_NO), '')             as PO_NO,
	    nullif(trim(opt.PO_LINE_ITEM_NO), '')   as PO_LINE_ITEM_NO,
	    -- case when nullif(trim(opt.PO_LINE_ITEM_NO), '') is null then PO_NO
	    --     else concat(nullif(trim(opt.PO_NO), ''), ' Line Item', nullif(trim(opt.PO_LINE_ITEM_NO), ''))
	    -- end                                     as PO_KEY,
	    -- split_part(replace(replace(trim(opt.OPPORTUNITY_ID), ' ', ','), '+', ','), ',', 1) as OPPORTUNITY_ID,
	    -- replace(replace(trim(opt.OPPORTUNITY_ID), ' ', ','), '+', ',')                     as ORIGINAL_OPPORTUNITY_ID,
	    -- lower(opt.IS_SPLIT_QUOTE)               as IS_SPLIT_QUOTE,
	    -- to_number(opt.DUPLICATE_QUOTE_VERSION)  as DUPLICATE_QUOTE_VERSION,
	    to_date(opt.PO_RECEIVED)                as PO_RECEIVED,
	    to_date(opt.POC_ISSUED)                 as POC_ISSUED,
	    to_date(opt.CO_RECEIVED)                as CO_RECEIVED,
	    null                                    as REQUESTED_DELIVERY_DATE,
	    opt.PO_CURRENCY,
	    to_decimal(opt.PO_AMOUNT, 38, 2)        as PO_AMOUNT,
	    opt.PO_INCOTERMS,
	    opt.PO_PAYMENT_TERMS,
	    opt.POC_COMMENT,
	    opt.OA_NO,
	    to_date(opt.OA_SUBMITTED)               as OA_SUBMITTED,
	    to_date(opt.OA_APPROVED)                as OA_APPROVED,
	    to_date(opt.POD_RECEIVED)               as POD_RECEIVED,
	    null                                    as IS_ACTIVE_OPT_PO,
	    null                                    as CREATED_BY_OPT_PO,
	    null                                    as CREATED_DATETIME_OPT_PO,
	    null                                    as UPDATED_BY_OPT_PO,
	    null                                    as UPDATED_DATETIME_OPT_PO,
	    null                                    as PO_REVIEWED_BY,
	    null                                    as OA_APPROVAL_INITIATED_BY,
	    null                                    as OA_APPROVED_BY
	from {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SHAREPOINT_ORDER_PROCESS_TRACKING_LEGACY') }} opt
	-- where SP_OPT_ID is not null -- 9/11/2025 request IT to check why empty record exists
	--     and PO_KEY is not null
	--     -- and STATUS <> 'Closed'  
),
transform_data AS (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
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
FROM source_data
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