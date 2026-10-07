/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERS.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEORDERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:56 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDERS',
    unique_key = ['SERVICEORDER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$TSTM<= '1/1/1970' THEN NULL ELSE T$TSTM  END AS DATETIME) AS ACTUALTRAVELSTARTTIME 
            ,T$APPO.CONSTANTDESCRIPTION                                                                                                          AS APPOINTMENTDESCRIPTION 
            ,CAST(T$APPO AS INT)                                                                                                                 AS APPOINTMENTID 
            ,T$BLYN.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BLYN AS INT)                                                                                                                 AS BLOCKEDID 
            ,CAST(CASE WHEN T$CADT<= '1/1/1970' THEN NULL ELSE T$CADT END AS DATE)                                                             AS CANCELDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDIS)),'')                                                                                         AS CANCELREASON 
            ,SOURCETABLE.T$TXTC   /* TEXT */                                                                                                     AS CANCELTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,T$CTCS.CONSTANTDESCRIPTION                                                                                                          AS CONSOLIDATETRAVELCOSTDESCRIPTION 
            ,CAST(T$CTCS AS INT)                                                                                                                 AS CONSOLIDATETRAVELCOSTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES3 
            ,T$DIPY.CONSTANTDESCRIPTION                                                                                                          AS DISCOUNTPOLICYDESCRIPTION 
            ,CAST(T$DIPY AS INT)                                                                                                                 AS DISCOUNTPOLICYID 
            ,T$DFPB.CONSTANTDESCRIPTION                                                                                                          AS DISCOUNTSFROMPRICEBOOKSDESCRIPTION 
            ,CAST(T$DFPB AS INT)                                                                                                                 AS DISCOUNTSFROMPRICEBOOKSID 
            ,CAST(CASE WHEN T$RACT<= '1/1/1970' THEN NULL ELSE T$RACT  END AS DATETIME) AS DISPATCHTIME 
            ,CAST(CASE WHEN T$ESTM<= '1/1/1970' THEN NULL ELSE T$ESTM  END AS DATETIME) AS EARLIESTSTARTTIME 
            ,T$EMER.CONSTANTDESCRIPTION                                                                                                          AS EMERGENCYORDERDESCRIPTION 
            ,CAST(T$EMER AS INT)                                                                                                                 AS EMERGENCYORDERID 
            ,"T$EXKR$U".CONSTANTDESCRIPTION                                                                                                        AS EXCLUDEFROMKRONOSDESCRIPTION 
            ,CAST("T$EXKR$U" AS INT)                                                                                                               AS EXCLUDEFROMKRONOSID 
            ,CAST(CASE WHEN T$AFTM<= '1/1/1970' THEN NULL ELSE T$AFTM  END AS DATETIME) AS EXECUTIONFINISHTIME 
            ,CAST(CASE WHEN T$ASTM<= '1/1/1970' THEN NULL ELSE T$ASTM  END AS DATETIME) AS EXECUTIONSTARTTIME 
            ,T$ITYN.CONSTANTDESCRIPTION                                                                                                          AS INTERRUPTEDDESCRIPTION 
            ,CAST(T$ITYN AS INT)                                                                                                                 AS INTERRUPTEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRIT)),'')                                                                                         AS INTERRUPTIONREASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICE_TOBUSINESSPARTNER 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS INVOICETEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITAD)),'')                                                                                         AS INVOICETOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITCN)),'')                                                                                         AS INVOICETOCONTACT 
            ,CAST(CASE WHEN T$LUTD<= '1/1/1970' THEN NULL ELSE T$LUTD  END AS DATETIME) AS LASTUPDATED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,CAST(CASE WHEN T$LFTM<= '1/1/1970' THEN NULL ELSE T$LFTM  END AS DATETIME) AS LATESTFINISHTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                         AS LINEOFBUSINESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LCAD)),'')                                                                                         AS LOCATIONADDRESS 
            ,"T$NCDR$U".CONSTANTDESCRIPTION                                                                                                        AS NCDRDESCRIPTION 
            ,CAST("T$NCDR$U" AS INT)                                                                                                               AS NCDRID 
            ,CAST(CASE WHEN T$ORDT<= '1/1/1970' THEN NULL ELSE T$ORDT  END AS DATETIME) AS ORDER_DATE 
            ,CAST(T$ORDU AS NUMERIC(15,2))                                                                                                       AS ORDER_DURATION 
            ,"T$PRIO$U".CONSTANTDESCRIPTION                                                                                                        AS ORDER_PRIORITYDESCRIPTION 
            ,CAST("T$PRIO$U" AS INT)                                                                                                               AS ORDER_PRIORITYID 
            ,CAST(CASE WHEN T$ORRT<= '1/1/1970' THEN NULL ELSE T$ORRT  END AS DATETIME) AS ORDER_RELEASETIME 
            ,T$OSTA.CONSTANTDESCRIPTION                                                                                                          AS ORDER_STATUSDESCRIPTION 
            ,CAST(T$OSTA AS INT)                                                                                                                 AS ORDER_STATUSID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ORDER_TEXT 
            ,T$OTIM.CONSTANTDESCRIPTION                                                                                                          AS OVERTIMEDESCRIPTION 
            ,CAST(T$OTIM AS INT)                                                                                                                 AS OVERTIMEID 
            ,CAST(T$MINU AS BIGINT)                                                                                                              AS PAGEFREQUENCY 
            ,"T$PDSR$U".CONSTANTDESCRIPTION                                                                                                        AS PAIDSERVICETYPEDESCRIPTION 
            ,CAST("T$PDSR$U" AS INT)                                                                                                               AS PAIDSERVICETYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFAD)),'')                                                                                         AS PAYFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFCN)),'')                                                                                         AS PAYFROMCONTACT 
            ,CAST(CASE WHEN T$PFTM<= '1/1/1970' THEN NULL ELSE T$PFTM  END AS DATETIME) AS PLANNEDFINISHTIME 
            ,CAST(CASE WHEN T$PSTM<= '1/1/1970' THEN NULL ELSE T$PSTM  END AS DATETIME) AS PLANNEDSTARTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,CAST(CASE WHEN T$RTDT<= '1/1/1970' THEN NULL ELSE T$RTDT  END AS DATETIME) AS RATEDATE 
            ,T$FCRT.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINERDESCRIPTION 
            ,CAST(T$FCRT AS INT)                                                                                                                 AS RATEDETERMINERID 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFA)),'')                                                                                         AS REFERENCEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFB)),'')                                                                                         AS REFERENCEB 
            ,T$RSRP.CONSTANTDESCRIPTION                                                                                                          AS RESCHEDULEWITHDETAILSRPDESCRIPTION 
            ,CAST(T$RSRP AS INT)                                                                                                                 AS RESCHEDULEWITHDETAILSRPID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLT)),'')                                                                                         AS SALESPRICELIST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREP)),'')                                                                                         AS SALESREPRESENTATIVEINSIDE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSAR)),'')                                                                                         AS SERVICEAREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAR)),'')                                                                                         AS SERVICECAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS SERVICECENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                                                                                         AS SERVICECONTRACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS SERVICEENGINEER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSH)),'')                                                                                         AS SERVICEORDERCOSTINGSHEET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSQU)),'')                                                                                         AS SERVICEORDERQUOTATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCN)),'')                                                                                         AS SHIPTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SOGP$U")),'')                                                                                       AS SOGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFAD)),'')                                                                                         AS SOLDTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFCN)),'')                                                                                         AS SOLDTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,T$TXYN.CONSTANTDESCRIPTION                                                                                                          AS TAXDESCRIPTION 
            ,CAST(T$TXYN AS INT)                                                                                                                 AS TAXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,T$TINV.CONSTANTDESCRIPTION                                                                                                          AS TOTALINVOICEDESCRIPTION 
            ,CAST(T$TINV AS INT)                                                                                                                 AS TOTALINVOICEID 
            ,CAST(T$TVDU AS NUMERIC(15,2))                                                                                                       AS TRAVELDURATION 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC200200") }} AS SOURCETABLE  
            /*APPOINTMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$APPO 
             ON   T$APPO.TABLENAME  = 'TSSOC200' 
              AND T$APPO.COLUMNNAME = 'T$APPO' 
              AND T$APPO.CONSTANT   = SOURCETABLE.T$APPO 
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLYN 
             ON   T$BLYN.TABLENAME  = 'TSSOC200' 
              AND T$BLYN.COLUMNNAME = 'T$BLYN' 
              AND T$BLYN.CONSTANT   = SOURCETABLE.T$BLYN 
            /*CONSOLIDATETRAVELCOST*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTCS 
             ON   T$CTCS.TABLENAME  = 'TSSOC200' 
              AND T$CTCS.COLUMNNAME = 'T$CTCS' 
              AND T$CTCS.CONSTANT   = SOURCETABLE.T$CTCS 
            /*DISCOUNTPOLICY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DIPY 
             ON   T$DIPY.TABLENAME  = 'TSSOC200' 
              AND T$DIPY.COLUMNNAME = 'T$DIPY' 
              AND T$DIPY.CONSTANT   = SOURCETABLE.T$DIPY 
            /*DISCOUNTSFROMPRICEBOOKS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DFPB 
             ON   T$DFPB.TABLENAME  = 'TSSOC200' 
              AND T$DFPB.COLUMNNAME = 'T$DFPB' 
              AND T$DFPB.CONSTANT   = SOURCETABLE.T$DFPB 
            /*EMERGENCYORDER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$EMER 
             ON   T$EMER.TABLENAME  = 'TSSOC200' 
              AND T$EMER.COLUMNNAME = 'T$EMER' 
              AND T$EMER.CONSTANT   = SOURCETABLE.T$EMER 
            /*EXCLUDEFROMKRONOSU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$EXKR$U" 
             ON   "T$EXKR$U".TABLENAME  = 'TSSOC200' 
              AND "T$EXKR$U".COLUMNNAME = 'T$EXKR.U' 
              AND "T$EXKR$U".CONSTANT   = SOURCETABLE."T$EXKR$U" 
            /*INTERRUPTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ITYN 
             ON   T$ITYN.TABLENAME  = 'TSSOC200' 
              AND T$ITYN.COLUMNNAME = 'T$ITYN' 
              AND T$ITYN.CONSTANT   = SOURCETABLE.T$ITYN 
            /*NCDRU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$NCDR$U" 
             ON   "T$NCDR$U".TABLENAME  = 'TSSOC200' 
              AND "T$NCDR$U".COLUMNNAME = 'T$NCDR.U' 
              AND "T$NCDR$U".CONSTANT   = SOURCETABLE."T$NCDR$U" 
            /*ORDERPRIORITYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRIO$U" 
             ON   "T$PRIO$U".TABLENAME  = 'TSSOC200' 
              AND "T$PRIO$U".COLUMNNAME = 'T$PRIO.U' 
              AND "T$PRIO$U".CONSTANT   = SOURCETABLE."T$PRIO$U" 
            /*ORDERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OSTA 
             ON   T$OSTA.TABLENAME  = 'TSSOC200' 
              AND T$OSTA.COLUMNNAME = 'T$OSTA' 
              AND T$OSTA.CONSTANT   = SOURCETABLE.T$OSTA 
            /*OVERTIME*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OTIM 
             ON   T$OTIM.TABLENAME  = 'TSSOC200' 
              AND T$OTIM.COLUMNNAME = 'T$OTIM' 
              AND T$OTIM.CONSTANT   = SOURCETABLE.T$OTIM 
            /*PAIDSERVICETYPEU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PDSR$U" 
             ON   "T$PDSR$U".TABLENAME  = 'TSSOC200' 
              AND "T$PDSR$U".COLUMNNAME = 'T$PDSR.U' 
              AND "T$PDSR$U".CONSTANT   = SOURCETABLE."T$PDSR$U" 
            /*RATEDETERMINER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FCRT 
             ON   T$FCRT.TABLENAME  = 'TSSOC200' 
              AND T$FCRT.COLUMNNAME = 'T$FCRT' 
              AND T$FCRT.CONSTANT   = SOURCETABLE.T$FCRT 
            /*RESCHEDULEWITHDETAILSRP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RSRP 
             ON   T$RSRP.TABLENAME  = 'TSSOC200' 
              AND T$RSRP.COLUMNNAME = 'T$RSRP' 
              AND T$RSRP.CONSTANT   = SOURCETABLE.T$RSRP 
            /*TAX*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TXYN 
             ON   T$TXYN.TABLENAME  = 'TSSOC200' 
              AND T$TXYN.COLUMNNAME = 'T$TXYN' 
              AND T$TXYN.CONSTANT   = SOURCETABLE.T$TXYN 
            /*TOTALINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TINV 
             ON   T$TINV.TABLENAME  = 'TSSOC200' 
              AND T$TINV.COLUMNNAME = 'T$TINV' 
              AND T$TINV.CONSTANT   = SOURCETABLE.T$TINV 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$TSTM<= '1/1/1970' THEN NULL ELSE T$TSTM  END AS DATETIME) AS ACTUALTRAVELSTARTTIME 
            ,T$APPO.CONSTANTDESCRIPTION                                                                                                          AS APPOINTMENTDESCRIPTION 
            ,CAST(T$APPO AS INT)                                                                                                                 AS APPOINTMENTID 
            ,T$BLYN.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BLYN AS INT)                                                                                                                 AS BLOCKEDID 
            ,CAST(CASE WHEN T$CADT<= '1/1/1970' THEN NULL ELSE T$CADT END AS DATE)                                                             AS CANCELDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDIS)),'')                                                                                         AS CANCELREASON 
            ,SOURCETABLE.T$TXTC   /* TEXT */                                                                                                     AS CANCELTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,T$CTCS.CONSTANTDESCRIPTION                                                                                                          AS CONSOLIDATETRAVELCOSTDESCRIPTION 
            ,CAST(T$CTCS AS INT)                                                                                                                 AS CONSOLIDATETRAVELCOSTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES3 
            ,T$DIPY.CONSTANTDESCRIPTION                                                                                                          AS DISCOUNTPOLICYDESCRIPTION 
            ,CAST(T$DIPY AS INT)                                                                                                                 AS DISCOUNTPOLICYID 
            ,T$DFPB.CONSTANTDESCRIPTION                                                                                                          AS DISCOUNTSFROMPRICEBOOKSDESCRIPTION 
            ,CAST(T$DFPB AS INT)                                                                                                                 AS DISCOUNTSFROMPRICEBOOKSID 
            ,CAST(CASE WHEN T$RACT<= '1/1/1970' THEN NULL ELSE T$RACT  END AS DATETIME) AS DISPATCHTIME 
            ,CAST(CASE WHEN T$ESTM<= '1/1/1970' THEN NULL ELSE T$ESTM  END AS DATETIME) AS EARLIESTSTARTTIME 
            ,T$EMER.CONSTANTDESCRIPTION                                                                                                          AS EMERGENCYORDERDESCRIPTION 
            ,CAST(T$EMER AS INT)                                                                                                                 AS EMERGENCYORDERID 
            ,"T$EXKR$U".CONSTANTDESCRIPTION                                                                                                        AS EXCLUDEFROMKRONOSDESCRIPTION 
            ,CAST("T$EXKR$U" AS INT)                                                                                                               AS EXCLUDEFROMKRONOSID 
            ,CAST(CASE WHEN T$AFTM<= '1/1/1970' THEN NULL ELSE T$AFTM  END AS DATETIME) AS EXECUTIONFINISHTIME 
            ,CAST(CASE WHEN T$ASTM<= '1/1/1970' THEN NULL ELSE T$ASTM  END AS DATETIME) AS EXECUTIONSTARTTIME 
            ,T$ITYN.CONSTANTDESCRIPTION                                                                                                          AS INTERRUPTEDDESCRIPTION 
            ,CAST(T$ITYN AS INT)                                                                                                                 AS INTERRUPTEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRIT)),'')                                                                                         AS INTERRUPTIONREASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICE_TOBUSINESSPARTNER 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS INVOICETEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITAD)),'')                                                                                         AS INVOICETOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITCN)),'')                                                                                         AS INVOICETOCONTACT 
            ,CAST(CASE WHEN T$LUTD<= '1/1/1970' THEN NULL ELSE T$LUTD  END AS DATETIME) AS LASTUPDATED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,CAST(CASE WHEN T$LFTM<= '1/1/1970' THEN NULL ELSE T$LFTM  END AS DATETIME) AS LATESTFINISHTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                         AS LINEOFBUSINESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LCAD)),'')                                                                                         AS LOCATIONADDRESS 
            ,"T$NCDR$U".CONSTANTDESCRIPTION                                                                                                        AS NCDRDESCRIPTION 
            ,CAST("T$NCDR$U" AS INT)                                                                                                               AS NCDRID 
            ,CAST(CASE WHEN T$ORDT<= '1/1/1970' THEN NULL ELSE T$ORDT  END AS DATETIME) AS ORDER_DATE 
            ,CAST(T$ORDU AS NUMERIC(15,2))                                                                                                       AS ORDER_DURATION 
            ,"T$PRIO$U".CONSTANTDESCRIPTION                                                                                                        AS ORDER_PRIORITYDESCRIPTION 
            ,CAST("T$PRIO$U" AS INT)                                                                                                               AS ORDER_PRIORITYID 
            ,CAST(CASE WHEN T$ORRT<= '1/1/1970' THEN NULL ELSE T$ORRT  END AS DATETIME) AS ORDER_RELEASETIME 
            ,T$OSTA.CONSTANTDESCRIPTION                                                                                                          AS ORDER_STATUSDESCRIPTION 
            ,CAST(T$OSTA AS INT)                                                                                                                 AS ORDER_STATUSID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ORDER_TEXT 
            ,T$OTIM.CONSTANTDESCRIPTION                                                                                                          AS OVERTIMEDESCRIPTION 
            ,CAST(T$OTIM AS INT)                                                                                                                 AS OVERTIMEID 
            ,CAST(T$MINU AS BIGINT)                                                                                                              AS PAGEFREQUENCY 
            ,"T$PDSR$U".CONSTANTDESCRIPTION                                                                                                        AS PAIDSERVICETYPEDESCRIPTION 
            ,CAST("T$PDSR$U" AS INT)                                                                                                               AS PAIDSERVICETYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFAD)),'')                                                                                         AS PAYFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFCN)),'')                                                                                         AS PAYFROMCONTACT 
            ,CAST(CASE WHEN T$PFTM<= '1/1/1970' THEN NULL ELSE T$PFTM  END AS DATETIME) AS PLANNEDFINISHTIME 
            ,CAST(CASE WHEN T$PSTM<= '1/1/1970' THEN NULL ELSE T$PSTM  END AS DATETIME) AS PLANNEDSTARTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,CAST(CASE WHEN T$RTDT<= '1/1/1970' THEN NULL ELSE T$RTDT  END AS DATETIME) AS RATEDATE 
            ,T$FCRT.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINERDESCRIPTION 
            ,CAST(T$FCRT AS INT)                                                                                                                 AS RATEDETERMINERID 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFA)),'')                                                                                         AS REFERENCEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFB)),'')                                                                                         AS REFERENCEB 
            ,T$RSRP.CONSTANTDESCRIPTION                                                                                                          AS RESCHEDULEWITHDETAILSRPDESCRIPTION 
            ,CAST(T$RSRP AS INT)                                                                                                                 AS RESCHEDULEWITHDETAILSRPID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLT)),'')                                                                                         AS SALESPRICELIST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREP)),'')                                                                                         AS SALESREPRESENTATIVEINSIDE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSAR)),'')                                                                                         AS SERVICEAREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAR)),'')                                                                                         AS SERVICECAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS SERVICECENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                                                                                         AS SERVICECONTRACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS SERVICEENGINEER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSH)),'')                                                                                         AS SERVICEORDERCOSTINGSHEET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSQU)),'')                                                                                         AS SERVICEORDERQUOTATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCN)),'')                                                                                         AS SHIPTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SOGP$U")),'')                                                                                       AS SOGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFAD)),'')                                                                                         AS SOLDTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFCN)),'')                                                                                         AS SOLDTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,T$TXYN.CONSTANTDESCRIPTION                                                                                                          AS TAXDESCRIPTION 
            ,CAST(T$TXYN AS INT)                                                                                                                 AS TAXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,T$TINV.CONSTANTDESCRIPTION                                                                                                          AS TOTALINVOICEDESCRIPTION 
            ,CAST(T$TINV AS INT)                                                                                                                 AS TOTALINVOICEID 
            ,CAST(T$TVDU AS NUMERIC(15,2))                                                                                                       AS TRAVELDURATION 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC200201") }} AS SOURCETABLE  
            /*APPOINTMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$APPO 
             ON   T$APPO.TABLENAME  = 'TSSOC200' 
              AND T$APPO.COLUMNNAME = 'T$APPO' 
              AND T$APPO.CONSTANT   = SOURCETABLE.T$APPO 
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BLYN 
             ON   T$BLYN.TABLENAME  = 'TSSOC200' 
              AND T$BLYN.COLUMNNAME = 'T$BLYN' 
              AND T$BLYN.CONSTANT   = SOURCETABLE.T$BLYN 
            /*CONSOLIDATETRAVELCOST*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTCS 
             ON   T$CTCS.TABLENAME  = 'TSSOC200' 
              AND T$CTCS.COLUMNNAME = 'T$CTCS' 
              AND T$CTCS.CONSTANT   = SOURCETABLE.T$CTCS 
            /*DISCOUNTPOLICY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DIPY 
             ON   T$DIPY.TABLENAME  = 'TSSOC200' 
              AND T$DIPY.COLUMNNAME = 'T$DIPY' 
              AND T$DIPY.CONSTANT   = SOURCETABLE.T$DIPY 
            /*DISCOUNTSFROMPRICEBOOKS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DFPB 
             ON   T$DFPB.TABLENAME  = 'TSSOC200' 
              AND T$DFPB.COLUMNNAME = 'T$DFPB' 
              AND T$DFPB.CONSTANT   = SOURCETABLE.T$DFPB 
            /*EMERGENCYORDER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$EMER 
             ON   T$EMER.TABLENAME  = 'TSSOC200' 
              AND T$EMER.COLUMNNAME = 'T$EMER' 
              AND T$EMER.CONSTANT   = SOURCETABLE.T$EMER 
            /*EXCLUDEFROMKRONOSU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$EXKR$U" 
             ON   "T$EXKR$U".TABLENAME  = 'TSSOC200' 
              AND "T$EXKR$U".COLUMNNAME = 'T$EXKR.U' 
              AND "T$EXKR$U".CONSTANT   = SOURCETABLE."T$EXKR$U" 
            /*INTERRUPTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ITYN 
             ON   T$ITYN.TABLENAME  = 'TSSOC200' 
              AND T$ITYN.COLUMNNAME = 'T$ITYN' 
              AND T$ITYN.CONSTANT   = SOURCETABLE.T$ITYN 
            /*NCDRU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$NCDR$U" 
             ON   "T$NCDR$U".TABLENAME  = 'TSSOC200' 
              AND "T$NCDR$U".COLUMNNAME = 'T$NCDR.U' 
              AND "T$NCDR$U".CONSTANT   = SOURCETABLE."T$NCDR$U" 
            /*ORDERPRIORITYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRIO$U" 
             ON   "T$PRIO$U".TABLENAME  = 'TSSOC200' 
              AND "T$PRIO$U".COLUMNNAME = 'T$PRIO.U' 
              AND "T$PRIO$U".CONSTANT   = SOURCETABLE."T$PRIO$U" 
            /*ORDERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OSTA 
             ON   T$OSTA.TABLENAME  = 'TSSOC200' 
              AND T$OSTA.COLUMNNAME = 'T$OSTA' 
              AND T$OSTA.CONSTANT   = SOURCETABLE.T$OSTA 
            /*OVERTIME*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OTIM 
             ON   T$OTIM.TABLENAME  = 'TSSOC200' 
              AND T$OTIM.COLUMNNAME = 'T$OTIM' 
              AND T$OTIM.CONSTANT   = SOURCETABLE.T$OTIM 
            /*PAIDSERVICETYPEU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PDSR$U" 
             ON   "T$PDSR$U".TABLENAME  = 'TSSOC200' 
              AND "T$PDSR$U".COLUMNNAME = 'T$PDSR.U' 
              AND "T$PDSR$U".CONSTANT   = SOURCETABLE."T$PDSR$U" 
            /*RATEDETERMINER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FCRT 
             ON   T$FCRT.TABLENAME  = 'TSSOC200' 
              AND T$FCRT.COLUMNNAME = 'T$FCRT' 
              AND T$FCRT.CONSTANT   = SOURCETABLE.T$FCRT 
            /*RESCHEDULEWITHDETAILSRP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RSRP 
             ON   T$RSRP.TABLENAME  = 'TSSOC200' 
              AND T$RSRP.COLUMNNAME = 'T$RSRP' 
              AND T$RSRP.CONSTANT   = SOURCETABLE.T$RSRP 
            /*TAX*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TXYN 
             ON   T$TXYN.TABLENAME  = 'TSSOC200' 
              AND T$TXYN.COLUMNNAME = 'T$TXYN' 
              AND T$TXYN.CONSTANT   = SOURCETABLE.T$TXYN 
            /*TOTALINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TINV 
             ON   T$TINV.TABLENAME  = 'TSSOC200' 
              AND T$TINV.COLUMNNAME = 'T$TINV' 
              AND T$TINV.CONSTANT   = SOURCETABLE.T$TINV 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTUALTRAVELSTARTTIME AS ACTUALTRAVELSTARTTIME, 
        source_data.APPOINTMENTDESCRIPTION AS APPOINTMENTDESCRIPTION, 
        source_data.APPOINTMENTID AS APPOINTMENTID, 
        source_data.BLOCKEDDESCRIPTION AS BLOCKEDDESCRIPTION, 
        source_data.BLOCKEDID AS BLOCKEDID, 
        source_data.CANCELDATE AS CANCELDATE, 
        source_data.CANCELREASON AS CANCELREASON, 
        source_data.CANCELTEXT AS CANCELTEXT, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONSOLIDATETRAVELCOSTDESCRIPTION AS CONSOLIDATETRAVELCOSTDESCRIPTION, 
        source_data.CONSOLIDATETRAVELCOSTID AS CONSOLIDATETRAVELCOSTID, 
        source_data.COUNTRY AS COUNTRY, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.CURRENCYRATESALES1 AS CURRENCYRATESALES1, 
        source_data.CURRENCYRATESALES2 AS CURRENCYRATESALES2, 
        source_data.CURRENCYRATESALES3 AS CURRENCYRATESALES3, 
        source_data.DISCOUNTPOLICYDESCRIPTION AS DISCOUNTPOLICYDESCRIPTION, 
        source_data.DISCOUNTPOLICYID AS DISCOUNTPOLICYID, 
        source_data.DISCOUNTSFROMPRICEBOOKSDESCRIPTION AS DISCOUNTSFROMPRICEBOOKSDESCRIPTION, 
        source_data.DISCOUNTSFROMPRICEBOOKSID AS DISCOUNTSFROMPRICEBOOKSID, 
        source_data.DISPATCHTIME AS DISPATCHTIME, 
        source_data.EARLIESTSTARTTIME AS EARLIESTSTARTTIME, 
        source_data.EMERGENCYORDERDESCRIPTION AS EMERGENCYORDERDESCRIPTION, 
        source_data.EMERGENCYORDERID AS EMERGENCYORDERID, 
        source_data.EXCLUDEFROMKRONOSDESCRIPTION AS EXCLUDEFROMKRONOSDESCRIPTION, 
        source_data.EXCLUDEFROMKRONOSID AS EXCLUDEFROMKRONOSID, 
        source_data.EXECUTIONFINISHTIME AS EXECUTIONFINISHTIME, 
        source_data.EXECUTIONSTARTTIME AS EXECUTIONSTARTTIME, 
        source_data.INTERRUPTEDDESCRIPTION AS INTERRUPTEDDESCRIPTION, 
        source_data.INTERRUPTEDID AS INTERRUPTEDID, 
        source_data.INTERRUPTIONREASON AS INTERRUPTIONREASON, 
        source_data.INVOICE_TOBUSINESSPARTNER AS INVOICE_TOBUSINESSPARTNER, 
        source_data.INVOICETEXT AS INVOICETEXT, 
        source_data.INVOICETOADDRESS AS INVOICETOADDRESS, 
        source_data.INVOICETOCONTACT AS INVOICETOCONTACT, 
        source_data.LASTUPDATED AS LASTUPDATED, 
        source_data.LATEPAYMENTSURCHARGE AS LATEPAYMENTSURCHARGE, 
        source_data.LATESTFINISHTIME AS LATESTFINISHTIME, 
        source_data.LINEOFBUSINESS AS LINEOFBUSINESS, 
        source_data.LOCATIONADDRESS AS LOCATIONADDRESS, 
        source_data.NCDRDESCRIPTION AS NCDRDESCRIPTION, 
        source_data.NCDRID AS NCDRID, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_DURATION AS ORDER_DURATION, 
        source_data.ORDER_PRIORITYDESCRIPTION AS ORDER_PRIORITYDESCRIPTION, 
        source_data.ORDER_PRIORITYID AS ORDER_PRIORITYID, 
        source_data.ORDER_RELEASETIME AS ORDER_RELEASETIME, 
        source_data.ORDER_STATUSDESCRIPTION AS ORDER_STATUSDESCRIPTION, 
        source_data.ORDER_STATUSID AS ORDER_STATUSID, 
        source_data.ORDER_TEXT AS ORDER_TEXT, 
        source_data.OVERTIMEDESCRIPTION AS OVERTIMEDESCRIPTION, 
        source_data.OVERTIMEID AS OVERTIMEID, 
        source_data.PAGEFREQUENCY AS PAGEFREQUENCY, 
        source_data.PAIDSERVICETYPEDESCRIPTION AS PAIDSERVICETYPEDESCRIPTION, 
        source_data.PAIDSERVICETYPEID AS PAIDSERVICETYPEID, 
        source_data.PAYFROMADDRESS AS PAYFROMADDRESS, 
        source_data.PAYFROMBUSINESSPARTNER AS PAYFROMBUSINESSPARTNER, 
        source_data.PAYFROMCONTACT AS PAYFROMCONTACT, 
        source_data.PLANNEDFINISHTIME AS PLANNEDFINISHTIME, 
        source_data.PLANNEDSTARTTIME AS PLANNEDSTARTTIME, 
        source_data.PROJECT AS PROJECT, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEDETERMINERDESCRIPTION AS RATEDETERMINERDESCRIPTION, 
        source_data.RATEDETERMINERID AS RATEDETERMINERID, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.RATETYPE AS RATETYPE, 
        source_data.REFERENCEA AS REFERENCEA, 
        source_data.REFERENCEB AS REFERENCEB, 
        source_data.RESCHEDULEWITHDETAILSRPDESCRIPTION AS RESCHEDULEWITHDETAILSRPDESCRIPTION, 
        source_data.RESCHEDULEWITHDETAILSRPID AS RESCHEDULEWITHDETAILSRPID, 
        source_data.SALESPRICELIST AS SALESPRICELIST, 
        source_data.SALESREPRESENTATIVEINSIDE AS SALESREPRESENTATIVEINSIDE, 
        source_data.SERVICEAREA AS SERVICEAREA, 
        source_data.SERVICECAR AS SERVICECAR, 
        source_data.SERVICECENTER AS SERVICECENTER, 
        source_data.SERVICECONTRACT AS SERVICECONTRACT, 
        source_data.SERVICEENGINEER AS SERVICEENGINEER, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SERVICEORDERCOSTINGSHEET AS SERVICEORDERCOSTINGSHEET, 
        source_data.SERVICEORDERQUOTATION AS SERVICEORDERQUOTATION, 
        source_data.SHIPTOADDRESS AS SHIPTOADDRESS, 
        source_data.SHIPTOBUSINESSPARTNER AS SHIPTOBUSINESSPARTNER, 
        source_data.SHIPTOCONTACT AS SHIPTOCONTACT, 
        source_data.SOGROUP AS SOGROUP, 
        source_data.SOLDTOADDRESS AS SOLDTOADDRESS, 
        source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER, 
        source_data.SOLDTOCONTACT AS SOLDTOCONTACT, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TAXDESCRIPTION AS TAXDESCRIPTION, 
        source_data.TAXID AS TAXID, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.TOTALINVOICEDESCRIPTION AS TOTALINVOICEDESCRIPTION, 
        source_data.TOTALINVOICEID AS TOTALINVOICEID, 
        source_data.TRAVELDURATION AS TRAVELDURATION
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTUALTRAVELSTARTTIME as TIMESTAMP_NTZ(9)) as ACTUALTRAVELSTARTTIME,
        cast(APPOINTMENTDESCRIPTION as VARCHAR(16777216)) as APPOINTMENTDESCRIPTION,
        cast(APPOINTMENTID as NUMBER(38,0)) as APPOINTMENTID,
        cast(BLOCKEDDESCRIPTION as VARCHAR(16777216)) as BLOCKEDDESCRIPTION,
        cast(BLOCKEDID as NUMBER(38,0)) as BLOCKEDID,
        cast(CANCELDATE as DATE) as CANCELDATE,
        cast(CANCELREASON as VARCHAR(6)) as CANCELREASON,
        cast(CANCELTEXT as NUMBER(38,10)) as CANCELTEXT,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONSOLIDATETRAVELCOSTDESCRIPTION as VARCHAR(16777216)) as CONSOLIDATETRAVELCOSTDESCRIPTION,
        cast(CONSOLIDATETRAVELCOSTID as NUMBER(38,0)) as CONSOLIDATETRAVELCOSTID,
        cast(COUNTRY as VARCHAR(3)) as COUNTRY,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(CURRENCYRATESALES1 as NUMBER(15,2)) as CURRENCYRATESALES1,
        cast(CURRENCYRATESALES2 as NUMBER(15,2)) as CURRENCYRATESALES2,
        cast(CURRENCYRATESALES3 as NUMBER(15,2)) as CURRENCYRATESALES3,
        cast(DISCOUNTPOLICYDESCRIPTION as VARCHAR(16777216)) as DISCOUNTPOLICYDESCRIPTION,
        cast(DISCOUNTPOLICYID as NUMBER(38,0)) as DISCOUNTPOLICYID,
        cast(DISCOUNTSFROMPRICEBOOKSDESCRIPTION as VARCHAR(16777216)) as DISCOUNTSFROMPRICEBOOKSDESCRIPTION,
        cast(DISCOUNTSFROMPRICEBOOKSID as NUMBER(38,0)) as DISCOUNTSFROMPRICEBOOKSID,
        cast(DISPATCHTIME as TIMESTAMP_NTZ(9)) as DISPATCHTIME,
        cast(EARLIESTSTARTTIME as TIMESTAMP_NTZ(9)) as EARLIESTSTARTTIME,
        cast(EMERGENCYORDERDESCRIPTION as VARCHAR(16777216)) as EMERGENCYORDERDESCRIPTION,
        cast(EMERGENCYORDERID as NUMBER(38,0)) as EMERGENCYORDERID,
        cast(EXCLUDEFROMKRONOSDESCRIPTION as VARCHAR(16777216)) as EXCLUDEFROMKRONOSDESCRIPTION,
        cast(EXCLUDEFROMKRONOSID as NUMBER(38,0)) as EXCLUDEFROMKRONOSID,
        cast(EXECUTIONFINISHTIME as TIMESTAMP_NTZ(9)) as EXECUTIONFINISHTIME,
        cast(EXECUTIONSTARTTIME as TIMESTAMP_NTZ(9)) as EXECUTIONSTARTTIME,
        cast(INTERRUPTEDDESCRIPTION as VARCHAR(16777216)) as INTERRUPTEDDESCRIPTION,
        cast(INTERRUPTEDID as NUMBER(38,0)) as INTERRUPTEDID,
        cast(INTERRUPTIONREASON as VARCHAR(6)) as INTERRUPTIONREASON,
        cast(INVOICE_TOBUSINESSPARTNER as VARCHAR(9)) as INVOICE_TOBUSINESSPARTNER,
        cast(INVOICETEXT as NUMBER(38,10)) as INVOICETEXT,
        cast(INVOICETOADDRESS as VARCHAR(9)) as INVOICETOADDRESS,
        cast(INVOICETOCONTACT as VARCHAR(9)) as INVOICETOCONTACT,
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(LATEPAYMENTSURCHARGE as VARCHAR(3)) as LATEPAYMENTSURCHARGE,
        cast(LATESTFINISHTIME as TIMESTAMP_NTZ(9)) as LATESTFINISHTIME,
        cast(LINEOFBUSINESS as VARCHAR(6)) as LINEOFBUSINESS,
        cast(LOCATIONADDRESS as VARCHAR(9)) as LOCATIONADDRESS,
        cast(NCDRDESCRIPTION as VARCHAR(16777216)) as NCDRDESCRIPTION,
        cast(NCDRID as NUMBER(38,0)) as NCDRID,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_DURATION as NUMBER(15,2)) as ORDER_DURATION,
        cast(ORDER_PRIORITYDESCRIPTION as VARCHAR(16777216)) as ORDER_PRIORITYDESCRIPTION,
        cast(ORDER_PRIORITYID as NUMBER(38,0)) as ORDER_PRIORITYID,
        cast(ORDER_RELEASETIME as TIMESTAMP_NTZ(9)) as ORDER_RELEASETIME,
        cast(ORDER_STATUSDESCRIPTION as VARCHAR(16777216)) as ORDER_STATUSDESCRIPTION,
        cast(ORDER_STATUSID as NUMBER(38,0)) as ORDER_STATUSID,
        cast(ORDER_TEXT as NUMBER(38,10)) as ORDER_TEXT,
        cast(OVERTIMEDESCRIPTION as VARCHAR(16777216)) as OVERTIMEDESCRIPTION,
        cast(OVERTIMEID as NUMBER(38,0)) as OVERTIMEID,
        cast(PAGEFREQUENCY as NUMBER(38,0)) as PAGEFREQUENCY,
        cast(PAIDSERVICETYPEDESCRIPTION as VARCHAR(16777216)) as PAIDSERVICETYPEDESCRIPTION,
        cast(PAIDSERVICETYPEID as NUMBER(38,0)) as PAIDSERVICETYPEID,
        cast(PAYFROMADDRESS as VARCHAR(9)) as PAYFROMADDRESS,
        cast(PAYFROMBUSINESSPARTNER as VARCHAR(9)) as PAYFROMBUSINESSPARTNER,
        cast(PAYFROMCONTACT as VARCHAR(9)) as PAYFROMCONTACT,
        cast(PLANNEDFINISHTIME as TIMESTAMP_NTZ(9)) as PLANNEDFINISHTIME,
        cast(PLANNEDSTARTTIME as TIMESTAMP_NTZ(9)) as PLANNEDSTARTTIME,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEDETERMINERDESCRIPTION as VARCHAR(16777216)) as RATEDETERMINERDESCRIPTION,
        cast(RATEDETERMINERID as NUMBER(38,0)) as RATEDETERMINERID,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(RATETYPE as VARCHAR(3)) as RATETYPE,
        cast(REFERENCEA as VARCHAR(30)) as REFERENCEA,
        cast(REFERENCEB as VARCHAR(20)) as REFERENCEB,
        cast(RESCHEDULEWITHDETAILSRPDESCRIPTION as VARCHAR(16777216)) as RESCHEDULEWITHDETAILSRPDESCRIPTION,
        cast(RESCHEDULEWITHDETAILSRPID as NUMBER(38,0)) as RESCHEDULEWITHDETAILSRPID,
        cast(SALESPRICELIST as VARCHAR(3)) as SALESPRICELIST,
        cast(SALESREPRESENTATIVEINSIDE as VARCHAR(6)) as SALESREPRESENTATIVEINSIDE,
        cast(SERVICEAREA as VARCHAR(3)) as SERVICEAREA,
        cast(SERVICECAR as VARCHAR(10)) as SERVICECAR,
        cast(SERVICECENTER as VARCHAR(6)) as SERVICECENTER,
        cast(SERVICECONTRACT as VARCHAR(9)) as SERVICECONTRACT,
        cast(SERVICEENGINEER as VARCHAR(6)) as SERVICEENGINEER,
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(SERVICEORDERCOSTINGSHEET as VARCHAR(9)) as SERVICEORDERCOSTINGSHEET,
        cast(SERVICEORDERQUOTATION as VARCHAR(9)) as SERVICEORDERQUOTATION,
        cast(SHIPTOADDRESS as VARCHAR(9)) as SHIPTOADDRESS,
        cast(SHIPTOBUSINESSPARTNER as VARCHAR(9)) as SHIPTOBUSINESSPARTNER,
        cast(SHIPTOCONTACT as VARCHAR(9)) as SHIPTOCONTACT,
        cast(SOGROUP as VARCHAR(12)) as SOGROUP,
        cast(SOLDTOADDRESS as VARCHAR(9)) as SOLDTOADDRESS,
        cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
        cast(SOLDTOCONTACT as VARCHAR(9)) as SOLDTOCONTACT,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(TAXDESCRIPTION as VARCHAR(16777216)) as TAXDESCRIPTION,
        cast(TAXID as NUMBER(38,0)) as TAXID,
        cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT,
        cast(TOTALINVOICEDESCRIPTION as VARCHAR(16777216)) as TOTALINVOICEDESCRIPTION,
        cast(TOTALINVOICEID as NUMBER(38,0)) as TOTALINVOICEID,
        cast(TRAVELDURATION as NUMBER(15,2)) as TRAVELDURATION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data