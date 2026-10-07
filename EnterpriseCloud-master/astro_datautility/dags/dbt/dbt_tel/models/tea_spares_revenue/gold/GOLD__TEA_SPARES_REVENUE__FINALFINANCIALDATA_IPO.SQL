{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    unique_key = ['DocLine',
    'FYPD'],
    alias='FINALFINANCIALDATA_IPO'
) }}

with FInalTransIntegrData as
(
    select 
        DOCLINE,
        SEQ,
        BSEQ,
        COST,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        DOC_DATE,
        STYPE,
        CPRBU,
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
        ITEM_DESCRIPTION,
        FQTY,
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
        NUMBER_OF_UNITS,
        CUSTPO,
        CUSTOMER_PO_NO,
        CUSTOMER_PO,
        EOL_FLAG,
        WAREHOUSE,
        SUPPLIERS,
        CPPFLAG
    from {{ ref('GOLD__TEA_SPARES_REVENUE__FINALTRANSINTEGRDATA') }} 
),

Customers as
(
    select 
        'C' || Customer_Code as Customer_Code,
        Customer_Code as Customer_Id,
        Customer
    from {{ ref('SILVER__TEA_SPARES_REVENUE__BAANV_TEA_CUSTOMERS') }} 
),

Customer_Group as
(
    select 
        CUSTOMERID,
        CUSTOMERGROUP as Customer_Group
    from {{ ref('BRONZE__TEA_SPARES_REVENUE__MDM_CUSTOMER') }}
),


Item as
(
    select distinct
        ITEM as PART_NUMBER,
        COMMODITY_CODE as Parts_Commodity
    from {{ ref('SILVER__TEA_SPARES_REVENUE__ITEM') }}
),

TEAItems as
(
    select
        ITEMID,
        CLASSIFICATION as COMMODITY_DESC
    from {{ ref('BRONZE__TEA_SPARES_REVENUE__MDM_TEAITEMS') }}
),


tbl_bu as 
(
    select 
    BU_CODE,
    BU_NAME
    from {{ ref('BRONZE__TEA_SPARES_REVENUE__FILE_BUSINESSUNIT') }}

),

