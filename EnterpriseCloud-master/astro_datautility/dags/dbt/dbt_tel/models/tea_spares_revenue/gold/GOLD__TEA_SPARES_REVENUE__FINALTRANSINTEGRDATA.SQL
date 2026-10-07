{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    unique_key = ['DocLine',
    'FYPD'],
    alias='FINALTRANSINTEGRDATA'
) }}

with Final_Trans_PNQty as
(
    select 
        DOCLINE,
        SEQ,
        BSEQ,
        COST,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        DOC_DATE,
        CONSUM,
        STYPE,
        DIMENSION_2,
        DIMENSION_3,
        DIMENSION_4,
        DIMENSION_5,
        REFERENCE,
        REF_4,
        OTYPE,
        FINALAMOUNT,
        FYPD,
        BUSINESS_PARTNER_ID,
        BPID,
        BP,
        PARTNO,
        QTY,
        NUMBER_OF_UNITS,
        CON,
        COST_COMPONENT_DESC,
        SUPPLIER_ORDER_NO,
        SUPPLIER,
        INVNO,
        CUSTPO,
        WAREHOUSE
    from {{ ref('GOLD__TEA_SPARES_REVENUE__FINALTRANS_PNQTY') }} 
),

dbo_BaanV_TEA_Suppliers as
(
    select 
      SUPPLIER_CODE,
      SUPPLIER,
      ADDRESS_NAME,
      ADDRESS,
      CITY,
      STATE_PROVINCE,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      FAX,
      TAX_NUMBER,
      VERIFICATION_DATE,
      CURRENCY,
      TERMS_OF_PAYMENT,
      FINANCIAL_SUPPLIER_GROUP,
      SUPPLIER_STATUS,
      SHIP_FROM_DATA,
      LINE_OF_BUSINESS,
      PURCHASE_PRICE_LIST,
      PRICE_BOOK,
      SUPPLIER_NAME_1099,
      SUPPLIER_ADDRESS_CODE_1099,
      SUPPLIER_ADDRESS_1099,
      SUPPLIER_CITY_1099,
      SUPPLIER_POSTAL_CODE_1099,
      PAYEE_NAME_CONTROL,
      FOREIGN_ENTITY,
      INCOME_TAX_TYPE,
      ACCOUNT_NO_1099,
      TIN_2ND,
      REASON_FOR_PAYMENT,
      BUSINESS_PARTNER_TYPE,
      COMMODITY_CODE,
      SUB_COMMODITY_CODE,
      GENERAL_BP_STATUS
    from {{ ref('SILVER__TEA_SPARES_REVENUE__SUPPLIERS') }}
),

