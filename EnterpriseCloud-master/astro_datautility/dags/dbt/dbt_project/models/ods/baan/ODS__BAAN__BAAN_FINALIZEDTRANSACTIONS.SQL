{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='BAAN_FINALIZEDTRANSACTIONS',
    unique_key = []
) }}

with source_data as 
(

SELECT
           a._CAPTUREDATETIME
               AS _CAPTUREDATETIME,
           a.t$otyp
               AS transaction_type,
           a.t$odoc
               AS document,
           a.t$olin
               AS line,
           a.t$osrl
               AS sequence_number,
           a.t$osrn
               AS background_sequence_no,
           a.t$ocmp
               AS original_company,
           a.t$ftyp
               AS original_transaction_type,
           a.t$fdoc
               AS original_document_no,
           a.t$obat
               AS batch,
           a.t$leac
               AS ledger_acc,
           b.t$desc
               AS ledger_acc_desc,
           /*
           Via CAS-33875-C0L9C6 Ticket
           TRUNC (
               DECODE (
                   a.t$dcdt,
                   TO_DATE ('08/20/0012', 'MM/DD/YYYY'), TO_DATE (
                                                             NULL,
                                                             'MM/DD/YYYY'),
                   a.t$dcdt + INTERVAL '-4:00:00' HOUR TO SECOND),
               'DD')
               AS doc_date,
           */
           a.t$dcdt
               AS doc_date,
           a.t$typ1
               AS dimension_type_1,
           a.t$dim1
               AS dimension_1,
           a.t$typ2
               AS dimension_type_2,
           a.t$dim2
               AS dimension_2,
           a.t$typ3
               AS dimension_type_3,
           a.t$dim3
               AS dimension_3,
           a.t$typ4
               AS dimension_type_4,
           a.t$dim4
               AS dimension_4,
           a.t$typ5
               AS dimension_type_5,
           a.t$dim5
               AS dimension_5,
           a.t$refr
               AS REFERENCE,
           a.t$amnt
               AS amount,
           a.t$ccur
               AS currency,
           a."T$RATE$1"
               AS rate,
           a."T$FACT$1"
               AS rate_factor,
           a."T$AMTH$1"
               AS amount_in_hc,
           a.t$dbcr
               AS dc,
           DECODE (a.t$dbcr,  1, 'Debit',  2, 'Credit',  '??')
               AS dc_desc,
           a.t$ccty
               AS country,
           a.t$cvat
               AS tax_code,
           a.t$vtyp
               AS tax_type,
           a.t$vlac
               AS tax_ledger_ac,
           a.t$vamt
               AS tax_amount,
           a."T$VAMH$1"
               AS tax_amount_hc,
           a.t$qty1
               AS quantity_1,
           a.t$qty2
               AS quantity_2,
           a.t$fprd
               AS financial_period,
           a.t$fyer
               AS fiscal_year,
           a.t$rprd
               AS reporting_period,
           a.t$ryer
               AS reporting_year,
           a.t$vprd
               AS tax_period,
           a.t$vyer
               AS tax_year,
           a.t$bpid
               AS business_partner_id,
           a.t$catg
               AS transaction_category,
           a.t$user
               AS last_modified_by,
           /*
           Via CAS-33875-C0L9C6 Ticket
           TRUNC (
               DECODE (
                   a.t$date,
                   TO_DATE ('08/20/0012', 'MM/DD/YYYY'), TO_DATE (
                                                             NULL,
                                                             'MM/DD/YYYY'),
                   a.t$date + INTERVAL '-4:00:00' HOUR TO SECOND),
               'DD')
               AS finalization_date,
            */
           a.t$date
               AS finalization_date,
           a.t$time
               AS finalization_time,
           a.t$trun
               AS finalization_run_no,
           a.t$cont
               AS control_account,
           a.t$ctyp
               AS trans_type_correction,
           a.t$cinv
               AS invoice_correction,
           a.t$corn
               AS standing_order,
           a.t$csrn
               AS standing_order_sequence_no,
           a.t$tcsh
               AS type_of_cash_transaction,
          a.t$tran
               AS type_of_transaction,
           a.t$txta
               AS transaction_text,
           a.t$dele
               AS deleted,
           a.t$intt
               AS integration_transaction,
           c.t$stdt
               AS period_begining
      FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD106201") }}  a,          /* Finalized Transactions */
                      {{ source("BAAN_ORACLE_LIVE", "TTFGLD008200") }} b, /* Chart of Accounts (use TEH) */
                           {{ source("BAAN_ORACLE_LIVE", "TTFGLD005200") }} c   /* Periods */
     WHERE     a.t$leac = b.t$leac
           AND c.t$ptyp = 1
           AND a.t$fyer = c.t$year
           AND a.t$fprd = c.t$prno

),

transform_data as
(
    SELECT *,
       '{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
    FROM source_data
),

