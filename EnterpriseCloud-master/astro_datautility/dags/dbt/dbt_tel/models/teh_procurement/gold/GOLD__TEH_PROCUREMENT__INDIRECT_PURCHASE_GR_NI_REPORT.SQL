{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='INDIRECT_PURCHASE_GR_NI_REPORT',
        tags=["finance"],
    	transient=false
) }} 

with ekbe as (
    select 
        ebeln,
        ebelp,
        MIN(CASE WHEN VGABE ='1' THEN BUDAT END ) AS PO_RECEIVED_DATE,
        MIN(CASE WHEN VGABE ='2' THEN BUDAT END ) AS PO_INVOICED_DATE
    from {{ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU217_EKBE')}}
    group by all
),
source_data as (
    select 
    ariba_purchasing_document_number as PURCHASE_ORDER_NUMBER,
    ARIBA_ITEM_NUMBER_OF_PURCHASING_DOCUMENT AS PURCHASE_ORDER_LINE_ITEM,
    coalesce(ariba_suppliercode, s4_suppliercode) as supplier_code,
    v.name_org_1 as supplier_name,
    coalesce( ariba_createdate, s4_po_createdate ) as po_date,
    coalesce(s4_shorttext, ariba_shorttext) as po_text,
    coalesce(s4_gr_qty, ariba_gr_qty) as GR_QTY,
    coalesce(s4_gr_amt, ariba_gr_amt) as GR_AMOUNT,
    coalesce(s4_inv_qty, ariba_inv_qty) as INV_QTY,
    coalesce(s4_gr_ir_amount, ariba_inv_amt ) as INV_AMOUNT,
    to_date(ekbe.po_received_Date,'YYYYMMDD') as po_received_Date,
    to_date(ekbe.po_invoiced_date,'YYYYMMDD') as po_invoiced_date,
    DATEDIFF(DAY,to_date(ekbe.po_received_Date,'YYYYMMDD'),CURRENT_DATE) AS AGE,
    CASE  WHEN AGE > 120 THEN '> 120'
        WHEN AGE >91 AND AGE <= 120 THEN '> 90'
        WHEN AGE >61 AND AGE <= 90 THEN '> 60'
        WHEN AGE >31 AND AGE <= 60 THEN '> 30'
        ELSE 'CURRENT' END AS AGE_BUCKET
    from {{ref('GOLD__TEH_PROCUREMENT__RECEIPTS_COMPARISON_ARIBA_S4')}} s
    left join {{ref('GOLD__TEH_PROCUREMENT__VENDOR_MASTER')}} v on 
    v.business_partner = coalesce(s.s4_suppliercode, s.ariba_suppliercode)
    left join ekbe on 
    ekbe.EBELN = s.ariba_purchasing_document_number and ekbe.ebelp = s.ariba_item_number_of_purchasing_document 
    WHERE (ABS(coalesce(s4_gr_amt, ariba_gr_amt,0) - coalesce(s4_gr_ir_amount, ariba_inv_amt,0 )) >0) 
    or (coalesce(s4_gr_amt, ariba_gr_amt) IS NOT NULL AND coalesce(s4_gr_ir_amount, ariba_inv_amt ) IS NULL)  
),
transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        PURCHASE_ORDER_NUMBER,
        PURCHASE_ORDER_LINE_ITEM,
        supplier_code,
        supplier_name,
        po_date,
        po_text,
        GR_QTY,
        GR_AMOUNT,
        INV_QTY,
        INV_AMOUNT,
        po_received_Date,
        po_invoiced_date,
        AGE,
        AGE_BUCKET
    from source_data
)
select * from transform_data
