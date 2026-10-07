{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='ORDER_PROCESS_TRACKING_LEGACY_OPPORTUNITY',
    unique_key=[],
    transient=false    
) }} 


WITH source_data AS (
    SELECT
        concat('SP_', opt.SP_OPT_ID)        as ID,
        case when length(trim(split_part(replace(replace(opt.OPPORTUNITY_ID, ' ', ','), '+', ','), ',', 1))) = 0 then trim(opt.TITLE) -- null or empty
            when length(trim(split_part(replace(replace(opt.OPPORTUNITY_ID, ' ', ','), '+', ','), ',', 1))) is null then trim(opt.TITLE)
            else concat(trim(split_part(replace(replace(opt.OPPORTUNITY_ID, ' ', ','), '+', ','), ',', 1)), ', ', trim(opt.TITLE))
        end                                 as OPT_KEY,
        trim(opt.TITLE)                     as QUOTE_KEY,
        case when nullif(trim(opt.PO_LINE_ITEM_NO), '') is null then nullif(trim(opt.PO_NO), '')
            else concat(nullif(trim(opt.PO_NO), ''), ' Line Item', nullif(trim(opt.PO_LINE_ITEM_NO), ''))
        end                                 as PO_KEY,
        trim(split_part(replace(replace(opt.OPPORTUNITY_ID, ' ', ','), '+', ','), ',', 1)) as OPPORTUNITY_ID,
        OPPORTUNITY_ID                                                                     as ORIGINAL_OPPORTUNITY_ID,
        case when opt.STATUS ilike 'PO Canceled' then 'PO Canceled'
            when opt.STATUS ilike 'PO on Hold' then 'PO on Hold'
            when opt.STATUS ilike 'Closed' 
                and opt.POD_RECEIVED is not null then 'POD Received'
            when opt.STATUS ilike 'Closed' 
                and opt.OA_APPROVED is not null 
                and opt.POD_RECEIVED is null then 'OA Approved'
            when opt.STATUS ilike 'Closed' 
                and opt.OA_SUBMITTED is not null 
                and opt.OA_APPROVED is null then 'OA Created'
            when opt.STATUS ilike 'Closed' 
                and opt.PO_RECEIVED is not null 
                and opt.CO_RECEIVED is not null 
                and opt.OA_SUBMITTED is null then 'CO Received'
            when opt.STATUS ilike 'Closed' 
                and opt.PO_RECEIVED is not null 
                and opt.OA_SUBMITTED is null then 'PO Received'
            when opt.STATUS ilike 'Closed' 
                and opt.QUOTE_ISSUED is not null 
                and opt.PO_RECEIVED is null then 'Quote Issued'
            when opt.STATUS ilike 'Closed' 
                and opt.QUOTE_APPROVED_FINAL is not null 
                and opt.QUOTE_ISSUED is null then 'Quote Approved'
            when opt.STATUS ilike 'Closed' 
                and opt.QUOTE_SUBMITTED is not null 
                and opt.QUOTE_APPROVED_FINAL is null then 'Quote Submitted'
            when opt.STATUS ilike 'Closed' 
                and opt.RFTQ_SUBMITTED is not null 
                and opt.QUOTE_SUBMITTED is null then 'RFTQ Submitted'
            when opt.STATUS ilike 'Closed' 
                and opt.QUOTE_NO is not null 
                and opt.PO_RECEIVED is null then 'Quote Issued'
            when opt.STATUS ilike 'Closed' 
                and opt.RFTQ_NO is not null 
                and opt.QUOTE_ISSUED is null then 'RFTQ Submitted'
            when opt.STATUS ilike 'PO Processed' then 'PO Received'
            else opt.STATUS
        end                                     as STATUS,
        case when opt.STATUS ilike 'Closed' then 'Yes'
            else 'No'
        end                                     as IS_CLOSED,
        opt.SALES_DISTRICT,
        opt.SALES_ORGANIZATION,
        opt.BUSINESS_ENTITY,
        case when opt.SALES_ACCOUNT ilike 'intel_cue' then 'Intel'
            when opt.SALES_ACCOUNT ilike 'GF/IBM' 
                and opt.END_USER ilike any ('GF', 'GLOBALFOUND%') then 'GF'
            when opt.SALES_ACCOUNT ilike 'GF/IBM' 
                and not opt.END_USER ilike any ('GF', 'GLOBALFOUND%') then 'IBM'
            else opt.SALES_ACCOUNT 
        end                                     as SALES_ACCOUNT,
        opt.SALES_REGION,
        opt.END_USER,
        opt.FAB,
        replace(opt.SUB_BU, '/', '_')           as SUB_BU,
        opt.SALES_CATEGORY,
        opt.QUOTE_TITLE,
        lower(opt.IS_SPLIT_QUOTE)               as IS_SPLIT_QUOTE,
        to_number(opt.DUPLICATE_QUOTE_VERSION)  as DUPLICATE_QUOTE_VERSION,
        null                                    as RECORD_CLOSED,
        null                                    as IS_ACTIVE_HEADER,
        to_timestamp(opt.CREATED)               as CREATED_DATETIME_HEADER,
        to_timestamp(opt.MODIFIED)              as UPDATED_DATETIME_HEADER,
        concat(substr(case when TEA_SALES ilike '%Gianmarco' then 'Nick Giamarco' 
                            else TEA_SALES 
                      end, 
                regexp_instr(TEA_SALES,' ',2,1,1)), ', ', trim(left(TEA_SALES, regexp_instr(TEA_SALES,' ',1,1,0)))
              )                                 as TEA_SALES,
        substr(opt.CREATED_BY, regexp_instr(opt.CREATED_BY,' ',1,2,1))   as CREATED_BY_HEADER,
        substr(opt.MODIFIED_BY, regexp_instr(opt.MODIFIED_BY,' ',1,2,1)) as UPDATED_BY_HEADER,
        null                                    as END_USER_ADDRESS,
        null                                    as END_USER_COUNTRY,
        null                                    as END_USER_ZIP_CODE,
        to_timestamp_ntz('2024-10-19 00:00:00.000 -0600') as DATA_SNAPSHOT_TIMESTAMP,
        --to_varchar(convert_timezone('America/Chicago', opt._FILEDATE), 'YYYY-MM-DD HH24:MI') as DATA_SNAPSHOT_TIMESTAMP,
        to_date('10/19/2024')                             as DATA_SNAPSHOT
    from {{ ref('BRONZE__TEH_EQUIPMENT_SALES__SHAREPOINT_ORDER_PROCESS_TRACKING_LEGACY') }} opt
    -- where SP_OPT_ID is not null  -- 9/11/2025 request IT to check why empty record exists
),
transform_data AS (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        ID,
	    OPT_KEY,
	    QUOTE_KEY,
	    PO_KEY,
	    OPPORTUNITY_ID,
	    ORIGINAL_OPPORTUNITY_ID,
	    STATUS,
	    IS_CLOSED,
	    SALES_DISTRICT,
	    SALES_ORGANIZATION,
	    BUSINESS_ENTITY,
	    SALES_ACCOUNT,
	    SALES_REGION,
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
FROM source_data
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
	    SALES_DISTRICT,
	    SALES_ORGANIZATION,
	    BUSINESS_ENTITY,
	    SALES_ACCOUNT,
	    SALES_REGION,
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