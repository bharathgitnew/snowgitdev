{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    unique_key = ['DocLine',
    'FYPD'],
    alias='FINALTRANS_PN'
) }}

with Tbl_finalizedtrans as
(
    select 
        TRANSACTION_TYPE,
        DOCUMENT,
        LINE,
        DOCLINE,
        SEQUENCE_NUMBER,
        BACKGROUND_SEQUENCE_NO,
        ORIGINAL_COMPANY,
        COST,
        ORIGINAL_TRANSACTION_TYPE,
        ORIGINAL_DOCUMENT_NO,
        BATCH,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        DOC_DATE,
        DIMENSION_TYPE_1,
        DIMENSION_1,
        DIMENSION_TYPE_2,
        DIMENSION_2,
        DIMENSION_TYPE_3,
        DIMENSION_3,
        DIMENSION_TYPE_4,
        DIMENSION_4,
        DIMENSION_TYPE_5,
        DIMENSION_5,
        CONSUM,
        STYPE,
        REFERENCE,
        REF_1,
        REF_ORDER,
        REF_ORDER_TEST2,
        REF_ORDER1,
        REF_3,
        REF_31,
        REF_4,
        OTYPE,
        AMOUNT,
        CURRENCY,
        RATE,
        RATE_FACTOR,
        AMOUNT_IN_HC,
        DC,
        FINALAMOUNT,
        DC_DESC,
        COUNTRY,
        TAX_CODE,
        TAX_TYPE,
        TAX_LEDGER_AC,
        TAX_AMOUNT,
        TAX_AMOUNT_HC,
        QUANTITY_1,
        QUANTITY_2,
        FINANCIAL_PERIOD,
        FISCAL_YEAR,
        FYPD,
        REPORTING_PERIOD,
        REPORTING_YEAR,
        TAX_PERIOD,
        TAX_YEAR,
        BUSINESS_PARTNER_ID,
        FT_INTEL,
        TRANSACTION_CATEGORY,
        LAST_MODIFIED_BY,
        FINALIZATION_DATE,
        FINALIZATION_TIME,
        FINALIZATION_RUN_NO,
        CONTROL_ACCOUNT,
        TRANS_TYPE_CORRECTION,
        INVOICE_CORRECTION,
        STANDING_ORDER,
        STANDING_ORDER_SEQUENCE_NO,
        TYPE_OF_CASH_TRANSACTION,
        TYPE_OF_TRANSACTION,
        TRANSACTION_TEXT,
        DELETED,
        INTEGRATION_TRANSACTION,
        PERIOD_BEGINING
    from {{ ref('GOLD__TEA_SPARES_REVENUE__SR_FINALIZEDTRANSACTIONS') }} 
),

MkTbl_Sales as
(
    select 
        SLSLINE,
        ITEM,
        ITEM_DESCRIPTION,
        SOLDTO_BPID,
        SOLDTO_BP,
        DELIVERED_QTY,
        ORDER_DATE,
        INVOICE_DATE,
        INVOICE_AMOUNT,
        REFERENCEA,
        REFERENCEB,
        INVOICE_NO,
        CUSTOMER_PO_NO
    from {{ ref('GOLD__TEA_SPARES_REVENUE__SR_SALESORDER') }} 
),

MkTbl_Service as
(
    select 
        SRVLINE,
        ITEM,
        ITEM_DESCRIPTION,
        SOLD_TO_BPID,
        SOLD_TO_BP,
        FDQTY,
        DELIVERY_TYPE,
        CONFIGURATION,
        SERIAL_NUMBER,
        MATERIAL_ORDER_DATE,
        COST_PRICE,
        INVOICE_NUMBER,
        CUSTOMER_PO,
        WAREHOUSE
    from {{ ref('GOLD__TEA_SPARES_REVENUE__SR_SERVICEORDER') }} 
),

MkTblPOLine as
(
    select 
        POLINE,
        ITEM,
        ITEM_DESCRIPTION,
        SUPPLIER_ORDER_NO,
        SUPPLIER,
        DELIVERED_QTY,
        ORDER_DATE,
        WAREHOUSE
    from {{ ref('GOLD__TEA_SPARES_REVENUE__SR_PURCHASEORDER') }} 
),

QryMTRLine as
(
    select 
        MTLINE,
        ITEM,
        ITEM_DESCRIPTION,
        RECEIVED_QTY,
        SHIP_FROM
    from {{ ref('GOLD__TEA_SPARES_REVENUE__SR_REPLENISHMENTORDER') }} 
),

