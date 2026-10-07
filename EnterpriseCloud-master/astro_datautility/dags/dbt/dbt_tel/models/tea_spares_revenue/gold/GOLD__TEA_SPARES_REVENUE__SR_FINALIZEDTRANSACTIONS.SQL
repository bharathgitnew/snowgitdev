{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SR_FINALIZEDTRANSACTIONS'
) }}

with final_trans_data as (
  select 
      AMOUNT,
      AMOUNT_IN_HC,
      BACKGROUND_SEQUENCE_NO,
      BATCH,
      BUSINESS_PARTNER_ID,
      CONTROL_ACCOUNT,
      COUNTRY,
      CURRENCY,
      DC,
      DC_DESC,
      DELETED,
      DIMENSION_1,
      DIMENSION_2,
      DIMENSION_3,
      DIMENSION_4,
      DIMENSION_5,
      DIMENSION_TYPE_1,
      DIMENSION_TYPE_2,
      DIMENSION_TYPE_3,
      DIMENSION_TYPE_4,
      DIMENSION_TYPE_5,
      DOCUMENT,
      DOC_DATE,
      FINALIZATION_DATE,
      FINALIZATION_RUN_NO,
      FINALIZATION_TIME,
      FINANCIAL_PERIOD,
      FISCAL_YEAR,
      INTEGRATION_TRANSACTION,
      INVOICE_CORRECTION,
      LAST_MODIFIED_BY,
      LEDGER_ACC,
      LEDGER_ACC_DESC,
      LINE,
      ORIGINAL_COMPANY,
      ORIGINAL_DOCUMENT_NO,
      ORIGINAL_TRANSACTION_TYPE,
      PERIOD_BEGINING,
      QUANTITY_1,
      QUANTITY_2,
      RATE,
      RATE_FACTOR,
      REFERENCE,
      REPORTING_PERIOD,
      REPORTING_YEAR,
      SEQUENCE_NUMBER,
      STANDING_ORDER,
      STANDING_ORDER_SEQUENCE_NO,
      TAX_AMOUNT,
      TAX_AMOUNT_HC,
      TAX_CODE,
      TAX_LEDGER_AC,
      TAX_PERIOD,
      TAX_TYPE,
      TAX_YEAR,
      TRANSACTION_CATEGORY,
      TRANSACTION_TEXT,
      TRANSACTION_TYPE,
      TRANS_TYPE_CORRECTION,
      TYPE_OF_CASH_TRANSACTION,
      TYPE_OF_TRANSACTION
  FROM {{ ref('SILVER__TEA_SPARES_REVENUE__FINALIZEDTRANSACTIONS') }}
)

,rev_cogs_source_data as (
  select 
      TRANSACTION_TYPE,
      DOCUMENT,
      LINE,
      SEQUENCE_NUMBER,
      BACKGROUND_SEQUENCE_NO,
      ORIGINAL_COMPANY,
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
      REFERENCE,
      AMOUNT,
      CURRENCY,
      RATE,
      RATE_FACTOR,
      AMOUNT_IN_HC,
      DC,
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
      REPORTING_PERIOD,
      REPORTING_YEAR,
      TAX_PERIOD,
      TAX_YEAR,
      BUSINESS_PARTNER_ID,
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
    FROM final_trans_data
    WHERE (LEDGER_ACC LIKE '1%'
    OR LEDGER_ACC LIKE '4%'
    OR LEDGER_ACC LIKE '5%')
    AND FISCAL_YEAR > 2009
)

