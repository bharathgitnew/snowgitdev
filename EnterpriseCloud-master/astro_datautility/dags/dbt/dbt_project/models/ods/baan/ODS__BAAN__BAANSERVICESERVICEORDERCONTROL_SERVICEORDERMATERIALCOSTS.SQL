/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERMATERIALCOSTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERMATERIALCOSTS.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEORDERMATERIALCOSTS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANSERVICESERVICEORDERCONTROL_SERVICEORDERMATERIALCOSTS',
    unique_key = ['LINENUMBER',
    'SERVICEORDER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,200                                                                                                                                       AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                                                                                                                     AS ACTIVITY 
            ,CAST("T$ACPR$1" AS NUMERIC(15,2))                                                                                                         AS ACTUALCOSTPRICE1 
            ,CAST("T$ACPR$2" AS NUMERIC(15,2))                                                                                                         AS ACTUALCOSTPRICE2 
            ,CAST("T$ACPR$3" AS NUMERIC(15,2))                                                                                                         AS ACTUALCOSTPRICE3 
            ,CAST(T$ADQT AS NUMERIC(15,2))                                                                                                           AS ACTUALCUMULATIVEQUANTITY 
            ,CAST("T$APAM$1" AS NUMERIC(15,2))                                                                                                         AS ACTUALPURCHASEAMOUNT1 
            ,CAST("T$APAM$2" AS NUMERIC(15,2))                                                                                                         AS ACTUALPURCHASEAMOUNT2 
            ,CAST("T$APAM$3" AS NUMERIC(15,2))                                                                                                         AS ACTUALPURCHASEAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AWRH)),'')                                                                                             AS ACTUALWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                             AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CFRW$U")),'')                                                                                           AS CARRIER 
            ,CAST("T$CASE$U" AS BIGINT)                                                                                                                AS CASENUMBER 
            ,CAST(CASE WHEN "T$CDAT$U"<= '1/1/1970' THEN NULL ELSE "T$CDAT$U"  END AS DATETIME) AS COMMITDATE 
            ,T$CTYN.CONSTANTDESCRIPTION                                                                                                              AS CONTRACTCOVERAGEDESCRIPTION 
            ,CAST(T$CTYN AS INT)                                                                                                                     AS CONTRACTCOVERAGEID 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORFORQUANTITYUNIT 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORSALESPRICEUNIT 
            ,CAST("T$ACFC$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTFIELDCHANGEORDERS1 
            ,CAST("T$ACFC$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTFIELDCHANGEORDERS2 
            ,CAST("T$ACFC$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTFIELDCHANGEORDERS3 
            ,CAST("T$ACOC$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOTHERCOSTS1 
            ,CAST("T$ACOC$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOTHERCOSTS2 
            ,CAST("T$ACOC$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOTHERCOSTS3 
            ,CAST("T$ACCO$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICECONTRACT1 
            ,CAST("T$ACCO$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICECONTRACT2 
            ,CAST("T$ACCO$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICECONTRACT3 
            ,CAST("T$ACIN$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERINVOICING1 
            ,CAST("T$ACIN$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERINVOICING2 
            ,CAST("T$ACIN$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERINVOICING3 
            ,CAST("T$ACQU$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERQUOTATION1 
            ,CAST("T$ACQU$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERQUOTATION2 
            ,CAST("T$ACQU$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERQUOTATION3 
            ,CAST("T$ACWA$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTWARRANTY1 
            ,CAST("T$ACWA$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTWARRANTY2 
            ,CAST("T$ACWA$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTWARRANTY3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCMP)),'')                                                                                             AS COSTCOMPONENT 
            ,T$CLST.CONSTANTDESCRIPTION                                                                                                              AS COSTLINESTATUSDESCRIPTION 
            ,CAST(T$CLST AS INT)                                                                                                                     AS COSTLINESTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRMC$U")),'')                                                                                           AS CRM_CASE_hash_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                                                                                           AS CUSTOMERPOLINE 
            ,CAST(CASE WHEN "T$CREQ$U"<= '1/1/1970' THEN NULL ELSE "T$CREQ$U"  END AS DATETIME) AS CUSTREQDELDT 
            ,CAST(T$QTDL AS NUMERIC(15,2))                                                                                                           AS DELIVEREDQUANTITY 
            ,T$DLTP.CONSTANTDESCRIPTION                                                                                                              AS DELIVERYTYPEDESCRIPTION 
            ,CAST(T$DLTP AS INT)                                                                                                                     AS DELIVERYTYPEID 
            ,"T$DDEL$U".CONSTANTDESCRIPTION                                                                                                            AS DIRECTDELIVERYDESCRIPTION 
            ,CAST("T$DDEL$U" AS INT)                                                                                                                   AS DIRECTDELIVERYID 
            ,CAST(T$DISC AS NUMERIC(15,2))                                                                                                           AS DISCOUNT 
            ,CAST(T$ASDI AS NUMERIC(15,2))                                                                                                           AS DISCOUNTAMOUNT_ASDI 
            ,CAST("T$LDAM$1" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_1 
            ,CAST("T$LDAM$2" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_2 
            ,CAST("T$LDAM$3" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_3 
            ,CAST("T$LDAM$4" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_4 
            ,CAST("T$LDAM$5" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$1")),'')                                                                                           AS DISCOUNTCODE1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$2")),'')                                                                                           AS DISCOUNTCODE2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$3")),'')                                                                                           AS DISCOUNTCODE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$4")),'')                                                                                           AS DISCOUNTCODE4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$5")),'')                                                                                           AS DISCOUNTCODE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$1")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$2")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$3")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$4")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$5")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION5 
            ,CAST("T$DMSE$1" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE1 
            ,CAST("T$DMSE$2" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE2 
            ,CAST("T$DMSE$3" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE3 
            ,CAST("T$DMSE$4" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE4 
            ,CAST("T$DMSE$5" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE5 
            ,"T$DMTY$1".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE1DESCRIPTION 
            ,CAST("T$DMTY$1" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE1ID 
            ,"T$DMTY$2".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE2DESCRIPTION 
            ,CAST("T$DMTY$2" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE2ID 
            ,"T$DMTY$3".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE3DESCRIPTION 
            ,CAST("T$DMTY$3" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE3ID 
            ,"T$DMTY$4".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE4DESCRIPTION 
            ,CAST("T$DMTY$4" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE4ID 
            ,"T$DMTY$5".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE5DESCRIPTION 
            ,CAST("T$DMTY$5" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE5ID 
            ,"T$DMTH$1".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD1DESCRIPTION 
            ,CAST("T$DMTH$1" AS INT)                                                                                                                   AS DISCOUNTMETHOD1ID 
            ,"T$DMTH$2".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD2DESCRIPTION 
            ,CAST("T$DMTH$2" AS INT)                                                                                                                   AS DISCOUNTMETHOD2ID 
            ,"T$DMTH$3".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD3DESCRIPTION 
            ,CAST("T$DMTH$3" AS INT)                                                                                                                   AS DISCOUNTMETHOD3ID 
            ,"T$DMTH$4".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD4DESCRIPTION 
            ,CAST("T$DMTH$4" AS INT)                                                                                                                   AS DISCOUNTMETHOD4ID 
            ,"T$DMTH$5".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD5DESCRIPTION 
            ,CAST("T$DMTH$5" AS INT)                                                                                                                   AS DISCOUNTMETHOD5ID 
            ,CAST("T$DPER$1" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE1 
            ,CAST("T$DPER$2" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE2 
            ,CAST("T$DPER$3" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE3 
            ,CAST("T$DPER$4" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE4 
            ,CAST("T$DPER$5" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE5 
            ,CAST(T$IDCN AS BIGINT)                                                                                                                  AS DOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                             AS ENGINEERINGITEMREVISION 
            ,CAST("T$ECPR$1" AS NUMERIC(15,2))                                                                                                         AS ESTIMATEDCOSTPRICE1 
            ,CAST("T$ECPR$2" AS NUMERIC(15,2))                                                                                                         AS ESTIMATEDCOSTPRICE2 
            ,CAST("T$ECPR$3" AS NUMERIC(15,2))                                                                                                         AS ESTIMATEDCOSTPRICE3 
            ,CAST(T$EQAN AS NUMERIC(15,2))                                                                                                           AS ESTIMATEDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EWRH)),'')                                                                                             AS ESTIMATIONWAREHOUSE 
            ,CAST(T$INAM AS NUMERIC(15,2))                                                                                                           AS INVOICEAMOUNT 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD END AS DATE)                                                                 AS INVOICEDATE 
            ,CAST(T$IDOC AS BIGINT)                                                                                                                  AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                             AS ITEM 
            ,CAST(CASE WHEN T$LTTM<= '1/1/1970' THEN NULL ELSE T$LTTM  END AS DATETIME)     AS LASTTRANSACTIONDATEACTUALCOSTLINE 
            ,CAST(T$LENG AS NUMERIC(15,2))                                                                                                           AS LENGTH 
            ,CAST(T$ILIN AS BIGINT)                                                                                                                  AS LINE 
            ,CAST(T$LINO AS INT)                                                                                                                     AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                             AS LOT 
            ,T$LSEL.CONSTANTDESCRIPTION                                                                                                              AS LotSelectionDescription  
            ,CAST(T$LSEL AS INT)                                                                                                                     AS LotSelectionId  
            ,CAST(T$NOUN AS BIGINT)                                                                                                                  AS NUMBEROFUNITS 
            ,"T$OACK$U".CONSTANTDESCRIPTION                                                                                                            AS ORDER_ACKNOWLEDGEMENTDESCRIPTION 
            ,CAST("T$OACK$U" AS INT)                                                                                                                   AS ORDER_ACKNOWLEDGEMENTID 
            ,CAST(CASE WHEN "T$PSHP$U"<= '1/1/1970' THEN NULL ELSE "T$PSHP$U"  END AS DATETIME) AS ORDER_DATE 
            ,"T$PRIO$U".CONSTANTDESCRIPTION                                                                                                            AS ORDER_PRIORITYDESCRIPTION 
            ,CAST("T$PRIO$U" AS INT)                                                                                                                   AS ORDER_PRIORITYID 
            ,CAST(CASE WHEN T$PDTM<= '1/1/1970' THEN NULL ELSE T$PDTM  END AS DATETIME)     AS PLANNEDDELIVERYTIME 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT END AS DATE)                                                                 AS POSTINGDATE 
            ,T$QTYN.CONSTANTDESCRIPTION                                                                                                              AS QUOTATIONCOVERAGEDESCRIPTION 
            ,CAST(T$QTYN AS INT)                                                                                                                     AS QUOTATIONCOVERAGEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$RSCD$U")),'')                                                                                           AS REASONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETR)),'')                                                                                             AS RETURNREASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRTE$U")),'')                                                                                           AS ROUTE 
            ,CAST(T$ASFC AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTFIELDCHANGEORDERS 
            ,CAST(T$ASOC AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTOTHERCOSTS 
            ,CAST(T$ASCO AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTSERVICECONTRACT 
            ,CAST(T$ASIN AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTSERVICEORDERINVOICING 
            ,CAST(T$ASQU AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTSERVICEORDERQUOTATIONS 
            ,CAST(T$ASWA AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTWARRANTY 
            ,CAST(T$PRIS AS NUMERIC(15,2))                                                                                                           AS SALESPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                             AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                             AS SALESQUANTITYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSKT)),'')                                                                                             AS SERVICEKIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                             AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$STAD$U")),'')                                                                                           AS SHIPTOADDRESS 
            ,CAST(T$QTSD AS NUMERIC(15,2))                                                                                                           AS SUBSEQUENTDELIVEREDQUANTITY 
            ,CAST(T$TXAM AS NUMERIC(15,2))                                                                                                           AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                             AS TAXCODE 
            ,CAST(T$ICMP AS INT)                                                                                                                     AS TCCOM000NCMP 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                         AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                             AS TFGLD011TTYP 
            ,CAST(T$THIC AS NUMERIC(15,2))                                                                                                           AS THICKNESS 
            ,CAST(T$ASTO AS NUMERIC(15,2))                                                                                                           AS TOTALSALESAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TSID$U")),'')                                                                                           AS TSMTRANSIDCONTNAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TSLN$U")),'')                                                                                           AS TSMTRANSLINE_hash_CONTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WHTF)),'')                                                                                             AS WAREHOUSEORDERFORTRANSFER 
            ,T$WTYN.CONSTANTDESCRIPTION                                                                                                              AS WARRANTYCOVERAGEDESCRIPTION 
            ,CAST(T$WTYN AS INT)                                                                                                                     AS WARRANTYCOVERAGEID 
            ,CAST(T$WIDT AS NUMERIC(15,2))                                                                                                           AS WIDTH 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC220200") }} AS SOURCETABLE  
            /*CONTRACTCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYN 
             ON   T$CTYN.TABLENAME  = 'TSSOC220' 
              AND T$CTYN.COLUMNNAME = 'T$CTYN' 
              AND T$CTYN.CONSTANT   = SOURCETABLE.T$CTYN 
            /*COSTLINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLST 
             ON   T$CLST.TABLENAME  = 'TSSOC220' 
              AND T$CLST.COLUMNNAME = 'T$CLST' 
              AND T$CLST.CONSTANT   = SOURCETABLE.T$CLST 
            /*DELIVERYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DLTP 
             ON   T$DLTP.TABLENAME  = 'TSSOC220' 
              AND T$DLTP.COLUMNNAME = 'T$DLTP' 
              AND T$DLTP.CONSTANT   = SOURCETABLE.T$DLTP 
            /*DIRECTDELIVERYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DDEL$U" 
             ON   "T$DDEL$U".TABLENAME  = 'TSSOC220' 
              AND "T$DDEL$U".COLUMNNAME = 'T$DDEL.U' 
              AND "T$DDEL$U".CONSTANT   = SOURCETABLE."T$DDEL$U" 
            /*DISCOUNTMATRIXTYPE1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$1" 
             ON   "T$DMTY$1".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$1".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$1".CONSTANT   = SOURCETABLE."T$DMTY$1" 
            /*DISCOUNTMATRIXTYPE2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$2" 
             ON   "T$DMTY$2".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$2".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$2".CONSTANT   = SOURCETABLE."T$DMTY$2" 
            /*DISCOUNTMATRIXTYPE3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$3" 
             ON   "T$DMTY$3".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$3".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$3".CONSTANT   = SOURCETABLE."T$DMTY$3" 
            /*DISCOUNTMATRIXTYPE4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$4" 
             ON   "T$DMTY$4".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$4".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$4".CONSTANT   = SOURCETABLE."T$DMTY$4" 
            /*DISCOUNTMATRIXTYPE5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$5" 
             ON   "T$DMTY$5".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$5".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$5".CONSTANT   = SOURCETABLE."T$DMTY$5" 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$1" 
             ON   "T$DMTH$1".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$1".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$1".CONSTANT   = SOURCETABLE."T$DMTH$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$2" 
             ON   "T$DMTH$2".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$2".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$2".CONSTANT   = SOURCETABLE."T$DMTH$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$3" 
             ON   "T$DMTH$3".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$3".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$3".CONSTANT   = SOURCETABLE."T$DMTH$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$4" 
             ON   "T$DMTH$4".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$4".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$4".CONSTANT   = SOURCETABLE."T$DMTH$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$5" 
             ON   "T$DMTH$5".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$5".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$5".CONSTANT   = SOURCETABLE."T$DMTH$5" 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'TSSOC220' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*ORDERACKNOWLEDGEMENTU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$OACK$U" 
             ON   "T$OACK$U".TABLENAME  = 'TSSOC220' 
              AND "T$OACK$U".COLUMNNAME = 'T$OACK.U' 
              AND "T$OACK$U".CONSTANT   = SOURCETABLE."T$OACK$U" 
            /*ORDERPRIORITYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRIO$U" 
             ON   "T$PRIO$U".TABLENAME  = 'TSSOC220' 
              AND "T$PRIO$U".COLUMNNAME = 'T$PRIO.U' 
              AND "T$PRIO$U".CONSTANT   = SOURCETABLE."T$PRIO$U" 
            /*QUOTATIONCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QTYN 
             ON   T$QTYN.TABLENAME  = 'TSSOC220' 
              AND T$QTYN.COLUMNNAME = 'T$QTYN' 
              AND T$QTYN.CONSTANT   = SOURCETABLE.T$QTYN 
            /*WARRANTYCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WTYN 
             ON   T$WTYN.TABLENAME  = 'TSSOC220' 
              AND T$WTYN.COLUMNNAME = 'T$WTYN' 
              AND T$WTYN.CONSTANT   = SOURCETABLE.T$WTYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                                                                                                                     AS ACTIVITY 
            ,CAST("T$ACPR$1" AS NUMERIC(15,2))                                                                                                         AS ACTUALCOSTPRICE1 
            ,CAST("T$ACPR$2" AS NUMERIC(15,2))                                                                                                         AS ACTUALCOSTPRICE2 
            ,CAST("T$ACPR$3" AS NUMERIC(15,2))                                                                                                         AS ACTUALCOSTPRICE3 
            ,CAST(T$ADQT AS NUMERIC(15,2))                                                                                                           AS ACTUALCUMULATIVEQUANTITY 
            ,CAST("T$APAM$1" AS NUMERIC(15,2))                                                                                                         AS ACTUALPURCHASEAMOUNT1 
            ,CAST("T$APAM$2" AS NUMERIC(15,2))                                                                                                         AS ACTUALPURCHASEAMOUNT2 
            ,CAST("T$APAM$3" AS NUMERIC(15,2))                                                                                                         AS ACTUALPURCHASEAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AWRH)),'')                                                                                             AS ACTUALWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                             AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CFRW$U")),'')                                                                                           AS CARRIER 
            ,CAST("T$CASE$U" AS BIGINT)                                                                                                                AS CASENUMBER 
            ,CAST(CASE WHEN "T$CDAT$U"<= '1/1/1970' THEN NULL ELSE "T$CDAT$U"  END AS DATETIME) AS COMMITDATE 
            ,T$CTYN.CONSTANTDESCRIPTION                                                                                                              AS CONTRACTCOVERAGEDESCRIPTION 
            ,CAST(T$CTYN AS INT)                                                                                                                     AS CONTRACTCOVERAGEID 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORFORQUANTITYUNIT 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORSALESPRICEUNIT 
            ,CAST("T$ACFC$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTFIELDCHANGEORDERS1 
            ,CAST("T$ACFC$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTFIELDCHANGEORDERS2 
            ,CAST("T$ACFC$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTFIELDCHANGEORDERS3 
            ,CAST("T$ACOC$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOTHERCOSTS1 
            ,CAST("T$ACOC$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOTHERCOSTS2 
            ,CAST("T$ACOC$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOTHERCOSTS3 
            ,CAST("T$ACCO$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICECONTRACT1 
            ,CAST("T$ACCO$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICECONTRACT2 
            ,CAST("T$ACCO$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICECONTRACT3 
            ,CAST("T$ACIN$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERINVOICING1 
            ,CAST("T$ACIN$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERINVOICING2 
            ,CAST("T$ACIN$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERINVOICING3 
            ,CAST("T$ACQU$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERQUOTATION1 
            ,CAST("T$ACQU$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERQUOTATION2 
            ,CAST("T$ACQU$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTSERVICEORDERQUOTATION3 
            ,CAST("T$ACWA$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTWARRANTY1 
            ,CAST("T$ACWA$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTWARRANTY2 
            ,CAST("T$ACWA$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTWARRANTY3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCMP)),'')                                                                                             AS COSTCOMPONENT 
            ,T$CLST.CONSTANTDESCRIPTION                                                                                                              AS COSTLINESTATUSDESCRIPTION 
            ,CAST(T$CLST AS INT)                                                                                                                     AS COSTLINESTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRMC$U")),'')                                                                                           AS CRM_CASE_hash_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                                                                                           AS CUSTOMERPOLINE 
            ,CAST(CASE WHEN "T$CREQ$U"<= '1/1/1970' THEN NULL ELSE "T$CREQ$U"  END AS DATETIME) AS CUSTREQDELDT 
            ,CAST(T$QTDL AS NUMERIC(15,2))                                                                                                           AS DELIVEREDQUANTITY 
            ,T$DLTP.CONSTANTDESCRIPTION                                                                                                              AS DELIVERYTYPEDESCRIPTION 
            ,CAST(T$DLTP AS INT)                                                                                                                     AS DELIVERYTYPEID 
            ,"T$DDEL$U".CONSTANTDESCRIPTION                                                                                                            AS DIRECTDELIVERYDESCRIPTION 
            ,CAST("T$DDEL$U" AS INT)                                                                                                                   AS DIRECTDELIVERYID 
            ,CAST(T$DISC AS NUMERIC(15,2))                                                                                                           AS DISCOUNT 
            ,CAST(T$ASDI AS NUMERIC(15,2))                                                                                                           AS DISCOUNTAMOUNT_ASDI 
            ,CAST("T$LDAM$1" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_1 
            ,CAST("T$LDAM$2" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_2 
            ,CAST("T$LDAM$3" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_3 
            ,CAST("T$LDAM$4" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_4 
            ,CAST("T$LDAM$5" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT_LDAM_5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$1")),'')                                                                                           AS DISCOUNTCODE1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$2")),'')                                                                                           AS DISCOUNTCODE2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$3")),'')                                                                                           AS DISCOUNTCODE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$4")),'')                                                                                           AS DISCOUNTCODE4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$5")),'')                                                                                           AS DISCOUNTCODE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$1")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$2")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$3")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$4")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$5")),'')                                                                                           AS DISCOUNTMATRIXDEFINITION5 
            ,CAST("T$DMSE$1" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE1 
            ,CAST("T$DMSE$2" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE2 
            ,CAST("T$DMSE$3" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE3 
            ,CAST("T$DMSE$4" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE4 
            ,CAST("T$DMSE$5" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXSEQUENCE5 
            ,"T$DMTY$1".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE1DESCRIPTION 
            ,CAST("T$DMTY$1" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE1ID 
            ,"T$DMTY$2".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE2DESCRIPTION 
            ,CAST("T$DMTY$2" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE2ID 
            ,"T$DMTY$3".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE3DESCRIPTION 
            ,CAST("T$DMTY$3" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE3ID 
            ,"T$DMTY$4".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE4DESCRIPTION 
            ,CAST("T$DMTY$4" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE4ID 
            ,"T$DMTY$5".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMATRIXTYPE5DESCRIPTION 
            ,CAST("T$DMTY$5" AS INT)                                                                                                                   AS DISCOUNTMATRIXTYPE5ID 
            ,"T$DMTH$1".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD1DESCRIPTION 
            ,CAST("T$DMTH$1" AS INT)                                                                                                                   AS DISCOUNTMETHOD1ID 
            ,"T$DMTH$2".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD2DESCRIPTION 
            ,CAST("T$DMTH$2" AS INT)                                                                                                                   AS DISCOUNTMETHOD2ID 
            ,"T$DMTH$3".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD3DESCRIPTION 
            ,CAST("T$DMTH$3" AS INT)                                                                                                                   AS DISCOUNTMETHOD3ID 
            ,"T$DMTH$4".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD4DESCRIPTION 
            ,CAST("T$DMTH$4" AS INT)                                                                                                                   AS DISCOUNTMETHOD4ID 
            ,"T$DMTH$5".CONSTANTDESCRIPTION                                                                                                            AS DISCOUNTMETHOD5DESCRIPTION 
            ,CAST("T$DMTH$5" AS INT)                                                                                                                   AS DISCOUNTMETHOD5ID 
            ,CAST("T$DPER$1" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE1 
            ,CAST("T$DPER$2" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE2 
            ,CAST("T$DPER$3" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE3 
            ,CAST("T$DPER$4" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE4 
            ,CAST("T$DPER$5" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTPERCENTAGE5 
            ,CAST(T$IDCN AS BIGINT)                                                                                                                  AS DOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                             AS ENGINEERINGITEMREVISION 
            ,CAST("T$ECPR$1" AS NUMERIC(15,2))                                                                                                         AS ESTIMATEDCOSTPRICE1 
            ,CAST("T$ECPR$2" AS NUMERIC(15,2))                                                                                                         AS ESTIMATEDCOSTPRICE2 
            ,CAST("T$ECPR$3" AS NUMERIC(15,2))                                                                                                         AS ESTIMATEDCOSTPRICE3 
            ,CAST(T$EQAN AS NUMERIC(15,2))                                                                                                           AS ESTIMATEDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EWRH)),'')                                                                                             AS ESTIMATIONWAREHOUSE 
            ,CAST(T$INAM AS NUMERIC(15,2))                                                                                                           AS INVOICEAMOUNT 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD END AS DATE)                                                                 AS INVOICEDATE 
            ,CAST(T$IDOC AS BIGINT)                                                                                                                  AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                             AS ITEM 
            ,CAST(CASE WHEN T$LTTM<= '1/1/1970' THEN NULL ELSE T$LTTM  END AS DATETIME)     AS LASTTRANSACTIONDATEACTUALCOSTLINE 
            ,CAST(T$LENG AS NUMERIC(15,2))                                                                                                           AS LENGTH 
            ,CAST(T$ILIN AS BIGINT)                                                                                                                  AS LINE 
            ,CAST(T$LINO AS INT)                                                                                                                     AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                             AS LOT 
            ,T$LSEL.CONSTANTDESCRIPTION                                                                                                              AS LotSelectionDescription  
            ,CAST(T$LSEL AS INT)                                                                                                                     AS LotSelectionId  
            ,CAST(T$NOUN AS BIGINT)                                                                                                                  AS NUMBEROFUNITS 
            ,"T$OACK$U".CONSTANTDESCRIPTION                                                                                                            AS ORDER_ACKNOWLEDGEMENTDESCRIPTION 
            ,CAST("T$OACK$U" AS INT)                                                                                                                   AS ORDER_ACKNOWLEDGEMENTID 
            ,CAST(CASE WHEN "T$PSHP$U"<= '1/1/1970' THEN NULL ELSE "T$PSHP$U"  END AS DATETIME) AS ORDER_DATE 
            ,"T$PRIO$U".CONSTANTDESCRIPTION                                                                                                            AS ORDER_PRIORITYDESCRIPTION 
            ,CAST("T$PRIO$U" AS INT)                                                                                                                   AS ORDER_PRIORITYID 
            ,CAST(CASE WHEN T$PDTM<= '1/1/1970' THEN NULL ELSE T$PDTM  END AS DATETIME)     AS PLANNEDDELIVERYTIME 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT END AS DATE)                                                                 AS POSTINGDATE 
            ,T$QTYN.CONSTANTDESCRIPTION                                                                                                              AS QUOTATIONCOVERAGEDESCRIPTION 
            ,CAST(T$QTYN AS INT)                                                                                                                     AS QUOTATIONCOVERAGEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$RSCD$U")),'')                                                                                           AS REASONCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETR)),'')                                                                                             AS RETURNREASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRTE$U")),'')                                                                                           AS ROUTE 
            ,CAST(T$ASFC AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTFIELDCHANGEORDERS 
            ,CAST(T$ASOC AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTOTHERCOSTS 
            ,CAST(T$ASCO AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTSERVICECONTRACT 
            ,CAST(T$ASIN AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTSERVICEORDERINVOICING 
            ,CAST(T$ASQU AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTSERVICEORDERQUOTATIONS 
            ,CAST(T$ASWA AS NUMERIC(15,2))                                                                                                           AS SALESAMOUNTWARRANTY 
            ,CAST(T$PRIS AS NUMERIC(15,2))                                                                                                           AS SALESPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                             AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                             AS SALESQUANTITYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSKT)),'')                                                                                             AS SERVICEKIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                             AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$STAD$U")),'')                                                                                           AS SHIPTOADDRESS 
            ,CAST(T$QTSD AS NUMERIC(15,2))                                                                                                           AS SUBSEQUENTDELIVEREDQUANTITY 
            ,CAST(T$TXAM AS NUMERIC(15,2))                                                                                                           AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                             AS TAXCODE 
            ,CAST(T$ICMP AS INT)                                                                                                                     AS TCCOM000NCMP 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                         AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                             AS TFGLD011TTYP 
            ,CAST(T$THIC AS NUMERIC(15,2))                                                                                                           AS THICKNESS 
            ,CAST(T$ASTO AS NUMERIC(15,2))                                                                                                           AS TOTALSALESAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TSID$U")),'')                                                                                           AS TSMTRANSIDCONTNAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TSLN$U")),'')                                                                                           AS TSMTRANSLINE_hash_CONTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WHTF)),'')                                                                                             AS WAREHOUSEORDERFORTRANSFER 
            ,T$WTYN.CONSTANTDESCRIPTION                                                                                                              AS WARRANTYCOVERAGEDESCRIPTION 
            ,CAST(T$WTYN AS INT)                                                                                                                     AS WARRANTYCOVERAGEID 
            ,CAST(T$WIDT AS NUMERIC(15,2))                                                                                                           AS WIDTH 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC220201") }} AS SOURCETABLE  
            /*CONTRACTCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYN 
             ON   T$CTYN.TABLENAME  = 'TSSOC220' 
              AND T$CTYN.COLUMNNAME = 'T$CTYN' 
              AND T$CTYN.CONSTANT   = SOURCETABLE.T$CTYN 
            /*COSTLINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLST 
             ON   T$CLST.TABLENAME  = 'TSSOC220' 
              AND T$CLST.COLUMNNAME = 'T$CLST' 
              AND T$CLST.CONSTANT   = SOURCETABLE.T$CLST 
            /*DELIVERYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DLTP 
             ON   T$DLTP.TABLENAME  = 'TSSOC220' 
              AND T$DLTP.COLUMNNAME = 'T$DLTP' 
              AND T$DLTP.CONSTANT   = SOURCETABLE.T$DLTP 
            /*DIRECTDELIVERYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DDEL$U" 
             ON   "T$DDEL$U".TABLENAME  = 'TSSOC220' 
              AND "T$DDEL$U".COLUMNNAME = 'T$DDEL.U' 
              AND "T$DDEL$U".CONSTANT   = SOURCETABLE."T$DDEL$U" 
            /*DISCOUNTMATRIXTYPE1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$1" 
             ON   "T$DMTY$1".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$1".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$1".CONSTANT   = SOURCETABLE."T$DMTY$1" 
            /*DISCOUNTMATRIXTYPE2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$2" 
             ON   "T$DMTY$2".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$2".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$2".CONSTANT   = SOURCETABLE."T$DMTY$2" 
            /*DISCOUNTMATRIXTYPE3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$3" 
             ON   "T$DMTY$3".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$3".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$3".CONSTANT   = SOURCETABLE."T$DMTY$3" 
            /*DISCOUNTMATRIXTYPE4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$4" 
             ON   "T$DMTY$4".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$4".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$4".CONSTANT   = SOURCETABLE."T$DMTY$4" 
            /*DISCOUNTMATRIXTYPE5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$5" 
             ON   "T$DMTY$5".TABLENAME  = 'TSSOC220' 
              AND "T$DMTY$5".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$5".CONSTANT   = SOURCETABLE."T$DMTY$5" 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$1" 
             ON   "T$DMTH$1".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$1".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$1".CONSTANT   = SOURCETABLE."T$DMTH$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$2" 
             ON   "T$DMTH$2".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$2".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$2".CONSTANT   = SOURCETABLE."T$DMTH$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$3" 
             ON   "T$DMTH$3".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$3".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$3".CONSTANT   = SOURCETABLE."T$DMTH$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$4" 
             ON   "T$DMTH$4".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$4".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$4".CONSTANT   = SOURCETABLE."T$DMTH$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$5" 
             ON   "T$DMTH$5".TABLENAME  = 'TSSOC220' 
              AND "T$DMTH$5".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$5".CONSTANT   = SOURCETABLE."T$DMTH$5" 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'TSSOC220' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*ORDERACKNOWLEDGEMENTU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$OACK$U" 
             ON   "T$OACK$U".TABLENAME  = 'TSSOC220' 
              AND "T$OACK$U".COLUMNNAME = 'T$OACK.U' 
              AND "T$OACK$U".CONSTANT   = SOURCETABLE."T$OACK$U" 
            /*ORDERPRIORITYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRIO$U" 
             ON   "T$PRIO$U".TABLENAME  = 'TSSOC220' 
              AND "T$PRIO$U".COLUMNNAME = 'T$PRIO.U' 
              AND "T$PRIO$U".CONSTANT   = SOURCETABLE."T$PRIO$U" 
            /*QUOTATIONCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QTYN 
             ON   T$QTYN.TABLENAME  = 'TSSOC220' 
              AND T$QTYN.COLUMNNAME = 'T$QTYN' 
              AND T$QTYN.CONSTANT   = SOURCETABLE.T$QTYN 
            /*WARRANTYCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WTYN 
             ON   T$WTYN.TABLENAME  = 'TSSOC220' 
              AND T$WTYN.COLUMNNAME = 'T$WTYN' 
              AND T$WTYN.CONSTANT   = SOURCETABLE.T$WTYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.ACTUALCOSTPRICE1 AS ACTUALCOSTPRICE1, 
        source_data.ACTUALCOSTPRICE2 AS ACTUALCOSTPRICE2, 
        source_data.ACTUALCOSTPRICE3 AS ACTUALCOSTPRICE3, 
        source_data.ACTUALCUMULATIVEQUANTITY AS ACTUALCUMULATIVEQUANTITY, 
        source_data.ACTUALPURCHASEAMOUNT1 AS ACTUALPURCHASEAMOUNT1, 
        source_data.ACTUALPURCHASEAMOUNT2 AS ACTUALPURCHASEAMOUNT2, 
        source_data.ACTUALPURCHASEAMOUNT3 AS ACTUALPURCHASEAMOUNT3, 
        source_data.ACTUALWAREHOUSE AS ACTUALWAREHOUSE, 
        source_data.BUYFROMBUSINESSPARTNER AS BUYFROMBUSINESSPARTNER, 
        source_data.CARRIER AS CARRIER, 
        source_data.CASENUMBER AS CASENUMBER, 
        source_data.COMMITDATE AS COMMITDATE, 
        source_data.CONTRACTCOVERAGEDESCRIPTION AS CONTRACTCOVERAGEDESCRIPTION, 
        source_data.CONTRACTCOVERAGEID AS CONTRACTCOVERAGEID, 
        source_data.CONVERSIONFACTORFORQUANTITYUNIT AS CONVERSIONFACTORFORQUANTITYUNIT, 
        source_data.CONVERSIONFACTORSALESPRICEUNIT AS CONVERSIONFACTORSALESPRICEUNIT, 
        source_data.COSTAMOUNTFIELDCHANGEORDERS1 AS COSTAMOUNTFIELDCHANGEORDERS1, 
        source_data.COSTAMOUNTFIELDCHANGEORDERS2 AS COSTAMOUNTFIELDCHANGEORDERS2, 
        source_data.COSTAMOUNTFIELDCHANGEORDERS3 AS COSTAMOUNTFIELDCHANGEORDERS3, 
        source_data.COSTAMOUNTOTHERCOSTS1 AS COSTAMOUNTOTHERCOSTS1, 
        source_data.COSTAMOUNTOTHERCOSTS2 AS COSTAMOUNTOTHERCOSTS2, 
        source_data.COSTAMOUNTOTHERCOSTS3 AS COSTAMOUNTOTHERCOSTS3, 
        source_data.COSTAMOUNTSERVICECONTRACT1 AS COSTAMOUNTSERVICECONTRACT1, 
        source_data.COSTAMOUNTSERVICECONTRACT2 AS COSTAMOUNTSERVICECONTRACT2, 
        source_data.COSTAMOUNTSERVICECONTRACT3 AS COSTAMOUNTSERVICECONTRACT3, 
        source_data.COSTAMOUNTSERVICEORDERINVOICING1 AS COSTAMOUNTSERVICEORDERINVOICING1, 
        source_data.COSTAMOUNTSERVICEORDERINVOICING2 AS COSTAMOUNTSERVICEORDERINVOICING2, 
        source_data.COSTAMOUNTSERVICEORDERINVOICING3 AS COSTAMOUNTSERVICEORDERINVOICING3, 
        source_data.COSTAMOUNTSERVICEORDERQUOTATION1 AS COSTAMOUNTSERVICEORDERQUOTATION1, 
        source_data.COSTAMOUNTSERVICEORDERQUOTATION2 AS COSTAMOUNTSERVICEORDERQUOTATION2, 
        source_data.COSTAMOUNTSERVICEORDERQUOTATION3 AS COSTAMOUNTSERVICEORDERQUOTATION3, 
        source_data.COSTAMOUNTWARRANTY1 AS COSTAMOUNTWARRANTY1, 
        source_data.COSTAMOUNTWARRANTY2 AS COSTAMOUNTWARRANTY2, 
        source_data.COSTAMOUNTWARRANTY3 AS COSTAMOUNTWARRANTY3, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.COSTLINESTATUSDESCRIPTION AS COSTLINESTATUSDESCRIPTION, 
        source_data.COSTLINESTATUSID AS COSTLINESTATUSID, 
        source_data.CRM_CASE_HASH_ AS CRM_CASE_HASH_, 
        source_data.CUSTOMERPOLINE AS CUSTOMERPOLINE, 
        source_data.CUSTREQDELDT AS CUSTREQDELDT, 
        source_data.DELIVEREDQUANTITY AS DELIVEREDQUANTITY, 
        source_data.DELIVERYTYPEDESCRIPTION AS DELIVERYTYPEDESCRIPTION, 
        source_data.DELIVERYTYPEID AS DELIVERYTYPEID, 
        source_data.DIRECTDELIVERYDESCRIPTION AS DIRECTDELIVERYDESCRIPTION, 
        source_data.DIRECTDELIVERYID AS DIRECTDELIVERYID, 
        source_data.DISCOUNT AS DISCOUNT, 
        source_data.DISCOUNTAMOUNT_ASDI AS DISCOUNTAMOUNT_ASDI, 
        source_data.DISCOUNTAMOUNT_LDAM_1 AS DISCOUNTAMOUNT_LDAM_1, 
        source_data.DISCOUNTAMOUNT_LDAM_2 AS DISCOUNTAMOUNT_LDAM_2, 
        source_data.DISCOUNTAMOUNT_LDAM_3 AS DISCOUNTAMOUNT_LDAM_3, 
        source_data.DISCOUNTAMOUNT_LDAM_4 AS DISCOUNTAMOUNT_LDAM_4, 
        source_data.DISCOUNTAMOUNT_LDAM_5 AS DISCOUNTAMOUNT_LDAM_5, 
        source_data.DISCOUNTCODE1 AS DISCOUNTCODE1, 
        source_data.DISCOUNTCODE2 AS DISCOUNTCODE2, 
        source_data.DISCOUNTCODE3 AS DISCOUNTCODE3, 
        source_data.DISCOUNTCODE4 AS DISCOUNTCODE4, 
        source_data.DISCOUNTCODE5 AS DISCOUNTCODE5, 
        source_data.DISCOUNTMATRIXDEFINITION1 AS DISCOUNTMATRIXDEFINITION1, 
        source_data.DISCOUNTMATRIXDEFINITION2 AS DISCOUNTMATRIXDEFINITION2, 
        source_data.DISCOUNTMATRIXDEFINITION3 AS DISCOUNTMATRIXDEFINITION3, 
        source_data.DISCOUNTMATRIXDEFINITION4 AS DISCOUNTMATRIXDEFINITION4, 
        source_data.DISCOUNTMATRIXDEFINITION5 AS DISCOUNTMATRIXDEFINITION5, 
        source_data.DISCOUNTMATRIXSEQUENCE1 AS DISCOUNTMATRIXSEQUENCE1, 
        source_data.DISCOUNTMATRIXSEQUENCE2 AS DISCOUNTMATRIXSEQUENCE2, 
        source_data.DISCOUNTMATRIXSEQUENCE3 AS DISCOUNTMATRIXSEQUENCE3, 
        source_data.DISCOUNTMATRIXSEQUENCE4 AS DISCOUNTMATRIXSEQUENCE4, 
        source_data.DISCOUNTMATRIXSEQUENCE5 AS DISCOUNTMATRIXSEQUENCE5, 
        source_data.DISCOUNTMATRIXTYPE1DESCRIPTION AS DISCOUNTMATRIXTYPE1DESCRIPTION, 
        source_data.DISCOUNTMATRIXTYPE1ID AS DISCOUNTMATRIXTYPE1ID, 
        source_data.DISCOUNTMATRIXTYPE2DESCRIPTION AS DISCOUNTMATRIXTYPE2DESCRIPTION, 
        source_data.DISCOUNTMATRIXTYPE2ID AS DISCOUNTMATRIXTYPE2ID, 
        source_data.DISCOUNTMATRIXTYPE3DESCRIPTION AS DISCOUNTMATRIXTYPE3DESCRIPTION, 
        source_data.DISCOUNTMATRIXTYPE3ID AS DISCOUNTMATRIXTYPE3ID, 
        source_data.DISCOUNTMATRIXTYPE4DESCRIPTION AS DISCOUNTMATRIXTYPE4DESCRIPTION, 
        source_data.DISCOUNTMATRIXTYPE4ID AS DISCOUNTMATRIXTYPE4ID, 
        source_data.DISCOUNTMATRIXTYPE5DESCRIPTION AS DISCOUNTMATRIXTYPE5DESCRIPTION, 
        source_data.DISCOUNTMATRIXTYPE5ID AS DISCOUNTMATRIXTYPE5ID, 
        source_data.DISCOUNTMETHOD1DESCRIPTION AS DISCOUNTMETHOD1DESCRIPTION, 
        source_data.DISCOUNTMETHOD1ID AS DISCOUNTMETHOD1ID, 
        source_data.DISCOUNTMETHOD2DESCRIPTION AS DISCOUNTMETHOD2DESCRIPTION, 
        source_data.DISCOUNTMETHOD2ID AS DISCOUNTMETHOD2ID, 
        source_data.DISCOUNTMETHOD3DESCRIPTION AS DISCOUNTMETHOD3DESCRIPTION, 
        source_data.DISCOUNTMETHOD3ID AS DISCOUNTMETHOD3ID, 
        source_data.DISCOUNTMETHOD4DESCRIPTION AS DISCOUNTMETHOD4DESCRIPTION, 
        source_data.DISCOUNTMETHOD4ID AS DISCOUNTMETHOD4ID, 
        source_data.DISCOUNTMETHOD5DESCRIPTION AS DISCOUNTMETHOD5DESCRIPTION, 
        source_data.DISCOUNTMETHOD5ID AS DISCOUNTMETHOD5ID, 
        source_data.DISCOUNTPERCENTAGE1 AS DISCOUNTPERCENTAGE1, 
        source_data.DISCOUNTPERCENTAGE2 AS DISCOUNTPERCENTAGE2, 
        source_data.DISCOUNTPERCENTAGE3 AS DISCOUNTPERCENTAGE3, 
        source_data.DISCOUNTPERCENTAGE4 AS DISCOUNTPERCENTAGE4, 
        source_data.DISCOUNTPERCENTAGE5 AS DISCOUNTPERCENTAGE5, 
        source_data.DOCUMENT AS DOCUMENT, 
        source_data.ENGINEERINGITEMREVISION AS ENGINEERINGITEMREVISION, 
        source_data.ESTIMATEDCOSTPRICE1 AS ESTIMATEDCOSTPRICE1, 
        source_data.ESTIMATEDCOSTPRICE2 AS ESTIMATEDCOSTPRICE2, 
        source_data.ESTIMATEDCOSTPRICE3 AS ESTIMATEDCOSTPRICE3, 
        source_data.ESTIMATEDQUANTITY AS ESTIMATEDQUANTITY, 
        source_data.ESTIMATIONWAREHOUSE AS ESTIMATIONWAREHOUSE, 
        source_data.INVOICEAMOUNT AS INVOICEAMOUNT, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.ITEM AS ITEM, 
        source_data.LASTTRANSACTIONDATEACTUALCOSTLINE AS LASTTRANSACTIONDATEACTUALCOSTLINE, 
        source_data.LENGTH AS LENGTH, 
        source_data.LINE AS LINE, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.LOT AS LOT, 
        source_data.LOTSELECTIONDESCRIPTION AS LOTSELECTIONDESCRIPTION, 
        source_data.LOTSELECTIONID AS LOTSELECTIONID, 
        source_data.NUMBEROFUNITS AS NUMBEROFUNITS, 
        source_data.ORDER_ACKNOWLEDGEMENTDESCRIPTION AS ORDER_ACKNOWLEDGEMENTDESCRIPTION, 
        source_data.ORDER_ACKNOWLEDGEMENTID AS ORDER_ACKNOWLEDGEMENTID, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_PRIORITYDESCRIPTION AS ORDER_PRIORITYDESCRIPTION, 
        source_data.ORDER_PRIORITYID AS ORDER_PRIORITYID, 
        source_data.PLANNEDDELIVERYTIME AS PLANNEDDELIVERYTIME, 
        source_data.POSTINGDATE AS POSTINGDATE, 
        source_data.QUOTATIONCOVERAGEDESCRIPTION AS QUOTATIONCOVERAGEDESCRIPTION, 
        source_data.QUOTATIONCOVERAGEID AS QUOTATIONCOVERAGEID, 
        source_data.REASONCODE AS REASONCODE, 
        source_data.RETURNREASON AS RETURNREASON, 
        source_data.ROUTE AS ROUTE, 
        source_data.SALESAMOUNTFIELDCHANGEORDERS AS SALESAMOUNTFIELDCHANGEORDERS, 
        source_data.SALESAMOUNTOTHERCOSTS AS SALESAMOUNTOTHERCOSTS, 
        source_data.SALESAMOUNTSERVICECONTRACT AS SALESAMOUNTSERVICECONTRACT, 
        source_data.SALESAMOUNTSERVICEORDERINVOICING AS SALESAMOUNTSERVICEORDERINVOICING, 
        source_data.SALESAMOUNTSERVICEORDERQUOTATIONS AS SALESAMOUNTSERVICEORDERQUOTATIONS, 
        source_data.SALESAMOUNTWARRANTY AS SALESAMOUNTWARRANTY, 
        source_data.SALESPRICE AS SALESPRICE, 
        source_data.SALESPRICEUNIT AS SALESPRICEUNIT, 
        source_data.SALESQUANTITYUNIT AS SALESQUANTITYUNIT, 
        source_data.SERVICEKIT AS SERVICEKIT, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SHIPTOADDRESS AS SHIPTOADDRESS, 
        source_data.SUBSEQUENTDELIVEREDQUANTITY AS SUBSEQUENTDELIVEREDQUANTITY, 
        source_data.TAXAMOUNT AS TAXAMOUNT, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TCCOM000NCMP AS TCCOM000NCMP, 
        source_data.TEXT AS TEXT, 
        source_data.TFGLD011TTYP AS TFGLD011TTYP, 
        source_data.THICKNESS AS THICKNESS, 
        source_data.TOTALSALESAMOUNT AS TOTALSALESAMOUNT, 
        source_data.TSMTRANSIDCONTNAME AS TSMTRANSIDCONTNAME, 
        source_data.TSMTRANSLINE_HASH_CONTNUMBER AS TSMTRANSLINE_HASH_CONTNUMBER, 
        source_data.WAREHOUSEORDERFORTRANSFER AS WAREHOUSEORDERFORTRANSFER, 
        source_data.WARRANTYCOVERAGEDESCRIPTION AS WARRANTYCOVERAGEDESCRIPTION, 
        source_data.WARRANTYCOVERAGEID AS WARRANTYCOVERAGEID, 
        source_data.WIDTH AS WIDTH
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTIVITY as NUMBER(38,0)) as ACTIVITY,
        cast(ACTUALCOSTPRICE1 as NUMBER(15,2)) as ACTUALCOSTPRICE1,
        cast(ACTUALCOSTPRICE2 as NUMBER(15,2)) as ACTUALCOSTPRICE2,
        cast(ACTUALCOSTPRICE3 as NUMBER(15,2)) as ACTUALCOSTPRICE3,
        cast(ACTUALCUMULATIVEQUANTITY as NUMBER(15,2)) as ACTUALCUMULATIVEQUANTITY,
        cast(ACTUALPURCHASEAMOUNT1 as NUMBER(15,2)) as ACTUALPURCHASEAMOUNT1,
        cast(ACTUALPURCHASEAMOUNT2 as NUMBER(15,2)) as ACTUALPURCHASEAMOUNT2,
        cast(ACTUALPURCHASEAMOUNT3 as NUMBER(15,2)) as ACTUALPURCHASEAMOUNT3,
        cast(ACTUALWAREHOUSE as VARCHAR(6)) as ACTUALWAREHOUSE,
        cast(BUYFROMBUSINESSPARTNER as VARCHAR(9)) as BUYFROMBUSINESSPARTNER,
        cast(CARRIER as VARCHAR(3)) as CARRIER,
        cast(CASENUMBER as NUMBER(38,0)) as CASENUMBER,
        cast(COMMITDATE as TIMESTAMP_NTZ(9)) as COMMITDATE,
        cast(CONTRACTCOVERAGEDESCRIPTION as VARCHAR(16777216)) as CONTRACTCOVERAGEDESCRIPTION,
        cast(CONTRACTCOVERAGEID as NUMBER(38,0)) as CONTRACTCOVERAGEID,
        cast(CONVERSIONFACTORFORQUANTITYUNIT as NUMBER(15,2)) as CONVERSIONFACTORFORQUANTITYUNIT,
        cast(CONVERSIONFACTORSALESPRICEUNIT as NUMBER(15,2)) as CONVERSIONFACTORSALESPRICEUNIT,
        cast(COSTAMOUNTFIELDCHANGEORDERS1 as NUMBER(15,2)) as COSTAMOUNTFIELDCHANGEORDERS1,
        cast(COSTAMOUNTFIELDCHANGEORDERS2 as NUMBER(15,2)) as COSTAMOUNTFIELDCHANGEORDERS2,
        cast(COSTAMOUNTFIELDCHANGEORDERS3 as NUMBER(15,2)) as COSTAMOUNTFIELDCHANGEORDERS3,
        cast(COSTAMOUNTOTHERCOSTS1 as NUMBER(15,2)) as COSTAMOUNTOTHERCOSTS1,
        cast(COSTAMOUNTOTHERCOSTS2 as NUMBER(15,2)) as COSTAMOUNTOTHERCOSTS2,
        cast(COSTAMOUNTOTHERCOSTS3 as NUMBER(15,2)) as COSTAMOUNTOTHERCOSTS3,
        cast(COSTAMOUNTSERVICECONTRACT1 as NUMBER(15,2)) as COSTAMOUNTSERVICECONTRACT1,
        cast(COSTAMOUNTSERVICECONTRACT2 as NUMBER(15,2)) as COSTAMOUNTSERVICECONTRACT2,
        cast(COSTAMOUNTSERVICECONTRACT3 as NUMBER(15,2)) as COSTAMOUNTSERVICECONTRACT3,
        cast(COSTAMOUNTSERVICEORDERINVOICING1 as NUMBER(15,2)) as COSTAMOUNTSERVICEORDERINVOICING1,
        cast(COSTAMOUNTSERVICEORDERINVOICING2 as NUMBER(15,2)) as COSTAMOUNTSERVICEORDERINVOICING2,
        cast(COSTAMOUNTSERVICEORDERINVOICING3 as NUMBER(15,2)) as COSTAMOUNTSERVICEORDERINVOICING3,
        cast(COSTAMOUNTSERVICEORDERQUOTATION1 as NUMBER(15,2)) as COSTAMOUNTSERVICEORDERQUOTATION1,
        cast(COSTAMOUNTSERVICEORDERQUOTATION2 as NUMBER(15,2)) as COSTAMOUNTSERVICEORDERQUOTATION2,
        cast(COSTAMOUNTSERVICEORDERQUOTATION3 as NUMBER(15,2)) as COSTAMOUNTSERVICEORDERQUOTATION3,
        cast(COSTAMOUNTWARRANTY1 as NUMBER(15,2)) as COSTAMOUNTWARRANTY1,
        cast(COSTAMOUNTWARRANTY2 as NUMBER(15,2)) as COSTAMOUNTWARRANTY2,
        cast(COSTAMOUNTWARRANTY3 as NUMBER(15,2)) as COSTAMOUNTWARRANTY3,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(COSTLINESTATUSDESCRIPTION as VARCHAR(16777216)) as COSTLINESTATUSDESCRIPTION,
        cast(COSTLINESTATUSID as NUMBER(38,0)) as COSTLINESTATUSID,
        cast(CRM_CASE_HASH_ as VARCHAR(18)) as CRM_CASE_HASH_,
        cast(CUSTOMERPOLINE as VARCHAR(10)) as CUSTOMERPOLINE,
        cast(CUSTREQDELDT as TIMESTAMP_NTZ(9)) as CUSTREQDELDT,
        cast(DELIVEREDQUANTITY as NUMBER(15,2)) as DELIVEREDQUANTITY,
        cast(DELIVERYTYPEDESCRIPTION as VARCHAR(16777216)) as DELIVERYTYPEDESCRIPTION,
        cast(DELIVERYTYPEID as NUMBER(38,0)) as DELIVERYTYPEID,
        cast(DIRECTDELIVERYDESCRIPTION as VARCHAR(16777216)) as DIRECTDELIVERYDESCRIPTION,
        cast(DIRECTDELIVERYID as NUMBER(38,0)) as DIRECTDELIVERYID,
        cast(DISCOUNT as NUMBER(15,2)) as DISCOUNT,
        cast(DISCOUNTAMOUNT_ASDI as NUMBER(15,2)) as DISCOUNTAMOUNT_ASDI,
        cast(DISCOUNTAMOUNT_LDAM_1 as NUMBER(15,2)) as DISCOUNTAMOUNT_LDAM_1,
        cast(DISCOUNTAMOUNT_LDAM_2 as NUMBER(15,2)) as DISCOUNTAMOUNT_LDAM_2,
        cast(DISCOUNTAMOUNT_LDAM_3 as NUMBER(15,2)) as DISCOUNTAMOUNT_LDAM_3,
        cast(DISCOUNTAMOUNT_LDAM_4 as NUMBER(15,2)) as DISCOUNTAMOUNT_LDAM_4,
        cast(DISCOUNTAMOUNT_LDAM_5 as NUMBER(15,2)) as DISCOUNTAMOUNT_LDAM_5,
        cast(DISCOUNTCODE1 as VARCHAR(3)) as DISCOUNTCODE1,
        cast(DISCOUNTCODE2 as VARCHAR(3)) as DISCOUNTCODE2,
        cast(DISCOUNTCODE3 as VARCHAR(3)) as DISCOUNTCODE3,
        cast(DISCOUNTCODE4 as VARCHAR(3)) as DISCOUNTCODE4,
        cast(DISCOUNTCODE5 as VARCHAR(3)) as DISCOUNTCODE5,
        cast(DISCOUNTMATRIXDEFINITION1 as VARCHAR(6)) as DISCOUNTMATRIXDEFINITION1,
        cast(DISCOUNTMATRIXDEFINITION2 as VARCHAR(6)) as DISCOUNTMATRIXDEFINITION2,
        cast(DISCOUNTMATRIXDEFINITION3 as VARCHAR(6)) as DISCOUNTMATRIXDEFINITION3,
        cast(DISCOUNTMATRIXDEFINITION4 as VARCHAR(6)) as DISCOUNTMATRIXDEFINITION4,
        cast(DISCOUNTMATRIXDEFINITION5 as VARCHAR(6)) as DISCOUNTMATRIXDEFINITION5,
        cast(DISCOUNTMATRIXSEQUENCE1 as NUMBER(38,0)) as DISCOUNTMATRIXSEQUENCE1,
        cast(DISCOUNTMATRIXSEQUENCE2 as NUMBER(38,0)) as DISCOUNTMATRIXSEQUENCE2,
        cast(DISCOUNTMATRIXSEQUENCE3 as NUMBER(38,0)) as DISCOUNTMATRIXSEQUENCE3,
        cast(DISCOUNTMATRIXSEQUENCE4 as NUMBER(38,0)) as DISCOUNTMATRIXSEQUENCE4,
        cast(DISCOUNTMATRIXSEQUENCE5 as NUMBER(38,0)) as DISCOUNTMATRIXSEQUENCE5,
        cast(DISCOUNTMATRIXTYPE1DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMATRIXTYPE1DESCRIPTION,
        cast(DISCOUNTMATRIXTYPE1ID as NUMBER(38,0)) as DISCOUNTMATRIXTYPE1ID,
        cast(DISCOUNTMATRIXTYPE2DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMATRIXTYPE2DESCRIPTION,
        cast(DISCOUNTMATRIXTYPE2ID as NUMBER(38,0)) as DISCOUNTMATRIXTYPE2ID,
        cast(DISCOUNTMATRIXTYPE3DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMATRIXTYPE3DESCRIPTION,
        cast(DISCOUNTMATRIXTYPE3ID as NUMBER(38,0)) as DISCOUNTMATRIXTYPE3ID,
        cast(DISCOUNTMATRIXTYPE4DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMATRIXTYPE4DESCRIPTION,
        cast(DISCOUNTMATRIXTYPE4ID as NUMBER(38,0)) as DISCOUNTMATRIXTYPE4ID,
        cast(DISCOUNTMATRIXTYPE5DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMATRIXTYPE5DESCRIPTION,
        cast(DISCOUNTMATRIXTYPE5ID as NUMBER(38,0)) as DISCOUNTMATRIXTYPE5ID,
        cast(DISCOUNTMETHOD1DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMETHOD1DESCRIPTION,
        cast(DISCOUNTMETHOD1ID as NUMBER(38,0)) as DISCOUNTMETHOD1ID,
        cast(DISCOUNTMETHOD2DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMETHOD2DESCRIPTION,
        cast(DISCOUNTMETHOD2ID as NUMBER(38,0)) as DISCOUNTMETHOD2ID,
        cast(DISCOUNTMETHOD3DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMETHOD3DESCRIPTION,
        cast(DISCOUNTMETHOD3ID as NUMBER(38,0)) as DISCOUNTMETHOD3ID,
        cast(DISCOUNTMETHOD4DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMETHOD4DESCRIPTION,
        cast(DISCOUNTMETHOD4ID as NUMBER(38,0)) as DISCOUNTMETHOD4ID,
        cast(DISCOUNTMETHOD5DESCRIPTION as VARCHAR(16777216)) as DISCOUNTMETHOD5DESCRIPTION,
        cast(DISCOUNTMETHOD5ID as NUMBER(38,0)) as DISCOUNTMETHOD5ID,
        cast(DISCOUNTPERCENTAGE1 as NUMBER(15,2)) as DISCOUNTPERCENTAGE1,
        cast(DISCOUNTPERCENTAGE2 as NUMBER(15,2)) as DISCOUNTPERCENTAGE2,
        cast(DISCOUNTPERCENTAGE3 as NUMBER(15,2)) as DISCOUNTPERCENTAGE3,
        cast(DISCOUNTPERCENTAGE4 as NUMBER(15,2)) as DISCOUNTPERCENTAGE4,
        cast(DISCOUNTPERCENTAGE5 as NUMBER(15,2)) as DISCOUNTPERCENTAGE5,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(ENGINEERINGITEMREVISION as VARCHAR(6)) as ENGINEERINGITEMREVISION,
        cast(ESTIMATEDCOSTPRICE1 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE1,
        cast(ESTIMATEDCOSTPRICE2 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE2,
        cast(ESTIMATEDCOSTPRICE3 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE3,
        cast(ESTIMATEDQUANTITY as NUMBER(15,2)) as ESTIMATEDQUANTITY,
        cast(ESTIMATIONWAREHOUSE as VARCHAR(6)) as ESTIMATIONWAREHOUSE,
        cast(INVOICEAMOUNT as NUMBER(15,2)) as INVOICEAMOUNT,
        cast(INVOICEDATE as DATE) as INVOICEDATE,
        cast(INVOICENUMBER as NUMBER(38,0)) as INVOICENUMBER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTTRANSACTIONDATEACTUALCOSTLINE as TIMESTAMP_NTZ(9)) as LASTTRANSACTIONDATEACTUALCOSTLINE,
        cast(LENGTH as NUMBER(15,2)) as LENGTH,
        cast(LINE as NUMBER(38,0)) as LINE,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(LOTSELECTIONDESCRIPTION as VARCHAR(16777216)) as LOTSELECTIONDESCRIPTION,
        cast(LOTSELECTIONID as NUMBER(38,0)) as LOTSELECTIONID,
        cast(NUMBEROFUNITS as NUMBER(38,0)) as NUMBEROFUNITS,
        cast(ORDER_ACKNOWLEDGEMENTDESCRIPTION as VARCHAR(16777216)) as ORDER_ACKNOWLEDGEMENTDESCRIPTION,
        cast(ORDER_ACKNOWLEDGEMENTID as NUMBER(38,0)) as ORDER_ACKNOWLEDGEMENTID,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_PRIORITYDESCRIPTION as VARCHAR(16777216)) as ORDER_PRIORITYDESCRIPTION,
        cast(ORDER_PRIORITYID as NUMBER(38,0)) as ORDER_PRIORITYID,
        cast(PLANNEDDELIVERYTIME as TIMESTAMP_NTZ(9)) as PLANNEDDELIVERYTIME,
        cast(POSTINGDATE as DATE) as POSTINGDATE,
        cast(QUOTATIONCOVERAGEDESCRIPTION as VARCHAR(16777216)) as QUOTATIONCOVERAGEDESCRIPTION,
        cast(QUOTATIONCOVERAGEID as NUMBER(38,0)) as QUOTATIONCOVERAGEID,
        cast(REASONCODE as VARCHAR(3)) as REASONCODE,
        cast(RETURNREASON as VARCHAR(6)) as RETURNREASON,
        cast(ROUTE as VARCHAR(5)) as ROUTE,
        cast(SALESAMOUNTFIELDCHANGEORDERS as NUMBER(15,2)) as SALESAMOUNTFIELDCHANGEORDERS,
        cast(SALESAMOUNTOTHERCOSTS as NUMBER(15,2)) as SALESAMOUNTOTHERCOSTS,
        cast(SALESAMOUNTSERVICECONTRACT as NUMBER(15,2)) as SALESAMOUNTSERVICECONTRACT,
        cast(SALESAMOUNTSERVICEORDERINVOICING as NUMBER(15,2)) as SALESAMOUNTSERVICEORDERINVOICING,
        cast(SALESAMOUNTSERVICEORDERQUOTATIONS as NUMBER(15,2)) as SALESAMOUNTSERVICEORDERQUOTATIONS,
        cast(SALESAMOUNTWARRANTY as NUMBER(15,2)) as SALESAMOUNTWARRANTY,
        cast(SALESPRICE as NUMBER(15,2)) as SALESPRICE,
        cast(SALESPRICEUNIT as VARCHAR(3)) as SALESPRICEUNIT,
        cast(SALESQUANTITYUNIT as VARCHAR(3)) as SALESQUANTITYUNIT,
        cast(SERVICEKIT as VARCHAR(6)) as SERVICEKIT,
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(SHIPTOADDRESS as VARCHAR(9)) as SHIPTOADDRESS,
        cast(SUBSEQUENTDELIVEREDQUANTITY as NUMBER(15,2)) as SUBSEQUENTDELIVEREDQUANTITY,
        cast(TAXAMOUNT as NUMBER(15,2)) as TAXAMOUNT,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(TCCOM000NCMP as NUMBER(38,0)) as TCCOM000NCMP,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(TFGLD011TTYP as VARCHAR(3)) as TFGLD011TTYP,
        cast(THICKNESS as NUMBER(15,2)) as THICKNESS,
        cast(TOTALSALESAMOUNT as NUMBER(15,2)) as TOTALSALESAMOUNT,
        cast(TSMTRANSIDCONTNAME as VARCHAR(30)) as TSMTRANSIDCONTNAME,
        cast(TSMTRANSLINE_HASH_CONTNUMBER as VARCHAR(30)) as TSMTRANSLINE_HASH_CONTNUMBER,
        cast(WAREHOUSEORDERFORTRANSFER as VARCHAR(9)) as WAREHOUSEORDERFORTRANSFER,
        cast(WARRANTYCOVERAGEDESCRIPTION as VARCHAR(16777216)) as WARRANTYCOVERAGEDESCRIPTION,
        cast(WARRANTYCOVERAGEID as NUMBER(38,0)) as WARRANTYCOVERAGEID,
        cast(WIDTH as NUMBER(15,2)) as WIDTH,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data