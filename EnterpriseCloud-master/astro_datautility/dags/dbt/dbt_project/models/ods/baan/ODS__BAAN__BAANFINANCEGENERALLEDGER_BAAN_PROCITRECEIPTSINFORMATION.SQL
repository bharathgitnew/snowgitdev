/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_BAAN_PROCITRECEIPTSINFORMATION.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_BAAN_PROCITRECEIPTSINFORMATION.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_BAAN_PROCITRECEIPTSINFORMATION 
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
    alias='BAANFINANCEGENERALLEDGER_BAAN_PROCITRECEIPTSINFORMATION',
    unique_key = ['COMPANYNUMBER',
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
            ,CAST(T$CONO AS INT)                                                                                                                 AS COMPANYNUMBER 
            ,CAST(T$UCST AS NUMERIC(15,2))                                                                                                       AS COST_percent_PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS PURCHASEINVOICESBYBATCH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PURCHASEORDER 
            ,CAST(CASE WHEN T$RCDT<= '1/1/1970' THEN NULL ELSE T$RCDT  END AS DATETIME) AS RECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCPT)),'')                                                                                         AS RECEIPTDETAILS 
            ,CAST(T$QNTY AS NUMERIC(15,2))                                                                                                       AS RECEIVEDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCUS)),'')                                                                                         AS RECEIVERUSERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RRFN)),'')                                                                                         AS REFERENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RQUS)),'')                                                                                         AS REQUESTORUSERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPP)),'')                                                                                         AS SUPPLIER 
            ,CAST(T$TCST AS NUMERIC(15,2))                                                                                                       AS TOTALCOST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPECODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ULEA)),'')                                                                                         AS UNMATCHEDLEDGERACC 
          
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD960200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMTH AS NUMERIC(15,2))                                                                                                       AS AMOUNTINHOMECURRENCY 
            ,CAST(T$CONO AS INT)                                                                                                                 AS COMPANYNUMBER 
            ,CAST(T$UCST AS NUMERIC(15,2))                                                                                                       AS COST_percent_PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS PURCHASEINVOICESBYBATCH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PURCHASEORDER 
            ,CAST(CASE WHEN T$RCDT<= '1/1/1970' THEN NULL ELSE T$RCDT  END AS DATETIME) AS RECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCPT)),'')                                                                                         AS RECEIPTDETAILS 
            ,CAST(T$QNTY AS NUMERIC(15,2))                                                                                                       AS RECEIVEDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCUS)),'')                                                                                         AS RECEIVERUSERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RRFN)),'')                                                                                         AS REFERENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RQUS)),'')                                                                                         AS REQUESTORUSERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUPP)),'')                                                                                         AS SUPPLIER 
            ,CAST(T$TCST AS NUMERIC(15,2))                                                                                                       AS TOTALCOST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPECODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ULEA)),'')                                                                                         AS UNMATCHEDLEDGERACC 
          
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD960201") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNTINHOMECURRENCY AS AMOUNTINHOMECURRENCY, 
        source_data.COMPANYNUMBER AS COMPANYNUMBER, 
        source_data.COST_PERCENT_PRICE AS COST_PERCENT_PRICE, 
        source_data.CURRENCYCODE AS CURRENCYCODE, 
        source_data.DIMENSION1 AS DIMENSION1, 
        source_data.DIMENSION2 AS DIMENSION2, 
        source_data.DIMENSION3 AS DIMENSION3, 
        source_data.DIMENSION4 AS DIMENSION4, 
        source_data.DIMENSION5 AS DIMENSION5, 
        source_data.DOCUMENTDATE AS DOCUMENTDATE, 
        source_data.DOCUMENTNUMBER AS DOCUMENTNUMBER, 
        source_data.FISCALPERIOD AS FISCALPERIOD, 
        source_data.FISCALYEAR AS FISCALYEAR, 
        source_data.ITEM AS ITEM, 
        source_data.LEDGERACCOUNT AS LEDGERACCOUNT, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.PURCHASEINVOICESBYBATCH AS PURCHASEINVOICESBYBATCH, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.RECEIPTDATE AS RECEIPTDATE, 
        source_data.RECEIPTDETAILS AS RECEIPTDETAILS, 
        source_data.RECEIVEDQUANTITY AS RECEIVEDQUANTITY, 
        source_data.RECEIVERUSERID AS RECEIVERUSERID, 
        source_data.REFERENCENUMBER AS REFERENCENUMBER, 
        source_data.REQUESTORUSERID AS REQUESTORUSERID, 
        source_data.SUPPLIER AS SUPPLIER, 
        source_data.TOTALCOST AS TOTALCOST, 
        source_data.TRANSACTIONTYPECODE AS TRANSACTIONTYPECODE, 
        source_data.UNIT AS UNIT, 
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
        cast(COMPANYNUMBER as NUMBER(38,0)) as COMPANYNUMBER,
        cast(COST_PERCENT_PRICE as NUMBER(15,2)) as COST_PERCENT_PRICE,
        cast(CURRENCYCODE as VARCHAR(3)) as CURRENCYCODE,
        cast(DIMENSION1 as VARCHAR(6)) as DIMENSION1,
        cast(DIMENSION2 as VARCHAR(6)) as DIMENSION2,
        cast(DIMENSION3 as VARCHAR(6)) as DIMENSION3,
        cast(DIMENSION4 as VARCHAR(6)) as DIMENSION4,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(DOCUMENTDATE as DATE) as DOCUMENTDATE,
        cast(DOCUMENTNUMBER as NUMBER(38,0)) as DOCUMENTNUMBER,
        cast(FISCALPERIOD as NUMBER(38,0)) as FISCALPERIOD,
        cast(FISCALYEAR as NUMBER(38,0)) as FISCALYEAR,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LEDGERACCOUNT as VARCHAR(12)) as LEDGERACCOUNT,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(PURCHASEINVOICESBYBATCH as NUMBER(38,0)) as PURCHASEINVOICESBYBATCH,
        cast(PURCHASEORDER as VARCHAR(9)) as PURCHASEORDER,
        cast(RECEIPTDATE as TIMESTAMP_NTZ(9)) as RECEIPTDATE,
        cast(RECEIPTDETAILS as VARCHAR(20)) as RECEIPTDETAILS,
        cast(RECEIVEDQUANTITY as NUMBER(15,2)) as RECEIVEDQUANTITY,
        cast(RECEIVERUSERID as VARCHAR(16)) as RECEIVERUSERID,
        cast(REFERENCENUMBER as VARCHAR(100)) as REFERENCENUMBER,
        cast(REQUESTORUSERID as VARCHAR(16)) as REQUESTORUSERID,
        cast(SUPPLIER as VARCHAR(9)) as SUPPLIER,
        cast(TOTALCOST as NUMBER(15,2)) as TOTALCOST,
        cast(TRANSACTIONTYPECODE as VARCHAR(3)) as TRANSACTIONTYPECODE,
        cast(UNIT as VARCHAR(3)) as UNIT,
        cast(UNMATCHEDLEDGERACC as VARCHAR(12)) as UNMATCHEDLEDGERACC,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data