,transform_data as (
  SELECT 
      '{{ invocation_id }}' AS _AUDIT_LOG_ID,
      SHA2('hash_me') as _ROW_HASH,
      TRANSACTION_TYPE,
      DOCUMENT,
      LINE,
      TRANSACTION_TYPE || DOCUMENT ||'_'|| LINE AS DOCLINE,
      SEQUENCE_NUMBER,
      BACKGROUND_SEQUENCE_NO,
      ORIGINAL_COMPANY,
      CASE
        WHEN LEFT(LEDGER_ACC,2)=56
        THEN 'Freight'
        WHEN LEFT(LEDGER_ACC,1)=4
        THEN 'Sales'
      ELSE 'Cost' END AS COST,
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
      CASE
        WHEN Right (dimension_4,1)='C' THEN 'Con'
        WHEN Right(dimension_4,3)='%C' THEN 'Con'
        WHEN Right(dimension_4,1)='N' THEN 'Non'
        WHEN Right(dimension_4,3)='%N' THEN 'Non'
        ELSE NULL 
      END AS CONSUM,
      CASE
        WHEN dimension_4 ilike 'sparec' THEN 'Sales'
        WHEN dimension_4 ilike 'sparen' THEN 'Sales'
        WHEN dimension_4 ilike 'qtzc' THEN 'Sales'
        WHEN dimension_4 ilike 'QTZN' THEN 'Sales'
        WHEN dimension_4 ilike 'IPO' THEN 'IPO'
        WHEN dimension_4 ilike 'CONPRT' THEN 'Srvc'
        WHEN dimension_4 ilike 'PDPRT' THEN 'Srvc'
        WHEN Left(dimension_4,3) ilike 'rpr' THEN 'Repair'
        WHEN dimension_4 ilike 'bbkprt' THEN 'BBK'
        ELSE 'NCDR' 
      END AS STYPE,
      REFERENCE,
      TRIM(REFERENCE) AS REF_1,
      CASE
          WHEN Left(Trim(reference),5) ilike 'GDNYI' THEN substr(Trim(reference),11,9)
          WHEN Left(Trim(reference),11) ilike 'REV - GDNYI' THEN substr(Trim(reference),17,9)
          WHEN Left(Trim(reference),9) ilike 'REV-GDNYI' THEN substr(Trim(reference),15,9)
          WHEN Left(Trim(reference),3) ilike 'NMB' THEN substr(Trim(reference),14,9)
          WHEN Left(Trim(reference),8) ilike 'REV -NMB' THEN substr(Trim(reference),19,9)
          WHEN Left(Trim(reference),9) ilike 'REV - NMB' THEN substr(Trim(reference),20,9)
          WHEN Left(Trim(reference),5) ilike 'REV -' THEN substr(Trim(reference),16,9)
          WHEN Left(Trim(reference),7) ilike 'REV-NMB' THEN substr(Trim(reference),18,9)
          WHEN Left(Trim(reference),4) ilike 'REV-' THEN substr(Trim(reference),5,9)
          WHEN Left(Trim(reference),3) ilike 'FAC' THEN substr(Trim(reference),1,9)
          WHEN Left(Trim(reference),3) ilike 'PRW' THEN substr(Trim(reference),1,9)
          WHEN Left(Trim(reference),3) ilike 'SUP' THEN substr(Trim(reference),1,9)
      ELSE Replace(Left(Trim(reference),10),'/','') END AS Ref_Order,
    CASE
    WHEN LEFT(TRIM(REFERENCE), 5) LIKE 'GDNYI' THEN SUBSTR(TRIM(REFERENCE), 11, 9)
    WHEN LEFT(TRIM(REFERENCE), 11) = 'REV - GDNYI' THEN SUBSTR(TRIM(REFERENCE), 17, 9)
    WHEN LEFT(TRIM(REFERENCE), 9) LIKE 'REV-GDNYI' THEN SUBSTR(TRIM(REFERENCE), 15, 9)
    WHEN LEFT(TRIM(REFERENCE), 10) LIKE 'REV -GDNYI' THEN SUBSTR(TRIM(REFERENCE), 16, 10) --NEW
    WHEN LEFT(TRIM(REFERENCE), 3) = 'NMB' THEN SUBSTR(TRIM(REFERENCE), 14, 9)
    WHEN LEFT(TRIM(REFERENCE), 8) = 'REV -NMB' THEN SUBSTR(TRIM(REFERENCE), 19, 9)
    WHEN LEFT(TRIM(REFERENCE), 9) = 'REV - NMB' THEN SUBSTR(TRIM(REFERENCE), 20, 9)
    WHEN LEFT(TRIM(REFERENCE), 4) = 'REV-' THEN SUBSTR(TRIM(REFERENCE), 16, 9)
    WHEN LEFT(TRIM(REFERENCE), 7) = 'REV-NMB' THEN SUBSTR(TRIM(REFERENCE), 18, 9)
    WHEN LEFT(TRIM(REFERENCE), 3) = 'REV-' THEN SUBSTR(TRIM(REFERENCE), 5, 9)
    WHEN LEFT(TRIM(REFERENCE), 3) = 'FAC' THEN SUBSTR(TRIM(REFERENCE), 1, 9)
    WHEN LEFT(TRIM(REFERENCE), 3) = 'PRW' THEN SUBSTR(TRIM(REFERENCE), 1, 9)
    WHEN LEFT(TRIM(REFERENCE), 3) = 'SUP' THEN SUBSTR(TRIM(REFERENCE), 1, 9)
    ELSE REPLACE(LEFT(TRIM(REFERENCE), 10), '/', '') END AS REF_ORDER_TEST2,
      CASE
        WHEN Left(Trim(reference),3) ilike 'WTY' THEN substr(Trim(reference),1,9)
        WHEN Left(Trim(reference),3) ilike 'TWS' THEN substr(Trim(reference),1,9)
        WHEN Left(Trim(reference),3) ilike 'FCN' THEN substr(Trim(reference),1,9)
        WHEN Left(Trim(reference),3) ilike 'TEL' THEN substr(Trim(reference),1,9)
        WHEN Left(Trim(reference),3) ilike 'EVL' THEN substr(Trim(reference),1,9)
        WHEN Left(Trim(reference),3) ilike 'TBS' THEN substr(Trim(reference),1,9)
      ELSE Replace(Left(Trim(reference),10),'/','') END AS Ref_Order1,
      CASE
        WHEN Left(Trim(reference),5) ilike 'GDNYI' THEN  substr(Trim(reference),21,4)
        WHEN Left(Trim(reference),11) ilike 'REV - GDNYI' THEN substr(Trim(reference),27,4)
        WHEN Left(Trim(reference),9) ilike 'REV-GDNYI' THEN substr(Trim(reference),25,4)
        WHEN Left(Trim(reference),3) ilike 'NMB' THEN substr(Trim(reference),24,4)
        WHEN Left(Trim(reference),8) ilike 'REV -NMB' THEN substr(Trim(reference),29,4)
        WHEN Left(Trim(reference),9) ilike 'REV - NMB' THEN substr(Trim(reference),30,4)
        WHEN Left(Trim(reference),5) ilike 'REV -' THEN substr(Trim(reference),26,4)
        WHEN Left(Trim(reference),7) ilike 'REV-NMB' THEN substr(Trim(reference),28,4)
        WHEN Left(Trim(reference),4) ilike 'REV-' THEN substr(Trim(reference),15,4)
        WHEN Left(Trim(reference),3) ilike 'FAC' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),3) ilike 'PRW' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),3) ilike 'SUP' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),1) ilike '/' THEN substr(Trim(reference),12,4)
      ELSE NULL END AS Ref_3,
      CASE
        WHEN Left(Trim(reference),3) ilike 'WTY' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),3) ilike 'TWS' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),3) ilike 'FCN' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),3) ilike 'TEL' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),3) ilike 'EVL' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),3) ilike 'TBS' THEN substr(Trim(reference),11,4)
        WHEN Left(Trim(reference),1) ilike '/' THEN substr(Trim(reference),12,4)
      ELSE NULL END AS Ref_31,
      CASE
        WHEN RIGHT(REF_3, 1) = '/' THEN CONCAT_WS('_', REF_ORDER, LEFT(REF_3, LEN(REF_3)-1))
        WHEN RIGHT(REF_3, 2) = '/0' THEN CONCAT_WS('_', REF_ORDER, LEFT(REF_3, LEN(REF_3)-2))
        WHEN RIGHT(REF_3, 2) = '/1' THEN CONCAT_WS('_', REF_ORDER, LEFT(REF_3, LEN(REF_3)-2))
        WHEN TRY_CAST(REF_3 AS NUMBER) IS NOT NULL THEN CONCAT_WS('_', REF_ORDER, TRY_CAST(REF_3 AS NUMBER))
        WHEN REF_ORDER1 Is Not Null THEN REF_ORDER1 || '_' || try_to_number(REF_31)
        ELSE REF_1 END AS REF_4,
      Left(REF_ORDER,4) AS OTYPE,
      AMOUNT,
      CURRENCY,
      RATE,
      RATE_FACTOR,
      AMOUNT_IN_HC,
      DC,
      CASE
      WHEN DC=2 THEN -AMOUNT_IN_HC 
      ELSE AMOUNT_IN_HC END AS FinalAmount,
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
      Fiscal_Year || '_' || financial_period AS FYPD,
      REPORTING_PERIOD,
      REPORTING_YEAR,
      TAX_PERIOD,
      TAX_YEAR,
      BUSINESS_PARTNER_ID,
      CASE
        WHEN Left(Trim(reference),5) ilike 'GDNYI' THEN 'Intel'
        WHEN Left(Trim(reference),4) ilike '/tws' THEN 'Intel'
        WHEN Left(Trim(reference),4) ilike '/tbs' THEN 'Intel'
        WHEN BUSINESS_PARTNER_ID='20301' THEN 'Intel'
        WHEN BUSINESS_PARTNER_ID='20306' THEN 'Intel'
        WHEN BUSINESS_PARTNER_ID='20316' THEN 'Intel'
      ELSE NULL END AS FT_INTEL,
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
  FROM rev_cogs_source_data
  WHERE (((rev_cogs_source_data.LEDGER_ACC ilike '5%')
  AND ((rev_cogs_source_data.DIMENSION_4) ilike 'spare%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike 'qtz%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike '%prt%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike 'rpr%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike '%pdf%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike '%rep%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike 'ipo%')
  OR (((rev_cogs_source_data.LEDGER_ACC ilike '4%')
  AND ((rev_cogs_source_data.DIMENSION_4) ilike 'spare%'
  OR (rev_cogs_source_data.DIMENSION_4) ilike 'qtz%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike '%prt%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike 'rpr%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike '%pdf%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike '%rep%' 
  OR (rev_cogs_source_data.DIMENSION_4) ilike 'ipo%')))))
)

