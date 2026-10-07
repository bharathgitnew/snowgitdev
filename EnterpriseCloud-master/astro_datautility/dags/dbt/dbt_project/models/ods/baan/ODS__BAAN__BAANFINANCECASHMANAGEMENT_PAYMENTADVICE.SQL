/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCECASHMANAGEMENT_PAYMENTADVICE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCECASHMANAGEMENT_PAYMENTADVICE.SQL 
-materialized incremental
-alias BAANFINANCECASHMANAGEMENT_PAYMENTADVICE 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:52 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCECASHMANAGEMENT_PAYMENTADVICE',
    unique_key = ['DOCUMENT',
    'INVOICEFROMBUSINESSPARTNER',
    'ORIGINALCOMPANY',
    'PAYMENTBATCH',
    'SEQUENCENUMBER',
    'TRANSACTIONTYPE_TTYP',
    'TYPEOFADVICEID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,200                                                                                                                                       AS _COMPANYID 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                           AS AMOUNTIN 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY3 
            ,CAST("T$DISH$1" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_DISH_1 
            ,CAST("T$DISH$2" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_DISH_2 
            ,CAST("T$DISH$3" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_DISH_3 
            ,CAST("T$LAPH$1" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_LAPH_1 
            ,CAST("T$LAPH$2" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_LAPH_2 
            ,CAST("T$LAPH$3" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_LAPH_3 
            ,CAST("T$PADH$1" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_PADH_1 
            ,CAST("T$PADH$2" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_PADH_2 
            ,CAST("T$PADH$3" AS NUMERIC(15,2))                                                                                                         AS AMOUNTINHOMECURRENCY_PADH_3 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                           AS AMOUNTTOBEPAID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                             AS CURRENCY 
            ,CAST(T$DISA AS NUMERIC(15,2))                                                                                                           AS DISCOUNT 
            ,CAST(T$NINV AS BIGINT)                                                                                                                  AS DOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IFBP)),'')                                                                                             AS INVOICEFROMBUSINESSPARTNER 
            ,CAST(T$LAPA AS NUMERIC(15,2))                                                                                                           AS LATEPMNTSURCHARGE 
            ,CAST(T$COMP AS INT)                                                                                                                     AS ORIGINALCOMPANY 
            ,CAST(T$OINV AS BIGINT)                                                                                                                  AS ORIGINALINVOICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTYP)),'')                                                                                             AS ORIGINALINVOICETRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BANK)),'')                                                                                             AS PAYFROMBANK 
            ,CAST(T$BTNO AS BIGINT)                                                                                                                  AS PAYMENTBATCH 
            ,CAST(T$PDAM AS NUMERIC(15,2))                                                                                                           AS PAYMENTDIFFERENCE 
            ,CAST(T$PDOC AS BIGINT)                                                                                                                  AS PAYMENTDOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                             AS PAYMENTRECEIPTMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BASU)),'')                                                                                             AS PAYTOBANK 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTBP)),'')                                                                                             AS PAYTOBUSINESSPARTNER 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT END AS DATE)                                                                 AS PLANNED_percent_PAYMENTDATE 
            ,CAST(CASE WHEN T$PLAN<= '1/1/1970' THEN NULL ELSE T$PLAN END AS DATE)                                                                 AS PLANNEDPAYMENTDATE 
            ,T$POST.CONSTANTDESCRIPTION                                                                                                              AS POSTEDDESCRIPTION 
            ,CAST(T$POST AS INT)                                                                                                                     AS POSTEDID 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                         AS RATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                         AS RATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                         AS RATE3 
            ,CAST(CASE WHEN T$RDAT<= '1/1/1970' THEN NULL ELSE T$RDAT  END AS DATETIME)     AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                                AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                                AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                                AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                             AS RATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REAS)),'')                                                                                             AS REASONFORPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFR)),'')                                                                                             AS REFERENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RAGR)),'')                                                                                             AS REMITTANCEAGREEMENT 
            ,CAST(CASE WHEN "T$ARIB$U"<= '1/1/1970' THEN NULL ELSE "T$ARIB$U"  END AS DATETIME) AS SENTTOARIBA 
            ,CAST(CASE WHEN "T$SENC$U"<= '1/1/1970' THEN NULL ELSE "T$SENC$U"  END AS DATETIME) AS SENTTOCHASEON 
            ,"T$TUPD$U".CONSTANTDESCRIPTION                                                                                                            AS SENTTODATASERVEDESCRIPTION 
            ,CAST("T$TUPD$U" AS INT)                                                                                                                   AS SENTTODATASERVEID 
            ,CAST(T$SORT AS BIGINT)                                                                                                                  AS SEQUENCENOFORCOMPOSING 
            ,CAST(T$SRNO AS INT)                                                                                                                     AS SEQUENCENUMBER 
            ,CAST(T$SCOM AS INT)                                                                                                                     AS SERIESNUMBERCOMPOSEDPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                             AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$VATC)),'')                                                                                             AS TAXCOUNTRY 
            ,CAST(T$VATA AS NUMERIC(15,2))                                                                                                           AS TRANSACTIONAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTYP)),'')                                                                                             AS TRANSACTIONTYPE_PTYP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                             AS TRANSACTIONTYPE_TTYP 
            ,T$TADV.CONSTANTDESCRIPTION                                                                                                              AS TYPEOFADVICEDESCRIPTION 
            ,CAST(T$TADV AS INT)                                                                                                                     AS TYPEOFADVICEID 
            ,T$BLAC.CONSTANTDESCRIPTION                                                                                                              AS TYPEOFBLOCKEDACCOUNTDESCRIPTION 
            ,CAST(T$BLAC AS INT)                                                                                                                     AS TYPEOFBLOCKEDACCOUNTID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFCMG101200") }} AS SOURCETABLE  
            /*POSTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$POST 
             ON   T$POST.TABLENAME  = 'TFCMG101' 
              AND T$POST.COLUMNNAME = 'T$POST' 
              AND T$POST.CONSTANT   = SOURCETABLE.T$POST 
            /*SENTTODATASERVEU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$TUPD$U" 
             ON   "T$TUPD$U".TABLENAME  = 'TFCMG101' 
              AND "T$TUPD$U".COLUMNNAME = 'T$TUPD.U' 
              AND "T$TUPD$U".CONSTANT   = SOURCETABLE."T$TUPD$U" 
            /*TYPEOFADVICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TADV 
             ON   T$TADV.TABLENAME  = 'TFCMG101' 
              AND T$TADV.COLUMNNAME = 'T$TADV' 
              AND T$TADV.CONSTANT   = SOURCETABLE.T$TADV 
            /*TYPEOFBLOCKEDACCOUNT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLAC 
             ON   T$BLAC.TABLENAME  = 'TFCMG101' 
              AND T$BLAC.COLUMNNAME = 'T$BLAC' 
              AND T$BLAC.CONSTANT   = SOURCETABLE.T$BLAC 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNTIN AS AMOUNTIN, 
        source_data.AMOUNTINHOMECURRENCY1 AS AMOUNTINHOMECURRENCY1, 
        source_data.AMOUNTINHOMECURRENCY2 AS AMOUNTINHOMECURRENCY2, 
        source_data.AMOUNTINHOMECURRENCY3 AS AMOUNTINHOMECURRENCY3, 
        source_data.AMOUNTINHOMECURRENCY_DISH_1 AS AMOUNTINHOMECURRENCY_DISH_1, 
        source_data.AMOUNTINHOMECURRENCY_DISH_2 AS AMOUNTINHOMECURRENCY_DISH_2, 
        source_data.AMOUNTINHOMECURRENCY_DISH_3 AS AMOUNTINHOMECURRENCY_DISH_3, 
        source_data.AMOUNTINHOMECURRENCY_LAPH_1 AS AMOUNTINHOMECURRENCY_LAPH_1, 
        source_data.AMOUNTINHOMECURRENCY_LAPH_2 AS AMOUNTINHOMECURRENCY_LAPH_2, 
        source_data.AMOUNTINHOMECURRENCY_LAPH_3 AS AMOUNTINHOMECURRENCY_LAPH_3, 
        source_data.AMOUNTINHOMECURRENCY_PADH_1 AS AMOUNTINHOMECURRENCY_PADH_1, 
        source_data.AMOUNTINHOMECURRENCY_PADH_2 AS AMOUNTINHOMECURRENCY_PADH_2, 
        source_data.AMOUNTINHOMECURRENCY_PADH_3 AS AMOUNTINHOMECURRENCY_PADH_3, 
        source_data.AMOUNTTOBEPAID AS AMOUNTTOBEPAID, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DISCOUNT AS DISCOUNT, 
        source_data.DOCUMENT AS DOCUMENT, 
        source_data.INVOICEFROMBUSINESSPARTNER AS INVOICEFROMBUSINESSPARTNER, 
        source_data.LATEPMNTSURCHARGE AS LATEPMNTSURCHARGE, 
        source_data.ORIGINALCOMPANY AS ORIGINALCOMPANY, 
        source_data.ORIGINALINVOICE AS ORIGINALINVOICE, 
        source_data.ORIGINALINVOICETRANSACTIONTYPE AS ORIGINALINVOICETRANSACTIONTYPE, 
        source_data.PAYFROMBANK AS PAYFROMBANK, 
        source_data.PAYMENTBATCH AS PAYMENTBATCH, 
        source_data.PAYMENTDIFFERENCE AS PAYMENTDIFFERENCE, 
        source_data.PAYMENTDOCUMENT AS PAYMENTDOCUMENT, 
        source_data.PAYMENTRECEIPTMETHOD AS PAYMENTRECEIPTMETHOD, 
        source_data.PAYTOBANK AS PAYTOBANK, 
        source_data.PAYTOBUSINESSPARTNER AS PAYTOBUSINESSPARTNER, 
        source_data.PLANNED_PERCENT_PAYMENTDATE AS PLANNED_PERCENT_PAYMENTDATE, 
        source_data.PLANNEDPAYMENTDATE AS PLANNEDPAYMENTDATE, 
        source_data.POSTEDDESCRIPTION AS POSTEDDESCRIPTION, 
        source_data.POSTEDID AS POSTEDID, 
        source_data.RATE1 AS RATE1, 
        source_data.RATE2 AS RATE2, 
        source_data.RATE3 AS RATE3, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.RATETYPE AS RATETYPE, 
        source_data.REASONFORPAYMENT AS REASONFORPAYMENT, 
        source_data.REFERENCE AS REFERENCE, 
        source_data.REMITTANCEAGREEMENT AS REMITTANCEAGREEMENT, 
        source_data.SENTTOARIBA AS SENTTOARIBA, 
        source_data.SENTTOCHASEON AS SENTTOCHASEON, 
        source_data.SENTTODATASERVEDESCRIPTION AS SENTTODATASERVEDESCRIPTION, 
        source_data.SENTTODATASERVEID AS SENTTODATASERVEID, 
        source_data.SEQUENCENOFORCOMPOSING AS SEQUENCENOFORCOMPOSING, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SERIESNUMBERCOMPOSEDPAYMENT AS SERIESNUMBERCOMPOSEDPAYMENT, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TAXCOUNTRY AS TAXCOUNTRY, 
        source_data.TRANSACTIONAMOUNT AS TRANSACTIONAMOUNT, 
        source_data.TRANSACTIONTYPE_PTYP AS TRANSACTIONTYPE_PTYP, 
        source_data.TRANSACTIONTYPE_TTYP AS TRANSACTIONTYPE_TTYP, 
        source_data.TYPEOFADVICEDESCRIPTION AS TYPEOFADVICEDESCRIPTION, 
        source_data.TYPEOFADVICEID AS TYPEOFADVICEID, 
        source_data.TYPEOFBLOCKEDACCOUNTDESCRIPTION AS TYPEOFBLOCKEDACCOUNTDESCRIPTION, 
        source_data.TYPEOFBLOCKEDACCOUNTID AS TYPEOFBLOCKEDACCOUNTID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AMOUNTIN as NUMBER(15,2)) as AMOUNTIN,
        cast(AMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY1,
        cast(AMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY2,
        cast(AMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY3,
        cast(AMOUNTINHOMECURRENCY_DISH_1 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_DISH_1,
        cast(AMOUNTINHOMECURRENCY_DISH_2 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_DISH_2,
        cast(AMOUNTINHOMECURRENCY_DISH_3 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_DISH_3,
        cast(AMOUNTINHOMECURRENCY_LAPH_1 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_LAPH_1,
        cast(AMOUNTINHOMECURRENCY_LAPH_2 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_LAPH_2,
        cast(AMOUNTINHOMECURRENCY_LAPH_3 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_LAPH_3,
        cast(AMOUNTINHOMECURRENCY_PADH_1 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_PADH_1,
        cast(AMOUNTINHOMECURRENCY_PADH_2 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_PADH_2,
        cast(AMOUNTINHOMECURRENCY_PADH_3 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY_PADH_3,
        cast(AMOUNTTOBEPAID as NUMBER(15,2)) as AMOUNTTOBEPAID,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(DISCOUNT as NUMBER(15,2)) as DISCOUNT,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(INVOICEFROMBUSINESSPARTNER as VARCHAR(9)) as INVOICEFROMBUSINESSPARTNER,
        cast(LATEPMNTSURCHARGE as NUMBER(15,2)) as LATEPMNTSURCHARGE,
        cast(ORIGINALCOMPANY as NUMBER(38,0)) as ORIGINALCOMPANY,
        cast(ORIGINALINVOICE as NUMBER(38,0)) as ORIGINALINVOICE,
        cast(ORIGINALINVOICETRANSACTIONTYPE as VARCHAR(3)) as ORIGINALINVOICETRANSACTIONTYPE,
        cast(PAYFROMBANK as VARCHAR(3)) as PAYFROMBANK,
        cast(PAYMENTBATCH as NUMBER(38,0)) as PAYMENTBATCH,
        cast(PAYMENTDIFFERENCE as NUMBER(15,2)) as PAYMENTDIFFERENCE,
        cast(PAYMENTDOCUMENT as NUMBER(38,0)) as PAYMENTDOCUMENT,
        cast(PAYMENTRECEIPTMETHOD as VARCHAR(3)) as PAYMENTRECEIPTMETHOD,
        cast(PAYTOBANK as VARCHAR(3)) as PAYTOBANK,
        cast(PAYTOBUSINESSPARTNER as VARCHAR(9)) as PAYTOBUSINESSPARTNER,
        cast(PLANNED_PERCENT_PAYMENTDATE as DATE) as PLANNED_PERCENT_PAYMENTDATE,
        cast(PLANNEDPAYMENTDATE as DATE) as PLANNEDPAYMENTDATE,
        cast(POSTEDDESCRIPTION as VARCHAR(16777216)) as POSTEDDESCRIPTION,
        cast(POSTEDID as NUMBER(38,0)) as POSTEDID,
        cast(RATE1 as NUMBER(15,2)) as RATE1,
        cast(RATE2 as NUMBER(15,2)) as RATE2,
        cast(RATE3 as NUMBER(15,2)) as RATE3,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(RATETYPE as VARCHAR(3)) as RATETYPE,
        cast(REASONFORPAYMENT as VARCHAR(3)) as REASONFORPAYMENT,
        cast(REFERENCE as VARCHAR(32)) as REFERENCE,
        cast(REMITTANCEAGREEMENT as VARCHAR(16)) as REMITTANCEAGREEMENT,
        cast(SENTTOARIBA as TIMESTAMP_NTZ(9)) as SENTTOARIBA,
        cast(SENTTOCHASEON as TIMESTAMP_NTZ(9)) as SENTTOCHASEON,
        cast(SENTTODATASERVEDESCRIPTION as VARCHAR(16777216)) as SENTTODATASERVEDESCRIPTION,
        cast(SENTTODATASERVEID as NUMBER(38,0)) as SENTTODATASERVEID,
        cast(SEQUENCENOFORCOMPOSING as NUMBER(38,0)) as SEQUENCENOFORCOMPOSING,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SERIESNUMBERCOMPOSEDPAYMENT as NUMBER(38,0)) as SERIESNUMBERCOMPOSEDPAYMENT,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(TAXCOUNTRY as VARCHAR(3)) as TAXCOUNTRY,
        cast(TRANSACTIONAMOUNT as NUMBER(15,2)) as TRANSACTIONAMOUNT,
        cast(TRANSACTIONTYPE_PTYP as VARCHAR(3)) as TRANSACTIONTYPE_PTYP,
        cast(TRANSACTIONTYPE_TTYP as VARCHAR(3)) as TRANSACTIONTYPE_TTYP,
        cast(TYPEOFADVICEDESCRIPTION as VARCHAR(16777216)) as TYPEOFADVICEDESCRIPTION,
        cast(TYPEOFADVICEID as NUMBER(38,0)) as TYPEOFADVICEID,
        cast(TYPEOFBLOCKEDACCOUNTDESCRIPTION as VARCHAR(16777216)) as TYPEOFBLOCKEDACCOUNTDESCRIPTION,
        cast(TYPEOFBLOCKEDACCOUNTID as NUMBER(38,0)) as TYPEOFBLOCKEDACCOUNTID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data