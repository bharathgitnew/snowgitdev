/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTHEADEREXPORT.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTHEADEREXPORT.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_ARIBAPAYMENTHEADEREXPORT 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:53 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTHEADEREXPORT',
    unique_key = ['PAYMENTID',
    'SEQUENCENO']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$COST AS NUMERIC(15,2))                                                                                                       AS ADJUSTEDTOTALCOST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACUR)),'')                                                                                         AS AMOUNTCURRENCY 
            ,CAST(CASE WHEN T$APDT<= '1/1/1970' THEN NULL ELSE T$APDT END AS DATE)                                                             AS APPROVALDATE 
            ,CAST(CASE WHEN T$BDAT<= '1/1/1970' THEN NULL ELSE T$BDAT END AS DATE)                                                             AS BASELINEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RDAT)),'')                                                                                         AS BASELINEDATEINREQUESTERTIMEZONE 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS BATCHNUMBER 
            ,CAST(T$COMP AS INT)                                                                                                                 AS COMPANYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNUM)),'')                                                                                         AS DIN_hash_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DURL)),'')                                                                                         AS DIRECTACTIONURL 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,CAST(CASE WHEN T$DUED<= '1/1/1970' THEN NULL ELSE T$DUED END AS DATE)                                                             AS DUEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EDAT)),'')                                                                                         AS EFFECTIVEDATEINREQUESTERTIMEZONE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FNAM)),'')                                                                                         AS FILENAME 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$YEAR AS INT)                                                                                                                 AS FISCALYEAR 
            ,CAST(T$GAMT AS NUMERIC(15,2))                                                                                                       AS GROSSAMOUNT 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT END AS DATE)                                                             AS INVOICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVN)),'')                                                                                         AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVT)),'')                                                                                         AS INVOICEPURPOSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REIN)),'')                                                                                         AS INVOICETOCREDITNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITXT)),'')                                                                                         AS ITEMTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PYDT)),'')                                                                                         AS PAYMENTTERMSEFFECTIVEDATE 
            ,T$ISPA.CONSTANTDESCRIPTION                                                                                                          AS PRICEADJUSTMENTINVOICEDESCRIPTION 
            ,CAST(T$ISPA AS INT)                                                                                                                 AS PRICEADJUSTMENTINVOICEID 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,CAST(CASE WHEN T$LUDT<= '1/1/1970' THEN NULL ELSE T$LUDT  END AS DATETIME) AS REPROCESSDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UPDT)),'')                                                                                         AS REPROCESSEDBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SAPI)),'')                                                                                         AS SAPINVOICEIND 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENO 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS SUPPLIERLOCATION 
            ,CAST(T$TAMT AS NUMERIC(15,2))                                                                                                       AS TAXACCURALAMOUNT 
            ,CAST(T$VPRD AS INT)                                                                                                                 AS TAXPERIOD 
            ,CAST(T$VYER AS INT)                                                                                                                 AS TAXYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD715200") }} AS SOURCETABLE  
            /*PRICEADJUSTMENTINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISPA 
             ON   T$ISPA.TABLENAME  = 'TFGLD715' 
              AND T$ISPA.COLUMNNAME = 'T$ISPA' 
              AND T$ISPA.CONSTANT   = SOURCETABLE.T$ISPA 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD715' 
              AND T$STUS.COLUMNNAME = 'T$STUS' 
              AND T$STUS.CONSTANT   = SOURCETABLE.T$STUS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$COST AS NUMERIC(15,2))                                                                                                       AS ADJUSTEDTOTALCOST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACUR)),'')                                                                                         AS AMOUNTCURRENCY 
            ,CAST(CASE WHEN T$APDT<= '1/1/1970' THEN NULL ELSE T$APDT END AS DATE)                                                             AS APPROVALDATE 
            ,CAST(CASE WHEN T$BDAT<= '1/1/1970' THEN NULL ELSE T$BDAT END AS DATE)                                                             AS BASELINEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RDAT)),'')                                                                                         AS BASELINEDATEINREQUESTERTIMEZONE 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS BATCHNUMBER 
            ,CAST(T$COMP AS INT)                                                                                                                 AS COMPANYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNUM)),'')                                                                                         AS DIN_hash_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DURL)),'')                                                                                         AS DIRECTACTIONURL 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,CAST(CASE WHEN T$DUED<= '1/1/1970' THEN NULL ELSE T$DUED END AS DATE)                                                             AS DUEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EDAT)),'')                                                                                         AS EFFECTIVEDATEINREQUESTERTIMEZONE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FNAM)),'')                                                                                         AS FILENAME 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$YEAR AS INT)                                                                                                                 AS FISCALYEAR 
            ,CAST(T$GAMT AS NUMERIC(15,2))                                                                                                       AS GROSSAMOUNT 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT END AS DATE)                                                             AS INVOICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVN)),'')                                                                                         AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVT)),'')                                                                                         AS INVOICEPURPOSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REIN)),'')                                                                                         AS INVOICETOCREDITNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITXT)),'')                                                                                         AS ITEMTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PYDT)),'')                                                                                         AS PAYMENTTERMSEFFECTIVEDATE 
            ,T$ISPA.CONSTANTDESCRIPTION                                                                                                          AS PRICEADJUSTMENTINVOICEDESCRIPTION 
            ,CAST(T$ISPA AS INT)                                                                                                                 AS PRICEADJUSTMENTINVOICEID 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,CAST(CASE WHEN T$LUDT<= '1/1/1970' THEN NULL ELSE T$LUDT  END AS DATETIME) AS REPROCESSDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UPDT)),'')                                                                                         AS REPROCESSEDBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SAPI)),'')                                                                                         AS SAPINVOICEIND 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENO 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS SUPPLIERLOCATION 
            ,CAST(T$TAMT AS NUMERIC(15,2))                                                                                                       AS TAXACCURALAMOUNT 
            ,CAST(T$VPRD AS INT)                                                                                                                 AS TAXPERIOD 
            ,CAST(T$VYER AS INT)                                                                                                                 AS TAXYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD715201") }} AS SOURCETABLE  
            /*PRICEADJUSTMENTINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISPA 
             ON   T$ISPA.TABLENAME  = 'TFGLD715' 
              AND T$ISPA.COLUMNNAME = 'T$ISPA' 
              AND T$ISPA.CONSTANT   = SOURCETABLE.T$ISPA 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD715' 
              AND T$STUS.COLUMNNAME = 'T$STUS' 
              AND T$STUS.CONSTANT   = SOURCETABLE.T$STUS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADJUSTEDTOTALCOST AS ADJUSTEDTOTALCOST, 
        source_data.AMOUNTCURRENCY AS AMOUNTCURRENCY, 
        source_data.APPROVALDATE AS APPROVALDATE, 
        source_data.BASELINEDATE AS BASELINEDATE, 
        source_data.BASELINEDATEINREQUESTERTIMEZONE AS BASELINEDATEINREQUESTERTIMEZONE, 
        source_data.BATCHNUMBER AS BATCHNUMBER, 
        source_data.COMPANYCODE AS COMPANYCODE, 
        source_data.DIN_HASH_ AS DIN_HASH_, 
        source_data.DIRECTACTIONURL AS DIRECTACTIONURL, 
        source_data.DOCUMENTNUMBER AS DOCUMENTNUMBER, 
        source_data.DUEDATE AS DUEDATE, 
        source_data.EFFECTIVEDATEINREQUESTERTIMEZONE AS EFFECTIVEDATEINREQUESTERTIMEZONE, 
        source_data.FILENAME AS FILENAME, 
        source_data.FISCALPERIOD AS FISCALPERIOD, 
        source_data.FISCALYEAR AS FISCALYEAR, 
        source_data.GROSSAMOUNT AS GROSSAMOUNT, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.INVOICEPURPOSE AS INVOICEPURPOSE, 
        source_data.INVOICETOCREDITNUMBER AS INVOICETOCREDITNUMBER, 
        source_data.ITEMTEXT AS ITEMTEXT, 
        source_data.PAYMENTID AS PAYMENTID, 
        source_data.PAYMENTMETHOD AS PAYMENTMETHOD, 
        source_data.PAYMENTTERMSEFFECTIVEDATE AS PAYMENTTERMSEFFECTIVEDATE, 
        source_data.PRICEADJUSTMENTINVOICEDESCRIPTION AS PRICEADJUSTMENTINVOICEDESCRIPTION, 
        source_data.PRICEADJUSTMENTINVOICEID AS PRICEADJUSTMENTINVOICEID, 
        source_data.PROCESSDATE AS PROCESSDATE, 
        source_data.REPROCESSDATE AS REPROCESSDATE, 
        source_data.REPROCESSEDBY AS REPROCESSEDBY, 
        source_data.SAPINVOICEIND AS SAPINVOICEIND, 
        source_data.SEQUENCENO AS SEQUENCENO, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.SUPPLIERLOCATION AS SUPPLIERLOCATION, 
        source_data.TAXACCURALAMOUNT AS TAXACCURALAMOUNT, 
        source_data.TAXPERIOD AS TAXPERIOD, 
        source_data.TAXYEAR AS TAXYEAR, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADJUSTEDTOTALCOST as NUMBER(15,2)) as ADJUSTEDTOTALCOST,
        cast(AMOUNTCURRENCY as VARCHAR(3)) as AMOUNTCURRENCY,
        cast(APPROVALDATE as DATE) as APPROVALDATE,
        cast(BASELINEDATE as DATE) as BASELINEDATE,
        cast(BASELINEDATEINREQUESTERTIMEZONE as VARCHAR(10)) as BASELINEDATEINREQUESTERTIMEZONE,
        cast(BATCHNUMBER as NUMBER(38,0)) as BATCHNUMBER,
        cast(COMPANYCODE as NUMBER(38,0)) as COMPANYCODE,
        cast(DIN_HASH_ as VARCHAR(12)) as DIN_HASH_,
        cast(DIRECTACTIONURL as VARCHAR(215)) as DIRECTACTIONURL,
        cast(DOCUMENTNUMBER as NUMBER(38,0)) as DOCUMENTNUMBER,
        cast(DUEDATE as DATE) as DUEDATE,
        cast(EFFECTIVEDATEINREQUESTERTIMEZONE as VARCHAR(20)) as EFFECTIVEDATEINREQUESTERTIMEZONE,
        cast(FILENAME as VARCHAR(100)) as FILENAME,
        cast(FISCALPERIOD as NUMBER(38,0)) as FISCALPERIOD,
        cast(FISCALYEAR as NUMBER(38,0)) as FISCALYEAR,
        cast(GROSSAMOUNT as NUMBER(15,2)) as GROSSAMOUNT,
        cast(INVOICEDATE as DATE) as INVOICEDATE,
        cast(INVOICENUMBER as VARCHAR(20)) as INVOICENUMBER,
        cast(INVOICEPURPOSE as VARCHAR(32)) as INVOICEPURPOSE,
        cast(INVOICETOCREDITNUMBER as VARCHAR(50)) as INVOICETOCREDITNUMBER,
        cast(ITEMTEXT as VARCHAR(999)) as ITEMTEXT,
        cast(PAYMENTID as VARCHAR(50)) as PAYMENTID,
        cast(PAYMENTMETHOD as VARCHAR(3)) as PAYMENTMETHOD,
        cast(PAYMENTTERMSEFFECTIVEDATE as VARCHAR(20)) as PAYMENTTERMSEFFECTIVEDATE,
        cast(PRICEADJUSTMENTINVOICEDESCRIPTION as VARCHAR(16777216)) as PRICEADJUSTMENTINVOICEDESCRIPTION,
        cast(PRICEADJUSTMENTINVOICEID as NUMBER(38,0)) as PRICEADJUSTMENTINVOICEID,
        cast(PROCESSDATE as TIMESTAMP_NTZ(9)) as PROCESSDATE,
        cast(REPROCESSDATE as TIMESTAMP_NTZ(9)) as REPROCESSDATE,
        cast(REPROCESSEDBY as VARCHAR(16)) as REPROCESSEDBY,
        cast(SAPINVOICEIND as VARCHAR(1)) as SAPINVOICEIND,
        cast(SEQUENCENO as NUMBER(38,0)) as SEQUENCENO,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(SUPPLIERLOCATION as VARCHAR(20)) as SUPPLIERLOCATION,
        cast(TAXACCURALAMOUNT as NUMBER(15,2)) as TAXACCURALAMOUNT,
        cast(TAXPERIOD as NUMBER(38,0)) as TAXPERIOD,
        cast(TAXYEAR as NUMBER(38,0)) as TAXYEAR,
        cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data