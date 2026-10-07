{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    unique_key = ['DocLine',
    'FYPD'],
    alias='FINALTRANS_PNQTY'
) }}

with Final_Trans_PN as
(
    select 
        DOCLINE,
        SEQUENCE_NUMBER,
        BACKGROUND_SEQUENCE_NO,
        COST,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        DOC_DATE,
        DIMENSION_2,
        DIMENSION_3,
        DIMENSION_4,
        DIMENSION_5,
        CONSUM,
        STYPE,
        REFERENCE,
        REF_4,
        OTYPE,
        FINALAMOUNT,
        FISCAL_YEAR,
        FYPD,
        BUSINESS_PARTNER_ID,
        BPID,
        BP,
        PN,
        INVNO,
        CUSTPO,
        SUPPLIER_ORDER_NO,
        SUPPLIER
    from {{ ref('GOLD__TEA_SPARES_REVENUE__FINALTRANS_PN') }} 
),

IntegrationTrans_Tbl as
(
    select 
        IDOCLINE,
        ORDERLINE,
        ORDER_SEQUENCE_NO,
        ITEM,
        QTY,
        PRODUCT_CLASS,
        DIMENSION_4,
        FYPD,
        COST_COMPONENT_DESC,
        TEA_BU,
        LEDGER_ACC,
        AMOUNT,
        DC,
        FINALAMOUNT,
        FINALQTY,
        NUMBER_OF_UNITS,
        WAREHOUSE,
        SOLD_TO_BP,
        SHIP_TO_BP
    from {{ ref('GOLD__TEA_SPARES_REVENUE__SR_INTEGRATEDTRANSACTIONS') }} 
),

transform_data as (

SELECT 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    Final_Trans_PN.DocLine,
    Final_Trans_PN.SEQUENCE_NUMBER AS SEQ, 
    Final_Trans_PN.BACKGROUND_SEQUENCE_NO AS BSEQ, 
    Final_Trans_PN.Cost, 
    Final_Trans_PN.LEDGER_ACC, 
    Final_Trans_PN.LEDGER_ACC_DESC, 
    Final_Trans_PN.DOC_DATE, 
    Final_Trans_PN.Consum, 
    Final_Trans_PN.SType, 
    Final_Trans_PN.DIMENSION_2, 
    Final_Trans_PN.DIMENSION_3, 
    Final_Trans_PN.DIMENSION_4, 
    Final_Trans_PN.DIMENSION_5, 
    Final_Trans_PN.REFERENCE, 
    Final_Trans_PN.Ref_4, 
    Final_Trans_PN.OType, 
    Final_Trans_PN.FinalAmount, 
    Final_Trans_PN.FYPd, 
    Final_Trans_PN.BUSINESS_PARTNER_ID, 
    Final_Trans_PN.BPID, 
    Final_Trans_PN.BP, 
    case 
        when Final_Trans_PN.PN is not null 
        then Final_Trans_PN.PN
        else integrationTrans_tbl.item
    end AS PARTNO,     
    IntegrationTrans_Tbl.Qty, 
    IntegrationTrans_Tbl.NUMBER_OF_UNITS, 
    case 
        when Final_Trans_PN.consum=''
        then Trim(IntegrationTrans_Tbl.product_class)
        else Final_Trans_PN.consum
    end AS CON,     
    IntegrationTrans_Tbl.COST_COMPONENT_DESC, 
    Final_Trans_PN.SUPPLIER_ORDER_NO, 
    Final_Trans_PN.SUPPLIER, 
    Final_Trans_PN.InvNo, 
    Final_Trans_PN.CustPO, 
    IntegrationTrans_Tbl.WAREHOUSE 
    FROM Final_Trans_PN 
    LEFT JOIN IntegrationTrans_Tbl 
    ON Final_Trans_PN.DocLine = IntegrationTrans_Tbl.IDocLine
    GROUP BY Final_Trans_PN.DocLine, 
    Final_Trans_PN.SEQUENCE_NUMBER, 
    Final_Trans_PN.BACKGROUND_SEQUENCE_NO, 
    Final_Trans_PN.Cost, 
    Final_Trans_PN.LEDGER_ACC, 
    Final_Trans_PN.LEDGER_ACC_DESC, 
    Final_Trans_PN.DOC_DATE, 
    Final_Trans_PN.Consum, 
    Final_Trans_PN.SType, 
    Final_Trans_PN.DIMENSION_2, 
    Final_Trans_PN.DIMENSION_3, 
    Final_Trans_PN.DIMENSION_4, 
    Final_Trans_PN.DIMENSION_5, 
    Final_Trans_PN.REFERENCE, 
    Final_Trans_PN.Ref_4, 
    Final_Trans_PN.OType, 
    Final_Trans_PN.FinalAmount, 
    Final_Trans_PN.FYPd, 
    Final_Trans_PN.BUSINESS_PARTNER_ID, 
    Final_Trans_PN.BPID, 
    Final_Trans_PN.BP, 
    case 
        when PN is not null 
        then PN
        else integrationTrans_tbl.item
    end,
    IntegrationTrans_Tbl.Qty, 
    IntegrationTrans_Tbl.NUMBER_OF_UNITS, 
    case 
        when consum=''
        then Trim(product_class)
        else consum
    end,     
    IntegrationTrans_Tbl.COST_COMPONENT_DESC, 
    Final_Trans_PN.SUPPLIER_ORDER_NO, 
    Final_Trans_PN.SUPPLIER, 
    Final_Trans_PN.InvNo, 
    Final_Trans_PN.CustPO, 
    IntegrationTrans_Tbl.WAREHOUSE
)

,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        DOCLINE,
        cast(SEQ as NUMBER(38,0)) as SEQ,
        cast(BSEQ as NUMBER(38,0)) as BSEQ,
        COST,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        cast(DOC_DATE as TIMESTAMP_NTZ(9)) as DOC_DATE,
        CONSUM,
        STYPE,
        DIMENSION_2,
        DIMENSION_3,
        DIMENSION_4,
        DIMENSION_5,
        REFERENCE,
        REF_4,
        OTYPE,
        cast(FINALAMOUNT as NUMBER(38,10)) as FINALAMOUNT,
        FYPD,
        BUSINESS_PARTNER_ID,
        BPID,
        BP,
        PARTNO,
        cast(QTY as NUMBER(38,0)) as QTY,
        cast(NUMBER_OF_UNITS as NUMBER(38,0)) as NUMBER_OF_UNITS,
        CON,
        COST_COMPONENT_DESC,
        SUPPLIER_ORDER_NO,
        SUPPLIER,
        INVNO,
        CUSTPO,
        WAREHOUSE
    from transform_data
    )
select * from type_data