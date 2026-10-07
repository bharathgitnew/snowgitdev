{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_CUSTOMER_ACTION_REQUEST'
) }}

with source_data as
(
    select
        arf.REQUEST_NUMBER                                  as REQUEST_NO,
        arf.REV                                             as REVISION_NO,
        arf.REQUEST_NUMBER || '-' || lpad(arf.REV, 2, '0')  as ARF_KEY,
        arf.EQUIPMENT_QUOTE_TEL_QUOTE_ID,
        UPPER(arf.STATUS)                                   as ARF_STATUS,
        upper(arf.ARF_TYPE)								    as ARF_TYPE,
        -- upper(SPECIFIC_REQUEST_TYPE)				as REQUEST_TYPE,
        upper(arf.COMPANY)								    as END_USER,
        coalesce(upper(arf.FAB), upper(arf.FABS))			as FAB,
        upper(arf.CATEGORY)							        as CATEGORY,
        arf.NODES										    as NODE,
        arf.PRODUCT_LINE,
        arf.MODEL,
        arf.REQUEST_DATE                                    as ARF_ORIGINAL_REQUESTED,
        arf.PUBLISH_DATE_REGION				                as ARF_PUBLISHED,
        REQUEST_REVISION_DATE                               as ARF_REVISION_REQUESTED,
        REVISE_DATE_REGION                                  as ARF_REVISED,
        arf.REVERTED_DATE                                   as ARF_REVERTED,
        arf.APPROVAL_DATE_REGION				            as ARF_APPROVED,
        arf.CANCEL_DATE						                as ARF_CANCELED,
        arf.ON_HOLD_DATE                                    as ARF_PUT_ON_HOLD,
        arf.RELEASE_FROM_HOLD_DATE                          as ARF_RELEASED_FROM_HOLD,
        arf.DESCRIPTION,
        upper(arf.REFERENCE_1)							    as TEL_REFERENCE,
        arf.TEL_COMMENT,
        arf.BIS_CUSTOMER_CODE							    as END_USER_CODE,
        arf.ACTIVE                                          as IS_ACTIVE
    from {{ref('BRONZE__TEH_EQUIPMENT_SALES__TELCUSTOMER_TELCUST_ARF_QRF_DATA')}} arf
    where arf.REQTYPE ilike 'ARF'
),
transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        REQUEST_NO,
	    REVISION_NO,
	    ARF_KEY,
	    EQUIPMENT_QUOTE_TEL_QUOTE_ID,
	    ARF_STATUS,
	    ARF_TYPE,
	    END_USER,
	    FAB,
	    CATEGORY,
	    NODE,
	    PRODUCT_LINE,
	    MODEL,
	    ARF_ORIGINAL_REQUESTED,
	    ARF_PUBLISHED,
	    ARF_REVISION_REQUESTED,
	    ARF_REVISED,
	    ARF_REVERTED,
	    ARF_APPROVED,
	    ARF_CANCELED,
	    ARF_PUT_ON_HOLD,
	    ARF_RELEASED_FROM_HOLD,
	    DESCRIPTION,
	    TEL_REFERENCE,
	    TEL_COMMENT,
	    END_USER_CODE,
	    IS_ACTIVE
    from source_data
) ,
type_data as
(
SELECT
    cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
    cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
    REQUEST_NO,
	REVISION_NO,
	ARF_KEY,
	EQUIPMENT_QUOTE_TEL_QUOTE_ID,
	ARF_STATUS,
	ARF_TYPE,
	END_USER,
	FAB,
	CATEGORY,
	NODE,
	PRODUCT_LINE,
	MODEL,
	ARF_ORIGINAL_REQUESTED,
	ARF_PUBLISHED,
	ARF_REVISION_REQUESTED,
	ARF_REVISED,
	ARF_REVERTED,
	ARF_APPROVED,
	ARF_CANCELED,
	ARF_PUT_ON_HOLD,
	ARF_RELEASED_FROM_HOLD,
	DESCRIPTION,
	TEL_REFERENCE,
	TEL_COMMENT,
	END_USER_CODE,
	IS_ACTIVE
from transform_data 
)
select * from type_data