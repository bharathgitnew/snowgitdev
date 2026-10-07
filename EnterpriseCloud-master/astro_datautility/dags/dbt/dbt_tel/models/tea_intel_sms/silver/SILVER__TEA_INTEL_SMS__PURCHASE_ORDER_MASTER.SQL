{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='SAPH_PURCHASE_ORDER_MASTER',
        transient=false
) }}

with business_partners_general_data as (
    select distinct
        NAME_1,
        CUSTOMER_NUMBER
    from {{ ref('SILVER__TEA_INTEL_SMS__BUSINESS_PARTNERS_GENERAL_DATA') }}
),

vendor_data as (
    select distinct
        LFA1_ACCOUNT_NUMBER_OF_VENDOR_OR_CREDITOR as VENDOR_NUMBER,
        LFA1_NAME_1_NAME1 as VENDOR_NAME
    from {{ ref('SILVER__TEA_INTEL_SMS__BUSINESS_PARTNERS_GENERAL_DATA') }}
),

gmx_eket as (
    select * from {{ ref('BRONZE__TEA_INTEL_SMS__SAPH_SAP_US_MMT_EV_EKET') }}
),

lead_times as (
    select distinct
        EINA_NUMBER_OF_PURCHASING_INFO_RECORD,
        try_to_number(EINE_PLANNED_DELIVERY_TIME_IN_DAYS)*1.4 EINE_PLANNED_DELIVERY_TIME_IN_DAYS
    from {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_INFORMATION_PURCHASE_ORDER') }}
    where
        EINA_NUMBER_OF_PURCHASING_INFO_RECORD is not null and
        PURCHASING_INFO_RECORD_CATEGORY = '0' and
        EINE_PURCHASING_ORGANIZATION = '3200' and
        EINE_PLANT = '3200'
),

shipped_quantities_total as (
    select
        EKKO_PURCHASING_DOCUMENT_NUMBER,
        ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
        DELIVERY_VBELN,
        TO_NUMBER(sum(QUANTITY_AS_PER_SUPPLIER_CONFIRMATION),38,3) as MAX_QUANTITY_AS_PER_SUPPLIER_CONFIRMATION,
        'LA' as CONFIRMATION_CATEGORY
    from {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_SUPPLIER_CONFIRMATION') }}
    where confirmation_category='LA'
    group by EKKO_PURCHASING_DOCUMENT_NUMBER, ITEM_NUMBER_OF_PURCHASING_DOCUMENT, DELIVERY_VBELN
),

unshipped_quantities_total as (
    select
        EKKO_PURCHASING_DOCUMENT_NUMBER,
        ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
        DELIVERY_VBELN,
        CREATION_DATE_OF_CONFIRMATION,
        QUANTITY_AS_PER_SUPPLIER_CONFIRMATION as MAX_QUANTITY_AS_PER_SUPPLIER_CONFIRMATION,
        CONFIRMATION_CATEGORY
    from {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_SUPPLIER_CONFIRMATION') }}
    where confirmation_category='AB'
),

all_shipment_quantity_data as (
    select
        EKKO_PURCHASING_DOCUMENT_NUMBER,
        ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
        DELIVERY_VBELN,
        CREATION_DATE_OF_CONFIRMATION,
        QUANTITY_AS_PER_SUPPLIER_CONFIRMATION as MAX_QUANTITY_AS_PER_SUPPLIER_CONFIRMATION,
        CONFIRMATION_CATEGORY
    from {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_SUPPLIER_CONFIRMATION') }}
    where confirmation_category='LA'

    union all

    select
        EKKO_PURCHASING_DOCUMENT_NUMBER,
        ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
        DELIVERY_VBELN,
        CREATION_DATE_OF_CONFIRMATION,
        MAX_QUANTITY_AS_PER_SUPPLIER_CONFIRMATION,
        CONFIRMATION_CATEGORY
    from unshipped_quantities_total
    where concat(EKKO_PURCHASING_DOCUMENT_NUMBER,ITEM_NUMBER_OF_PURCHASING_DOCUMENT,MAX_QUANTITY_AS_PER_SUPPLIER_CONFIRMATION)
        not in (
            select concat(EKKO_PURCHASING_DOCUMENT_NUMBER,ITEM_NUMBER_OF_PURCHASING_DOCUMENT,MAX_QUANTITY_AS_PER_SUPPLIER_CONFIRMATION)
            from shipped_quantities_total
        )
),

-- received_quantities as (
--     select
--         poasl.EKET_PURCHASING_DOCUMENT_NUMBER as PURCHASING_DOCUMENT_NUMBER,
--         poasl.ITEM_NUMBER_OF_PURCHASING_DOCUMENT as ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
--         sum(coalesce(gmx_eket.WEMNG, poasl.QUANTITY_OF_GOODS_RECEIVED)) as QTY_RECEIVED
--     from {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_AGREEMENT_SCHEDULE_LINE') }} poasl
--     full join gmx_eket on 
--         try_to_number(poasl.EKET_PURCHASING_DOCUMENT_NUMBER) = try_to_number(gmx_eket.EBELN) and
--         try_to_number(poasl.ITEM_NUMBER_OF_PURCHASING_DOCUMENT) = try_to_number(gmx_eket.EBELP) and
--         try_to_number(poasl.DELIVERY_SCHEDULE_LINE_COUNTER) = try_to_number(gmx_eket.ETENR)
--     where SCHEDULED_QUANTITY > 0
--     group by
--         EKET_PURCHASING_DOCUMENT_NUMBER,
--         ITEM_NUMBER_OF_PURCHASING_DOCUMENT
-- ),
EKBE as ( select 
		EBELN AS PURCHASING_DOCUMENT_NUMBER,
		EBELP AS ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
		SUM(CASE WHEN SHKZG = 'S' THEN MENGE ELSE MENGE * -1 END) AS QTY_RECEIVED
from {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU217_EKBE') }}  where BEWTP in ('E')
group by EBELN,EBELP,SHKZG
),
 
received_quantities as (
    select
       PURCHASING_DOCUMENT_NUMBER,
       ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
        sum(QTY_RECEIVED) as QTY_RECEIVED
    from EKBE 
    group by
        PURCHASING_DOCUMENT_NUMBER,
        ITEM_NUMBER_OF_PURCHASING_DOCUMENT
),
shipping_info as (
    select
        posc.EKPO_PURCHASING_DOCUMENT_NUMBER,
        posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP,
        listagg(distinct nullif(trim(zsdt.Z_SHP_HAWB), ''), ', ') HAWB,
        listagg(distinct nullif(trim(zsdt.Z_SHP_MAWB), ''), ', ') MAWB,
        listagg(distinct nullif(trim(zsdt.ZZCCCD), ''), ', ') SHIP_DATE
    from (
        select distinct
            EKPO_PURCHASING_DOCUMENT_NUMBER,
            ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP
        from {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_SUPPLIER_CONFIRMATION') }}
    ) posc
    left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZMMT1013') }} zmmt on
        try_to_number(posc.EKPO_PURCHASING_DOCUMENT_NUMBER) = try_to_number(zmmt.ZDOC_NO) and
        try_to_number(posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP) = try_to_number(zmmt.ZDOC_ITM)
    left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZSDT0060') }} zsdt on
        try_to_number(zmmt.ZOBD_NO) = try_to_number(zsdt.VBELN)
    where zsdt.DEL_FLG is null
    group by
        posc.EKPO_PURCHASING_DOCUMENT_NUMBER,
        posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP
),

adrc_cte as (
    select 
        * 
    from {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU087_ADRC') }} adrc
    where adrc.LANGU= 'EN'  and adrc.nation = 'I'
),

Intel_flag as
(
    select   
        ekes.EKPO_PURCHASING_DOCUMENT_NUMBER,
        ekes.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP,
        case when adrc.name1 is NULL then PLANT_ADRC.name1 else adrc.name1  end as address,
        case 
            when  EKES.STORAGE_LOCATION = 'Z100' and ( address iLike '%INTEL%'  or address ilike '%Consignment%') then 'Intel'
            when substr(EKES.STORAGE_LOCATION,3,1) = '3' then 'Intel'
            else 'Non-Intel'
        end as Intel
    from (
        select distinct
            EKPO_PURCHASING_DOCUMENT_NUMBER,
            ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP,
            case when NUMBER_OF_DELIVERY_ADDRESS = '' then MANUAL_ADDRESS_NUMBER_IN_PURCHASING_DOCUMENT_ITEM else NUMBER_OF_DELIVERY_ADDRESS
            end as NUMBER_OF_DELIVERY_ADDRESS,
            PLANT,
            STORAGE_LOCATION
        from {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_SUPPLIER_CONFIRMATION') }} 
    ) as ekes
    left join adrc_cte as adrc
        on ekes.NUMBER_OF_DELIVERY_ADDRESS = adrc.addrnumber
    left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU063_T001W') }} as PLANT_ADRC
        on ekes.PLANT = PLANT_ADRC.werks
),

PARTS_EXPORT_IMPORT_CONTROL as (
    select
        productnum
        , US_HSNUM
    from {{ ref('BRONZE__TEA_INTEL_SMS__SAPH_PARTS_EXPORTIMPORT_CONTROL') }}
),

billing_info as (
    select 
        VBAP_SALES_DOCUMENT,
        SALES_DOCUMENT_ITEM_POSNR,
        sum(VBRP_BILL_NET_VALUE_OF_THE_BILLING_ITEM_IN_DOCUMENT_CURRENCY) as NET_VALUE,
        max(try_to_date(VBRP_BILL_DATE_ON_WHICH_SERVICES_ARE_RENDERED, 'YYYYMMDD')) as RECEIPT_DATE,
        sum(VBRP_BILL_ACTUAL_BILLED_QUANTITY) as INVOICE_QTY
    from {{ ref('SILVER__TEA_INTEL_SMS__SALES_ORDER_BILLING_LINE') }}
    group by all
),

material_info as (
    select distinct 
        MVKE_MATERIAL_NUMBER,
        ORDER_ITEM_NAME
    from {{ ref('SILVER__TEA_INTEL_SMS__MATERIAL_SALES_ORG_MASTER') }}
    where 
        SALES_ORGANIZATION = '3200' and
        DISTRIBUTION_CHANNEL = '00'
),

bp_info as (
    select distinct
        SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER as SO_NUMBER, 
        PARTNER_FUNCTION, 
        kna1.NAME_1
    from {{ ref('SILVER__TEA_INTEL_SMS__BUSINESS_PARTNERS') }} bp
    left join business_partners_general_data kna1 on 
        bp.CUSTOMER_NUMBER = kna1.CUSTOMER_NUMBER
    where PARTNER_FUNCTION in ('SP', 'SH')
),

bp_pivot as (
    select SO_NUMBER, SOLD_TO, SHIP_TO 
    from bp_info
    pivot(max(NAME_1) for PARTNER_FUNCTION in ('SP', 'SH'))
        as p (SO_NUMBER, SOLD_TO, SHIP_TO)
),


source_data as (
    select distinct
        posc.EKKO_PURCHASER_EMPLOYEE_NO as EMPLOYEE_NUMBER,
        posc.PURCHASING_DOCUMENT_TYPE as PO_TYPE,
        left(posc.MATERIAL_NUMBER_MATNR, 2) as BU,
        posc.VENDOR_S_ACCOUNT_NUMBER as VENDOR,
        lfa1_vendor.VENDOR_NAME as VENDOR_NAME,
        posc.COLLECTIVE_NUMBER as COLLECTIVE_NUMBER,
        posc.EKKO_PURCHASING_DOCUMENT_NUMBER as PO_NUMBER,
        posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP as LINE_ITEM,
        posc.SEQUENTIAL_NUMBER_OF_SUPPLIER_CONFIRMATION_ETENS as CONFIRMATION_SEQ,
        posc.ORDER_PRIORITY_ZZOPZZ as PRIORITY,
        to_varchar(try_to_date(posc.PURCHASING_DOCUMENT_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') as PO_DATE,
        posc.MATERIAL_NUMBER_MATNR as PART_NUMBER,
        material_info.ORDER_ITEM_NAME as DESCRIPTION,
        posc.PURCHASE_ORDER_QUANTITY AS PURCHASE_QTY,
        CASE WHEN PO_TYPE = 'ZPR3' THEN 
        (posc.PURCHASE_ORDER_QUANTITY + zeroifnull(received_quantities.QTY_RECEIVED)) 
        ELSE (posc.PURCHASE_ORDER_QUANTITY - zeroifnull(received_quantities.QTY_RECEIVED)) END as OPEN_QTY,
        CASE WHEN PO_TYPE = 'ZPR3' THEN
        zeroifnull(received_quantities.QTY_RECEIVED)*(-1) ELSE zeroifnull(received_quantities.QTY_RECEIVED) END as QTY_RECEIVED,
        posc.STORAGE_LOCATION as SLOC,
        posc.QUANTITY_AS_PER_SUPPLIER_CONFIRMATION as CONFIRMED_QTY,
        to_varchar(try_to_date(poasl.ITEM_DELIVERY_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') as REQUESTED_DELIVERY_DATE,
        to_varchar(try_to_date(posc.EKES_DELIVERY_DATE_OF_SUPPLIER_CONFIRMATION, 'YYYYMMDD'), 'MM/DD/YYYY') as CONFIRMED_DEL_DATE,
        to_varchar(try_to_date(posc.CREATION_DATE_OF_CONFIRMATION, 'YYYYMMDD'), 'MM/DD/YYYY') as TEL_UPDATE,
        sales_info.VBAP_SALES_DOCUMENT as SO_NUMBER,
        posc.DELIVERY_VBELN as TEA_IBDO,
        posc.DELIVERY_ITEM_VBELP as DO_ITEM_NUMBER,
        to_varchar(try_to_date(shipping_info.SHIP_DATE), 'MM/DD/YYYY') as SHIP_DATE,
        shipping_info.HAWB as HAWB,
        shipping_info.MAWB as MAWB,
        posc.OUR_REFERENCE as OUR_REFERENCE,
        bp_pivot.SOLD_TO as CUSTOMER,
        sales_info.VBAK_CUSTOMER_REFERENCE as CUSTOMER_REFERENCE,
        bp_pivot.SHIP_TO as END_USER,
        posc.NET_PRICE_IN_PURCHASING_DOCUMENT as NET_PRICE,
        posc.GROSS_ORDER_VALUE_IN_PO_CURRENCY as LINE_TOTAL,
        posc.CURRENCY_KEY as CURRENCY,
        lead_times.EINE_PLANNED_DELIVERY_TIME_IN_DAYS as LEAD_TIME,
        to_varchar(dateadd('day', lead_times.EINE_PLANNED_DELIVERY_TIME_IN_DAYS, try_to_date(posc.PURCHASING_DOCUMENT_DATE, 'YYYYMMDD')), 'MM/DD/YYYY') as LT_DELIVERY_DATE,
        marc.ZZLABC as LOCAL_ABC, --ABC_LOCAL,
        marc.ZZSABC as CUSTOMER_SPECIFIC_ABC, --ABC_INTEL,
        round(doi.ON_HAND, 3) as TEA_OH,
        round(doi.MTH1 + doi.MTH2 + doi.MTH3, 3) as THREE_MONTH_USAGE,
        round(THREE_MONTH_USAGE/3, 3) as AVG_MONTHLY_USAGE,
        round(THREE_MONTH_USAGE/90, 3) as AVG_DAILY_USAGE,
        round(doi.DOI_3_MONTHS, 3) as THREE_MONTH_DOI,
        case
            when nullif(HAWB, '') is not null then 'SHIPPED'
            else 'NOT-SHIPPED'
        end as SHIPPED,
        case
            when posc.SUPPLIER_CONFIRMATION_DELETION_INDICATOR = 'X' or posc.EKPO_DELETION_INDICATOR_IN_PURCHASING_DOCUMENT = 'L' then 'CANCELLED'
            when try_to_date(CONFIRMED_DEL_DATE, 'MM/DD/YYYY') is null then 'NOETA'
            when try_to_date(CONFIRMED_DEL_DATE, 'MM/DD/YYYY') > try_to_date(LT_DELIVERY_DATE, 'MM/DD/YYYY') then 'LATE2PLAN'
            when try_to_date(CONFIRMED_DEL_DATE, 'MM/DD/YYYY') < current_date() then 'PASTDELDT'
            when SHIPPED = 'SHIPPED' and try_to_number(CONFIRMATION_SEQ) = 1 then 'SHIPPED'
            when posc.DELIVERY_VBELN is null then 'WAITING ON SHIPMENT'
            when OPEN_QTY = 0 then 'DELIVERED'
            else null
        end as STATUS,
        Intel_flag.intel,
        case
            when posc.ORDER_PRIORITY_ZZOPZZ <> '1' then 'NA'
            when posc.ORDER_PRIORITY_ZZOPZZ = '1' and DATEDIFF(day, try_to_date(posc.PURCHASING_DOCUMENT_DATE, 'YYYYMMDD'), try_to_date(poasl.item_delivery_date, 'YYYYMMDD')) < lead_times.EINE_PLANNED_DELIVERY_TIME_IN_DAYS then 'FAKE'
            else 'OK'
        end as FakeNormal,
        PEIC.US_HSNUM AS HTS,
        posc.PURCHASE_REQUISITION_NUMBER as PURCHASE_REQUISITION_NUMBER,
        -- podl.PURCHASE_REQUISITION_NUMBER as PURCHASE_REQUISITION_NUMBER,
        to_varchar(billing_info.RECEIPT_DATE, 'MM/DD/YYYY') as RECEIPT_DATE,
        datediff('days', to_date(PO_DATE), to_date(TEL_UPDATE)) as RESPONSE_TIME,
        billing_info.INVOICE_QTY as INVOICE_QTY,
        billing_info.NET_VALUE as INVOICE_AMT,
        poasl.NUMBER_OF_PURCHASING_INFO_RECORD as PIR,
        poasl.DELIVERY_SCHEDULE_LINE_COUNTER as DELIVERY_SCHEDULE_LINE_COUNTER,
        to_varchar(try_to_date(podl.CONFIRMED_CUSTOMS_CLEARANCE_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') as CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        --- filters for Open PO, not reported
        posc.PURCHASING_ORGANIZATION_EKORG,
        posc.SUPPLIER_CONFIRMATION_DELETION_INDICATOR,
        posc.EKPO_DELETION_INDICATOR_IN_PURCHASING_DOCUMENT,
        posc.DELIVERY_COMPLETED_INDICATOR,
        posc.CREATED_BY_EMPLOYEE_NO,
        posc.CREATED_BY_EMPLOYEE_NAME,
        posc.SALES_REP_EMPLOYEE_NO,
        coalesce(sales_rep_emp.FULL_NAME, posc.SALES_REP_EMPLOYEE_NO) as SALES_REP_EMPLOYEE_NAME
    from {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_SUPPLIER_CONFIRMATION') }} posc
    -- left join all_shipment_quantity_data on
    --     all_shipment_quantity_data.EKKO_PURCHASING_DOCUMENT_NUMBER=posc.EKKO_PURCHASING_DOCUMENT_NUMBER and
    --     all_shipment_quantity_data.ITEM_NUMBER_OF_PURCHASING_DOCUMENT=posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT and
    --     all_shipment_quantity_data.MAX_QUANTITY_AS_PER_SUPPLIER_CONFIRMATION=posc.QUANTITY_AS_PER_SUPPLIER_CONFIRMATION and
    --     all_shipment_quantity_data.CREATION_DATE_OF_CONFIRMATION=posc.CREATION_DATE_OF_CONFIRMATION and
    --     all_shipment_quantity_data.CONFIRMATION_CATEGORY=posc.CONFIRMATION_CATEGORY
    left join received_quantities on
        posc.EKKO_PURCHASING_DOCUMENT_NUMBER = received_quantities.PURCHASING_DOCUMENT_NUMBER and
        posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP = received_quantities.ITEM_NUMBER_OF_PURCHASING_DOCUMENT
    left join {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_DELIVERY_LINE') }} podl on
        posc.DELIVERY_VBELN=podl.LIPS_DELIVERY and posc.DELIVERY_ITEM_VBELP=podl.DELIVERY_ITEM_POSNR
    left join {{ ref('SILVER__TEA_INTEL_SMS__PURCHASE_ORDER_AGREEMENT_SCHEDULE_LINE') }} poasl on
        posc.EKKO_PURCHASING_DOCUMENT_NUMBER=poasl.EKKO_PURCHASING_DOCUMENT_NUMBER and
        posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP=poasl.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP
    left join vendor_data lfa1_vendor on
        posc.VENDOR_S_ACCOUNT_NUMBER = lfa1_vendor.VENDOR_NUMBER
    left join lead_times on
        poasl.NUMBER_OF_PURCHASING_INFO_RECORD = lead_times.EINA_NUMBER_OF_PURCHASING_INFO_RECORD
    left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU026_MARC') }} marc on
        poasl.MATERIAL_NUMBER_MATNR=marc.MATNR and poasl.PLANT=marc.WERKS
    left join {{ ref('SILVER__TEA_INTEL_SMS__DAYS_OF_INVENTORY_MASTER') }} doi on
        poasl.MATERIAL_NUMBER_MATNR = doi.MATERIAL and
        poasl.STORAGE_LOCATION = doi.STORAGE_LOCATION
    left join shipping_info on
        posc.EKPO_PURCHASING_DOCUMENT_NUMBER = shipping_info.EKPO_PURCHASING_DOCUMENT_NUMBER and
        posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP = shipping_info.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP
    left join Intel_flag on
        posc.EKPO_PURCHASING_DOCUMENT_NUMBER = Intel_flag.EKPO_PURCHASING_DOCUMENT_NUMBER and
        posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP = Intel_flag.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP
    LEFT JOIN PARTS_EXPORT_IMPORT_CONTROL AS PEIC ON
        RIGHT(posc.MATERIAL_NUMBER_MATNR, LEN(posc.MATERIAL_NUMBER_MATNR) -2) = PEIC.PRODUCTNUM
    left join {{ ref('SILVER__TEA_INTEL_SMS__DROPSHIP_MODEL') }} dropship on
        try_to_number(posc.EKKO_PURCHASING_DOCUMENT_NUMBER) = try_to_number(dropship.PURCHASING_DOCUMENT_NUMBER) and
        try_to_number(posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP) = try_to_number(dropship.ITEM_NUMBER_OF_PURCHASING_DOCUMENT)
    left join material_info on
        posc.MATERIAL_NUMBER_MATNR = material_info.MVKE_MATERIAL_NUMBER
    left join {{ ref('SILVER__TEA_INTEL_SMS__SALES_ORDER_DOCUMENT_FLOW') }} sales_info on
        sales_info.VBFA_DOCUMENT_CATEGORY_OF_SUBSEQUENT_DOCUMENT = 'V' and
        try_to_number(sales_info.VBFA_SUBSEQUENT_SALES_AND_DISTRIBUTION_DOCUMENT) = try_to_number(posc.EKKO_PURCHASING_DOCUMENT_NUMBER) and
        try_to_number(sales_info.VBFA_SUBSEQUENT_ITEM_OF_AN_SD_DOCUMENT) = try_to_number(posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT_EBELP)
    left join billing_info on
        try_to_number(billing_info.VBAP_SALES_DOCUMENT) =  try_to_number(sales_info.VBAP_SALES_DOCUMENT) and
        try_to_number(billing_info.SALES_DOCUMENT_ITEM_POSNR) =  try_to_number(sales_info.SALES_DOCUMENT_ITEM_POSNR)
    left join bp_pivot on
        bp_pivot.SO_NUMBER = sales_info.VBAP_SALES_DOCUMENT
    left join {{ ref('SILVER__TEA_INTEL_SMS__GLOBAL_EMPLOYEE') }} as sales_rep_emp
        on posc.SALES_REP_EMPLOYEE_NO = sales_rep_emp.EMPLOYEE_ID
),

transform_data as (
    select
        '{{ invocation_id }}' as _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        EMPLOYEE_NUMBER,
        PO_TYPE,
        BU,
        VENDOR,
        VENDOR_NAME,
        COLLECTIVE_NUMBER,
        PO_NUMBER,
        LINE_ITEM,
        CONFIRMATION_SEQ,
        PRIORITY,
        PO_DATE,
        PART_NUMBER,
        DESCRIPTION,
        PURCHASE_QTY,
        OPEN_QTY,
        QTY_RECEIVED,
        SLOC,
        CONFIRMED_QTY,
        REQUESTED_DELIVERY_DATE,
        CONFIRMED_DEL_DATE,
        TEL_UPDATE,
        SO_NUMBER,
        TEA_IBDO,
        DO_ITEM_NUMBER,
        SHIP_DATE,
        HAWB,
        MAWB,
        OUR_REFERENCE,
        CUSTOMER,
        CUSTOMER_REFERENCE,
        END_USER,
        NET_PRICE,
        LINE_TOTAL,
        CURRENCY,
        LEAD_TIME,
        LT_DELIVERY_DATE,
        LOCAL_ABC,
        CUSTOMER_SPECIFIC_ABC,
        TEA_OH,
        THREE_MONTH_USAGE,
        AVG_MONTHLY_USAGE,
        AVG_DAILY_USAGE,
        THREE_MONTH_DOI,
        SHIPPED,
        STATUS,
        PURCHASING_ORGANIZATION_EKORG,
        SUPPLIER_CONFIRMATION_DELETION_INDICATOR,
        EKPO_DELETION_INDICATOR_IN_PURCHASING_DOCUMENT,
        INTEL,
        FAKENORMAL,
        HTS,
        PURCHASE_REQUISITION_NUMBER,
        RECEIPT_DATE,
        RESPONSE_TIME,
        INVOICE_QTY,
        INVOICE_AMT,
        PIR,
        DELIVERY_SCHEDULE_LINE_COUNTER,
        CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        DELIVERY_COMPLETED_INDICATOR,
        CREATED_BY_EMPLOYEE_NO,
        CREATED_BY_EMPLOYEE_NAME,
        SALES_REP_EMPLOYEE_NO,
        SALES_REP_EMPLOYEE_NAME,
    from source_data
),

type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        EMPLOYEE_NUMBER,
        PO_TYPE,
        BU,
        VENDOR,
        VENDOR_NAME,
        COLLECTIVE_NUMBER,
        PO_NUMBER,
        LINE_ITEM,
        CONFIRMATION_SEQ,
        PRIORITY,
        PO_DATE,
        PART_NUMBER,
        DESCRIPTION,
        PURCHASE_QTY,
        cast(OPEN_QTY as VARCHAR(16777216)) as OPEN_QTY,
        cast(QTY_RECEIVED as VARCHAR(16777216)) as QTY_RECEIVED,
        SLOC,
        CONFIRMED_QTY,
        REQUESTED_DELIVERY_DATE,
        CONFIRMED_DEL_DATE,
        TEL_UPDATE,
        SO_NUMBER,
        TEA_IBDO,
        DO_ITEM_NUMBER,
        SHIP_DATE,
        HAWB,
        MAWB,
        OUR_REFERENCE,
        CUSTOMER,
        CUSTOMER_REFERENCE,
        END_USER,
        NET_PRICE,
        LINE_TOTAL,
        CURRENCY,
        cast(LEAD_TIME as VARCHAR(16777216)) as LEAD_TIME,
        LT_DELIVERY_DATE,
        LOCAL_ABC,
        CUSTOMER_SPECIFIC_ABC,
        cast(TEA_OH as VARCHAR(16777216)) as TEA_OH,
        cast(THREE_MONTH_USAGE as VARCHAR(16777216)) as THREE_MONTH_USAGE,
        cast(AVG_MONTHLY_USAGE as VARCHAR(16777216)) as AVG_MONTHLY_USAGE,
        cast(AVG_DAILY_USAGE as VARCHAR(16777216)) as AVG_DAILY_USAGE,
        cast(THREE_MONTH_DOI as VARCHAR(16777216)) as THREE_MONTH_DOI,
        SHIPPED,
        STATUS,
        PURCHASING_ORGANIZATION_EKORG,
        SUPPLIER_CONFIRMATION_DELETION_INDICATOR,
        EKPO_DELETION_INDICATOR_IN_PURCHASING_DOCUMENT,
        INTEL,
        FAKENORMAL,
        HTS,
        PURCHASE_REQUISITION_NUMBER,
        RECEIPT_DATE,
        cast(RESPONSE_TIME as VARCHAR(16777216)) as RESPONSE_TIME,
        cast(INVOICE_QTY as VARCHAR(16777216)) as INVOICE_QTY,
        cast(INVOICE_AMT as VARCHAR(16777216)) as INVOICE_AMT,
        PIR,
        DELIVERY_SCHEDULE_LINE_COUNTER,
        CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        DELIVERY_COMPLETED_INDICATOR,
        CREATED_BY_EMPLOYEE_NO,
        CREATED_BY_EMPLOYEE_NAME,
        SALES_REP_EMPLOYEE_NO,
        SALES_REP_EMPLOYEE_NAME,
    from transform_data
)

select * from type_data