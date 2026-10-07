{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='PURCHASE_ORDER_BASE',
        tags=["finance"],
    	transient=false
) }} 

with source_data as (
    SELECT DISTINCT
    ARIBA_PURCHASING_DOCUMENT_NUMBER AS PO_NUMBER,
    ARIBA_ITEM_NUMBER_OF_PURCHASING_DOCUMENT AS PO_LINE_NUMBER,
    ARIBA_SHORTTEXT,
    ARIBA_GR_AMT,
    ARIBA_INV_AMT,
    ARIBA_NET_ORDER_VALUE_IN_PO_CURRENCY,
    coalesce(P.COSTCENTERCODE, asset_s.kostl) as costcentercode,
    P.COSTCENTERDESCRIPTION,
    P.ASSETCODE AS "FIXED_ASSET_NUMBER", 
    p.GENERALLEDGERCODE AS GL_ACCOUNT_NUMBER
FROM {{ref('GOLD__TEH_PROCUREMENT__RECEIPTS_COMPARISON_ARIBA_S4')}} S
JOIN {{ref('SILVER__TEH_PROCUREMENT__PURCHASEORDER_SPLITACCOUNTING')}} P 
ON P.PURCHASEORDERIDKEY = S.ARIBA_PURCHASING_DOCUMENT_NUMBER 
and purchaseorderlineitemkey= s.ARIBA_ITEM_NUMBER_OF_PURCHASING_DOCUMENT
left join (select ANLN1, KOSTL from {{ref('BRONZE__TEH_PROCUREMENT__SAPH_SAP_AAM_EV_ANLZ_GMX')}} ) asset_s
on p.assetcode = asset_s.anln1
),
transform_data as (
    select 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        *
    from source_data
)
select * from transform_data