transform_data as (

    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        FInalTransIntegrData.DocLine, 
        FInalTransIntegrData.SEQ, 
        FInalTransIntegrData.BSEQ, 
        FInalTransIntegrData.Cost, 
        FInalTransIntegrData.LEDGER_ACC, 
        FInalTransIntegrData.LEDGER_ACC_DESC, 
        FInalTransIntegrData.DOC_DATE, 
        Case
            When Left(FInalTransIntegrData.PartNo,3)='TFR'
            Then 'Repair'
            When Right(FInalTransIntegrData.PartNo,4)='-RFS'
            Then 'Repair'
            When Right(FInalTransIntegrData.PartNo,4)='-RPR'
            Then 'Repair'
            Else FInalTransIntegrData.SType
        End AS SalesType, 
        FInalTransIntegrData.DIMENSION_2, 
        Case 
            When FInalTransIntegrData.CPRBU='MB'
            Then 'SD'
            When FInalTransIntegrData.CPRBU='DS'
            Then 'TPS'
            When FInalTransIntegrData.CPRBU='TF'
            Then 'FSI'
            When FInalTransIntegrData.CPRBU='RE'
            Then 'RLSA_ES'
            When FInalTransIntegrData.CPRBU='NX'
            Then 'NEXX'
            When FInalTransIntegrData.CPRBU='SS'
            Then '3DI_Bonder'
            When FInalTransIntegrData.CPRBU='VD'
            Then '3DI_TPS'
            When FInalTransIntegrData.CPRBU<>''
            Then FInalTransIntegrData.CPRBU
            When FInalTransIntegrData.BUMOD='4140_Certas'
            Then 'L1_Certas'
            When FInalTransIntegrData.BUMOD='4150'
            Then 'TS'
            When Left(FInalTransIntegrData.custPO,6)='RE-TEA'
            Then 'RLSA_ES'
            When Left(FInalTransIntegrData.PartNo,2)='RE'
            Then 'RLSA_ES'
            Else tbl_bu.BU_NAME
            End AS BUName,         
        FInalTransIntegrData.BUMOD, 
        FInalTransIntegrData.DIMENSION_3, 
        FInalTransIntegrData.DIMENSION_4, 
        Case
            When Left(FInalTransIntegrData.DIMENSION_4,5)='SPARE'
            Then 'SPARE'
            When FInalTransIntegrData.DIMENSION_4='CONPRT'
            Then 'SRVC'
            When FInalTransIntegrData.DIMENSION_4='pdprt'
            Then 'SRVC'
            When Left(FInalTransIntegrData.DIMENSION_4,3)='RPR'
            Then 'REPAIR'
            When FInalTransIntegrData.DIMENSION_4='FCNPRT'
            Then 'NCDR_FCN'
            When FInalTransIntegrData.DIMENSION_4='warprt'
            Then 'NCDR_WTY'
            When FInalTransIntegrData.DIMENSION_4='prwprt'
            Then 'NCDR_SUP'
            When FInalTransIntegrData.DIMENSION_4='insprt'
            Then 'NCDR_SUP'
            Else 'NCDR_OTHER'
        End AS DIMENSION_42, 
        FInalTransIntegrData.DIMENSION_5, 
        FInalTransIntegrData.REFERENCE, 
        FInalTransIntegrData.Ref_4, 
        FInalTransIntegrData.OType, 
        FInalTransIntegrData.FinalAmount as FinalAmount, 

            case 
                when FInalTransIntegrData.LEDGER_ACC like '4%'
                then FInalTransIntegrData.FinalAmount
                else 0
            end 
         as Revenue,
            case 
                when FInalTransIntegrData.LEDGER_ACC like '5%'
                then FInalTransIntegrData.FinalAmount
                else 0
            end 
         as COGS,          
        FInalTransIntegrData.FYPd, 
        DATE_FROM_PARTS(left(FInalTransIntegrData.FYPd,4),right(FInalTransIntegrData.FYPD,length(FInalTransIntegrData.FYPD) - position('_',FInalTransIntegrData.FYPD)),'01') as Calendardate,
        FInalTransIntegrData.BPID, 
        FInalTransIntegrData.BP, 
        Case 
            When FInalTransIntegrData.cost='Freight'
            Then 'Freight'
            Else FInalTransIntegrData.PartNo
        End AS PN, 
        Case
            When FInalTransIntegrData.cost='Freight'
            Then 'Freight'
            Else ITEM_DESCRIPTION
        End AS PN_DESC, 
        Case
            When FInalTransIntegrData.COST ILIKE 'Sales' And FInalTransIntegrData.FINALAMOUNT<0
            Then Abs(FInalTransIntegrData.FQTY)
            When FInalTransIntegrData.COST ILIKE 'Sales' And FInalTransIntegrData.FINALAMOUNT>0
            Then -1*Abs(FInalTransIntegrData.FQTY)
            When FInalTransIntegrData.COST ILIKE 'Cost' And FInalTransIntegrData.FINALAMOUNT>0
            Then Abs(FInalTransIntegrData.FQTY)
            When FInalTransIntegrData.COST ILIKE 'Cost' And FInalTransIntegrData.FINALAMOUNT<0
            Then -1*Abs(FInalTransIntegrData.FQTY)
            Else FInalTransIntegrData.FQTY
        End AS QTY, 
        FInalTransIntegrData.RPR, 
        Case
            When Left(FInalTransIntegrData.partNo,3)='CPR'
            Then 'RPRSVC'
            When Left(FInalTransIntegrData.PartNo,3)='TFR'
            Then 'RPRPRT'
            When Right(FInalTransIntegrData.partno,4)='-RFS'
            Then 'RPREXC'
            When Right(FInalTransIntegrData.partno,4)='-RPR'
            Then 'RPRSVC'
            When Left(FInalTransIntegrData.dimension_4,3)='rpr'
            Then FInalTransIntegrData.Dimension_4
            When FInalTransIntegrData.rpr<>''
            Then FInalTransIntegrData.rpr
            Else FInalTransIntegrData.FCon
        End AS FinalCon, 
        FInalTransIntegrData.SUPPLIER_GROUP, 
        Case
            When supplier_group='00001'
            Then 'TEL'
            Else 'NonTEL'
        End AS TELSUpply, 
        FInalTransIntegrData.SUPPLIER, 
        FInalTransIntegrData.COST_COMPONENT_DESC, 
        Case
            When Left(cost_component_desc,7)='surchar'
            Then FInalTransIntegrData.finalAmount
            Else 0
        End AS Surcharge, 
        FInalTransIntegrData.ABC_LOCAL, 
        FInalTransIntegrData.FS_FLAG, 
        FInalTransIntegrData.NUMBER_OF_UNITS as NUMBER_OF_UNITS, 
        FInalTransIntegrData.SUPPLIER_ORDER_NO, 
        FInalTransIntegrData.EOL_FLAG, 
        FInalTransIntegrData.WAREHOUSE,
        FInalTransIntegrData.PartNo,
        FInalTransIntegrData.CPRBU,
        FInalTransIntegrData.CustPO,
        Customers.Customer,
        Customer_Group.Customer_Group,
        Item.Parts_Commodity,
        TEAItems.COMMODITY_DESC
    FROM FInalTransIntegrData
    left join Customers
    on FInalTransIntegrData.DIMENSION_5 = Customers.Customer_Code
    left join Customer_Group
    on Customers.Customer_Id = Customer_Group.CUSTOMERID
    left join Item
    on  FInalTransIntegrData.PartNo = Item.PART_NUMBER
    left join tbl_bu
    on FInalTransIntegrData.DIMENSION_2 = tbl_bu.BU_Code
    LEFT JOIN TEAItems
    ON FInalTransIntegrData.PartNo = TEAItems.itemid
    GROUP BY         FInalTransIntegrData.DocLine, 
        FInalTransIntegrData.SEQ, 
        FInalTransIntegrData.BSEQ, 
        FInalTransIntegrData.Cost, 
        FInalTransIntegrData.LEDGER_ACC, 
        FInalTransIntegrData.LEDGER_ACC_DESC, 
        FInalTransIntegrData.DOC_DATE, 
        Case
            When Left(FInalTransIntegrData.PartNo,3)='TFR'
            Then 'Repair'
            When Right(FInalTransIntegrData.PartNo,4)='-RFS'
            Then 'Repair'
            When Right(FInalTransIntegrData.PartNo,4)='-RPR'
            Then 'Repair'
            Else FInalTransIntegrData.SType
        End, 
        FInalTransIntegrData.DIMENSION_2, 
        Case 
            When FInalTransIntegrData.CPRBU='MB'
            Then 'SD'
            When FInalTransIntegrData.CPRBU='DS'
            Then 'TPS'
            When FInalTransIntegrData.CPRBU='TF'
            Then 'FSI'
            When FInalTransIntegrData.CPRBU='RE'
            Then 'RLSA_ES'
            When FInalTransIntegrData.CPRBU='NX'
            Then 'NEXX'
            When FInalTransIntegrData.CPRBU='SS'
            Then '3DI_Bonder'
            When FInalTransIntegrData.CPRBU='VD'
            Then '3DI_TPS'
            When FInalTransIntegrData.CPRBU<>''
            Then FInalTransIntegrData.CPRBU
            When FInalTransIntegrData.BUMOD='4140_Certas'
            Then 'L1_Certas'
            When FInalTransIntegrData.BUMOD='4150'
            Then 'TS'
            When Left(FInalTransIntegrData.custPO,6)='RE-TEA'
            Then 'RLSA_ES'
            When Left(FInalTransIntegrData.PartNo,2)='RE'
            Then 'RLSA_ES'
            Else tbl_bu.BU_NAME
            End,         
        FInalTransIntegrData.BUMOD, 
        FInalTransIntegrData.DIMENSION_3, 
        FInalTransIntegrData.DIMENSION_4, 
        Case
            When Left(FInalTransIntegrData.DIMENSION_4,5)='SPARE'
            Then 'SPARE'
            When FInalTransIntegrData.DIMENSION_4='CONPRT'
            Then 'SRVC'
            When FInalTransIntegrData.DIMENSION_4='pdprt'
            Then 'SRVC'
            When Left(FInalTransIntegrData.DIMENSION_4,3)='RPR'
            Then 'REPAIR'
            When FInalTransIntegrData.DIMENSION_4='FCNPRT'
            Then 'NCDR_FCN'
            When FInalTransIntegrData.DIMENSION_4='warprt'
            Then 'NCDR_WTY'
            When FInalTransIntegrData.DIMENSION_4='prwprt'
            Then 'NCDR_SUP'
            When FInalTransIntegrData.DIMENSION_4='insprt'
            Then 'NCDR_SUP'
            Else 'NCDR_OTHER'
        End, 
        FInalTransIntegrData.DIMENSION_5, 
        FInalTransIntegrData.REFERENCE, 
        FInalTransIntegrData.Ref_4, 
        FInalTransIntegrData.OType, 
        FInalTransIntegrData.FinalAmount, 

            case 
                when FInalTransIntegrData.LEDGER_ACC like '4%'
                then FInalTransIntegrData.FinalAmount
                else 0
            end,
            case 
                when FInalTransIntegrData.LEDGER_ACC like '5%'
                then FInalTransIntegrData.FinalAmount
                else 0
            end,          
        FInalTransIntegrData.FYPd, 
        DATE_FROM_PARTS(left(FInalTransIntegrData.FYPd,4),right(FInalTransIntegrData.FYPD,length(FInalTransIntegrData.FYPD) - position('_',FInalTransIntegrData.FYPD)),'01'),
        FInalTransIntegrData.BPID, 
        FInalTransIntegrData.BP, 
        Case 
            When FInalTransIntegrData.cost='Freight'
            Then 'Freight'
            Else FInalTransIntegrData.PartNo
        End, 
        Case
            When FInalTransIntegrData.cost='Freight'
            Then 'Freight'
            Else ITEM_DESCRIPTION
        End, 
        Case
            When FInalTransIntegrData.COST ILIKE 'Sales' And FInalTransIntegrData.FINALAMOUNT<0
            Then Abs(FInalTransIntegrData.FQTY)
            When FInalTransIntegrData.COST ILIKE 'Sales' And FInalTransIntegrData.FINALAMOUNT>0
            Then -1*Abs(FInalTransIntegrData.FQTY)
            When FInalTransIntegrData.COST ILIKE 'Cost' And FInalTransIntegrData.FINALAMOUNT>0
            Then Abs(FInalTransIntegrData.FQTY)
            When FInalTransIntegrData.COST ILIKE 'Cost' And FInalTransIntegrData.FINALAMOUNT<0
            Then -1*Abs(FInalTransIntegrData.FQTY)
            Else FInalTransIntegrData.FQTY
        End, 
        FInalTransIntegrData.RPR, 
        Case
            When Left(FInalTransIntegrData.partNo,3)='CPR'
            Then 'RPRSVC'
            When Left(FInalTransIntegrData.PartNo,3)='TFR'
            Then 'RPRPRT'
            When Right(FInalTransIntegrData.partno,4)='-RFS'
            Then 'RPREXC'
            When Right(FInalTransIntegrData.partno,4)='-RPR'
            Then 'RPRSVC'
            When Left(FInalTransIntegrData.dimension_4,3)='rpr'
            Then FInalTransIntegrData.Dimension_4
            When FInalTransIntegrData.rpr<>''
            Then FInalTransIntegrData.rpr
            Else FInalTransIntegrData.FCon
        End, 
        FInalTransIntegrData.SUPPLIER_GROUP, 
        Case
            When supplier_group='00001'
            Then 'TEL'
            Else 'NonTEL'
        End, 
        FInalTransIntegrData.SUPPLIER, 
        FInalTransIntegrData.COST_COMPONENT_DESC, 
        Case
            When Left(cost_component_desc,7)='surchar'
            Then FInalTransIntegrData.finalAmount
            Else 0
        End, 
        FInalTransIntegrData.ABC_LOCAL, 
        FInalTransIntegrData.FS_FLAG, 
        FInalTransIntegrData.NUMBER_OF_UNITS, 
        FInalTransIntegrData.SUPPLIER_ORDER_NO, 
        FInalTransIntegrData.EOL_FLAG, 
        FInalTransIntegrData.WAREHOUSE,
        FInalTransIntegrData.PartNo,
        FInalTransIntegrData.CPRBU,
        FInalTransIntegrData.CustPO,
        Customers.Customer,
        Customer_Group.Customer_Group,
        Item.Parts_Commodity,
        TEAItems.COMMODITY_DESC
    HAVING (((FInalTransIntegrData.DIMENSION_2) Like '9100%'))

)

