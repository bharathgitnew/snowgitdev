/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEACCOUNTSRECEIVABLE_OPENITEMSSALESINVOICES_AND_RECEIPTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEACCOUNTSRECEIVABLE_OPENITEMSSALESINVOICES_AND_RECEIPTS.SQL 
-materialized incremental
-alias BAANFINANCEACCOUNTSRECEIVABLE_OPENITEMSSALESINVOICES_AND_RECEIPTS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:51 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEACCOUNTSRECEIVABLE_OPENITEMSSALESINVOICES_AND_RECEIPTS',
    unique_key = ['_COMPANYID',
    'DOCUMENT',
    'DOCUMENTNUMBER',
    'LINE',
    'LINENUMBER',
    'TRANSACTIONTYPE_TTYP']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY3 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                       AS AMOUNTININVCURR 
            ,CAST(T$DOCA AS BIGINT)                                                                                                              AS ANTICIPATEDDOCUMENTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TYPA)),'')                                                                                         AS ANTICIPATEDTRANSACTIONTYPE 
            ,T$ARRQ.CONSTANTDESCRIPTION                                                                                                          AS ARRINVOICEDESCRIPTION 
            ,CAST(T$ARRQ AS INT)                                                                                                                 AS ARRINVOICEID 
            ,CAST(T$BALC AS NUMERIC(15,2))                                                                                                       AS BALANCEAMOUNT 
            ,CAST(T$BALA AS NUMERIC(15,2))                                                                                                       AS BALANCEANTICIPATED 
            ,CAST("T$BAHC$1" AS NUMERIC(15,2))                                                                                                     AS BALANCEANTICIPATEDINHC1 
            ,CAST("T$BAHC$2" AS NUMERIC(15,2))                                                                                                     AS BALANCEANTICIPATEDINHC2 
            ,CAST("T$BAHC$3" AS NUMERIC(15,2))                                                                                                     AS BALANCEANTICIPATEDINHC3 
            ,CAST("T$BALH$1" AS NUMERIC(15,2))                                                                                                     AS BALANCEINHC1 
            ,CAST("T$BALH$2" AS NUMERIC(15,2))                                                                                                     AS BALANCEINHC2 
            ,CAST("T$BALH$3" AS NUMERIC(15,2))                                                                                                     AS BALANCEINHC3 
            ,CAST(T$BACO AS NUMERIC(15,2))                                                                                                       AS BANKCHARGES 
            ,CAST("T$BACA$1" AS NUMERIC(15,2))                                                                                                     AS BANKCHARGESHC1 
            ,CAST("T$BACA$2" AS NUMERIC(15,2))                                                                                                     AS BANKCHARGESHC2 
            ,CAST("T$BACA$3" AS NUMERIC(15,2))                                                                                                     AS BANKCHARGESHC3 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS BATCHNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS BUSINESSPARTNER 
            ,T$CAIN.CONSTANTDESCRIPTION                                                                                                          AS CALCULATEINTERESTDESCRIPTION 
            ,CAST(T$CAIN AS INT)                                                                                                                 AS CALCULATEINTERESTID 
            ,CAST(T$BASI AS NUMERIC(15,2))                                                                                                       AS CURRENCYDIFFBASIS 
            ,CAST("T$CDAM$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYDIFFERENCE1 
            ,CAST("T$CDAM$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYDIFFERENCE2 
            ,CAST("T$CDAM$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYDIFFERENCE3 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BANK)),'')                                                                                         AS CUSTOMERSBANK 
            ,CAST(T$NINV AS BIGINT)                                                                                                              AS DOCUMENT 
            ,CAST(CASE WHEN T$DOCD<= '1/1/1970' THEN NULL ELSE T$DOCD END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,T$TREC.CONSTANTDESCRIPTION                                                                                                          AS DOCUMENTTYPEDESCRIPTION 
            ,CAST(T$TREC AS INT)                                                                                                                 AS DOCUMENTTYPEID 
            ,T$DOUB.CONSTANTDESCRIPTION                                                                                                          AS DOUBTFULDESCRIPTION 
            ,CAST(T$DOUB AS INT)                                                                                                                 AS DOUBTFULID 
            ,CAST(CASE WHEN T$DUED<= '1/1/1970' THEN NULL ELSE T$DUED END AS DATE)                                                             AS DUEDATE 
            ,CAST(CASE WHEN T$LIQD<= '1/1/1970' THEN NULL ELSE T$LIQD END AS DATE)                                                             AS EXPECTEDLIQUIDITYDATE 
            ,CAST(T$DC1A AS NUMERIC(15,2))                                                                                                       AS FIRSTDISCOUNTAMOUNT 
            ,CAST("T$DC1H$1" AS NUMERIC(15,2))                                                                                                     AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY1 
            ,CAST("T$DC1H$2" AS NUMERIC(15,2))                                                                                                     AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY2 
            ,CAST("T$DC1H$3" AS NUMERIC(15,2))                                                                                                     AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY3 
            ,CAST(T$DC1I AS NUMERIC(15,2))                                                                                                       AS FIRSTDISCOUNTAMOUNTININVOICECURRENCY 
            ,CAST(CASE WHEN T$DID1<= '1/1/1970' THEN NULL ELSE T$DID1 END AS DATE)                                                             AS FIRSTDISCOUNTDATE 
            ,CAST(T$PROD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$YEAR AS INT)                                                                                                                 AS FISCALYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS INVOICE_percent_AMOUNT 
            ,CAST(CASE WHEN T$LPDT<= '1/1/1970' THEN NULL ELSE T$LPDT END AS DATE)                                                             AS LATEPAYMENTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,CAST(T$LAPA AS NUMERIC(15,2))                                                                                                       AS LATEPMTSURCHAMT 
            ,CAST("T$LAPH$1" AS NUMERIC(15,2))                                                                                                     AS LATEPMTSURCHAMTINHC1 
            ,CAST("T$LAPH$2" AS NUMERIC(15,2))                                                                                                     AS LATEPMTSURCHAMTINHC2 
            ,CAST("T$LAPH$3" AS NUMERIC(15,2))                                                                                                     AS LATEPMTSURCHAMTINHC3 
            ,CAST(T$LAPI AS NUMERIC(15,2))                                                                                                       AS LATEPMTSURCHARGEAMOUNTINIC 
            ,CAST(T$LETT AS TINYINT)                                                                                                             AS LETTERNUMBER 
            ,T$LVAT.CONSTANTDESCRIPTION                                                                                                          AS LEVELOFTAXCALCULATIONDESCRIPTION 
            ,CAST(T$LVAT AS INT)                                                                                                                 AS LEVELOFTAXCALCULATIONID 
            ,CAST(T$LINE AS BIGINT)                                                                                                              AS LINE 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,CAST(T$LAMT AS NUMERIC(15,2))                                                                                                       AS LINKEDAMOUNT 
            ,CAST(T$ORNO AS BIGINT)                                                                                                              AS ORDER_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS ORDER_FROMBUSPAR 
            ,CAST(T$OINV AS BIGINT)                                                                                                              AS ORIGINALINVOICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYBYBUSINESSPARTNER 
            ,CAST(T$PADA AS NUMERIC(15,2))                                                                                                       AS PAYMENTDIFFERENCE 
            ,CAST("T$PADH$1" AS NUMERIC(15,2))                                                                                                     AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY1 
            ,CAST("T$PADH$2" AS NUMERIC(15,2))                                                                                                     AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY2 
            ,CAST("T$PADH$3" AS NUMERIC(15,2))                                                                                                     AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY3 
            ,CAST(T$PADI AS NUMERIC(15,2))                                                                                                       AS PAYMENTDIFFERENCEAMOUNTININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTRECEIPTMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ADRS)),'')                                                                                         AS POSTALADDRESS 
            ,CAST(T$POST AS BIGINT)                                                                                                              AS POSTINGBATCH 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT END AS DATE)                                                             AS POSTINGDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PROB)),'')                                                                                         AS PROBLEMCODE 
            ,CAST(CASE WHEN T$PROP<= '1/1/1970' THEN NULL ELSE T$PROP END AS DATE)                                                             AS PROBLEMDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PREF)),'')                                                                                         AS PROBLEMREFERENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PROJ)),'')                                                                                         AS PROJECT 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATECAT 
            ,T$RADE.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINATIONDESCRIPTION 
            ,CAST(T$RADE AS INT)                                                                                                                 AS RATEDETERMINATIONID 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RATETYPE 
            ,T$STEP.CONSTANTDESCRIPTION                                                                                                          AS RECEIPTPROCEDURESTEPDESCRIPTION 
            ,CAST(T$STEP AS INT)                                                                                                                 AS RECEIPTPROCEDURESTEPID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREP)),'')                                                                                         AS SALESREP 
            ,CAST(T$DC2A AS NUMERIC(15,2))                                                                                                       AS SECONDDISCOUNTAMOUNT 
            ,CAST("T$DC2H$1" AS NUMERIC(15,2))                                                                                                     AS SECONDDISCOUNTAMOUNTINHOMECURRENCY1 
            ,CAST("T$DC2H$2" AS NUMERIC(15,2))                                                                                                     AS SECONDDISCOUNTAMOUNTINHOMECURRENCY2 
            ,CAST("T$DC2H$3" AS NUMERIC(15,2))                                                                                                     AS SECONDDISCOUNTAMOUNTINHOMECURRENCY3 
            ,CAST(T$DC2I AS NUMERIC(15,2))                                                                                                       AS SECONDDISCOUNTAMOUNTININVOICECURRENCY 
            ,CAST(CASE WHEN T$DID2<= '1/1/1970' THEN NULL ELSE T$DID2 END AS DATE)                                                             AS SECONDDISCOUNTDATE 
            ,CAST(T$SVAM AS NUMERIC(15,2))                                                                                                       AS SHIFTEDTAX 
            ,CAST("T$SVAH$1" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXHC1 
            ,CAST("T$SVAH$2" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXHC2 
            ,CAST("T$SVAH$3" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXHC3 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS STATISTICSUPDATEDDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS STATISTICSUPDATEDID 
            ,T$RCPT.CONSTANTDESCRIPTION                                                                                                          AS STATUSFORLINKINGUNALLOCATEDPAYMENTDESCRIPTION 
            ,CAST(T$RCPT AS INT)                                                                                                                 AS STATUSFORLINKINGUNALLOCATEDPAYMENTID 
            ,CAST(T$VATA AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,CAST("T$VATH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$VATH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$VATH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,CAST(T$VATI AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTINIC 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$VATC)),'')                                                                                         AS TAXCOUNTRY 
            ,CAST(T$VATP AS INT)                                                                                                                 AS TAXPERIOD 
            ,CAST(T$VATY AS INT)                                                                                                                 AS TAXYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,SOURCETABLE.T$TEXT   /* TEXT */                                                                                                     AS TEXT 
            ,CAST(T$DC3A AS NUMERIC(15,2))                                                                                                       AS THIRDDISCOUNTAMOUNT 
            ,CAST("T$DC3H$1" AS NUMERIC(15,2))                                                                                                     AS THIRDDISCOUNTAMOUNTINHOMECURRENCY1 
            ,CAST("T$DC3H$2" AS NUMERIC(15,2))                                                                                                     AS THIRDDISCOUNTAMOUNTINHOMECURRENCY2 
            ,CAST("T$DC3H$3" AS NUMERIC(15,2))                                                                                                     AS THIRDDISCOUNTAMOUNTINHOMECURRENCY3 
            ,CAST(T$DC3I AS NUMERIC(15,2))                                                                                                       AS THIRDDISCOUNTAMOUNTININVOICECURRENCY 
            ,CAST(CASE WHEN T$DID3<= '1/1/1970' THEN NULL ELSE T$DID3 END AS DATE)                                                             AS THIRDDISCOUNTDATE 
            ,CAST("T$TORE$1" AS NUMERIC(15,2))                                                                                                     AS TOREALIZEDCURRENCYDIFFERENCES1 
            ,CAST("T$TORE$2" AS NUMERIC(15,2))                                                                                                     AS TOREALIZEDCURRENCYDIFFERENCES2 
            ,CAST("T$TORE$3" AS NUMERIC(15,2))                                                                                                     AS TOREALIZEDCURRENCYDIFFERENCES3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFR)),'')                                                                                         AS TRANSACTIONREFERENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTYP)),'')                                                                                         AS TRANSACTIONTYPEOFORIGINALINVOICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TDOC)),'')                                                                                         AS TRANSACTIONTYPE_TDOC 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE_TTYP 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFACR200200") }} AS SOURCETABLE  
            /*ARRINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ARRQ 
             ON   T$ARRQ.TABLENAME  = 'TFACR200' 
              AND T$ARRQ.COLUMNNAME = 'T$ARRQ' 
              AND T$ARRQ.CONSTANT   = SOURCETABLE.T$ARRQ 
            /*CALCULATEINTEREST*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CAIN 
             ON   T$CAIN.TABLENAME  = 'TFACR200' 
              AND T$CAIN.COLUMNNAME = 'T$CAIN' 
              AND T$CAIN.CONSTANT   = SOURCETABLE.T$CAIN 
            /*DOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TREC 
             ON   T$TREC.TABLENAME  = 'TFACR200' 
              AND T$TREC.COLUMNNAME = 'T$TREC' 
              AND T$TREC.CONSTANT   = SOURCETABLE.T$TREC 
            /*DOUBTFUL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DOUB 
             ON   T$DOUB.TABLENAME  = 'TFACR200' 
              AND T$DOUB.COLUMNNAME = 'T$DOUB' 
              AND T$DOUB.CONSTANT   = SOURCETABLE.T$DOUB 
            /*LEVELOFTAXCALCULATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LVAT 
             ON   T$LVAT.TABLENAME  = 'TFACR200' 
              AND T$LVAT.COLUMNNAME = 'T$LVAT' 
              AND T$LVAT.CONSTANT   = SOURCETABLE.T$LVAT 
            /*RATEDETERMINATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RADE 
             ON   T$RADE.TABLENAME  = 'TFACR200' 
              AND T$RADE.COLUMNNAME = 'T$RADE' 
              AND T$RADE.CONSTANT   = SOURCETABLE.T$RADE 
            /*RECEIPTPROCEDURESTEP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STEP 
             ON   T$STEP.TABLENAME  = 'TFACR200' 
              AND T$STEP.COLUMNNAME = 'T$STEP' 
              AND T$STEP.CONSTANT   = SOURCETABLE.T$STEP 
            /*STATISTICSUPDATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'TFACR200' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*STATUSFORLINKINGUNALLOCATEDPAYMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RCPT 
             ON   T$RCPT.TABLENAME  = 'TFACR200' 
              AND T$RCPT.COLUMNNAME = 'T$RCPT' 
              AND T$RCPT.CONSTANT   = SOURCETABLE.T$RCPT 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY3 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                       AS AMOUNTININVCURR 
            ,CAST(T$DOCA AS BIGINT)                                                                                                              AS ANTICIPATEDDOCUMENTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TYPA)),'')                                                                                         AS ANTICIPATEDTRANSACTIONTYPE 
            ,T$ARRQ.CONSTANTDESCRIPTION                                                                                                          AS ARRINVOICEDESCRIPTION 
            ,CAST(T$ARRQ AS INT)                                                                                                                 AS ARRINVOICEID 
            ,CAST(T$BALC AS NUMERIC(15,2))                                                                                                       AS BALANCEAMOUNT 
            ,CAST(T$BALA AS NUMERIC(15,2))                                                                                                       AS BALANCEANTICIPATED 
            ,CAST("T$BAHC$1" AS NUMERIC(15,2))                                                                                                     AS BALANCEANTICIPATEDINHC1 
            ,CAST("T$BAHC$2" AS NUMERIC(15,2))                                                                                                     AS BALANCEANTICIPATEDINHC2 
            ,CAST("T$BAHC$3" AS NUMERIC(15,2))                                                                                                     AS BALANCEANTICIPATEDINHC3 
            ,CAST("T$BALH$1" AS NUMERIC(15,2))                                                                                                     AS BALANCEINHC1 
            ,CAST("T$BALH$2" AS NUMERIC(15,2))                                                                                                     AS BALANCEINHC2 
            ,CAST("T$BALH$3" AS NUMERIC(15,2))                                                                                                     AS BALANCEINHC3 
            ,CAST(T$BACO AS NUMERIC(15,2))                                                                                                       AS BANKCHARGES 
            ,CAST("T$BACA$1" AS NUMERIC(15,2))                                                                                                     AS BANKCHARGESHC1 
            ,CAST("T$BACA$2" AS NUMERIC(15,2))                                                                                                     AS BANKCHARGESHC2 
            ,CAST("T$BACA$3" AS NUMERIC(15,2))                                                                                                     AS BANKCHARGESHC3 
            ,CAST(T$BTNO AS BIGINT)                                                                                                              AS BATCHNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS BUSINESSPARTNER 
            ,T$CAIN.CONSTANTDESCRIPTION                                                                                                          AS CALCULATEINTERESTDESCRIPTION 
            ,CAST(T$CAIN AS INT)                                                                                                                 AS CALCULATEINTERESTID 
            ,CAST(T$BASI AS NUMERIC(15,2))                                                                                                       AS CURRENCYDIFFBASIS 
            ,CAST("T$CDAM$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYDIFFERENCE1 
            ,CAST("T$CDAM$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYDIFFERENCE2 
            ,CAST("T$CDAM$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYDIFFERENCE3 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BANK)),'')                                                                                         AS CUSTOMERSBANK 
            ,CAST(T$NINV AS BIGINT)                                                                                                              AS DOCUMENT 
            ,CAST(CASE WHEN T$DOCD<= '1/1/1970' THEN NULL ELSE T$DOCD END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(T$DOCN AS BIGINT)                                                                                                              AS DOCUMENTNUMBER 
            ,T$TREC.CONSTANTDESCRIPTION                                                                                                          AS DOCUMENTTYPEDESCRIPTION 
            ,CAST(T$TREC AS INT)                                                                                                                 AS DOCUMENTTYPEID 
            ,T$DOUB.CONSTANTDESCRIPTION                                                                                                          AS DOUBTFULDESCRIPTION 
            ,CAST(T$DOUB AS INT)                                                                                                                 AS DOUBTFULID 
            ,CAST(CASE WHEN T$DUED<= '1/1/1970' THEN NULL ELSE T$DUED END AS DATE)                                                             AS DUEDATE 
            ,CAST(CASE WHEN T$LIQD<= '1/1/1970' THEN NULL ELSE T$LIQD END AS DATE)                                                             AS EXPECTEDLIQUIDITYDATE 
            ,CAST(T$DC1A AS NUMERIC(15,2))                                                                                                       AS FIRSTDISCOUNTAMOUNT 
            ,CAST("T$DC1H$1" AS NUMERIC(15,2))                                                                                                     AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY1 
            ,CAST("T$DC1H$2" AS NUMERIC(15,2))                                                                                                     AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY2 
            ,CAST("T$DC1H$3" AS NUMERIC(15,2))                                                                                                     AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY3 
            ,CAST(T$DC1I AS NUMERIC(15,2))                                                                                                       AS FIRSTDISCOUNTAMOUNTININVOICECURRENCY 
            ,CAST(CASE WHEN T$DID1<= '1/1/1970' THEN NULL ELSE T$DID1 END AS DATE)                                                             AS FIRSTDISCOUNTDATE 
            ,CAST(T$PROD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$YEAR AS INT)                                                                                                                 AS FISCALYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS INVOICE_percent_AMOUNT 
            ,CAST(CASE WHEN T$LPDT<= '1/1/1970' THEN NULL ELSE T$LPDT END AS DATE)                                                             AS LATEPAYMENTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,CAST(T$LAPA AS NUMERIC(15,2))                                                                                                       AS LATEPMTSURCHAMT 
            ,CAST("T$LAPH$1" AS NUMERIC(15,2))                                                                                                     AS LATEPMTSURCHAMTINHC1 
            ,CAST("T$LAPH$2" AS NUMERIC(15,2))                                                                                                     AS LATEPMTSURCHAMTINHC2 
            ,CAST("T$LAPH$3" AS NUMERIC(15,2))                                                                                                     AS LATEPMTSURCHAMTINHC3 
            ,CAST(T$LAPI AS NUMERIC(15,2))                                                                                                       AS LATEPMTSURCHARGEAMOUNTINIC 
            ,CAST(T$LETT AS TINYINT)                                                                                                             AS LETTERNUMBER 
            ,T$LVAT.CONSTANTDESCRIPTION                                                                                                          AS LEVELOFTAXCALCULATIONDESCRIPTION 
            ,CAST(T$LVAT AS INT)                                                                                                                 AS LEVELOFTAXCALCULATIONID 
            ,CAST(T$LINE AS BIGINT)                                                                                                              AS LINE 
            ,CAST(T$LINO AS BIGINT)                                                                                                              AS LINENUMBER 
            ,CAST(T$LAMT AS NUMERIC(15,2))                                                                                                       AS LINKEDAMOUNT 
            ,CAST(T$ORNO AS BIGINT)                                                                                                              AS ORDER_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS ORDER_FROMBUSPAR 
            ,CAST(T$OINV AS BIGINT)                                                                                                              AS ORIGINALINVOICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYBYBUSINESSPARTNER 
            ,CAST(T$PADA AS NUMERIC(15,2))                                                                                                       AS PAYMENTDIFFERENCE 
            ,CAST("T$PADH$1" AS NUMERIC(15,2))                                                                                                     AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY1 
            ,CAST("T$PADH$2" AS NUMERIC(15,2))                                                                                                     AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY2 
            ,CAST("T$PADH$3" AS NUMERIC(15,2))                                                                                                     AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY3 
            ,CAST(T$PADI AS NUMERIC(15,2))                                                                                                       AS PAYMENTDIFFERENCEAMOUNTININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTRECEIPTMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ADRS)),'')                                                                                         AS POSTALADDRESS 
            ,CAST(T$POST AS BIGINT)                                                                                                              AS POSTINGBATCH 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT END AS DATE)                                                             AS POSTINGDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PROB)),'')                                                                                         AS PROBLEMCODE 
            ,CAST(CASE WHEN T$PROP<= '1/1/1970' THEN NULL ELSE T$PROP END AS DATE)                                                             AS PROBLEMDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PREF)),'')                                                                                         AS PROBLEMREFERENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PROJ)),'')                                                                                         AS PROJECT 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATECAT 
            ,T$RADE.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINATIONDESCRIPTION 
            ,CAST(T$RADE AS INT)                                                                                                                 AS RATEDETERMINATIONID 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RATETYPE 
            ,T$STEP.CONSTANTDESCRIPTION                                                                                                          AS RECEIPTPROCEDURESTEPDESCRIPTION 
            ,CAST(T$STEP AS INT)                                                                                                                 AS RECEIPTPROCEDURESTEPID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREP)),'')                                                                                         AS SALESREP 
            ,CAST(T$DC2A AS NUMERIC(15,2))                                                                                                       AS SECONDDISCOUNTAMOUNT 
            ,CAST("T$DC2H$1" AS NUMERIC(15,2))                                                                                                     AS SECONDDISCOUNTAMOUNTINHOMECURRENCY1 
            ,CAST("T$DC2H$2" AS NUMERIC(15,2))                                                                                                     AS SECONDDISCOUNTAMOUNTINHOMECURRENCY2 
            ,CAST("T$DC2H$3" AS NUMERIC(15,2))                                                                                                     AS SECONDDISCOUNTAMOUNTINHOMECURRENCY3 
            ,CAST(T$DC2I AS NUMERIC(15,2))                                                                                                       AS SECONDDISCOUNTAMOUNTININVOICECURRENCY 
            ,CAST(CASE WHEN T$DID2<= '1/1/1970' THEN NULL ELSE T$DID2 END AS DATE)                                                             AS SECONDDISCOUNTDATE 
            ,CAST(T$SVAM AS NUMERIC(15,2))                                                                                                       AS SHIFTEDTAX 
            ,CAST("T$SVAH$1" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXHC1 
            ,CAST("T$SVAH$2" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXHC2 
            ,CAST("T$SVAH$3" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXHC3 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS STATISTICSUPDATEDDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS STATISTICSUPDATEDID 
            ,T$RCPT.CONSTANTDESCRIPTION                                                                                                          AS STATUSFORLINKINGUNALLOCATEDPAYMENTDESCRIPTION 
            ,CAST(T$RCPT AS INT)                                                                                                                 AS STATUSFORLINKINGUNALLOCATEDPAYMENTID 
            ,CAST(T$VATA AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,CAST("T$VATH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$VATH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$VATH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,CAST(T$VATI AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTINIC 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$VATC)),'')                                                                                         AS TAXCOUNTRY 
            ,CAST(T$VATP AS INT)                                                                                                                 AS TAXPERIOD 
            ,CAST(T$VATY AS INT)                                                                                                                 AS TAXYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,SOURCETABLE.T$TEXT   /* TEXT */                                                                                                     AS TEXT 
            ,CAST(T$DC3A AS NUMERIC(15,2))                                                                                                       AS THIRDDISCOUNTAMOUNT 
            ,CAST("T$DC3H$1" AS NUMERIC(15,2))                                                                                                     AS THIRDDISCOUNTAMOUNTINHOMECURRENCY1 
            ,CAST("T$DC3H$2" AS NUMERIC(15,2))                                                                                                     AS THIRDDISCOUNTAMOUNTINHOMECURRENCY2 
            ,CAST("T$DC3H$3" AS NUMERIC(15,2))                                                                                                     AS THIRDDISCOUNTAMOUNTINHOMECURRENCY3 
            ,CAST(T$DC3I AS NUMERIC(15,2))                                                                                                       AS THIRDDISCOUNTAMOUNTININVOICECURRENCY 
            ,CAST(CASE WHEN T$DID3<= '1/1/1970' THEN NULL ELSE T$DID3 END AS DATE)                                                             AS THIRDDISCOUNTDATE 
            ,CAST("T$TORE$1" AS NUMERIC(15,2))                                                                                                     AS TOREALIZEDCURRENCYDIFFERENCES1 
            ,CAST("T$TORE$2" AS NUMERIC(15,2))                                                                                                     AS TOREALIZEDCURRENCYDIFFERENCES2 
            ,CAST("T$TORE$3" AS NUMERIC(15,2))                                                                                                     AS TOREALIZEDCURRENCYDIFFERENCES3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFR)),'')                                                                                         AS TRANSACTIONREFERENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTYP)),'')                                                                                         AS TRANSACTIONTYPEOFORIGINALINVOICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TDOC)),'')                                                                                         AS TRANSACTIONTYPE_TDOC 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE_TTYP 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFACR200201") }} AS SOURCETABLE  
            /*ARRINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ARRQ 
             ON   T$ARRQ.TABLENAME  = 'TFACR200' 
              AND T$ARRQ.COLUMNNAME = 'T$ARRQ' 
              AND T$ARRQ.CONSTANT   = SOURCETABLE.T$ARRQ 
            /*CALCULATEINTEREST*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CAIN 
             ON   T$CAIN.TABLENAME  = 'TFACR200' 
              AND T$CAIN.COLUMNNAME = 'T$CAIN' 
              AND T$CAIN.CONSTANT   = SOURCETABLE.T$CAIN 
            /*DOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TREC 
             ON   T$TREC.TABLENAME  = 'TFACR200' 
              AND T$TREC.COLUMNNAME = 'T$TREC' 
              AND T$TREC.CONSTANT   = SOURCETABLE.T$TREC 
            /*DOUBTFUL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DOUB 
             ON   T$DOUB.TABLENAME  = 'TFACR200' 
              AND T$DOUB.COLUMNNAME = 'T$DOUB' 
              AND T$DOUB.CONSTANT   = SOURCETABLE.T$DOUB 
            /*LEVELOFTAXCALCULATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LVAT 
             ON   T$LVAT.TABLENAME  = 'TFACR200' 
              AND T$LVAT.COLUMNNAME = 'T$LVAT' 
              AND T$LVAT.CONSTANT   = SOURCETABLE.T$LVAT 
            /*RATEDETERMINATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RADE 
             ON   T$RADE.TABLENAME  = 'TFACR200' 
              AND T$RADE.COLUMNNAME = 'T$RADE' 
              AND T$RADE.CONSTANT   = SOURCETABLE.T$RADE 
            /*RECEIPTPROCEDURESTEP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STEP 
             ON   T$STEP.TABLENAME  = 'TFACR200' 
              AND T$STEP.COLUMNNAME = 'T$STEP' 
              AND T$STEP.CONSTANT   = SOURCETABLE.T$STEP 
            /*STATISTICSUPDATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'TFACR200' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*STATUSFORLINKINGUNALLOCATEDPAYMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RCPT 
             ON   T$RCPT.TABLENAME  = 'TFACR200' 
              AND T$RCPT.COLUMNNAME = 'T$RCPT' 
              AND T$RCPT.CONSTANT   = SOURCETABLE.T$RCPT 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNT AS AMOUNT, 
        source_data.AMOUNTINHOMECURRENCY1 AS AMOUNTINHOMECURRENCY1, 
        source_data.AMOUNTINHOMECURRENCY2 AS AMOUNTINHOMECURRENCY2, 
        source_data.AMOUNTINHOMECURRENCY3 AS AMOUNTINHOMECURRENCY3, 
        source_data.AMOUNTININVCURR AS AMOUNTININVCURR, 
        source_data.ANTICIPATEDDOCUMENTNUMBER AS ANTICIPATEDDOCUMENTNUMBER, 
        source_data.ANTICIPATEDTRANSACTIONTYPE AS ANTICIPATEDTRANSACTIONTYPE, 
        source_data.ARRINVOICEDESCRIPTION AS ARRINVOICEDESCRIPTION, 
        source_data.ARRINVOICEID AS ARRINVOICEID, 
        source_data.BALANCEAMOUNT AS BALANCEAMOUNT, 
        source_data.BALANCEANTICIPATED AS BALANCEANTICIPATED, 
        source_data.BALANCEANTICIPATEDINHC1 AS BALANCEANTICIPATEDINHC1, 
        source_data.BALANCEANTICIPATEDINHC2 AS BALANCEANTICIPATEDINHC2, 
        source_data.BALANCEANTICIPATEDINHC3 AS BALANCEANTICIPATEDINHC3, 
        source_data.BALANCEINHC1 AS BALANCEINHC1, 
        source_data.BALANCEINHC2 AS BALANCEINHC2, 
        source_data.BALANCEINHC3 AS BALANCEINHC3, 
        source_data.BANKCHARGES AS BANKCHARGES, 
        source_data.BANKCHARGESHC1 AS BANKCHARGESHC1, 
        source_data.BANKCHARGESHC2 AS BANKCHARGESHC2, 
        source_data.BANKCHARGESHC3 AS BANKCHARGESHC3, 
        source_data.BATCHNUMBER AS BATCHNUMBER, 
        source_data.BUSINESSPARTNER AS BUSINESSPARTNER, 
        source_data.CALCULATEINTERESTDESCRIPTION AS CALCULATEINTERESTDESCRIPTION, 
        source_data.CALCULATEINTERESTID AS CALCULATEINTERESTID, 
        source_data.CURRENCYDIFFBASIS AS CURRENCYDIFFBASIS, 
        source_data.CURRENCYDIFFERENCE1 AS CURRENCYDIFFERENCE1, 
        source_data.CURRENCYDIFFERENCE2 AS CURRENCYDIFFERENCE2, 
        source_data.CURRENCYDIFFERENCE3 AS CURRENCYDIFFERENCE3, 
        source_data.CURRENCYRATE1 AS CURRENCYRATE1, 
        source_data.CURRENCYRATE2 AS CURRENCYRATE2, 
        source_data.CURRENCYRATE3 AS CURRENCYRATE3, 
        source_data.CUSTOMERSBANK AS CUSTOMERSBANK, 
        source_data.DOCUMENT AS DOCUMENT, 
        source_data.DOCUMENTDATE AS DOCUMENTDATE, 
        source_data.DOCUMENTNUMBER AS DOCUMENTNUMBER, 
        source_data.DOCUMENTTYPEDESCRIPTION AS DOCUMENTTYPEDESCRIPTION, 
        source_data.DOCUMENTTYPEID AS DOCUMENTTYPEID, 
        source_data.DOUBTFULDESCRIPTION AS DOUBTFULDESCRIPTION, 
        source_data.DOUBTFULID AS DOUBTFULID, 
        source_data.DUEDATE AS DUEDATE, 
        source_data.EXPECTEDLIQUIDITYDATE AS EXPECTEDLIQUIDITYDATE, 
        source_data.FIRSTDISCOUNTAMOUNT AS FIRSTDISCOUNTAMOUNT, 
        source_data.FIRSTDISCOUNTAMOUNTINHOMECURRENCY1 AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY1, 
        source_data.FIRSTDISCOUNTAMOUNTINHOMECURRENCY2 AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY2, 
        source_data.FIRSTDISCOUNTAMOUNTINHOMECURRENCY3 AS FIRSTDISCOUNTAMOUNTINHOMECURRENCY3, 
        source_data.FIRSTDISCOUNTAMOUNTININVOICECURRENCY AS FIRSTDISCOUNTAMOUNTININVOICECURRENCY, 
        source_data.FIRSTDISCOUNTDATE AS FIRSTDISCOUNTDATE, 
        source_data.FISCALPERIOD AS FISCALPERIOD, 
        source_data.FISCALYEAR AS FISCALYEAR, 
        source_data.INVOICE_PERCENT_AMOUNT AS INVOICE_PERCENT_AMOUNT, 
        source_data.LATEPAYMENTDATE AS LATEPAYMENTDATE, 
        source_data.LATEPAYMENTSURCHARGE AS LATEPAYMENTSURCHARGE, 
        source_data.LATEPMTSURCHAMT AS LATEPMTSURCHAMT, 
        source_data.LATEPMTSURCHAMTINHC1 AS LATEPMTSURCHAMTINHC1, 
        source_data.LATEPMTSURCHAMTINHC2 AS LATEPMTSURCHAMTINHC2, 
        source_data.LATEPMTSURCHAMTINHC3 AS LATEPMTSURCHAMTINHC3, 
        source_data.LATEPMTSURCHARGEAMOUNTINIC AS LATEPMTSURCHARGEAMOUNTINIC, 
        source_data.LETTERNUMBER AS LETTERNUMBER, 
        source_data.LEVELOFTAXCALCULATIONDESCRIPTION AS LEVELOFTAXCALCULATIONDESCRIPTION, 
        source_data.LEVELOFTAXCALCULATIONID AS LEVELOFTAXCALCULATIONID, 
        source_data.LINE AS LINE, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.LINKEDAMOUNT AS LINKEDAMOUNT, 
        source_data.ORDER_ AS ORDER_, 
        source_data.ORDER_FROMBUSPAR AS ORDER_FROMBUSPAR, 
        source_data.ORIGINALINVOICE AS ORIGINALINVOICE, 
        source_data.PAYBYBUSINESSPARTNER AS PAYBYBUSINESSPARTNER, 
        source_data.PAYMENTDIFFERENCE AS PAYMENTDIFFERENCE, 
        source_data.PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY1 AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY1, 
        source_data.PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY2 AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY2, 
        source_data.PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY3 AS PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY3, 
        source_data.PAYMENTDIFFERENCEAMOUNTININVOICECURRENCY AS PAYMENTDIFFERENCEAMOUNTININVOICECURRENCY, 
        source_data.PAYMENTRECEIPTMETHOD AS PAYMENTRECEIPTMETHOD, 
        source_data.POSTALADDRESS AS POSTALADDRESS, 
        source_data.POSTINGBATCH AS POSTINGBATCH, 
        source_data.POSTINGDATE AS POSTINGDATE, 
        source_data.PROBLEMCODE AS PROBLEMCODE, 
        source_data.PROBLEMDATE AS PROBLEMDATE, 
        source_data.PROBLEMREFERENCE AS PROBLEMREFERENCE, 
        source_data.PROJECT AS PROJECT, 
        source_data.RATECAT AS RATECAT, 
        source_data.RATEDETERMINATIONDESCRIPTION AS RATEDETERMINATIONDESCRIPTION, 
        source_data.RATEDETERMINATIONID AS RATEDETERMINATIONID, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.RATETYPE AS RATETYPE, 
        source_data.RECEIPTPROCEDURESTEPDESCRIPTION AS RECEIPTPROCEDURESTEPDESCRIPTION, 
        source_data.RECEIPTPROCEDURESTEPID AS RECEIPTPROCEDURESTEPID, 
        source_data.SALESREP AS SALESREP, 
        source_data.SECONDDISCOUNTAMOUNT AS SECONDDISCOUNTAMOUNT, 
        source_data.SECONDDISCOUNTAMOUNTINHOMECURRENCY1 AS SECONDDISCOUNTAMOUNTINHOMECURRENCY1, 
        source_data.SECONDDISCOUNTAMOUNTINHOMECURRENCY2 AS SECONDDISCOUNTAMOUNTINHOMECURRENCY2, 
        source_data.SECONDDISCOUNTAMOUNTINHOMECURRENCY3 AS SECONDDISCOUNTAMOUNTINHOMECURRENCY3, 
        source_data.SECONDDISCOUNTAMOUNTININVOICECURRENCY AS SECONDDISCOUNTAMOUNTININVOICECURRENCY, 
        source_data.SECONDDISCOUNTDATE AS SECONDDISCOUNTDATE, 
        source_data.SHIFTEDTAX AS SHIFTEDTAX, 
        source_data.SHIFTEDTAXHC1 AS SHIFTEDTAXHC1, 
        source_data.SHIFTEDTAXHC2 AS SHIFTEDTAXHC2, 
        source_data.SHIFTEDTAXHC3 AS SHIFTEDTAXHC3, 
        source_data.STATISTICSUPDATEDDESCRIPTION AS STATISTICSUPDATEDDESCRIPTION, 
        source_data.STATISTICSUPDATEDID AS STATISTICSUPDATEDID, 
        source_data.STATUSFORLINKINGUNALLOCATEDPAYMENTDESCRIPTION AS STATUSFORLINKINGUNALLOCATEDPAYMENTDESCRIPTION, 
        source_data.STATUSFORLINKINGUNALLOCATEDPAYMENTID AS STATUSFORLINKINGUNALLOCATEDPAYMENTID, 
        source_data.TAXAMOUNT AS TAXAMOUNT, 
        source_data.TAXAMOUNTINHOMECURRENCY1 AS TAXAMOUNTINHOMECURRENCY1, 
        source_data.TAXAMOUNTINHOMECURRENCY2 AS TAXAMOUNTINHOMECURRENCY2, 
        source_data.TAXAMOUNTINHOMECURRENCY3 AS TAXAMOUNTINHOMECURRENCY3, 
        source_data.TAXAMOUNTINIC AS TAXAMOUNTINIC, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TAXCOUNTRY AS TAXCOUNTRY, 
        source_data.TAXPERIOD AS TAXPERIOD, 
        source_data.TAXYEAR AS TAXYEAR, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.TEXT AS TEXT, 
        source_data.THIRDDISCOUNTAMOUNT AS THIRDDISCOUNTAMOUNT, 
        source_data.THIRDDISCOUNTAMOUNTINHOMECURRENCY1 AS THIRDDISCOUNTAMOUNTINHOMECURRENCY1, 
        source_data.THIRDDISCOUNTAMOUNTINHOMECURRENCY2 AS THIRDDISCOUNTAMOUNTINHOMECURRENCY2, 
        source_data.THIRDDISCOUNTAMOUNTINHOMECURRENCY3 AS THIRDDISCOUNTAMOUNTINHOMECURRENCY3, 
        source_data.THIRDDISCOUNTAMOUNTININVOICECURRENCY AS THIRDDISCOUNTAMOUNTININVOICECURRENCY, 
        source_data.THIRDDISCOUNTDATE AS THIRDDISCOUNTDATE, 
        source_data.TOREALIZEDCURRENCYDIFFERENCES1 AS TOREALIZEDCURRENCYDIFFERENCES1, 
        source_data.TOREALIZEDCURRENCYDIFFERENCES2 AS TOREALIZEDCURRENCYDIFFERENCES2, 
        source_data.TOREALIZEDCURRENCYDIFFERENCES3 AS TOREALIZEDCURRENCYDIFFERENCES3, 
        source_data.TRANSACTIONREFERENCE AS TRANSACTIONREFERENCE, 
        source_data.TRANSACTIONTYPEOFORIGINALINVOICE AS TRANSACTIONTYPEOFORIGINALINVOICE, 
        source_data.TRANSACTIONTYPE_TDOC AS TRANSACTIONTYPE_TDOC, 
        source_data.TRANSACTIONTYPE_TTYP AS TRANSACTIONTYPE_TTYP
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AMOUNT as NUMBER(15,2)) as AMOUNT,
        cast(AMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY1,
        cast(AMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY2,
        cast(AMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY3,
        cast(AMOUNTININVCURR as NUMBER(15,2)) as AMOUNTININVCURR,
        cast(ANTICIPATEDDOCUMENTNUMBER as NUMBER(38,0)) as ANTICIPATEDDOCUMENTNUMBER,
        cast(ANTICIPATEDTRANSACTIONTYPE as VARCHAR(3)) as ANTICIPATEDTRANSACTIONTYPE,
        cast(ARRINVOICEDESCRIPTION as VARCHAR(16777216)) as ARRINVOICEDESCRIPTION,
        cast(ARRINVOICEID as NUMBER(38,0)) as ARRINVOICEID,
        cast(BALANCEAMOUNT as NUMBER(15,2)) as BALANCEAMOUNT,
        cast(BALANCEANTICIPATED as NUMBER(15,2)) as BALANCEANTICIPATED,
        cast(BALANCEANTICIPATEDINHC1 as NUMBER(15,2)) as BALANCEANTICIPATEDINHC1,
        cast(BALANCEANTICIPATEDINHC2 as NUMBER(15,2)) as BALANCEANTICIPATEDINHC2,
        cast(BALANCEANTICIPATEDINHC3 as NUMBER(15,2)) as BALANCEANTICIPATEDINHC3,
        cast(BALANCEINHC1 as NUMBER(15,2)) as BALANCEINHC1,
        cast(BALANCEINHC2 as NUMBER(15,2)) as BALANCEINHC2,
        cast(BALANCEINHC3 as NUMBER(15,2)) as BALANCEINHC3,
        cast(BANKCHARGES as NUMBER(15,2)) as BANKCHARGES,
        cast(BANKCHARGESHC1 as NUMBER(15,2)) as BANKCHARGESHC1,
        cast(BANKCHARGESHC2 as NUMBER(15,2)) as BANKCHARGESHC2,
        cast(BANKCHARGESHC3 as NUMBER(15,2)) as BANKCHARGESHC3,
        cast(BATCHNUMBER as NUMBER(38,0)) as BATCHNUMBER,
        cast(BUSINESSPARTNER as VARCHAR(9)) as BUSINESSPARTNER,
        cast(CALCULATEINTERESTDESCRIPTION as VARCHAR(16777216)) as CALCULATEINTERESTDESCRIPTION,
        cast(CALCULATEINTERESTID as NUMBER(38,0)) as CALCULATEINTERESTID,
        cast(CURRENCYDIFFBASIS as NUMBER(15,2)) as CURRENCYDIFFBASIS,
        cast(CURRENCYDIFFERENCE1 as NUMBER(15,2)) as CURRENCYDIFFERENCE1,
        cast(CURRENCYDIFFERENCE2 as NUMBER(15,2)) as CURRENCYDIFFERENCE2,
        cast(CURRENCYDIFFERENCE3 as NUMBER(15,2)) as CURRENCYDIFFERENCE3,
        cast(CURRENCYRATE1 as NUMBER(15,2)) as CURRENCYRATE1,
        cast(CURRENCYRATE2 as NUMBER(15,2)) as CURRENCYRATE2,
        cast(CURRENCYRATE3 as NUMBER(15,2)) as CURRENCYRATE3,
        cast(CUSTOMERSBANK as VARCHAR(3)) as CUSTOMERSBANK,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(DOCUMENTDATE as DATE) as DOCUMENTDATE,
        cast(DOCUMENTNUMBER as NUMBER(38,0)) as DOCUMENTNUMBER,
        cast(DOCUMENTTYPEDESCRIPTION as VARCHAR(16777216)) as DOCUMENTTYPEDESCRIPTION,
        cast(DOCUMENTTYPEID as NUMBER(38,0)) as DOCUMENTTYPEID,
        cast(DOUBTFULDESCRIPTION as VARCHAR(16777216)) as DOUBTFULDESCRIPTION,
        cast(DOUBTFULID as NUMBER(38,0)) as DOUBTFULID,
        cast(DUEDATE as DATE) as DUEDATE,
        cast(EXPECTEDLIQUIDITYDATE as DATE) as EXPECTEDLIQUIDITYDATE,
        cast(FIRSTDISCOUNTAMOUNT as NUMBER(15,2)) as FIRSTDISCOUNTAMOUNT,
        cast(FIRSTDISCOUNTAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as FIRSTDISCOUNTAMOUNTINHOMECURRENCY1,
        cast(FIRSTDISCOUNTAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as FIRSTDISCOUNTAMOUNTINHOMECURRENCY2,
        cast(FIRSTDISCOUNTAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as FIRSTDISCOUNTAMOUNTINHOMECURRENCY3,
        cast(FIRSTDISCOUNTAMOUNTININVOICECURRENCY as NUMBER(15,2)) as FIRSTDISCOUNTAMOUNTININVOICECURRENCY,
        cast(FIRSTDISCOUNTDATE as DATE) as FIRSTDISCOUNTDATE,
        cast(FISCALPERIOD as NUMBER(38,0)) as FISCALPERIOD,
        cast(FISCALYEAR as NUMBER(38,0)) as FISCALYEAR,
        cast(INVOICE_PERCENT_AMOUNT as VARCHAR(3)) as INVOICE_PERCENT_AMOUNT,
        cast(LATEPAYMENTDATE as DATE) as LATEPAYMENTDATE,
        cast(LATEPAYMENTSURCHARGE as VARCHAR(3)) as LATEPAYMENTSURCHARGE,
        cast(LATEPMTSURCHAMT as NUMBER(15,2)) as LATEPMTSURCHAMT,
        cast(LATEPMTSURCHAMTINHC1 as NUMBER(15,2)) as LATEPMTSURCHAMTINHC1,
        cast(LATEPMTSURCHAMTINHC2 as NUMBER(15,2)) as LATEPMTSURCHAMTINHC2,
        cast(LATEPMTSURCHAMTINHC3 as NUMBER(15,2)) as LATEPMTSURCHAMTINHC3,
        cast(LATEPMTSURCHARGEAMOUNTINIC as NUMBER(15,2)) as LATEPMTSURCHARGEAMOUNTINIC,
        cast(LETTERNUMBER as NUMBER(38,0)) as LETTERNUMBER,
        cast(LEVELOFTAXCALCULATIONDESCRIPTION as VARCHAR(16777216)) as LEVELOFTAXCALCULATIONDESCRIPTION,
        cast(LEVELOFTAXCALCULATIONID as NUMBER(38,0)) as LEVELOFTAXCALCULATIONID,
        cast(LINE as NUMBER(38,0)) as LINE,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(LINKEDAMOUNT as NUMBER(15,2)) as LINKEDAMOUNT,
        cast(ORDER_ as NUMBER(38,0)) as ORDER_,
        cast(ORDER_FROMBUSPAR as VARCHAR(9)) as ORDER_FROMBUSPAR,
        cast(ORIGINALINVOICE as NUMBER(38,0)) as ORIGINALINVOICE,
        cast(PAYBYBUSINESSPARTNER as VARCHAR(9)) as PAYBYBUSINESSPARTNER,
        cast(PAYMENTDIFFERENCE as NUMBER(15,2)) as PAYMENTDIFFERENCE,
        cast(PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY1,
        cast(PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY2,
        cast(PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as PAYMENTDIFFERENCEAMOUNTINHOMECURRENCY3,
        cast(PAYMENTDIFFERENCEAMOUNTININVOICECURRENCY as NUMBER(15,2)) as PAYMENTDIFFERENCEAMOUNTININVOICECURRENCY,
        cast(PAYMENTRECEIPTMETHOD as VARCHAR(3)) as PAYMENTRECEIPTMETHOD,
        cast(POSTALADDRESS as VARCHAR(9)) as POSTALADDRESS,
        cast(POSTINGBATCH as NUMBER(38,0)) as POSTINGBATCH,
        cast(POSTINGDATE as DATE) as POSTINGDATE,
        cast(PROBLEMCODE as VARCHAR(3)) as PROBLEMCODE,
        cast(PROBLEMDATE as DATE) as PROBLEMDATE,
        cast(PROBLEMREFERENCE as VARCHAR(3)) as PROBLEMREFERENCE,
        cast(PROJECT as VARCHAR(6)) as PROJECT,
        cast(RATECAT as TIMESTAMP_NTZ(9)) as RATECAT,
        cast(RATEDETERMINATIONDESCRIPTION as VARCHAR(16777216)) as RATEDETERMINATIONDESCRIPTION,
        cast(RATEDETERMINATIONID as NUMBER(38,0)) as RATEDETERMINATIONID,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(RATETYPE as VARCHAR(3)) as RATETYPE,
        cast(RECEIPTPROCEDURESTEPDESCRIPTION as VARCHAR(16777216)) as RECEIPTPROCEDURESTEPDESCRIPTION,
        cast(RECEIPTPROCEDURESTEPID as NUMBER(38,0)) as RECEIPTPROCEDURESTEPID,
        cast(SALESREP as VARCHAR(6)) as SALESREP,
        cast(SECONDDISCOUNTAMOUNT as NUMBER(15,2)) as SECONDDISCOUNTAMOUNT,
        cast(SECONDDISCOUNTAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as SECONDDISCOUNTAMOUNTINHOMECURRENCY1,
        cast(SECONDDISCOUNTAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as SECONDDISCOUNTAMOUNTINHOMECURRENCY2,
        cast(SECONDDISCOUNTAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as SECONDDISCOUNTAMOUNTINHOMECURRENCY3,
        cast(SECONDDISCOUNTAMOUNTININVOICECURRENCY as NUMBER(15,2)) as SECONDDISCOUNTAMOUNTININVOICECURRENCY,
        cast(SECONDDISCOUNTDATE as DATE) as SECONDDISCOUNTDATE,
        cast(SHIFTEDTAX as NUMBER(15,2)) as SHIFTEDTAX,
        cast(SHIFTEDTAXHC1 as NUMBER(15,2)) as SHIFTEDTAXHC1,
        cast(SHIFTEDTAXHC2 as NUMBER(15,2)) as SHIFTEDTAXHC2,
        cast(SHIFTEDTAXHC3 as NUMBER(15,2)) as SHIFTEDTAXHC3,
        cast(STATISTICSUPDATEDDESCRIPTION as VARCHAR(16777216)) as STATISTICSUPDATEDDESCRIPTION,
        cast(STATISTICSUPDATEDID as NUMBER(38,0)) as STATISTICSUPDATEDID,
        cast(STATUSFORLINKINGUNALLOCATEDPAYMENTDESCRIPTION as VARCHAR(16777216)) as STATUSFORLINKINGUNALLOCATEDPAYMENTDESCRIPTION,
        cast(STATUSFORLINKINGUNALLOCATEDPAYMENTID as NUMBER(38,0)) as STATUSFORLINKINGUNALLOCATEDPAYMENTID,
        cast(TAXAMOUNT as NUMBER(15,2)) as TAXAMOUNT,
        cast(TAXAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY1,
        cast(TAXAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY2,
        cast(TAXAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY3,
        cast(TAXAMOUNTINIC as NUMBER(15,2)) as TAXAMOUNTINIC,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(TAXCOUNTRY as VARCHAR(3)) as TAXCOUNTRY,
        cast(TAXPERIOD as NUMBER(38,0)) as TAXPERIOD,
        cast(TAXYEAR as NUMBER(38,0)) as TAXYEAR,
        cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(THIRDDISCOUNTAMOUNT as NUMBER(15,2)) as THIRDDISCOUNTAMOUNT,
        cast(THIRDDISCOUNTAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as THIRDDISCOUNTAMOUNTINHOMECURRENCY1,
        cast(THIRDDISCOUNTAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as THIRDDISCOUNTAMOUNTINHOMECURRENCY2,
        cast(THIRDDISCOUNTAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as THIRDDISCOUNTAMOUNTINHOMECURRENCY3,
        cast(THIRDDISCOUNTAMOUNTININVOICECURRENCY as NUMBER(15,2)) as THIRDDISCOUNTAMOUNTININVOICECURRENCY,
        cast(THIRDDISCOUNTDATE as DATE) as THIRDDISCOUNTDATE,
        cast(TOREALIZEDCURRENCYDIFFERENCES1 as NUMBER(15,2)) as TOREALIZEDCURRENCYDIFFERENCES1,
        cast(TOREALIZEDCURRENCYDIFFERENCES2 as NUMBER(15,2)) as TOREALIZEDCURRENCYDIFFERENCES2,
        cast(TOREALIZEDCURRENCYDIFFERENCES3 as NUMBER(15,2)) as TOREALIZEDCURRENCYDIFFERENCES3,
        cast(TRANSACTIONREFERENCE as VARCHAR(32)) as TRANSACTIONREFERENCE,
        cast(TRANSACTIONTYPEOFORIGINALINVOICE as VARCHAR(3)) as TRANSACTIONTYPEOFORIGINALINVOICE,
        cast(TRANSACTIONTYPE_TDOC as VARCHAR(3)) as TRANSACTIONTYPE_TDOC,
        cast(TRANSACTIONTYPE_TTYP as VARCHAR(3)) as TRANSACTIONTYPE_TTYP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data