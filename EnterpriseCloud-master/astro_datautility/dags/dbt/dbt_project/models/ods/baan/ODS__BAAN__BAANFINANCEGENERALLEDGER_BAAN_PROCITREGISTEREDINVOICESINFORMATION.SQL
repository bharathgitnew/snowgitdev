/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_BAAN_PROCITREGISTEREDINVOICESINFORMATION.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_BAAN_PROCITREGISTEREDINVOICESINFORMATION.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_BAAN_PROCITREGISTEREDINVOICESINFORMATION 
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
    alias='BAANFINANCEGENERALLEDGER_BAAN_PROCITREGISTEREDINVOICESINFORMATION',
    unique_key = ['COMPANY',
    'DOCUMENTNUMBER',
    'LINENUMBER',
    'TRANSACTIONTYPE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMTH AS NUMERIC(15,2))                                                                                                       AS AMOUNTINHOMECURRENCY 
            ,CAST(T$CONO AS INT)                                                                                                                 AS COMPANY 
            ,CAST(CASE WHEN T$INCD<= '1/1/1970' THEN NULL ELSE T$INCD  END AS DATETIME) AS CREATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNUM)),'')                                                                                         AS DIN_hash_ 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,CAST(CASE WHEN T$INDD<= '1/1/1970' THEN NULL ELSE T$INDD END AS DATE)                                                             AS DUEDATE 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR 
            ,CAST(T$IFRT AS NUMERIC(15,2))                                                                                                       AS FREI 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS INVOICEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INCR)),'')                                                                                         AS INVOICECREATEDBY 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD END AS DATE)                                                             AS INVOICEDATE 
            ,CAST(T$INLC AS INT)                                                                                                                 AS INVOICELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVO)),'')                                                                                         AS INVOICENUMBER 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PONUMBER 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT  END AS DATETIME) AS POSTINGDATE 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS PURCHASEINVOICESBYBATCH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPP)),'')                                                                                         AS SUPPLIER 
            ,CAST(T$ITAX AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMNT)),'')                                                                                         AS TERMSOFPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NOTE)),'')                                                                                         AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD961200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMTH AS NUMERIC(15,2))                                                                                                       AS AMOUNTINHOMECURRENCY 
            ,CAST(T$CONO AS INT)                                                                                                                 AS COMPANY 
            ,CAST(CASE WHEN T$INCD<= '1/1/1970' THEN NULL ELSE T$INCD  END AS DATETIME) AS CREATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNUM)),'')                                                                                         AS DIN_hash_ 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,CAST(CASE WHEN T$INDD<= '1/1/1970' THEN NULL ELSE T$INDD END AS DATE)                                                             AS DUEDATE 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR 
            ,CAST(T$IFRT AS NUMERIC(15,2))                                                                                                       AS FREI 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS INVOICEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INCR)),'')                                                                                         AS INVOICECREATEDBY 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD END AS DATE)                                                             AS INVOICEDATE 
            ,CAST(T$INLC AS INT)                                                                                                                 AS INVOICELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVO)),'')                                                                                         AS INVOICENUMBER 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PONUMBER 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT  END AS DATETIME) AS POSTINGDATE 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS PURCHASEINVOICESBYBATCH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPP)),'')                                                                                         AS SUPPLIER 
            ,CAST(T$ITAX AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMNT)),'')                                                                                         AS TERMSOFPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NOTE)),'')                                                                                         AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD961201") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNTINHOMECURRENCY AS AMOUNTINHOMECURRENCY, 
        source_data.COMPANY AS COMPANY, 
        source_data.CREATIONDATE AS CREATIONDATE, 
        source_data.CURRENCYCODE AS CURRENCYCODE, 
        source_data.DIN_HASH_ AS DIN_HASH_, 
        source_data.DOCUMENTDATE AS DOCUMENTDATE, 
        source_data.DOCUMENTNUMBER AS DOCUMENTNUMBER, 
        source_data.DUEDATE AS DUEDATE, 
        source_data.FISCALPERIOD AS FISCALPERIOD, 
        source_data.FISCALYEAR AS FISCALYEAR, 
        source_data.FREI AS FREI, 
        source_data.INVOICEAMOUNT AS INVOICEAMOUNT, 
        source_data.INVOICECREATEDBY AS INVOICECREATEDBY, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICELINES AS INVOICELINES, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.PONUMBER AS PONUMBER, 
        source_data.POSTINGDATE AS POSTINGDATE, 
        source_data.PURCHASEINVOICESBYBATCH AS PURCHASEINVOICESBYBATCH, 
        source_data.SUPPLIER AS SUPPLIER, 
        source_data.TAXAMOUNT AS TAXAMOUNT, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.TEXT AS TEXT, 
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
        cast(AMOUNTINHOMECURRENCY as NUMBER(15,2)) as AMOUNTINHOMECURRENCY,
        cast(COMPANY as NUMBER(38,0)) as COMPANY,
        cast(CREATIONDATE as TIMESTAMP_NTZ(9)) as CREATIONDATE,
        cast(CURRENCYCODE as VARCHAR(3)) as CURRENCYCODE,
        cast(DIN_HASH_ as VARCHAR(12)) as DIN_HASH_,
        cast(DOCUMENTDATE as DATE) as DOCUMENTDATE,
        cast(DOCUMENTNUMBER as NUMBER(38,0)) as DOCUMENTNUMBER,
        cast(DUEDATE as DATE) as DUEDATE,
        cast(FISCALPERIOD as NUMBER(38,0)) as FISCALPERIOD,
        cast(FISCALYEAR as NUMBER(38,0)) as FISCALYEAR,
        cast(FREI as NUMBER(15,2)) as FREI,
        cast(INVOICEAMOUNT as NUMBER(15,2)) as INVOICEAMOUNT,
        cast(INVOICECREATEDBY as VARCHAR(16)) as INVOICECREATEDBY,
        cast(INVOICEDATE as DATE) as INVOICEDATE,
        cast(INVOICELINES as NUMBER(38,0)) as INVOICELINES,
        cast(INVOICENUMBER as VARCHAR(20)) as INVOICENUMBER,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(PONUMBER as VARCHAR(9)) as PONUMBER,
        cast(POSTINGDATE as TIMESTAMP_NTZ(9)) as POSTINGDATE,
        cast(PURCHASEINVOICESBYBATCH as NUMBER(38,0)) as PURCHASEINVOICESBYBATCH,
        cast(SUPPLIER as VARCHAR(9)) as SUPPLIER,
        cast(TAXAMOUNT as NUMBER(15,2)) as TAXAMOUNT,
        cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT,
        cast(TEXT as VARCHAR(30)) as TEXT,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data