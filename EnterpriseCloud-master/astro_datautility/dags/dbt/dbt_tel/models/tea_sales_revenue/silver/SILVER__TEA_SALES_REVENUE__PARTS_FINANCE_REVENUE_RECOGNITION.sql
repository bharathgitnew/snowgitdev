{{ config(
        alias = 'PARTS_FINANCE_REVENUE_RECOGNITION',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        enabled= true,
        transient = false
) }}

with vbfa_cte as (
    select distinct
    F._FILEDATE,
    F._FILENAME,
    f.VBELN                                        as BILLING_DOC,
    f.VBELV                                        as SALES_ORDER,
    f.POSNV                                        as SALES_ORDER_ITEM,
    f.POSNN                                        as BILLING_DOC_ITEM,
    f.VBTYP_N                                        as SALES_ORDER_TYPE,
    VBTYP_V                                        as PREDECESSOR_DOC_TYPE

       from {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU064_VBFA') }} f
    where 1=1
),
vbrk_cte as (
    select distinct
    f.VBELN                                        as BILLING_DOC,
    f.FKDAT                                        as BILLING_DATE,           -- Proxy (99% same)
    f.BUKRS                                        as COMPANY_CODE,
    f.WAERK                                        as CURRENCY,
    F.GJAHR                                        as FISCAL_YEAR,
    F.BELNR                                        as FI_DOC_NBR
    from {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU014_VBRK') }} f   
    where 1=1    
),
vbrp_cte as (
    select distinct
    f.VBELN                                        as BILLING_DOC,
    f.POSNR                                        as BILLING_DOC_ITEM,
    f.VGTYP                                        as REF_DOC_TYPE,
    f.VGBEL                                        as REF_DOC_NBR,
    f.VGPOS                                        as REF_DOC_LINE
        from {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU015_VBRP') }} f   
    where 1=1
),

bkpf_cte as (
    select distinct
    f.BUKRS                                        as COMPANY_CODE,
    f.BELNR                                        as FI_DOC_NBR,
    f.GJAHR                                        as FISCAL_YEAR,
    f.BUDAT                                        as ACCOUNT_POSTING_DATE    -- True FI posting date
    from {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU037_BKPF') }} f   
    where 1=1
),

SOURCE_DATA AS (
    select
        F._FILEDATE AS _FILEDATE,
        F._FILENAME AS _FILENAME,
        f.SALES_ORDER,
        f.SALES_ORDER_ITEM,
        vbrk.BILLING_DOC,
        vbrk.BILLING_DATE as BILLING_DATE,           
        bkpf.ACCOUNT_POSTING_DATE as ACCOUNT_POSTING_DATE,  -- True FI posting date
        vbrk.COMPANY_CODE              as COMPANY_CODE,
        vbrk.CURRENCY                  as CURRENCY,

        /* Resolve Outbound Delivery (OBDO) primarily via document flow Delivery -> Billing.
           If missing, fall back to VBRP reference when it points to Delivery. */
        coalesce(fb.SALES_ORDER,
                 case when vbrp.REF_DOC_TYPE = 'J' then vbrp.REF_DOC_NBR end) as OUTBOUND_DELIVERY_ORDER_NBR,
        coalesce(fb.SALES_ORDER_ITEM,
                 case when vbrp.REF_DOC_TYPE = 'J' then vbrp.REF_DOC_LINE end) as OUTBOUND_DELIVERY_ORDER_LINE

    from vbfa_cte f                 -- Doc flow: Sales Order (C) -> Billing (M)
    join vbrk_cte vbrk
      on vbrk.BILLING_DOC = f.BILLING_DOC
     and f.SALES_ORDER_TYPE = 'M'                                   -- Successor type = Billing

    -- Item-level details (optional / for fallback)
        left join vbrp_cte vbrp
            on vbrp.BILLING_DOC = vbrk.BILLING_DOC
         and vbrp.BILLING_DOC_ITEM = f.BILLING_DOC_ITEM

    /* Doc flow: Delivery (J) -> Billing (M), to fetch the OBDO that fed this billing */
    left join vbfa_cte fb
      on fb.PREDECESSOR_DOC_TYPE = 'J'                                  -- Predecessor type = Delivery
     and fb.SALES_ORDER_TYPE = 'M'                                  -- Successor type = Billing
     and fb.BILLING_DOC   = vbrk.BILLING_DOC                           -- Same billing doc
    and (fb.BILLING_DOC_ITEM = vbrp.BILLING_DOC_ITEM or fb.BILLING_DOC_ITEM = f.BILLING_DOC_ITEM)

    -- True FI posting date
    left join bkpf_cte bkpf
      on bkpf.COMPANY_CODE = vbrk.COMPANY_CODE
     and bkpf.FI_DOC_NBR = vbrk.FI_DOC_NBR
     and bkpf.FISCAL_YEAR = vbrk.FISCAL_YEAR
    

    where 1=1
),
TRANSFORM_DATA as (
    select
        _FILEDATE ,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        SALES_ORDER,
        SALES_ORDER_ITEM,
        BILLING_DOC,
        TRY_TO_DATE(BILLING_DATE::STRING, 'YYYYMMDD') as BILLING_DATE,
        TRY_TO_DATE(ACCOUNT_POSTING_DATE::STRING, 'YYYYMMDD') as ACCOUNT_POSTING_DATE,
        COMPANY_CODE,
        CURRENCY,
        OUTBOUND_DELIVERY_ORDER_NBR,
        OUTBOUND_DELIVERY_ORDER_LINE
    from SOURCE_DATA
),type_data as 
(
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        SALES_ORDER,
        SALES_ORDER_ITEM,
        BILLING_DOC,
        BILLING_DATE,
        ACCOUNT_POSTING_DATE,
        COMPANY_CODE,
        CURRENCY,
        OUTBOUND_DELIVERY_ORDER_NBR,
        OUTBOUND_DELIVERY_ORDER_LINE
    FROM transform_data
)

select * from type_data