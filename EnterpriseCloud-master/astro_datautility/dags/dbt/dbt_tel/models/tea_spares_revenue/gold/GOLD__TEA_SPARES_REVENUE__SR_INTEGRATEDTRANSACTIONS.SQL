{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SR_INTEGRATEDTRANSACTIONS'
) }}

with int_trans_data as (
  select 
        AMOUNT,
        BATCH_NUMBER,
        CONFIGURATION,
        CONTRACT_TYPE,
        COST_COMPONENT,
        COST_COMPONENT_DESC,
        COST_PRICE_COMPONENT,
        COUNTRY,
        CREATED_BY,
        CURRENCY,
        CURRENCY_RATE,
        CURRENCY_RATE_FACTOR,
        DC,
        DIMENSION_1,
        DIMENSION_2,
        DIMENSION_3,
        DIMENSION_4,
        DIMENSION_5,
        DOCUMENT,
        DOCUMENT_LINE_NUMBER,
        FINANCE_COMPANY,
        FINANCIAL_PERIOD,
        FINANCIAL_TRANSACTION,
        FISCAL_YEAR,
        INSTALLMENT,
        INVOICE_FROM_BPID,
        ITEM,
        LEDGER_ACC,
        LOG_DATE,
        MODEL,
        NUMBER_OF_PERIODS,
        NUMBER_OF_UNITS,
        ORDER_NO,
        ORDER_POSITION,
        ORDER_SEQUENCE_NO,
        ORIGINAL_COMPANY,
        POSTED_BY,
        POSTING_DATE,
        PRODUCT_CLASS,
        PROJECT,
        QUANTITY_1,
        QUANTITY_2,
        REFERENCE,
        REPORTING_PERIOD,
        REPORTING_YEAR,
        SEQUENCE_NUMBER,
        SERIAL_NUMBER,
        SERVICE_COST_TYPE,
        SERVICE_ITEM,
        SERVICE_ITEM_GROUP,
        SERVICE_OFFICE,
        SERVICE_TYPE,
        SHIP_FROM_BP,
        SHIP_FROM_BPID,
        SHIP_TO_BP,
        SHIP_TO_BPID,
        SOLD_TO_BP,
        SOLD_TO_BPID,
        TAX_AMOUNT,
        TAX_PERIOD,
        TAX_TYPE,
        TAX_YEAR,
        TEA_BU,
        TEL_BU,
        TRANSACTION_DATE,
        TRANSACTION_ORIGIN,
        TRANSACTION_STATUS,
        TRANSACTION_TYPE,
        UNIT,
        WAREHOUSE,
        WARRANTY,
        WARRANTY_TYPE
    FROM {{ ref('SILVER__TEA_SPARES_REVENUE__INTEGRATEDTRANSACTIONS') }}
)

