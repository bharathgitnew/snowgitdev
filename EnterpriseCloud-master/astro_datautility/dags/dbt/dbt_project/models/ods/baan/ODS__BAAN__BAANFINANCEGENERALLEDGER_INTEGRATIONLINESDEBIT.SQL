/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_INTEGRATIONLINESDEBIT.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_INTEGRATIONLINESDEBIT.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_INTEGRATIONLINESDEBIT 
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
    alias='BAANFINANCEGENERALLEDGER_INTEGRATIONLINESDEBIT',
    unique_key = ['FINANCIALTRANSACTIONID',
    'ORIGINALCOMPANY',
    'SEQUENCENUMBER',
    'TRANSACTIONDATE',
    'TRANSACTIONORIGINID']
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
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                         AS COSTPRICECOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE3 
            ,T$DBCR.CONSTANTDESCRIPTION                                                                                                          AS DEBITCREDITDESCRIPTION 
            ,CAST(T$DBCR AS INT)                                                                                                                 AS DEBITCREDITID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS DEPARTMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSIONCODE1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSIONCODE2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSIONCODE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSIONCODE4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSIONCODE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ENID)),'')                                                                                         AS ENTERPRISEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,T$FITR.CONSTANTDESCRIPTION                                                                                                          AS FINANCIALTRANSACTIONDESCRIPTION 
            ,CAST(T$FITR AS INT)                                                                                                                 AS FINANCIALTRANSACTIONID 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$NUNI AS NUMERIC(15,2))                                                                                                       AS NUMBEROFUNITS 
            ,CAST(T$OCOM AS INT)                                                                                                                 AS ORIGINALCOMPANY 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,CAST(T$RPRD AS INT)                                                                                                                 AS REPORTINGPERIOD 
            ,CAST(T$RYER AS INT)                                                                                                                 AS REPORTINGYEAR 
            ,CAST(T$SERN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,T$TROR.CONSTANTDESCRIPTION                                                                                                          AS TRANSACTIONORIGINDESCRIPTION 
            ,CAST(T$TROR AS INT)                                                                                                                 AS TRANSACTIONORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD410200") }} AS SOURCETABLE  
            /*DEBITCREDIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DBCR 
             ON   T$DBCR.TABLENAME  = 'TFGLD410' 
              AND T$DBCR.COLUMNNAME = 'T$DBCR' 
              AND T$DBCR.CONSTANT   = SOURCETABLE.T$DBCR 
            /*FINANCIALTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FITR 
             ON   T$FITR.TABLENAME  = 'TFGLD410' 
              AND T$FITR.COLUMNNAME = 'T$FITR' 
              AND T$FITR.CONSTANT   = SOURCETABLE.T$FITR 
            /*TRANSACTIONORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TROR 
             ON   T$TROR.TABLENAME  = 'TFGLD410' 
              AND T$TROR.COLUMNNAME = 'T$TROR' 
              AND T$TROR.CONSTANT   = SOURCETABLE.T$TROR 
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
        source_data.COSTPRICECOMPONENT AS COSTPRICECOMPONENT, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.CURRENCYRATE1 AS CURRENCYRATE1, 
        source_data.CURRENCYRATE2 AS CURRENCYRATE2, 
        source_data.CURRENCYRATE3 AS CURRENCYRATE3, 
        source_data.DEBITCREDITDESCRIPTION AS DEBITCREDITDESCRIPTION, 
        source_data.DEBITCREDITID AS DEBITCREDITID, 
        source_data.DEPARTMENT AS DEPARTMENT, 
        source_data.DIMENSIONCODE1 AS DIMENSIONCODE1, 
        source_data.DIMENSIONCODE2 AS DIMENSIONCODE2, 
        source_data.DIMENSIONCODE3 AS DIMENSIONCODE3, 
        source_data.DIMENSIONCODE4 AS DIMENSIONCODE4, 
        source_data.DIMENSIONCODE5 AS DIMENSIONCODE5, 
        source_data.ENTERPRISEUNIT AS ENTERPRISEUNIT, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.FINANCIALTRANSACTIONDESCRIPTION AS FINANCIALTRANSACTIONDESCRIPTION, 
        source_data.FINANCIALTRANSACTIONID AS FINANCIALTRANSACTIONID, 
        source_data.FISCALPERIOD AS FISCALPERIOD, 
        source_data.FISCALYEAR AS FISCALYEAR, 
        source_data.ITEM AS ITEM, 
        source_data.LEDGERACCOUNT AS LEDGERACCOUNT, 
        source_data.NUMBEROFUNITS AS NUMBEROFUNITS, 
        source_data.ORIGINALCOMPANY AS ORIGINALCOMPANY, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.REPORTINGPERIOD AS REPORTINGPERIOD, 
        source_data.REPORTINGYEAR AS REPORTINGYEAR, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.TRANSACTIONORIGINDESCRIPTION AS TRANSACTIONORIGINDESCRIPTION, 
        source_data.TRANSACTIONORIGINID AS TRANSACTIONORIGINID, 
        source_data.UNIT AS UNIT, 
        source_data.WAREHOUSE AS WAREHOUSE
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
        cast(COSTPRICECOMPONENT as VARCHAR(8)) as COSTPRICECOMPONENT,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(CURRENCYRATE1 as NUMBER(15,2)) as CURRENCYRATE1,
        cast(CURRENCYRATE2 as NUMBER(15,2)) as CURRENCYRATE2,
        cast(CURRENCYRATE3 as NUMBER(15,2)) as CURRENCYRATE3,
        cast(DEBITCREDITDESCRIPTION as VARCHAR(16777216)) as DEBITCREDITDESCRIPTION,
        cast(DEBITCREDITID as NUMBER(38,0)) as DEBITCREDITID,
        cast(DEPARTMENT as VARCHAR(6)) as DEPARTMENT,
        cast(DIMENSIONCODE1 as VARCHAR(6)) as DIMENSIONCODE1,
        cast(DIMENSIONCODE2 as VARCHAR(6)) as DIMENSIONCODE2,
        cast(DIMENSIONCODE3 as VARCHAR(6)) as DIMENSIONCODE3,
        cast(DIMENSIONCODE4 as VARCHAR(6)) as DIMENSIONCODE4,
        cast(DIMENSIONCODE5 as VARCHAR(6)) as DIMENSIONCODE5,
        cast(ENTERPRISEUNIT as VARCHAR(6)) as ENTERPRISEUNIT,
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(FINANCIALTRANSACTIONDESCRIPTION as VARCHAR(16777216)) as FINANCIALTRANSACTIONDESCRIPTION,
        cast(FINANCIALTRANSACTIONID as NUMBER(38,0)) as FINANCIALTRANSACTIONID,
        cast(FISCALPERIOD as NUMBER(38,0)) as FISCALPERIOD,
        cast(FISCALYEAR as NUMBER(38,0)) as FISCALYEAR,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LEDGERACCOUNT as VARCHAR(12)) as LEDGERACCOUNT,
        cast(NUMBEROFUNITS as NUMBER(15,2)) as NUMBEROFUNITS,
        cast(ORIGINALCOMPANY as NUMBER(38,0)) as ORIGINALCOMPANY,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(REPORTINGPERIOD as NUMBER(38,0)) as REPORTINGPERIOD,
        cast(REPORTINGYEAR as NUMBER(38,0)) as REPORTINGYEAR,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(TRANSACTIONORIGINDESCRIPTION as VARCHAR(16777216)) as TRANSACTIONORIGINDESCRIPTION,
        cast(TRANSACTIONORIGINID as NUMBER(38,0)) as TRANSACTIONORIGINID,
        cast(UNIT as VARCHAR(3)) as UNIT,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data