,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        TRANSACTION_TYPE,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(LINE as NUMBER(38,0)) as LINE,
        DOCLINE,
        cast(SEQUENCE_NUMBER as NUMBER(38,0)) as SEQUENCE_NUMBER,
        cast(BACKGROUND_SEQUENCE_NO as NUMBER(38,0)) as BACKGROUND_SEQUENCE_NO,
        cast(ORIGINAL_COMPANY as NUMBER(38,0)) as ORIGINAL_COMPANY,
        COST,
        ORIGINAL_TRANSACTION_TYPE,
        cast(ORIGINAL_DOCUMENT_NO as NUMBER(38,0)) as ORIGINAL_DOCUMENT_NO,
        cast(BATCH as NUMBER(38,0)) as BATCH,
        LEDGER_ACC,
        LEDGER_ACC_DESC,
        cast(DOC_DATE as TIMESTAMP_NTZ(9)) as DOC_DATE,
        cast(DIMENSION_TYPE_1 as NUMBER(38,0)) as DIMENSION_TYPE_1,
        DIMENSION_1,
        cast(DIMENSION_TYPE_2 as NUMBER(38,0)) as DIMENSION_TYPE_2,
        DIMENSION_2,
        cast(DIMENSION_TYPE_3 as NUMBER(38,0)) as DIMENSION_TYPE_3,
        DIMENSION_3,
        cast(DIMENSION_TYPE_4 as NUMBER(38,0)) as DIMENSION_TYPE_4,
        DIMENSION_4,
        cast(DIMENSION_TYPE_5 as NUMBER(38,0)) as DIMENSION_TYPE_5,
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
        cast(AMOUNT as NUMBER(38,10)) as AMOUNT,
        CURRENCY,
        cast(RATE as NUMBER(18,2)) as RATE,
        cast(RATE_FACTOR as NUMBER(18,2)) as RATE_FACTOR,
        cast(AMOUNT_IN_HC as NUMBER(18,2)) as AMOUNT_IN_HC,
        cast(DC as NUMBER(38,10)) as DC,
        cast(FINALAMOUNT as NUMBER(38,10)) as FINALAMOUNT,
        DC_DESC,
        COUNTRY,
        TAX_CODE,
        cast(TAX_TYPE as NUMBER(38,10)) as TAX_TYPE,
        TAX_LEDGER_AC,
        cast(TAX_AMOUNT as NUMBER(18,2)) as TAX_AMOUNT,
        cast(TAX_AMOUNT_HC as NUMBER(18,2)) as TAX_AMOUNT_HC,
        cast(QUANTITY_1 as NUMBER(38,0)) as QUANTITY_1,
        cast(QUANTITY_2 as NUMBER(38,0)) as QUANTITY_2,
        cast(FINANCIAL_PERIOD as NUMBER(38,0)) as FINANCIAL_PERIOD,
        cast(FISCAL_YEAR as NUMBER(38,0)) as FISCAL_YEAR,
        FYPD,
        cast(REPORTING_PERIOD as NUMBER(38,0)) as REPORTING_PERIOD,
        cast(REPORTING_YEAR as NUMBER(38,0)) as REPORTING_YEAR,
        cast(TAX_PERIOD as NUMBER(38,0)) as TAX_PERIOD,
        cast(TAX_YEAR as NUMBER(38,0)) as TAX_YEAR,
        BUSINESS_PARTNER_ID,
        FT_INTEL,
        cast(TRANSACTION_CATEGORY as NUMBER(38,0)) as TRANSACTION_CATEGORY,
        LAST_MODIFIED_BY,
        cast(FINALIZATION_DATE as TIMESTAMP_NTZ(9)) as FINALIZATION_DATE,
        cast(FINALIZATION_TIME as NUMBER(38,0)) as FINALIZATION_TIME,
        cast(FINALIZATION_RUN_NO as NUMBER(38,0)) as FINALIZATION_RUN_NO,
        cast(CONTROL_ACCOUNT as NUMBER(38,0)) as CONTROL_ACCOUNT,
        TRANS_TYPE_CORRECTION,
        cast(INVOICE_CORRECTION as NUMBER(38,10)) as INVOICE_CORRECTION,
        cast(STANDING_ORDER as NUMBER(38,10)) as STANDING_ORDER,
        cast(STANDING_ORDER_SEQUENCE_NO as NUMBER(38,10)) as STANDING_ORDER_SEQUENCE_NO,
        cast(TYPE_OF_CASH_TRANSACTION as NUMBER(38,10)) as TYPE_OF_CASH_TRANSACTION,
        cast(TYPE_OF_TRANSACTION as NUMBER(38,10)) as TYPE_OF_TRANSACTION,
        cast(TRANSACTION_TEXT as NUMBER(38,10)) as TRANSACTION_TEXT,
        cast(DELETED as NUMBER(38,10)) as DELETED,
        cast(INTEGRATION_TRANSACTION as NUMBER(38,10)) as INTEGRATION_TRANSACTION,
        cast(PERIOD_BEGINING as TIMESTAMP_NTZ(9)) as PERIOD_BEGINING
    from transform_data
    )
select * from type_data