,type_data as
(
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        ABC_LOCAL,
        BP,
        BPID,
        CAST(BSEQ  as NUMBER(38,0)) as  BSEQ,
        BUMOD,
        COST,
        COST_COMPONENT_DESC,
        DIMENSION_2,
        BUName,        
        DIMENSION_3,
        DIMENSION_4,
        DIMENSION_42,
        DIMENSION_5,
        CAST(DOC_DATE  as TIMESTAMP_NTZ(9)) as  DOC_DATE,
        DOCLINE,
        EOL_FLAG,
        CAST(FINALAMOUNT as NUMBER(38,10)) as  FINALAMOUNT,
        CAST(Revenue as NUMBER(38,10)) as  Revenue,
        CAST(COGS as NUMBER(38,10)) as  COGS,          
        FINALCON,
        FS_FLAG,
        FYPD,
        CAST(Calendardate as DATE) as Calendardate,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        CAST(NUMBER_OF_UNITS as NUMBER(38,0))as  NUMBER_OF_UNITS,
        OTYPE,
        PN,
        PN_DESC,
        CAST(QTY as NUMBER(38,0)) as  QTY,
        REF_4,
        REFERENCE,
        RPR,
        SALESTYPE,
        CAST(SEQ as NUMBER(38,0)) as  SEQ,
        SUPPLIER,
        SUPPLIER_GROUP,
        SUPPLIER_ORDER_NO,
        CAST(SURCHARGE as NUMBER(38,0)) as  SURCHARGE,
        TELSUPPLY,
        WAREHOUSE,
        PartNo,
        CPRBU,
        CustPO,
        Customer,
        Customer_Group,
        Parts_Commodity,
        COMMODITY_DESC
    from transform_data
)

select * from type_data