dbo_BaanV_TEA_Items as
(
    select 
        PROJECT_ITEM,
        PROJECT,
        ITEM,
        ITEM_DESCRIPTION,
        ITEM_TYPE,
        ITEM_GROUP,
        ON_HAND_QTY,
        ON_ORDER_QTY,
        ALLOCATED_QTY,
        ECONOMIC_QTY,
        SIGNAL_CODE,
        JAPAN_PRODUCT_LINE,
        CONSUMABLE,
        PURCHASE_PRICE,
        SALES_PRICE,
        MAT_SURCHARGE,
        MAT_COST,
        COST_PRICE,
        LEAD_TIME,
        SAFETY_TIME,
        MIN_ORDER_QTY,
        INVENTORY_UNIT,
        PURCHASE_UNIT,
        PURCHASE_PRICE_UNIT,
        STAT_GROUP,
        SUPPLIER_GROUP,
        PLANNER,
        LAST_INV_TRANS_DATE,
        LAST_PP_DATE,
        LAST_SP_DATE,
        LAST_CP_DATE,
        ORDER_QTY_MULTIPLE_OF,
        CUMULATIVE_ISSUE,
        WAREHOUSE,
        REPAIR_FLAG,
        INTEL_FLAG,
        REMARKS,
        BUYER_CODE,
        INSPECTION,
        COUNTRY_OF_ORIGIN,
        AVERAGE_PURCHASE_PRICE,
        LATEST_PURCHASE_PRICE,
        HARMONIZED_TARIFF_CODE,
        ECCN,
        SCHEDULEB,
        COMMODITY_CODE,
        PRODUCT_TYPE,
        SELECTION_CODE,
        WEIGHT,
        SALES_UNIT,
        SALES_PRICE_UNIT,
        RETURN_FLAG,
        ABC_GLOBAL,
        ABC_LOCAL,
        ABC_INTEL,
        MANUFACTURER,
        MANUFACTURER_NAME,
        ITEM_SIZE,
        EBIZ_DISCLOSURE_FLAG,
        SALES_MIN_QTY,
        PHYSICS_MATERIAL,
        EXPORT_REGULATION_FLAG,
        EXPORT_REGULATION_DESC,
        OBJECT_GROUP,
        FS_FLAG,
        DPAL_FLAG,
        EOL_FLAG,
        WEIGHT_UNIT,
        WEIGHT_WITH_PACKAGE,
        UN_NUMBER,
        PACKING_SIZE_L,
        PACKING_SIZE_W,
        PACKING_SIZE_H,
        BOXCODE,
        CRITICALITY_SCORE,
        ALLOCATION
    from {{ ref('SILVER__TEA_SPARES_REVENUE__ITEM') }}
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


transform_data as (

    SELECT DISTINCT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        Final_Trans_PNQty.DocLine, 
        Final_Trans_PNQty.SEQ,
        Final_Trans_PNQty.BSEQ,
        Final_Trans_PNQty.Cost, 
        Final_Trans_PNQty.LEDGER_ACC, 
        Final_Trans_PNQty.LEDGER_ACC_DESC, 
        Final_Trans_PNQty.DOC_DATE, 
        Final_Trans_PNQty.SType, 
        Case 
            When Final_Trans_PNQty.Dimension_2 = '5888' And Left(Final_Trans_PNQty.PartNo,3) = 'CPR'
            Then Substring(final_Trans_PNQTY.partNo,5,2)
            When Final_Trans_PNQty.Dimension_2 = '5888' And Final_Trans_PNQty.PartNo <> ''
            Then Left(Final_Trans_PNQty.PartNo,2)
            Else ''
        End AS CPRBU,
        Final_Trans_PNQty.DIMENSION_2, 
        Final_Trans_PNQty.DIMENSION_3, 
        Final_Trans_PNQty.DIMENSION_4, 
        Final_Trans_PNQty.DIMENSION_5, 
        Final_Trans_PNQty.REFERENCE, 
        Final_Trans_PNQty.Ref_4, 
        Final_Trans_PNQty.OType, 
        Final_Trans_PNQty.FinalAmount, 
        Final_Trans_PNQty.FYPd, 
        Final_Trans_PNQty.BUSINESS_PARTNER_ID, 
        Final_Trans_PNQty.BPID, 
        Final_Trans_PNQty.BP, 
        Final_Trans_PNQty.PartNo, 
        dbo_BaanV_TEA_Items.ITEM_DESCRIPTION, 

        Case 
            When Final_Trans_PNQty.QTY Is Not Null
            Then Final_Trans_PNQty.QTY
            When Final_Trans_PNQty.QTY Is Null And MkTbl_Sales.DELIVERED_QTY Is Not Null OR Left(Final_Trans_PNQty.REFERENCE,5)='REV -'
            Then -1* MkTbl_Sales.DELIVERED_QTY
            When Final_Trans_PNQty.QTY Is Null And MkTbl_Service.FDQTY Is Not Null
            Then MkTbl_Service.FDQTY
            Else MkTbl_Service.FDQTY
        End AS FQty, 

        Case
            When Left(dbo_BaanV_TEA_Items.selection_code,1)='X'
            Then 'RPREXC'
            When Left(dbo_BaanV_TEA_Items.selection_code,1)='r'
            Then 'RPRPRT'
            When Left(dbo_BaanV_TEA_Items.selection_code,1)='n'
            Then 'RPREXC'
            When Final_Trans_PNQty.Otype='RPR0'
            Then 'RPRSVC'
            When Final_Trans_PNQty.Otype='Repa'
            Then 'RPRSVC'
            Else ''
        End AS RPR, 

        Case 
            When Final_Trans_PNQty.Dimension_2='5930'
            Then 'RLSA_ES'
            When Final_Trans_PNQty.Dimension_2='4190'
            Then 'RLSA_ES'
            When Final_Trans_PNQty.Dimension_2='5100' And Final_Trans_PNQty.SType='Sales'
            Then '4110'
            When Final_Trans_PNQty.Dimension_2='5200' And Final_Trans_PNQty.SType='Sales'
            Then '4120'
            When Final_Trans_PNQty.Dimension_2='5400' And Left(final_Trans_PNQTY.partno,2)='L1'
            Then '4140_Certas'
            When Final_Trans_PNQty.Dimension_2='5400' And Final_Trans_PNQty.SType='Sales'
            Then '4140'
            When Final_Trans_PNQty.Dimension_2='4140' And Left(final_Trans_PNQTY.partno,2)='L1'
            Then '4140_Certas'
            When Final_Trans_PNQty.Dimension_2='5600' And Final_Trans_PNQty.SType='Sales'
            Then '4160'
            When Final_Trans_PNQty.Dimension_2='5100' And Final_Trans_PNQty.SType='Repair'
            Then '4110'
            When Final_Trans_PNQty.Dimension_2='5200' And Final_Trans_PNQty.SType='Repair'
            Then '4120'
            When Final_Trans_PNQty.Dimension_2='5888' And Left(FINAL_TRANS_pnQTY.PARTNO,3)='CPR'
            Then Substring(final_Trans_PNQTY.PARTNO,5,2)
            When Final_Trans_PNQty.Dimension_2='5888'
            Then Left(Final_Trans_PNQty.PARTNO,2)
            When Left(Final_Trans_PNQty.PartNo,2)='ES' And dbo_BaanV_TEA_Items.FS_Flag='no'
            Then '5300_300'
            Else Final_Trans_PNQty.Dimension_2
        End AS BUMOD, 

        Case 
            When Final_Trans_PNQty.con Is Not Null
            Then Final_Trans_PNQty.con
            When Final_Trans_PNQty.con='' And dbo_BaanV_TEA_Items.consumable='yes'
            Then 'CON'
            Else 'NON'
        End AS FCon, 

        dbo_BaanV_TEA_Items.SUPPLIER_GROUP, 
        Final_Trans_PNQty.COST_COMPONENT_DESC, 
        Final_Trans_PNQty.Con, 
        dbo_BaanV_TEA_Items.CONSUMABLE, 
        dbo_BaanV_TEA_Items.SELECTION_CODE, 
        dbo_BaanV_TEA_Items.ABC_LOCAL, 
        dbo_BaanV_TEA_Items.ABC_INTEL, 
        dbo_BaanV_TEA_Items.FS_FLAG, 
        Final_Trans_PNQty.SUPPLIER_ORDER_NO, 
        Final_Trans_PNQty.SUPPLIER, 
        Final_Trans_PNQty.NUMBER_OF_UNITS, 
        Final_Trans_PNQty.CustPO, 
        MkTbl_Sales.CUSTOMER_PO_NO,
        MkTbl_Service.CUSTOMER_PO, 
        dbo_BaanV_TEA_Items.EOL_FLAG, 
        Final_Trans_PNQty.WAREHOUSE, 
        dbo_BaanV_TEA_Suppliers.SUPPLIER AS SUPPLIERS, 
        Case
            When Contains(Final_Trans_PNQty.reference,'CPP')= 'True'
            Then 'CPP'
            Else '' 
        END AS CPPFlag 
     
    FROM dbo_BaanV_TEA_Suppliers 
        RIGHT JOIN ((MkTbl_Sales 
        RIGHT JOIN 
        (Final_Trans_PNQty 
        LEFT JOIN dbo_BaanV_TEA_Items ON Final_Trans_PNQty.PartNo = dbo_BaanV_TEA_Items.ITEM) 
        ON MkTbl_Sales.SlsLine = Final_Trans_PNQty.Ref_4) 
        LEFT JOIN MkTbl_Service ON Final_Trans_PNQty.Ref_4 = MkTbl_Service.SrvLine) 
        ON dbo_BaanV_TEA_Suppliers.SUPPLIER_CODE = dbo_BaanV_TEA_Items.SUPPLIER_GROUP
    GROUP BY Final_Trans_PNQty.DocLine, 
    Final_Trans_PNQty.SEQ, 
    Final_Trans_PNQty.BSEQ, 
    Final_Trans_PNQty.Cost, 
    Final_Trans_PNQty.LEDGER_ACC, 
    Final_Trans_PNQty.LEDGER_ACC_DESC, 
    Final_Trans_PNQty.DOC_DATE, 
    Final_Trans_PNQty.SType, 
    Case 
        When Final_Trans_PNQty.Dimension_2 = '5888' And Left(Final_Trans_PNQty.PartNo,3) = 'CPR'
        Then Substring(final_Trans_PNQTY.partNo,5,2)
        When Final_Trans_PNQty.Dimension_2 = '5888' And Final_Trans_PNQty.PartNo <> ''
        Then Left(Final_Trans_PNQty.PartNo,2)
        Else ''
    End, 
    Final_Trans_PNQty.DIMENSION_2, 
    Final_Trans_PNQty.DIMENSION_3, 
    Final_Trans_PNQty.DIMENSION_4, 
    Final_Trans_PNQty.DIMENSION_5, 
    Final_Trans_PNQty.REFERENCE, 
    Final_Trans_PNQty.Ref_4, 
    Final_Trans_PNQty.OType, 
    Final_Trans_PNQty.FinalAmount, 
    Final_Trans_PNQty.FYPd, 
    Final_Trans_PNQty.BUSINESS_PARTNER_ID, 
    Final_Trans_PNQty.BPID, 
    Final_Trans_PNQty.BP, 
    Final_Trans_PNQty.PartNo, 
    dbo_BaanV_TEA_Items.ITEM_DESCRIPTION, 
        Case 
            When Final_Trans_PNQty.QTY Is Not Null
            Then Final_Trans_PNQty.QTY
            When Final_Trans_PNQty.QTY Is Null And MkTbl_Sales.DELIVERED_QTY Is Not Null OR Left(Final_Trans_PNQty.REFERENCE,5)='REV -'
            Then -1* MkTbl_Sales.DELIVERED_QTY
            When Final_Trans_PNQty.QTY Is Null And MkTbl_Service.FDQTY Is Not Null
            Then MkTbl_Service.FDQTY
            Else MkTbl_Service.FDQTY
        End,

        Case
            When Left(dbo_BaanV_TEA_Items.selection_code,1)='X'
            Then 'RPREXC'
            When Left(dbo_BaanV_TEA_Items.selection_code,1)='r'
            Then 'RPRPRT'
            When Left(dbo_BaanV_TEA_Items.selection_code,1)='n'
            Then 'RPREXC'
            When Final_Trans_PNQty.Otype='RPR0'
            Then 'RPRSVC'
            When Final_Trans_PNQty.Otype='Repa'
            Then 'RPRSVC'
            Else ''
        End, 

        Case 
            When Final_Trans_PNQty.dimension_2='5930'
            Then 'RLSA_ES'
            When Final_Trans_PNQty.Dimension_2='4190'
            Then 'RLSA_ES'
            When Final_Trans_PNQty.Dimension_2='5100' And Final_Trans_PNQty.Stype='Sales'
            Then '4110'
            When Final_Trans_PNQty.Dimension_2='5200' And Final_Trans_PNQty.Stype='Sales'
            Then '4120'
            When Final_Trans_PNQty.Dimension_2='5400' And Left(Final_Trans_PNQty.partno,2)='L1'
            Then '4140_Certas'
            When Final_Trans_PNQty.Dimension_2='5400' And Final_Trans_PNQty.Stype='Sales'
            Then '4140'
            When Final_Trans_PNQty.Dimension_2='4140' And Left(Final_Trans_PNQty.partno,2)='L1'
            Then '4140_Certas'
            When Final_Trans_PNQty.Dimension_2='5600' And Final_Trans_PNQty.Stype='Sales'
            Then '4160'
            When Final_Trans_PNQty.Dimension_2='5100' And Final_Trans_PNQty.Stype='Repair'
            Then '4110'
            When Final_Trans_PNQty.Dimension_2='5200' And Final_Trans_PNQty.SType='Repair'
            Then '4120'
            When Final_Trans_PNQty.Dimension_2='5888' And Left(FINAL_TRANS_pnQTY.PARTNO,3)='CPR'
            Then Substring(final_Trans_PNQTY.PARTNO,5,2)
            When Final_Trans_PNQty.Dimension_2='5888'
            Then Left(Final_Trans_PNQty.PARTNO,2)
            When Left(Final_Trans_PNQty.PartNo,2)='ES' And dbo_BaanV_TEA_Items.FS_Flag='no'
            Then '5300_300'
            Else Final_Trans_PNQty.Dimension_2
        End, 

        Case 
            When Final_Trans_PNQty.con Is Not Null
            Then Final_Trans_PNQty.con
            When Final_Trans_PNQty.con='' And dbo_BaanV_TEA_Items.consumable='yes'
            Then 'CON'
            Else 'NON'
        End,
    
    dbo_BaanV_TEA_Items.SUPPLIER_GROUP, 
    Final_Trans_PNQty.COST_COMPONENT_DESC, 
    Final_Trans_PNQty.Con, 
    dbo_BaanV_TEA_Items.CONSUMABLE, 
    dbo_BaanV_TEA_Items.SELECTION_CODE, 
    dbo_BaanV_TEA_Items.ABC_LOCAL, 
    dbo_BaanV_TEA_Items.ABC_INTEL, 
    dbo_BaanV_TEA_Items.FS_FLAG, 
    Final_Trans_PNQty.SUPPLIER_ORDER_NO, 
    Final_Trans_PNQty.SUPPLIER, 
    Final_Trans_PNQty.NUMBER_OF_UNITS, 
    Final_Trans_PNQty.CustPO, 
    MkTbl_Sales.CUSTOMER_PO_NO, 
    MkTbl_Service.CUSTOMER_PO, 
    dbo_BaanV_TEA_Items.EOL_FLAG, 
    Final_Trans_PNQty.WAREHOUSE, 
    dbo_BaanV_TEA_Suppliers.SUPPLIER, 
        Case
            When Contains(Final_Trans_PNQty.reference,'CPP')= 'True'
            Then 'CPP'
            Else '' 
        END 
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY Final_Trans_PNQty.DocLine,Final_Trans_PNQty.FYPD ORDER BY Final_Trans_PNQty.DOC_DATE DESC) )= 1        

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
        STYPE,
        CPRBU,
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
        ITEM_DESCRIPTION,
        cast(FQTY as NUMBER(38,5)) as FQTY,
        RPR,
        BUMOD,
        FCON,
        SUPPLIER_GROUP,
        COST_COMPONENT_DESC,
        CON,
        CONSUMABLE,
        SELECTION_CODE,
        ABC_LOCAL,
        ABC_INTEL,
        FS_FLAG,
        SUPPLIER_ORDER_NO,
        SUPPLIER,
        cast(NUMBER_OF_UNITS as NUMBER(38,0)) as NUMBER_OF_UNITS,
        CUSTPO,
        CUSTOMER_PO_NO,
        CUSTOMER_PO,
        EOL_FLAG,
        WAREHOUSE,
        SUPPLIERS,
        CPPFLAG
    from transform_data
    )
select * from type_data