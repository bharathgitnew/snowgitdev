/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_BAAN_PROCITAPPROVEDINVOICESINFORMATION.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_BAAN_PROCITAPPROVEDINVOICESINFORMATION.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_BAAN_PROCITAPPROVEDINVOICESINFORMATION 
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
    alias='BAANFINANCEGENERALLEDGER_BAAN_PROCITAPPROVEDINVOICESINFORMATION',
    unique_key = ['COMPANY',
    'DOCUMENTNUMBER',
    'LINENUMBER',
    'TRANSACTIONTYPECODE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMTH AS NUMERIC(15,2))                                                                                                       AS AMOUNTINHOMECURRENCY 
            ,CAST(T$CONO AS INT)                                                                                                                 AS COMPANY 
            ,CAST(T$GLCO AS INT)                                                                                                                 AS COMPANYCODE 
            ,CAST(CASE WHEN T$INCD<= '1/1/1970' THEN NULL ELSE T$INCD  END AS DATETIME) AS CREATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNUM)),'')                                                                                         AS DIN_hash_ 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,CAST(CASE WHEN T$INDD<= '1/1/1970' THEN NULL ELSE T$INDD  END AS DATETIME) AS DUEDATE 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR 
            ,CAST(T$IFRT AS NUMERIC(15,2))                                                                                                       AS FREIGHT 
            ,CAST(T$HDID AS INT)                                                                                                                 AS HEADER 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS INVOICEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INCR)),'')                                                                                         AS INVOICECREATEDBY 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME) AS INVOICEDATE 
            ,CAST(T$INLC AS INT)                                                                                                                 AS INVOICELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVO)),'')                                                                                         AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$LNID AS INT)                                                                                                                 AS LINE 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PONUMBER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT  END AS DATETIME) AS POSTINGDATE 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS PURCHASEINVOICESBYBATCH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPP)),'')                                                                                         AS SUPPLIER 
            ,CAST(T$ITAX AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMNT)),'')                                                                                         AS TERMSOFPAYMENTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NOTE)),'')                                                                                         AS TEXT 
            ,CAST(T$LTOT AS NUMERIC(15,2))                                                                                                       AS TOTALAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPECODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ULEA)),'')                                                                                         AS UNMATCHEDLEDGERACC 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD962200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMTH AS NUMERIC(15,2))                                                                                                       AS AMOUNTINHOMECURRENCY 
            ,CAST(T$CONO AS INT)                                                                                                                 AS COMPANY 
            ,CAST(T$GLCO AS INT)                                                                                                                 AS COMPANYCODE 
            ,CAST(CASE WHEN T$INCD<= '1/1/1970' THEN NULL ELSE T$INCD  END AS DATETIME) AS CREATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNUM)),'')                                                                                         AS DIN_hash_ 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,CAST(CASE WHEN T$INDD<= '1/1/1970' THEN NULL ELSE T$INDD  END AS DATETIME) AS DUEDATE 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR 
            ,CAST(T$IFRT AS NUMERIC(15,2))                                                                                                       AS FREIGHT 
            ,CAST(T$HDID AS INT)                                                                                                                 AS HEADER 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS INVOICEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INCR)),'')                                                                                         AS INVOICECREATEDBY 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME) AS INVOICEDATE 
            ,CAST(T$INLC AS INT)                                                                                                                 AS INVOICELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVO)),'')                                                                                         AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$LNID AS INT)                                                                                                                 AS LINE 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PONUMBER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT  END AS DATETIME) AS POSTINGDATE 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS PURCHASEINVOICESBYBATCH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPP)),'')                                                                                         AS SUPPLIER 
            ,CAST(T$ITAX AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMNT)),'')                                                                                         AS TERMSOFPAYMENTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NOTE)),'')                                                                                         AS TEXT 
            ,CAST(T$LTOT AS NUMERIC(15,2))                                                                                                       AS TOTALAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPECODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ULEA)),'')                                                                                         AS UNMATCHEDLEDGERACC 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD962201") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNTINHOMECURRENCY AS AMOUNTINHOMECURRENCY, 
        source_data.COMPANY AS COMPANY, 
        source_data.COMPANYCODE AS COMPANYCODE, 
        source_data.CREATIONDATE AS CREATIONDATE, 
        source_data.CURRENCYCODE AS CURRENCYCODE, 
        source_data.DIMENSION1 AS DIMENSION1, 
        source_data.DIMENSION2 AS DIMENSION2, 
        source_data.DIMENSION3 AS DIMENSION3, 
        source_data.DIMENSION4 AS DIMENSION4, 
        source_data.DIMENSION5 AS DIMENSION5, 
        source_data.DIN_HASH_ AS DIN_HASH_, 
        source_data.DOCUMENTDATE AS DOCUMENTDATE, 
        source_data.DOCUMENTNUMBER AS DOCUMENTNUMBER, 
        source_data.DUEDATE AS DUEDATE, 
        source_data.FISCALPERIOD AS FISCALPERIOD, 
        source_data.FISCALYEAR AS FISCALYEAR, 
        source_data.FREIGHT AS FREIGHT, 
        source_data.HEADER AS HEADER, 
        source_data.INVOICEAMOUNT AS INVOICEAMOUNT, 
        source_data.INVOICECREATEDBY AS INVOICECREATEDBY, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICELINES AS INVOICELINES, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.LEDGERACCOUNT AS LEDGERACCOUNT, 
        source_data.LINE AS LINE, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.PONUMBER AS PONUMBER, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.POSTINGDATE AS POSTINGDATE, 
        source_data.PURCHASEINVOICESBYBATCH AS PURCHASEINVOICESBYBATCH, 
        source_data.SUPPLIER AS SUPPLIER, 
        source_data.TAXAMOUNT AS TAXAMOUNT, 
        source_data.TERMSOFPAYMENTS AS TERMSOFPAYMENTS, 
        source_data.TEXT AS TEXT, 
        source_data.TOTALAMOUNT AS TOTALAMOUNT, 
        source_data.TRANSACTIONTYPECODE AS TRANSACTIONTYPECODE, 
        source_data.UNMATCHEDLEDGERACC AS UNMATCHEDLEDGERACC
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
        cast(COMPANYCODE as NUMBER(38,0)) as COMPANYCODE,
        cast(CREATIONDATE as TIMESTAMP_NTZ(9)) as CREATIONDATE,
        cast(CURRENCYCODE as VARCHAR(3)) as CURRENCYCODE,
        cast(DIMENSION1 as VARCHAR(6)) as DIMENSION1,
        cast(DIMENSION2 as VARCHAR(6)) as DIMENSION2,
        cast(DIMENSION3 as VARCHAR(6)) as DIMENSION3,
        cast(DIMENSION4 as VARCHAR(6)) as DIMENSION4,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(DIN_HASH_ as VARCHAR(12)) as DIN_HASH_,
        cast(DOCUMENTDATE as DATE) as DOCUMENTDATE,
        cast(DOCUMENTNUMBER as NUMBER(38,0)) as DOCUMENTNUMBER,
        cast(DUEDATE as TIMESTAMP_NTZ(9)) as DUEDATE,
        cast(FISCALPERIOD as NUMBER(38,0)) as FISCALPERIOD,
        cast(FISCALYEAR as NUMBER(38,0)) as FISCALYEAR,
        cast(FREIGHT as NUMBER(15,2)) as FREIGHT,
        cast(HEADER as NUMBER(38,0)) as HEADER,
        cast(INVOICEAMOUNT as NUMBER(15,2)) as INVOICEAMOUNT,
        cast(INVOICECREATEDBY as VARCHAR(16)) as INVOICECREATEDBY,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICELINES as NUMBER(38,0)) as INVOICELINES,
        cast(INVOICENUMBER as VARCHAR(20)) as INVOICENUMBER,
        cast(LEDGERACCOUNT as VARCHAR(12)) as LEDGERACCOUNT,
        cast(LINE as NUMBER(38,0)) as LINE,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(PONUMBER as VARCHAR(9)) as PONUMBER,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(POSTINGDATE as TIMESTAMP_NTZ(9)) as POSTINGDATE,
        cast(PURCHASEINVOICESBYBATCH as NUMBER(38,0)) as PURCHASEINVOICESBYBATCH,
        cast(SUPPLIER as VARCHAR(9)) as SUPPLIER,
        cast(TAXAMOUNT as NUMBER(15,2)) as TAXAMOUNT,
        cast(TERMSOFPAYMENTS as VARCHAR(3)) as TERMSOFPAYMENTS,
        cast(TEXT as VARCHAR(30)) as TEXT,
        cast(TOTALAMOUNT as NUMBER(15,2)) as TOTALAMOUNT,
        cast(TRANSACTIONTYPECODE as VARCHAR(3)) as TRANSACTIONTYPECODE,
        cast(UNMATCHEDLEDGERACC as VARCHAR(12)) as UNMATCHEDLEDGERACC,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data