transform_data as (

    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        Tbl_finalizedtrans.DocLine, 
        Tbl_finalizedtrans.SEQUENCE_NUMBER, 
        Tbl_finalizedtrans.BACKGROUND_SEQUENCE_NO, 
        Tbl_finalizedtrans.Cost, 
        Tbl_finalizedtrans.LEDGER_ACC, 
        Tbl_finalizedtrans.LEDGER_ACC_DESC, 
        Tbl_finalizedtrans.DOC_DATE, 
        Tbl_finalizedtrans.DIMENSION_2,
        Tbl_finalizedtrans.DIMENSION_3, 
        Tbl_finalizedtrans.DIMENSION_4, 
        Tbl_finalizedtrans.DIMENSION_5, 
        Tbl_finalizedtrans.Consum, 
        Tbl_finalizedtrans.SType, 
        Tbl_finalizedtrans.REFERENCE, 
        Tbl_finalizedtrans.Ref_4, 
        Tbl_finalizedtrans.OType, 
        Tbl_finalizedtrans.FinalAmount, 
        Tbl_finalizedtrans.FISCAL_YEAR, 
        Tbl_finalizedtrans.FYPd, 
        Tbl_finalizedtrans.BUSINESS_PARTNER_ID, 
        MkTbl_Sales.soldto_bpid || MkTbl_Service.sold_to_bpid AS BPID, 
        MkTbl_Sales.soldto_bp || MkTbl_Service.sold_to_bp AS BP, 
        QryMTRLine.item || MkTblPOLine.item || MkTbl_Sales.item || MkTbl_Service.item AS PN, 
        INVOICE_NO || invoice_number AS InvNo, 
        CUSTOMER_PO_NO || Customer_PO AS CustPO,
        MkTblPOLine.SUPPLIER_ORDER_NO,
        MkTblPOLine.SUPPLIER
    FROM (((Tbl_finalizedtrans 
    LEFT JOIN QryMTRLine 
    ON Tbl_finalizedtrans.Ref_4 = QryMTRLine.MTLine)
    LEFT JOIN MkTbl_Sales 
    ON Tbl_finalizedtrans.Ref_4 = MkTbl_Sales.SlsLine)
    LEFT JOIN MkTbl_Service 
    ON Tbl_finalizedtrans.Ref_4 = MkTbl_Service.SrvLine)
    LEFT JOIN MkTblPOLine 
    ON Tbl_finalizedtrans.Ref_4 = MkTblPOLine.POLine
    GROUP BY Tbl_finalizedtrans.DocLine, 
    Tbl_finalizedtrans.SEQUENCE_NUMBER, 
    Tbl_finalizedtrans.BACKGROUND_SEQUENCE_NO,
    Tbl_finalizedtrans.Cost,
    Tbl_finalizedtrans.LEDGER_ACC, 
    Tbl_finalizedtrans.LEDGER_ACC_DESC, 
    Tbl_finalizedtrans.DOC_DATE, 
    Tbl_finalizedtrans.DIMENSION_2, 
    Tbl_finalizedtrans.DIMENSION_3, 
    Tbl_finalizedtrans.DIMENSION_4, 
    Tbl_finalizedtrans.DIMENSION_5, 
    Tbl_finalizedtrans.Consum, 
    Tbl_finalizedtrans.SType, 
    Tbl_finalizedtrans.REFERENCE,
    Tbl_finalizedtrans.Ref_4, 
    Tbl_finalizedtrans.OType, 
    Tbl_finalizedtrans.FinalAmount, 
    Tbl_finalizedtrans.FISCAL_YEAR, 
    Tbl_finalizedtrans.FYPd, 
    Tbl_finalizedtrans.BUSINESS_PARTNER_ID,
    MkTbl_Sales.soldto_bpid || MkTbl_Service.sold_to_bpid, 
    MkTbl_Sales.soldto_bp || MkTbl_Service.sold_to_bp, 
    QryMTRLine.item || mktblpoline.item || MkTbl_Sales.item || MkTbl_Service.item, 
    INVOICE_NO || invoice_number, 
    CUSTOMER_PO_NO || Customer_PO, 
    MkTblPOLine.SUPPLIER_ORDER_NO,
    MkTblPOLine.SUPPLIER

)

,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        DOCLINE,
        cast(SEQUENCE_NUMBER as NUMBER(38,0)) as SEQUENCE_NUMBER,
        cast(BACKGROUND_SEQUENCE_NO as NUMBER(38,0)) as BACKGROUND_SEQUENCE_NO,
        COST,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        cast(DOC_DATE as TIMESTAMP_NTZ(9)) as DOC_DATE,
        DIMENSION_2,
        DIMENSION_3,
        DIMENSION_4,
        DIMENSION_5,
        CONSUM,
        STYPE,
        REFERENCE,
        REF_4,
        OTYPE,
        cast(FINALAMOUNT as NUMBER(38,10)) as FINALAMOUNT,
        cast(FISCAL_YEAR as NUMBER(38,0)) as FISCAL_YEAR,
        FYPD,
        BUSINESS_PARTNER_ID,
        BPID,
        BP,
        PN,
        INVNO,
        CUSTPO,
        SUPPLIER_ORDER_NO,
        SUPPLIER
    from transform_data
    )
select * from type_data