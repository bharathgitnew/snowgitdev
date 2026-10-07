/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCECASHMANAGEMENT_ANTICIPATEDPAYMENTSRECEIPTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCECASHMANAGEMENT_ANTICIPATEDPAYMENTSRECEIPTS.SQL 
-materialized incremental
-alias BAANFINANCECASHMANAGEMENT_ANTICIPATEDPAYMENTSRECEIPTS 
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
    alias='BAANFINANCECASHMANAGEMENT_ANTICIPATEDPAYMENTSRECEIPTS',
    unique_key = ['DOCUMENTFORANTPMT',
    'PAYFROMBANK',
    'TRANSACTIONTYPE']
) }}


with source_data as 
(
    SELECT 
          SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
        ,200                                                                                                                                   AS _COMPANYID 
        ,CAST(T$RACC AS NUMERIC(15,2))                                                                                                       AS ACCEPTEDAMOUNT 
        ,T$CACC.CONSTANTDESCRIPTION                                                                                                          AS ACCEPTENCEOFRECEIPTDESCRIPTION 
        ,CAST(T$CACC AS INT)                                                                                                                 AS ACCEPTENCEOFRECEIPTID 
        ,CAST(T$BTNO AS BIGINT)                                                                                                              AS BATCHNUMBER 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BACU)),'')                                                                                         AS BUSINESSPARTNERBANK 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHEQ)),'')                                                                                         AS CHECKNUMBER 
        ,T$COPO.CONSTANTDESCRIPTION                                                                                                          AS CODEOFPOSTINGDESCRIPTION 
        ,CAST(T$COPO AS INT)                                                                                                                 AS CODEOFPOSTINGID 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
        ,CAST(CASE WHEN T$CREA<= '1/1/1970' THEN NULL ELSE T$CREA END AS DATE)                                                             AS DATEOFCREATIONANTICIPATEDPAYMENTRECEIPT 
        ,CAST(T$DSTB AS BIGINT)                                                                                                              AS DOCNRFORDOCSENTTOBANK 
        ,CAST(T$PDOC AS BIGINT)                                                                                                              AS DOCUMENTFORANTPMT 
        ,CAST(CASE WHEN T$DDTN<= '1/1/1970' THEN NULL ELSE T$DDTN END AS DATE)                                                             AS DUEDATEOFTRADENOTE 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS PARENTBUSINESSPARTNER 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BANK)),'')                                                                                         AS PAYFROMBANK 
        ,CAST(T$PBAT AS BIGINT)                                                                                                              AS PAYMENTBATCH 
        ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT END AS DATE)                                                             AS PAYMENTDATE 
        ,CAST(T$DOCN AS BIGINT)                                                                                                              AS PAYMENTDOCUMENT 
        ,T$STPD.CONSTANTDESCRIPTION                                                                                                          AS PAYMENTDOCUMENTSTATUSDESCRIPTION 
        ,CAST(T$STPD AS INT)                                                                                                                 AS PAYMENTDOCUMENTSTATUSID 
        ,CAST(T$PPER AS INT)                                                                                                                 AS PAYMENTPERIOD 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTRECEIPTMETHOD 
        ,T$STEP.CONSTANTDESCRIPTION                                                                                                          AS PAYMENTRECEIPTPROCEDURESTATUSDESCRIPTION 
        ,CAST(T$STEP AS INT)                                                                                                                 AS PAYMENTRECEIPTPROCEDURESTATUSID 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTYP)),'')                                                                                         AS PAYMENTTRANSACTIONTYPE 
        ,CAST(T$PYER AS INT)                                                                                                                 AS PAYMENTYEAR 
        ,CAST(CASE WHEN T$PLAN<= '1/1/1970' THEN NULL ELSE T$PLAN END AS DATE)                                                             AS PLANNEDCLEARINGDATE 
        ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS RATE1 
        ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS RATE2 
        ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS RATE3 
        ,CAST(CASE WHEN T$RDAT<= '1/1/1970' THEN NULL ELSE T$RDAT  END AS DATETIME) AS RATEDATE 
        ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
        ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
        ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RATETYPE 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCUR)),'')                                                                                         AS RECONCILIATIONCURRENCY 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREF)),'')                                                                                         AS REFERENCEOFRECEIPT 
        ,CAST(T$RREJ AS NUMERIC(15,2))                                                                                                       AS REJECTEDAMOUNT 
        ,t$srec.ConstantDescription                                                                                                          AS SelectForautomaticreconciliationDescription 
        ,CAST(t$srec AS INT)                                                                                                                 AS SelectForautomaticreconciliationId 
        ,T$STBK.CONSTANTDESCRIPTION                                                                                                          AS SENTTOBANKDESCRIPTION 
        ,CAST(T$STBK AS INT)                                                                                                                 AS SENTTOBANKID 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TOBK)),'')                                                                                         AS TOBANK 
        ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS TRANSACTIONAMOUNT 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TDOC)),'')                                                                                         AS TRANSACTIONTYPE 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TSTB)),'')                                                                                         AS TRANSACTIONTYPEDOCUMENTSENTTOBANK 
        ,CAST(T$YEAR AS INT)                                                                                                                 AS YEAR 
    FROM {{ source("BAAN_ORACLE_LIVE", "TTFCMG110200") }} AS SOURCETABLE  
        /*ACCEPTENCEOFRECEIPT*/ 
        LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CACC 
          ON   T$CACC.TABLENAME  = 'TFCMG110' 
          AND T$CACC.COLUMNNAME = 'T$CACC' 
          AND T$CACC.CONSTANT   = SOURCETABLE.T$CACC 
        /*CODEOFPOSTING*/ 
        LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COPO 
          ON   T$COPO.TABLENAME  = 'TFCMG110' 
          AND T$COPO.COLUMNNAME = 'T$COPO' 
          AND T$COPO.CONSTANT   = SOURCETABLE.T$COPO 
        /*PAYMENTDOCUMENTSTATUS*/ 
        LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STPD 
          ON   T$STPD.TABLENAME  = 'TFCMG110' 
          AND T$STPD.COLUMNNAME = 'T$STPD' 
          AND T$STPD.CONSTANT   = SOURCETABLE.T$STPD 
        /*PAYMENTRECEIPTPROCEDURESTATUS*/ 
        LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STEP 
          ON   T$STEP.TABLENAME  = 'TFCMG110' 
          AND T$STEP.COLUMNNAME = 'T$STEP' 
          AND T$STEP.CONSTANT   = SOURCETABLE.T$STEP 
        /*SELECT TOP 10*/  
        LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SREC 
          ON   T$SREC.TABLENAME  = 'TFCMG110' 
          AND T$SREC.COLUMNNAME = 'T$SREC' 
          AND T$SREC.CONSTANT   = SOURCETABLE.T$SREC 
        /*SENTTOBANK*/ 
        LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STBK 
          ON   T$STBK.TABLENAME  = 'TFCMG110' 
          AND T$STBK.COLUMNNAME = 'T$STBK' 
          AND T$STBK.CONSTANT   = SOURCETABLE.T$STBK 
    {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
)        
,transform_data as
( 
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACCEPTEDAMOUNT,
        ACCEPTENCEOFRECEIPTDESCRIPTION,
        ACCEPTENCEOFRECEIPTID,
        BATCHNUMBER,
        BUSINESSPARTNERBANK,
        CHECKNUMBER,
        CODEOFPOSTINGDESCRIPTION,
        CODEOFPOSTINGID,
        CURRENCY,
        DATEOFCREATIONANTICIPATEDPAYMENTRECEIPT,
        DOCNRFORDOCSENTTOBANK,
        DOCUMENTFORANTPMT,
        DUEDATEOFTRADENOTE,
        PARENTBUSINESSPARTNER,
        PAYFROMBANK,
        PAYMENTBATCH,
        PAYMENTDATE,
        PAYMENTDOCUMENT,
        PAYMENTDOCUMENTSTATUSDESCRIPTION,
        PAYMENTDOCUMENTSTATUSID,
        PAYMENTPERIOD,
        PAYMENTRECEIPTMETHOD,
        PAYMENTRECEIPTPROCEDURESTATUSDESCRIPTION,
        PAYMENTRECEIPTPROCEDURESTATUSID,
        PAYMENTTRANSACTIONTYPE,
        PAYMENTYEAR,
        PLANNEDCLEARINGDATE,
        RATE1,
        RATE2,
        RATE3,
        RATEDATE,
        RATEFACTOR1,
        RATEFACTOR2,
        RATEFACTOR3,
        RATETYPE,
        RECONCILIATIONCURRENCY,
        REFERENCEOFRECEIPT,
        REJECTEDAMOUNT,
        SELECTFORAUTOMATICRECONCILIATIONDESCRIPTION,
        SELECTFORAUTOMATICRECONCILIATIONID,
        SENTTOBANKDESCRIPTION,
        SENTTOBANKID,
        TOBANK,
        TRANSACTIONAMOUNT,
        TRANSACTIONTYPE,
        TRANSACTIONTYPEDOCUMENTSENTTOBANK,
        YEAR
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACCEPTEDAMOUNT as NUMBER(15,2)) as ACCEPTEDAMOUNT,
        cast(ACCEPTENCEOFRECEIPTDESCRIPTION as VARCHAR(16777216)) as ACCEPTENCEOFRECEIPTDESCRIPTION,
        cast(ACCEPTENCEOFRECEIPTID as NUMBER(38,0)) as ACCEPTENCEOFRECEIPTID,
        cast(BATCHNUMBER as NUMBER(38,0)) as BATCHNUMBER,
        cast(BUSINESSPARTNERBANK as VARCHAR(3)) as BUSINESSPARTNERBANK,
        cast(CHECKNUMBER as VARCHAR(15)) as CHECKNUMBER,
        cast(CODEOFPOSTINGDESCRIPTION as VARCHAR(16777216)) as CODEOFPOSTINGDESCRIPTION,
        cast(CODEOFPOSTINGID as NUMBER(38,0)) as CODEOFPOSTINGID,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(DATEOFCREATIONANTICIPATEDPAYMENTRECEIPT as DATE) as DATEOFCREATIONANTICIPATEDPAYMENTRECEIPT,
        cast(DOCNRFORDOCSENTTOBANK as NUMBER(38,0)) as DOCNRFORDOCSENTTOBANK,
        cast(DOCUMENTFORANTPMT as NUMBER(38,0)) as DOCUMENTFORANTPMT,
        cast(DUEDATEOFTRADENOTE as DATE) as DUEDATEOFTRADENOTE,
        cast(PARENTBUSINESSPARTNER as VARCHAR(9)) as PARENTBUSINESSPARTNER,
        cast(PAYFROMBANK as VARCHAR(3)) as PAYFROMBANK,
        cast(PAYMENTBATCH as NUMBER(38,0)) as PAYMENTBATCH,
        cast(PAYMENTDATE as DATE) as PAYMENTDATE,
        cast(PAYMENTDOCUMENT as NUMBER(38,0)) as PAYMENTDOCUMENT,
        cast(PAYMENTDOCUMENTSTATUSDESCRIPTION as VARCHAR(16777216)) as PAYMENTDOCUMENTSTATUSDESCRIPTION,
        cast(PAYMENTDOCUMENTSTATUSID as NUMBER(38,0)) as PAYMENTDOCUMENTSTATUSID,
        cast(PAYMENTPERIOD as NUMBER(38,0)) as PAYMENTPERIOD,
        cast(PAYMENTRECEIPTMETHOD as VARCHAR(3)) as PAYMENTRECEIPTMETHOD,
        cast(PAYMENTRECEIPTPROCEDURESTATUSDESCRIPTION as VARCHAR(16777216)) as PAYMENTRECEIPTPROCEDURESTATUSDESCRIPTION,
        cast(PAYMENTRECEIPTPROCEDURESTATUSID as NUMBER(38,0)) as PAYMENTRECEIPTPROCEDURESTATUSID,
        cast(PAYMENTTRANSACTIONTYPE as VARCHAR(3)) as PAYMENTTRANSACTIONTYPE,
        cast(PAYMENTYEAR as NUMBER(38,0)) as PAYMENTYEAR,
        cast(PLANNEDCLEARINGDATE as DATE) as PLANNEDCLEARINGDATE,
        cast(RATE1 as NUMBER(15,2)) as RATE1,
        cast(RATE2 as NUMBER(15,2)) as RATE2,
        cast(RATE3 as NUMBER(15,2)) as RATE3,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(RATETYPE as VARCHAR(3)) as RATETYPE,
        cast(RECONCILIATIONCURRENCY as VARCHAR(3)) as RECONCILIATIONCURRENCY,
        cast(REFERENCEOFRECEIPT as VARCHAR(30)) as REFERENCEOFRECEIPT,
        cast(REJECTEDAMOUNT as NUMBER(15,2)) as REJECTEDAMOUNT,
        cast(SELECTFORAUTOMATICRECONCILIATIONDESCRIPTION as VARCHAR(16777216)) as SELECTFORAUTOMATICRECONCILIATIONDESCRIPTION,
        cast(SELECTFORAUTOMATICRECONCILIATIONID as NUMBER(38,0)) as SELECTFORAUTOMATICRECONCILIATIONID,
        cast(SENTTOBANKDESCRIPTION as VARCHAR(16777216)) as SENTTOBANKDESCRIPTION,
        cast(SENTTOBANKID as NUMBER(38,0)) as SENTTOBANKID,
        cast(TOBANK as VARCHAR(3)) as TOBANK,
        cast(TRANSACTIONAMOUNT as NUMBER(15,2)) as TRANSACTIONAMOUNT,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(TRANSACTIONTYPEDOCUMENTSENTTOBANK as VARCHAR(3)) as TRANSACTIONTYPEDOCUMENTSENTTOBANK,
        cast(YEAR as NUMBER(38,0)) as YEAR,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data