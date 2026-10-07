{{ config(
        alias = 'BLOCKED_INVOICES',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
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
        case 
            when gmx._FILEDATE > ifnull(api._FILEDATE, '1970-01-01') then gmx.ZLSPR 
            else api.ZLSPR
        end as ZLSPR
    from {{ ref('BRONZE__TEA_DIRECT_PURCHASING__SAPAPI_ZCDV_T_CMTU038_BSEG') }} api
    full join {{ ref('BRONZE__TEA_DIRECT_PURCHASING__SAPH_SAP_US_FIT_EV_BSEG') }} as gmx on
        try_to_number(api.BUKRS) = gmx.BUKRS and
        try_to_number(api.GJAHR) = gmx.GJAHR and
        try_to_number(api.BELNR) = gmx.BELNR and
        try_to_number(api.BUZEI) = gmx.BUZEI
  where api.KOART in ( 'K')
),



-- gets the PO doc and lines that have goods received to be inner joined with invoiced POs
gr_pos as (
    select distinct
        EBELN as PO_NUMBER, 
        EBELP as PO_ITEM
    from {{ ref('BRONZE__TEA_DIRECT_PURCHASING__SAPAPI_ZCDV_T_CMTU217_EKBE') }}
    where BEWTP = 'E'
),

-- gets the unique company code, year, and accounting docs ensuring one line per AWREF and AWITEM
/*acdoca as (
    select 
        RBUKRS, 
        GJAHR, 
        BELNR,
        AWREF, 
        AWITEM
    from ODS.SAPAPI.ZCDV_T_CMTU024_ACDOCA 
    where 
        RLDNR = '0L' 
    qualify row_number() over(partition by RBUKRS, GJAHR, BELNR, AWREF, AWITEM order by BELNR) = 1
),
*/

invoice_details as (
    select  
        ekbe.EBELN as PO_NUMBER, 
        ekbe.EBELP as PO_ITEM, 
        ekbe.BELNR as INVOICE_DOC, 
        ekbe.BUZEI as INVOICE_ITEM, 
--        acdoca.BELNR as ACC_DOC, 
        bseg.BELNR as ACC_DOC,
        bseg.ZLSPR as BLOCK_IND,
        bseg.BUZEI as ACC_line,
       bseg.GJAHR as Year,
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
        end as BLOCK_DESC
    from {{ ref('BRONZE__TEA_DIRECT_PURCHASING__SAPAPI_ZCDV_T_CMTU217_EKBE') }} ekbe
  
--    left join acdoca on
--        try_to_number(acdoca.AWREF) = ekbe.BELNR and 
--        try_to_number(acdoca.AWITEM) = ekbe.BUZEI
    left join bseg on

        bseg.PO_NUMBER = ekbe.EBELN and 
--        bseg.PO_ITEM = ekbe.EBELP and 
        bseg.INVOICE_DOC =  ekbe.BELNR and  
        bseg.Invoice_year = ekbe.GJAHR
--to_number(bseg.INVOICE_ITEM =  to_number(ekbe.BUZEI)
  
--        bseg.BUKRS = acdoca.RBUKRS and
--        bseg.GJAHR = acdoca.GJAHR and 
--        bseg.BELNR = acdoca.BELNR and 
--        try_to_number(bseg.BUZEI) = '1'
    where ekbe.BEWTP = 'Q'
),

source_data as (
    select
        invoice_details.PO_NUMBER, 
        invoice_details.PO_ITEM, 
        invoice_details.INVOICE_DOC,
        invoice_details.INVOICE_ITEM,
        invoice_details.BLOCK_IND,
        invoice_details.BLOCK_DESC
--       , invoice_details.RACCT
    from invoice_details 
    inner join gr_pos on -- only report on POs that have both goods recieved and invoices
        invoice_details.PO_NUMBER = gr_pos.PO_NUMBER and
        try_to_number(invoice_details.PO_ITEM) = gr_pos.PO_ITEM
    where 
        left(invoice_details.PO_NUMBER, 2) not in ('PO', 'EP')
  and        BLOCK_DESC != 'Free for payment'
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        PO_NUMBER,
        PO_ITEM,
        INVOICE_DOC,
        INVOICE_ITEM,
        BLOCK_IND,
        BLOCK_DESC
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        PO_NUMBER,
        PO_ITEM,
        INVOICE_DOC,
        INVOICE_ITEM,
        BLOCK_IND,
        BLOCK_DESC
    from transform_data
)

select * from type_data