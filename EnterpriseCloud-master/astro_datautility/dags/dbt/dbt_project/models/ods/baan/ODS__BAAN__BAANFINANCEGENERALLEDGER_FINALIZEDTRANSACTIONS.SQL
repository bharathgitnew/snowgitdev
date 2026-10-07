/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONS.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONS 
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
    alias='BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONS',
    unique_key = ['_COMPANYID',
    'BACKGROUNDSEQUENCENO',
    'DOCUMENT',
    'LINENUMBER',
    'SEQUENCENUMBER',
    'TRANSACTIONTYPE']
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
            ,CAST(T$OSRN AS TINYINT)                                                                                                             AS BACKGROUNDSEQUENCENO 
            ,CAST(T$OBAT AS BIGINT)                                                                                                              AS BATCHNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS BUSINESSPARTNER 
            ,T$CONT.CONSTANTDESCRIPTION                                                                                                          AS CONTROLACCOUNTDESCRIPTION 
            ,CAST(T$CONT AS INT)                                                                                                                 AS CONTROLACCOUNTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRYFORTAX 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,T$DBCR.CONSTANTDESCRIPTION                                                                                                          AS DEBITCREDITDESCRIPTION 
            ,CAST(T$DBCR AS INT)                                                                                                                 AS DEBITCREDITID 
            ,T$DELE.CONSTANTDESCRIPTION                                                                                                          AS DELETEDDESCRIPTION 
            ,CAST(T$DELE AS INT)                                                                                                                 AS DELETEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,CAST(T$TYP1 AS TINYINT)                                                                                                             AS DIMENSIONTYPE1 
            ,CAST(T$TYP2 AS TINYINT)                                                                                                             AS DIMENSIONTYPE2 
            ,CAST(T$TYP3 AS TINYINT)                                                                                                             AS DIMENSIONTYPE3 
            ,CAST(T$TYP4 AS TINYINT)                                                                                                             AS DIMENSIONTYPE4 
            ,CAST(T$TYP5 AS TINYINT)                                                                                                             AS DIMENSIONTYPE5 
            ,CAST(T$ODOC AS BIGINT)                                                                                                              AS DOCUMENT 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,CAST(CASE WHEN T$DATE<= '1/1/1970' THEN NULL ELSE T$DATE END AS DATE)                                                             AS FINALIZATIONDATE 
            ,CAST(T$TRUN AS BIGINT)                                                                                                              AS FINALIZATIONRUNNUMBER 
            ,CAST(T$TIME AS BIGINT)                                                                                                              AS FINALIZATIONTIME 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR_FYER 
            ,CAST(T$OYER AS INT)                                                                                                                 AS FISCALYEAR_OYER 
            ,T$INTT.CONSTANTDESCRIPTION                                                                                                          AS INTEGRATIONTRANSACTIONDESCRIPTION 
            ,CAST(T$INTT AS INT)                                                                                                                 AS INTEGRATIONTRANSACTIONID 
            ,CAST(T$CINV AS BIGINT)                                                                                                              AS INVOICECORRECTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USER)),'')                                                                                         AS LASTMODIFICATIONBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNTNUMBER 
            ,CAST(T$OLIN AS BIGINT)                                                                                                              AS LINENUMBER 
            ,CAST(T$OCMP AS INT)                                                                                                                 AS ORIGINALCOMPANY 
            ,CAST(T$FDOC AS BIGINT)                                                                                                              AS ORIGINALDOCUMENTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FTYP)),'')                                                                                         AS ORIGINALTRANSACTIONTYPE 
            ,CAST(T$QTY1 AS NUMERIC(15,2))                                                                                                       AS QUANTITY1 
            ,CAST(T$QTY2 AS NUMERIC(15,2))                                                                                                       AS QUANTITY2 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS RATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS RATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS RATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$FACT$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$FACT$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$FACT$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REF2)),'')                                                                                         AS REFERENCE_REF2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFR)),'')                                                                                         AS REFERENCE_REFR 
            ,CAST(T$RPRD AS INT)                                                                                                                 AS REPORTINGPERIOD 
            ,CAST(T$RYER AS INT)                                                                                                                 AS REPORTINGYEAR 
            ,CAST(T$OSRL AS BIGINT)                                                                                                              AS SEQUENCENUMBER 
            ,CAST(T$CORN AS BIGINT)                                                                                                              AS STANDINRDER 
            ,CAST(T$CSRN AS TINYINT)                                                                                                             AS STANDINRDERSEQUENCENO 
            ,CAST(T$VAMT AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,CAST("T$VAMH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$VAMH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$VAMH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$VLAC)),'')                                                                                         AS TAXLEDGERACCOUNT 
            ,CAST(T$VPRD AS INT)                                                                                                                 AS TAXPERIOD 
            ,T$VTYP.CONSTANTDESCRIPTION                                                                                                          AS TAXTYPEDESCRIPTION 
            ,CAST(T$VTYP AS INT)                                                                                                                 AS TAXTYPEID 
            ,CAST(T$VYER AS INT)                                                                                                                 AS TAXYEAR 
            ,T$CATG.CONSTANTDESCRIPTION                                                                                                          AS TRANSACTIONCATERYDESCRIPTION 
            ,CAST(T$CATG AS INT)                                                                                                                 AS TRANSACTIONCATERYID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TRANSACTIONTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTYP)),'')                                                                                         AS TRANSTYPECORRECTION 
            ,T$TCSH.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFCASHTRANSACTIONDESCRIPTION 
            ,CAST(T$TCSH AS INT)                                                                                                                 AS TYPEOFCASHTRANSACTIONID 
            ,T$TRAN.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFTRANSACTIONDESCRIPTION 
            ,CAST(T$TRAN AS INT)                                                                                                                 AS TYPEOFTRANSACTIONID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD106200") }} AS SOURCETABLE  
            /*CONTROLACCOUNT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONT 
             ON   T$CONT.TABLENAME  = 'TFGLD106' 
              AND T$CONT.COLUMNNAME = 'T$CONT' 
              AND T$CONT.CONSTANT   = SOURCETABLE.T$CONT 
            /*DEBITCREDIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DBCR 
             ON   T$DBCR.TABLENAME  = 'TFGLD106' 
              AND T$DBCR.COLUMNNAME = 'T$DBCR' 
              AND T$DBCR.CONSTANT   = SOURCETABLE.T$DBCR 
            /*DELETED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DELE 
             ON   T$DELE.TABLENAME  = 'TFGLD106' 
              AND T$DELE.COLUMNNAME = 'T$DELE' 
              AND T$DELE.CONSTANT   = SOURCETABLE.T$DELE 
            /*INTEGRATIONTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INTT 
             ON   T$INTT.TABLENAME  = 'TFGLD106' 
              AND T$INTT.COLUMNNAME = 'T$INTT' 
              AND T$INTT.CONSTANT   = SOURCETABLE.T$INTT 
            /*TAXTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VTYP 
             ON   T$VTYP.TABLENAME  = 'TFGLD106' 
              AND T$VTYP.COLUMNNAME = 'T$VTYP' 
              AND T$VTYP.CONSTANT   = SOURCETABLE.T$VTYP 
            /*TRANSACTIONCATERY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CATG 
             ON   T$CATG.TABLENAME  = 'TFGLD106' 
              AND T$CATG.COLUMNNAME = 'T$CATG' 
              AND T$CATG.CONSTANT   = SOURCETABLE.T$CATG 
            /*TYPEOFCASHTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TCSH 
             ON   T$TCSH.TABLENAME  = 'TFGLD106' 
              AND T$TCSH.COLUMNNAME = 'T$TCSH' 
              AND T$TCSH.CONSTANT   = SOURCETABLE.T$TCSH 
            /*TYPEOFTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TRAN 
             ON   T$TRAN.TABLENAME  = 'TFGLD106' 
              AND T$TRAN.COLUMNNAME = 'T$TRAN' 
              AND T$TRAN.CONSTANT   = SOURCETABLE.T$TRAN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY3 
            ,CAST(T$OSRN AS TINYINT)                                                                                                             AS BACKGROUNDSEQUENCENO 
            ,CAST(T$OBAT AS BIGINT)                                                                                                              AS BATCHNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS BUSINESSPARTNER 
            ,T$CONT.CONSTANTDESCRIPTION                                                                                                          AS CONTROLACCOUNTDESCRIPTION 
            ,CAST(T$CONT AS INT)                                                                                                                 AS CONTROLACCOUNTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRYFORTAX 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,T$DBCR.CONSTANTDESCRIPTION                                                                                                          AS DEBITCREDITDESCRIPTION 
            ,CAST(T$DBCR AS INT)                                                                                                                 AS DEBITCREDITID 
            ,T$DELE.CONSTANTDESCRIPTION                                                                                                          AS DELETEDDESCRIPTION 
            ,CAST(T$DELE AS INT)                                                                                                                 AS DELETEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,CAST(T$TYP1 AS TINYINT)                                                                                                             AS DIMENSIONTYPE1 
            ,CAST(T$TYP2 AS TINYINT)                                                                                                             AS DIMENSIONTYPE2 
            ,CAST(T$TYP3 AS TINYINT)                                                                                                             AS DIMENSIONTYPE3 
            ,CAST(T$TYP4 AS TINYINT)                                                                                                             AS DIMENSIONTYPE4 
            ,CAST(T$TYP5 AS TINYINT)                                                                                                             AS DIMENSIONTYPE5 
            ,CAST(T$ODOC AS BIGINT)                                                                                                              AS DOCUMENT 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,CAST(CASE WHEN T$DATE<= '1/1/1970' THEN NULL ELSE T$DATE END AS DATE)                                                             AS FINALIZATIONDATE 
            ,CAST(T$TRUN AS BIGINT)                                                                                                              AS FINALIZATIONRUNNUMBER 
            ,CAST(T$TIME AS BIGINT)                                                                                                              AS FINALIZATIONTIME 
            ,CAST(T$FPRD AS INT)                                                                                                                 AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                                                                                 AS FISCALYEAR_FYER 
            ,CAST(T$OYER AS INT)                                                                                                                 AS FISCALYEAR_OYER 
            ,T$INTT.CONSTANTDESCRIPTION                                                                                                          AS INTEGRATIONTRANSACTIONDESCRIPTION 
            ,CAST(T$INTT AS INT)                                                                                                                 AS INTEGRATIONTRANSACTIONID 
            ,CAST(T$CINV AS BIGINT)                                                                                                              AS INVOICECORRECTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USER)),'')                                                                                         AS LASTMODIFICATIONBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNTNUMBER 
            ,CAST(T$OLIN AS BIGINT)                                                                                                              AS LINENUMBER 
            ,CAST(T$OCMP AS INT)                                                                                                                 AS ORIGINALCOMPANY 
            ,CAST(T$FDOC AS BIGINT)                                                                                                              AS ORIGINALDOCUMENTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FTYP)),'')                                                                                         AS ORIGINALTRANSACTIONTYPE 
            ,CAST(T$QTY1 AS NUMERIC(15,2))                                                                                                       AS QUANTITY1 
            ,CAST(T$QTY2 AS NUMERIC(15,2))                                                                                                       AS QUANTITY2 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS RATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS RATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS RATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$FACT$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$FACT$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$FACT$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REF2)),'')                                                                                         AS REFERENCE_REF2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFR)),'')                                                                                         AS REFERENCE_REFR 
            ,CAST(T$RPRD AS INT)                                                                                                                 AS REPORTINGPERIOD 
            ,CAST(T$RYER AS INT)                                                                                                                 AS REPORTINGYEAR 
            ,CAST(T$OSRL AS BIGINT)                                                                                                              AS SEQUENCENUMBER 
            ,CAST(T$CORN AS BIGINT)                                                                                                              AS STANDINRDER 
            ,CAST(T$CSRN AS TINYINT)                                                                                                             AS STANDINRDERSEQUENCENO 
            ,CAST(T$VAMT AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,CAST("T$VAMH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$VAMH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$VAMH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$VLAC)),'')                                                                                         AS TAXLEDGERACCOUNT 
            ,CAST(T$VPRD AS INT)                                                                                                                 AS TAXPERIOD 
            ,T$VTYP.CONSTANTDESCRIPTION                                                                                                          AS TAXTYPEDESCRIPTION 
            ,CAST(T$VTYP AS INT)                                                                                                                 AS TAXTYPEID 
            ,CAST(T$VYER AS INT)                                                                                                                 AS TAXYEAR 
            ,T$CATG.CONSTANTDESCRIPTION                                                                                                          AS TRANSACTIONCATERYDESCRIPTION 
            ,CAST(T$CATG AS INT)                                                                                                                 AS TRANSACTIONCATERYID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TRANSACTIONTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTYP)),'')                                                                                         AS TRANSTYPECORRECTION 
            ,T$TCSH.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFCASHTRANSACTIONDESCRIPTION 
            ,CAST(T$TCSH AS INT)                                                                                                                 AS TYPEOFCASHTRANSACTIONID 
            ,T$TRAN.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFTRANSACTIONDESCRIPTION 
            ,CAST(T$TRAN AS INT)                                                                                                                 AS TYPEOFTRANSACTIONID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD106201") }} AS SOURCETABLE  
            /*CONTROLACCOUNT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONT 
             ON   T$CONT.TABLENAME  = 'TFGLD106' 
              AND T$CONT.COLUMNNAME = 'T$CONT' 
              AND T$CONT.CONSTANT   = SOURCETABLE.T$CONT 
            /*DEBITCREDIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DBCR 
             ON   T$DBCR.TABLENAME  = 'TFGLD106' 
              AND T$DBCR.COLUMNNAME = 'T$DBCR' 
              AND T$DBCR.CONSTANT   = SOURCETABLE.T$DBCR 
            /*DELETED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DELE 
             ON   T$DELE.TABLENAME  = 'TFGLD106' 
              AND T$DELE.COLUMNNAME = 'T$DELE' 
              AND T$DELE.CONSTANT   = SOURCETABLE.T$DELE 
            /*INTEGRATIONTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INTT 
             ON   T$INTT.TABLENAME  = 'TFGLD106' 
              AND T$INTT.COLUMNNAME = 'T$INTT' 
              AND T$INTT.CONSTANT   = SOURCETABLE.T$INTT 
            /*TAXTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VTYP 
             ON   T$VTYP.TABLENAME  = 'TFGLD106' 
              AND T$VTYP.COLUMNNAME = 'T$VTYP' 
              AND T$VTYP.CONSTANT   = SOURCETABLE.T$VTYP 
            /*TRANSACTIONCATERY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CATG 
             ON   T$CATG.TABLENAME  = 'TFGLD106' 
              AND T$CATG.COLUMNNAME = 'T$CATG' 
              AND T$CATG.CONSTANT   = SOURCETABLE.T$CATG 
            /*TYPEOFCASHTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TCSH 
             ON   T$TCSH.TABLENAME  = 'TFGLD106' 
              AND T$TCSH.COLUMNNAME = 'T$TCSH' 
              AND T$TCSH.CONSTANT   = SOURCETABLE.T$TCSH 
            /*TYPEOFTRANSACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TRAN 
             ON   T$TRAN.TABLENAME  = 'TFGLD106' 
              AND T$TRAN.COLUMNNAME = 'T$TRAN' 
              AND T$TRAN.CONSTANT   = SOURCETABLE.T$TRAN 
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
        source_data.BACKGROUNDSEQUENCENO AS BACKGROUNDSEQUENCENO, 
        source_data.BATCHNUMBER AS BATCHNUMBER, 
        source_data.BUSINESSPARTNER AS BUSINESSPARTNER, 
        source_data.CONTROLACCOUNTDESCRIPTION AS CONTROLACCOUNTDESCRIPTION, 
        source_data.CONTROLACCOUNTID AS CONTROLACCOUNTID, 
        source_data.COUNTRYFORTAX AS COUNTRYFORTAX, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DEBITCREDITDESCRIPTION AS DEBITCREDITDESCRIPTION, 
        source_data.DEBITCREDITID AS DEBITCREDITID, 
        source_data.DELETEDDESCRIPTION AS DELETEDDESCRIPTION, 
        source_data.DELETEDID AS DELETEDID, 
        source_data.DIMENSION1 AS DIMENSION1, 
        source_data.DIMENSION2 AS DIMENSION2, 
        source_data.DIMENSION3 AS DIMENSION3, 
        source_data.DIMENSION4 AS DIMENSION4, 
        source_data.DIMENSION5 AS DIMENSION5, 
        source_data.DIMENSIONTYPE1 AS DIMENSIONTYPE1, 
        source_data.DIMENSIONTYPE2 AS DIMENSIONTYPE2, 
        source_data.DIMENSIONTYPE3 AS DIMENSIONTYPE3, 
        source_data.DIMENSIONTYPE4 AS DIMENSIONTYPE4, 
        source_data.DIMENSIONTYPE5 AS DIMENSIONTYPE5, 
        source_data.DOCUMENT AS DOCUMENT, 
        source_data.DOCUMENTDATE AS DOCUMENTDATE, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.FINALIZATIONDATE AS FINALIZATIONDATE, 
        source_data.FINALIZATIONRUNNUMBER AS FINALIZATIONRUNNUMBER, 
        source_data.FINALIZATIONTIME AS FINALIZATIONTIME, 
        source_data.FISCALPERIOD AS FISCALPERIOD, 
        source_data.FISCALYEAR_FYER AS FISCALYEAR_FYER, 
        source_data.FISCALYEAR_OYER AS FISCALYEAR_OYER, 
        source_data.INTEGRATIONTRANSACTIONDESCRIPTION AS INTEGRATIONTRANSACTIONDESCRIPTION, 
        source_data.INTEGRATIONTRANSACTIONID AS INTEGRATIONTRANSACTIONID, 
        source_data.INVOICECORRECTION AS INVOICECORRECTION, 
        source_data.LASTMODIFICATIONBY AS LASTMODIFICATIONBY, 
        source_data.LEDGERACCOUNTNUMBER AS LEDGERACCOUNTNUMBER, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.ORIGINALCOMPANY AS ORIGINALCOMPANY, 
        source_data.ORIGINALDOCUMENTNUMBER AS ORIGINALDOCUMENTNUMBER, 
        source_data.ORIGINALTRANSACTIONTYPE AS ORIGINALTRANSACTIONTYPE, 
        source_data.QUANTITY1 AS QUANTITY1, 
        source_data.QUANTITY2 AS QUANTITY2, 
        source_data.RATE1 AS RATE1, 
        source_data.RATE2 AS RATE2, 
        source_data.RATE3 AS RATE3, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.REFERENCE_REF2 AS REFERENCE_REF2, 
        source_data.REFERENCE_REFR AS REFERENCE_REFR, 
        source_data.REPORTINGPERIOD AS REPORTINGPERIOD, 
        source_data.REPORTINGYEAR AS REPORTINGYEAR, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.STANDINRDER AS STANDINRDER, 
        source_data.STANDINRDERSEQUENCENO AS STANDINRDERSEQUENCENO, 
        source_data.TAXAMOUNT AS TAXAMOUNT, 
        source_data.TAXAMOUNTINHOMECURRENCY1 AS TAXAMOUNTINHOMECURRENCY1, 
        source_data.TAXAMOUNTINHOMECURRENCY2 AS TAXAMOUNTINHOMECURRENCY2, 
        source_data.TAXAMOUNTINHOMECURRENCY3 AS TAXAMOUNTINHOMECURRENCY3, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TAXLEDGERACCOUNT AS TAXLEDGERACCOUNT, 
        source_data.TAXPERIOD AS TAXPERIOD, 
        source_data.TAXTYPEDESCRIPTION AS TAXTYPEDESCRIPTION, 
        source_data.TAXTYPEID AS TAXTYPEID, 
        source_data.TAXYEAR AS TAXYEAR, 
        source_data.TRANSACTIONCATERYDESCRIPTION AS TRANSACTIONCATERYDESCRIPTION, 
        source_data.TRANSACTIONCATERYID AS TRANSACTIONCATERYID, 
        source_data.TRANSACTIONTEXT AS TRANSACTIONTEXT, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE, 
        source_data.TRANSTYPECORRECTION AS TRANSTYPECORRECTION, 
        source_data.TYPEOFCASHTRANSACTIONDESCRIPTION AS TYPEOFCASHTRANSACTIONDESCRIPTION, 
        source_data.TYPEOFCASHTRANSACTIONID AS TYPEOFCASHTRANSACTIONID, 
        source_data.TYPEOFTRANSACTIONDESCRIPTION AS TYPEOFTRANSACTIONDESCRIPTION, 
        source_data.TYPEOFTRANSACTIONID AS TYPEOFTRANSACTIONID
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
        cast(BACKGROUNDSEQUENCENO as NUMBER(38,0)) as BACKGROUNDSEQUENCENO,
        cast(BATCHNUMBER as NUMBER(38,0)) as BATCHNUMBER,
        cast(BUSINESSPARTNER as VARCHAR(9)) as BUSINESSPARTNER,
        cast(CONTROLACCOUNTDESCRIPTION as VARCHAR(16777216)) as CONTROLACCOUNTDESCRIPTION,
        cast(CONTROLACCOUNTID as NUMBER(38,0)) as CONTROLACCOUNTID,
        cast(COUNTRYFORTAX as VARCHAR(3)) as COUNTRYFORTAX,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(DEBITCREDITDESCRIPTION as VARCHAR(16777216)) as DEBITCREDITDESCRIPTION,
        cast(DEBITCREDITID as NUMBER(38,0)) as DEBITCREDITID,
        cast(DELETEDDESCRIPTION as VARCHAR(16777216)) as DELETEDDESCRIPTION,
        cast(DELETEDID as NUMBER(38,0)) as DELETEDID,
        cast(DIMENSION1 as VARCHAR(6)) as DIMENSION1,
        cast(DIMENSION2 as VARCHAR(6)) as DIMENSION2,
        cast(DIMENSION3 as VARCHAR(6)) as DIMENSION3,
        cast(DIMENSION4 as VARCHAR(6)) as DIMENSION4,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(DIMENSIONTYPE1 as NUMBER(38,0)) as DIMENSIONTYPE1,
        cast(DIMENSIONTYPE2 as NUMBER(38,0)) as DIMENSIONTYPE2,
        cast(DIMENSIONTYPE3 as NUMBER(38,0)) as DIMENSIONTYPE3,
        cast(DIMENSIONTYPE4 as NUMBER(38,0)) as DIMENSIONTYPE4,
        cast(DIMENSIONTYPE5 as NUMBER(38,0)) as DIMENSIONTYPE5,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(DOCUMENTDATE as DATE) as DOCUMENTDATE,
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(FINALIZATIONDATE as DATE) as FINALIZATIONDATE,
        cast(FINALIZATIONRUNNUMBER as NUMBER(38,0)) as FINALIZATIONRUNNUMBER,
        cast(FINALIZATIONTIME as NUMBER(38,0)) as FINALIZATIONTIME,
        cast(FISCALPERIOD as NUMBER(38,0)) as FISCALPERIOD,
        cast(FISCALYEAR_FYER as NUMBER(38,0)) as FISCALYEAR_FYER,
        cast(FISCALYEAR_OYER as NUMBER(38,0)) as FISCALYEAR_OYER,
        cast(INTEGRATIONTRANSACTIONDESCRIPTION as VARCHAR(16777216)) as INTEGRATIONTRANSACTIONDESCRIPTION,
        cast(INTEGRATIONTRANSACTIONID as NUMBER(38,0)) as INTEGRATIONTRANSACTIONID,
        cast(INVOICECORRECTION as NUMBER(38,0)) as INVOICECORRECTION,
        cast(LASTMODIFICATIONBY as VARCHAR(16)) as LASTMODIFICATIONBY,
        cast(LEDGERACCOUNTNUMBER as VARCHAR(12)) as LEDGERACCOUNTNUMBER,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(ORIGINALCOMPANY as NUMBER(38,0)) as ORIGINALCOMPANY,
        cast(ORIGINALDOCUMENTNUMBER as NUMBER(38,0)) as ORIGINALDOCUMENTNUMBER,
        cast(ORIGINALTRANSACTIONTYPE as VARCHAR(3)) as ORIGINALTRANSACTIONTYPE,
        cast(QUANTITY1 as NUMBER(15,2)) as QUANTITY1,
        cast(QUANTITY2 as NUMBER(15,2)) as QUANTITY2,
        cast(RATE1 as NUMBER(15,2)) as RATE1,
        cast(RATE2 as NUMBER(15,2)) as RATE2,
        cast(RATE3 as NUMBER(15,2)) as RATE3,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(REFERENCE_REF2 as VARCHAR(32)) as REFERENCE_REF2,
        cast(REFERENCE_REFR as VARCHAR(32)) as REFERENCE_REFR,
        cast(REPORTINGPERIOD as NUMBER(38,0)) as REPORTINGPERIOD,
        cast(REPORTINGYEAR as NUMBER(38,0)) as REPORTINGYEAR,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(STANDINRDER as NUMBER(38,0)) as STANDINRDER,
        cast(STANDINRDERSEQUENCENO as NUMBER(38,0)) as STANDINRDERSEQUENCENO,
        cast(TAXAMOUNT as NUMBER(15,2)) as TAXAMOUNT,
        cast(TAXAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY1,
        cast(TAXAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY2,
        cast(TAXAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY3,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(TAXLEDGERACCOUNT as VARCHAR(12)) as TAXLEDGERACCOUNT,
        cast(TAXPERIOD as NUMBER(38,0)) as TAXPERIOD,
        cast(TAXTYPEDESCRIPTION as VARCHAR(16777216)) as TAXTYPEDESCRIPTION,
        cast(TAXTYPEID as NUMBER(38,0)) as TAXTYPEID,
        cast(TAXYEAR as NUMBER(38,0)) as TAXYEAR,
        cast(TRANSACTIONCATERYDESCRIPTION as VARCHAR(16777216)) as TRANSACTIONCATERYDESCRIPTION,
        cast(TRANSACTIONCATERYID as NUMBER(38,0)) as TRANSACTIONCATERYID,
        cast(TRANSACTIONTEXT as NUMBER(38,10)) as TRANSACTIONTEXT,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(TRANSTYPECORRECTION as VARCHAR(3)) as TRANSTYPECORRECTION,
        cast(TYPEOFCASHTRANSACTIONDESCRIPTION as VARCHAR(16777216)) as TYPEOFCASHTRANSACTIONDESCRIPTION,
        cast(TYPEOFCASHTRANSACTIONID as NUMBER(38,0)) as TYPEOFCASHTRANSACTIONID,
        cast(TYPEOFTRANSACTIONDESCRIPTION as VARCHAR(16777216)) as TYPEOFTRANSACTIONDESCRIPTION,
        cast(TYPEOFTRANSACTIONID as NUMBER(38,0)) as TYPEOFTRANSACTIONID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data