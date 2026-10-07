{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='BLOCKED_INVOICES',
        tags=["finance"],
    	transient=false
) }} 


with bseg as (
    select 
        coalesce(api.BUKRS, gmx.BUKRS) as BUKRS,
        coalesce(api.GJAHR, gmx.GJAHR) as GJAHR,
        coalesce(api.BELNR, gmx.BELNR) as BELNR,
        coalesce(api.BUZEI, gmx.BUZEI) as BUZEI,
        coalesce(api.EBELN,gmx.EBELN) as PO_NUMBER,
        coalesce(api.EBELP,gmx.EBELP) as PO_ITEM,
        SUBSTR(coalesce(api.AWKEY,gmx.AWKEY ),0,10) as INVOICE_DOC,
        SUBSTR(coalesce(api.AWKEY,gmx.AWKEY ),11,4) as Invoice_year,
        coalesce(api.LIFNR,gmx.LIFNR) as SUPPLIER_CODE,
        case 
            when gmx._FILEDATE > ifnull(api._FILEDATE, '1970-01-01') then gmx.ZLSPR 
            else api.ZLSPR
        end as ZLSPR
    from {{ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU038_BSEG')}} api
    full join {{ref('BRONZE__TEH_PROCUREMENT__SAPH_SAP_US_FIT_EV_BSEG')}} as gmx on
        try_to_number(api.BUKRS) = gmx.BUKRS and
        try_to_number(api.GJAHR) = gmx.GJAHR and
        try_to_number(api.BELNR) = gmx.BELNR and
        try_to_number(api.BUZEI) = gmx.BUZEI
  where api.KOART in ( 'K')
), 
source_data as (
    select 
    PO_NUMBER,
    PO_ITEM, 
    INVOICE_DOC, 
    INVOICE_YEAR,
    ZLSPR AS BLOCK_IND,
    case -- using manual case statements until SAP text table is ingested
                when ifnull(bseg.ZLSPR,'')='' then 'Free for payment'
                when bseg.ZLSPR='*' then 'Skip account'
                when bseg.ZLSPR='A' then 'Locked for payment'
                when bseg.ZLSPR='B' then 'Acct acceptce before'
                when bseg.ZLSPR='E' then 'Urgent Payment'
                when bseg.ZLSPR='I' then 'CML:InvestorContract'
                when bseg.ZLSPR='N' then 'Postprocess inc.pmnt'
                when bseg.ZLSPR='P' then 'Payment request'
                when bseg.ZLSPR='R' then 'Invoice verification'
                when bseg.ZLSPR='T' then 'Before technical ins'
                when bseg.ZLSPR='V' then 'Payment clearing'
                when bseg.ZLSPR='X' then 'Targeted receivables'
                when bseg.ZLSPR='Y' then 'Inspection ammt diff'
                else null
    end as BLOCK_DESC,
    bseg.supplier_code as supplier_code,
    name_org_1 as supplier_name
    from bseg
    left join {{ref('GOLD__TEH_PROCUREMENT__VENDOR_MASTER')}} v on 
    v.business_partner = bseg.supplier_code
    where   left(PO_NUMBER, 2) in ('PO', 'EP')
    and   BLOCK_DESC != 'Free for payment'
),
transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        po_number as purchase_order_number,
        po_item as purchase_order_line_item_number,
        INVOICE_DOC,
        INVOICE_YEAR,
        BLOCK_IND,
        BLOCK_DESC,
        SUPPLIER_CODE,
        SUPPLIER_NAME
    from source_data
)
select * from transform_data