,source_data as
(
  SELECT 
    ORIGINAL_COMPANY,
    TRANSACTION_ORIGIN,
    FINANCIAL_TRANSACTION,
    LOG_DATE,
    SEQUENCE_NUMBER,
    TRANSACTION_TYPE,
    DOCUMENT,
    DOCUMENT_LINE_NUMBER,
    FINANCE_COMPANY,
    INVOICE_FROM_BPID,
    LEDGER_ACC,
    DIMENSION_1,
    DIMENSION_2,
    DIMENSION_3,
    DIMENSION_4,
    DIMENSION_5,
    FISCAL_YEAR,
    FINANCIAL_PERIOD,
    TAX_YEAR,
    TAX_PERIOD,
    REPORTING_YEAR,
    REPORTING_PERIOD,
    CURRENCY,
    CURRENCY_RATE,
    CURRENCY_RATE_FACTOR,
    AMOUNT,
    DC,
    REFERENCE,
    COUNTRY,
    TAX_TYPE,
    TAX_AMOUNT,
    QUANTITY_1,
    QUANTITY_2,
    NUMBER_OF_UNITS,
    UNIT,
    CREATED_BY,
    TRANSACTION_DATE,
    ORDER_NO,
    ORDER_POSITION,
    ORDER_SEQUENCE_NO,
    COST_PRICE_COMPONENT,
    WAREHOUSE,
    ITEM,
    PROJECT,
    NUMBER_OF_PERIODS,
    TRANSACTION_STATUS,
    BATCH_NUMBER,
    POSTED_BY,
    POSTING_DATE,
    TEL_BU,
    TEA_BU,
    PRODUCT_CLASS,
    COST_COMPONENT,
    COST_COMPONENT_DESC,
    CONFIGURATION,
    MODEL,
    SERIAL_NUMBER,
    WARRANTY,
    SERVICE_OFFICE,
    WARRANTY_TYPE,
    CONTRACT_TYPE,
    SERVICE_TYPE,
    SERVICE_ITEM_GROUP,
    SERVICE_COST_TYPE,
    SERVICE_ITEM,
    INSTALLMENT,
    SOLD_TO_BPID,
    SOLD_TO_BP,
    SHIP_FROM_BPID,
    SHIP_FROM_BP,
    SHIP_TO_BPID,
    SHIP_TO_BP
  FROM int_trans_data
  WHERE (LEDGER_ACC LIKE '1%'
  OR LEDGER_ACC LIKE '4%'
  OR LEDGER_ACC LIKE '5%')
  AND FISCAL_YEAR > 2009
)

,transform_data as (
  SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    transaction_type||document||'_'||document_line_number AS IDOCLINE, 
    ORDER_NO||'_'||order_position AS OrderLine, 
    ORDER_SEQUENCE_NO, 
    ITEM, 
    NUMBER_OF_UNITS AS Qty, 
    PRODUCT_CLASS, 
    DIMENSION_4,
    Fiscal_Year || '_' || financial_period AS FYPD,
    COST_COMPONENT_DESC, 
    TEA_BU, 
    LEDGER_ACC, 
    AMOUNT, 
    DC, 
    CASE
    WHEN DC=2 THEN -AMOUNT 
    ELSE AMOUNT END AS FinalAmount,
    CASE
    WHEN finalamount>0 And Left(ledger_acc,1)='4' THEN -number_of_units
    WHEN finalamount<0 And Left(ledger_acc,1)='5' THEN -number_of_units
    ELSE number_of_units END AS FinalQty, 
    NUMBER_OF_UNITS, 
    WAREHOUSE, 
    SOLD_TO_BP, 
    SHIP_TO_BP
  FROM source_data
  WHERE (((source_data.DIMENSION_4) ilike 'spare%'
  Or (source_data.DIMENSION_4) ilike '%prt' 
  Or (source_data.DIMENSION_4) ilike 'qtz%' 
  Or (source_data.DIMENSION_4) ilike 'rpr%' 
  Or (source_data.DIMENSION_4) ilike '%rep%' 
  Or (source_data.DIMENSION_4) ilike '%pdf%' 
  Or (source_data.DIMENSION_4) ilike 'ip%'))
)
,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        IDOCLINE,
        ORDERLINE,
        cast(ORDER_SEQUENCE_NO as NUMBER(38,0)) as ORDER_SEQUENCE_NO,
        ITEM,
        cast(QTY as NUMBER(38,0)) as QTY,
        PRODUCT_CLASS,
        DIMENSION_4,
        FYPD,
        COST_COMPONENT_DESC,
        TEA_BU,
        LEDGER_ACC,
        cast(AMOUNT as NUMBER(38,10)) as AMOUNT,
        cast(DC as NUMBER(38,0)) as DC,
        cast(FINALAMOUNT as NUMBER(38,10)) as FINALAMOUNT,
        cast(FINALQTY as NUMBER(38,0)) as FINALQTY,
        cast(NUMBER_OF_UNITS as NUMBER(38,0)) as NUMBER_OF_UNITS,
        WAREHOUSE,
        SOLD_TO_BP,
        SHIP_TO_BP
    from transform_data
    )
select * from type_data