type_data as
(
    SELECT
        cast(TRANSACTION_TYPE as VARCHAR(3)) as   TRANSACTION_TYPE,
        cast(DOCUMENT as NUMBER(38,0)) as   DOCUMENT,
        cast(LINE as NUMBER(38,0)) as   LINE,
        cast(SEQUENCE_NUMBER as NUMBER(38,0)) as   SEQUENCE_NUMBER,
        cast(BACKGROUND_SEQUENCE_NO as NUMBER(38,0)) as   BACKGROUND_SEQUENCE_NO,
        cast(ORIGINAL_COMPANY as NUMBER(38,0)) as   ORIGINAL_COMPANY,
        cast(ORIGINAL_TRANSACTION_TYPE as VARCHAR(3)) as   ORIGINAL_TRANSACTION_TYPE,
        cast(ORIGINAL_DOCUMENT_NO as NUMBER(38,0)) as   ORIGINAL_DOCUMENT_NO,
        cast(BATCH as NUMBER(38,0)) as   BATCH,
        cast(LEDGER_ACC as VARCHAR(12)) as   LEDGER_ACC,
        cast(LEDGER_ACC_DESC as VARCHAR(30)) as   LEDGER_ACC_DESC,
        cast(DOC_DATE as TIMESTAMP_NTZ(9)) as   DOC_DATE,
        cast(DIMENSION_TYPE_1 as NUMBER(38,0)) as   DIMENSION_TYPE_1,
        cast(DIMENSION_1 as VARCHAR(6)) as   DIMENSION_1,
        cast(DIMENSION_TYPE_2 as NUMBER(38,0)) as   DIMENSION_TYPE_2,
        cast(DIMENSION_2 as VARCHAR(6)) as   DIMENSION_2,
        cast(DIMENSION_TYPE_3 as NUMBER(38,0)) as   DIMENSION_TYPE_3,
        cast(DIMENSION_3 as VARCHAR(6)) as   DIMENSION_3,
        cast(DIMENSION_TYPE_4 as NUMBER(38,0)) as   DIMENSION_TYPE_4,
        cast(DIMENSION_4 as VARCHAR(6)) as   DIMENSION_4,
        cast(DIMENSION_TYPE_5 as NUMBER(38,0)) as   DIMENSION_TYPE_5,
        cast(DIMENSION_5 as VARCHAR(6)) as   DIMENSION_5,
        cast(REFERENCE as VARCHAR(32)) as   REFERENCE,
        cast(AMOUNT as NUMBER(38,10)) as   AMOUNT,
        cast(CURRENCY as VARCHAR(3)) as   CURRENCY,
        cast(RATE as NUMBER(18,2)) as   RATE,
        cast(RATE_FACTOR as NUMBER(18,2)) as   RATE_FACTOR,
        cast(AMOUNT_IN_HC as NUMBER(18,2)) as   AMOUNT_IN_HC,
        cast(DC as NUMBER(38,10)) as   DC,
        cast(DC_DESC as VARCHAR(6)) as   DC_DESC,
        cast(COUNTRY as VARCHAR(3)) as   COUNTRY,
        cast(TAX_CODE as VARCHAR(9)) as   TAX_CODE,
        cast(TAX_TYPE as NUMBER(38,10)) as   TAX_TYPE,
        cast(TAX_LEDGER_AC as VARCHAR(12)) as   TAX_LEDGER_AC,
        cast(TAX_AMOUNT as NUMBER(18,2)) as   TAX_AMOUNT,
        cast(TAX_AMOUNT_HC as NUMBER(18,2)) as   TAX_AMOUNT_HC,
        cast(QUANTITY_1 as NUMBER(38,0)) as   QUANTITY_1,
        cast(QUANTITY_2 as NUMBER(38,0)) as   QUANTITY_2,
        cast(FINANCIAL_PERIOD as NUMBER(38,0)) as   FINANCIAL_PERIOD,
        cast(FISCAL_YEAR as NUMBER(38,0)) as   FISCAL_YEAR,
        cast(REPORTING_PERIOD as NUMBER(38,0)) as   REPORTING_PERIOD,
        cast(REPORTING_YEAR as NUMBER(38,0)) as   REPORTING_YEAR,
        cast(TAX_PERIOD as NUMBER(38,0)) as   TAX_PERIOD,
        cast(TAX_YEAR as NUMBER(38,0)) as   TAX_YEAR,
        cast(BUSINESS_PARTNER_ID as VARCHAR(9)) as   BUSINESS_PARTNER_ID,
        cast(TRANSACTION_CATEGORY as NUMBER(38,0)) as   TRANSACTION_CATEGORY,
        cast(LAST_MODIFIED_BY as VARCHAR(16)) as   LAST_MODIFIED_BY,
        cast(FINALIZATION_DATE as TIMESTAMP_NTZ(9)) as   FINALIZATION_DATE,
        cast(FINALIZATION_TIME as NUMBER(38,0)) as   FINALIZATION_TIME,
        cast(FINALIZATION_RUN_NO as NUMBER(38,0)) as   FINALIZATION_RUN_NO,
        cast(CONTROL_ACCOUNT as NUMBER(38,0)) as   CONTROL_ACCOUNT,
        cast(TRANS_TYPE_CORRECTION as VARCHAR(3)) as   TRANS_TYPE_CORRECTION,
        cast(INVOICE_CORRECTION as NUMBER(38,10)) as   INVOICE_CORRECTION,
        cast(STANDING_ORDER as NUMBER(38,10)) as   STANDING_ORDER,
        cast(STANDING_ORDER_SEQUENCE_NO as NUMBER(38,10)) as   STANDING_ORDER_SEQUENCE_NO,
        cast(TYPE_OF_CASH_TRANSACTION as NUMBER(38,10)) as   TYPE_OF_CASH_TRANSACTION,
        cast(TYPE_OF_TRANSACTION as NUMBER(38,10)) as   TYPE_OF_TRANSACTION,
        cast(TRANSACTION_TEXT as NUMBER(38,10)) as   TRANSACTION_TEXT,
        cast(DELETED as NUMBER(38,10)) as   DELETED,
        cast(INTEGRATION_TRANSACTION as NUMBER(38,10)) as   INTEGRATION_TRANSACTION,
        cast(PERIOD_BEGINING as TIMESTAMP_NTZ(9)) as   PERIOD_BEGINING,
        cast(AUDIT_LOG_ID as VARCHAR(36)) as   AUDIT_LOG_ID,
        cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as   _CAPTUREDATETIME
    FROM transform_data

)


select * from type_data