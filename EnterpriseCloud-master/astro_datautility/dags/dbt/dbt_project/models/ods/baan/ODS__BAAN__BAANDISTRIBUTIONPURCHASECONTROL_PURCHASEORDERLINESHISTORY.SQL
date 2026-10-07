/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERLINESHISTORY.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERLINESHISTORY.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERLINESHISTORY 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:50 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERLINESHISTORY',
    unique_key = ['POSITIONNUMBER_PONO',
    'PURCHASEORDER',
    'RECORDTYPEID',
    'SEQUENCENUMBER_SERN',
    'TRANSACTIONDATE']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CACT)),'')                                                                                         AS ACTIVITY 
            ,CAST(CASE WHEN T$DDTE<= '1/1/1970' THEN NULL ELSE T$DDTE  END AS DATETIME) AS ACTUALDELIVERYDATE 
            ,CAST(T$QSEQ AS INT)                                                                                                                 AS ALTERNATIVE 
            ,CAST(T$AMTA AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OWNO)),'')                                                                                         AS BPORDERREFERENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS BUYFROM_percent_BUSINESSPARTNER 
            ,CAST(CASE WHEN T$DDTD<= '1/1/1970' THEN NULL ELSE T$DDTD  END AS DATETIME) AS CHANGEDDELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                         AS CHANGEORDERSEQNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                         AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                         AS CHANGETYPELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITT)),'')                                                                                         AS CODEITEMTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,CAST(CASE WHEN T$DDTC<= '1/1/1970' THEN NULL ELSE T$DDTC  END AS DATETIME) AS CONFIRMEDDELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CONO)),'')                                                                                         AS CONTRACT 
            ,CAST(T$CVPP AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTORPRICETOINVENTORYUNIT 
            ,CAST(T$CVQP AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTORPURCHASETOINVENTORYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCCO)),'')                                                                                         AS COSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,CAST(CASE WHEN T$DDTB<= '1/1/1970' THEN NULL ELSE T$DDTB  END AS DATETIME) AS CURRENTPLANNEDDELIVERYDATE 
            ,T$DTRM.CONSTANTDESCRIPTION                                                                                                          AS DETERMININGDESCRIPTION 
            ,CAST(T$DTRM AS INT)                                                                                                                 AS DETERMININGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                         AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,CAST("T$LDAM$1" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTAMOUNT1 
            ,CAST("T$LDAM$2" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTAMOUNT2 
            ,CAST("T$LDAM$3" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTAMOUNT3 
            ,CAST("T$LDAM$4" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTAMOUNT4 
            ,CAST("T$LDAM$5" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTAMOUNT5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$1")),'')                                                                                       AS DISCOUNTCODE1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$2")),'')                                                                                       AS DISCOUNTCODE2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$3")),'')                                                                                       AS DISCOUNTCODE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$4")),'')                                                                                       AS DISCOUNTCODE4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CDIS$5")),'')                                                                                       AS DISCOUNTCODE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$1")),'')                                                                                       AS DISCOUNTMATRIXDEFINITION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$2")),'')                                                                                       AS DISCOUNTMATRIXDEFINITION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$3")),'')                                                                                       AS DISCOUNTMATRIXDEFINITION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$4")),'')                                                                                       AS DISCOUNTMATRIXDEFINITION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DMDE$5")),'')                                                                                       AS DISCOUNTMATRIXDEFINITION5 
            ,CAST("T$DMSE$1" AS BIGINT)                                                                                                            AS DISCOUNTMATRIXSEQUENCE1 
            ,CAST("T$DMSE$2" AS BIGINT)                                                                                                            AS DISCOUNTMATRIXSEQUENCE2 
            ,CAST("T$DMSE$3" AS BIGINT)                                                                                                            AS DISCOUNTMATRIXSEQUENCE3 
            ,CAST("T$DMSE$4" AS BIGINT)                                                                                                            AS DISCOUNTMATRIXSEQUENCE4 
            ,CAST("T$DMSE$5" AS BIGINT)                                                                                                            AS DISCOUNTMATRIXSEQUENCE5 
            ,"T$DMTY$1".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMATRIXTYPE1DESCRIPTION 
            ,CAST("T$DMTY$1" AS INT)                                                                                                               AS DISCOUNTMATRIXTYPE1ID 
            ,"T$DMTY$2".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMATRIXTYPE2DESCRIPTION 
            ,CAST("T$DMTY$2" AS INT)                                                                                                               AS DISCOUNTMATRIXTYPE2ID 
            ,"T$DMTY$3".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMATRIXTYPE3DESCRIPTION 
            ,CAST("T$DMTY$3" AS INT)                                                                                                               AS DISCOUNTMATRIXTYPE3ID 
            ,"T$DMTY$4".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMATRIXTYPE4DESCRIPTION 
            ,CAST("T$DMTY$4" AS INT)                                                                                                               AS DISCOUNTMATRIXTYPE4ID 
            ,"T$DMTY$5".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMATRIXTYPE5DESCRIPTION 
            ,CAST("T$DMTY$5" AS INT)                                                                                                               AS DISCOUNTMATRIXTYPE5ID 
            ,"T$DMTH$1".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD1DESCRIPTION 
            ,CAST("T$DMTH$1" AS INT)                                                                                                               AS DISCOUNTMETHOD1ID 
            ,"T$DMTH$2".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD2DESCRIPTION 
            ,CAST("T$DMTH$2" AS INT)                                                                                                               AS DISCOUNTMETHOD2ID 
            ,"T$DMTH$3".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD3DESCRIPTION 
            ,CAST("T$DMTH$3" AS INT)                                                                                                               AS DISCOUNTMETHOD3ID 
            ,"T$DMTH$4".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD4DESCRIPTION 
            ,CAST("T$DMTH$4" AS INT)                                                                                                               AS DISCOUNTMETHOD4ID 
            ,"T$DMTH$5".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD5DESCRIPTION 
            ,CAST("T$DMTH$5" AS INT)                                                                                                               AS DISCOUNTMETHOD5ID 
            ,CAST("T$DISC$1" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE1 
            ,CAST("T$DISC$2" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE2 
            ,CAST("T$DISC$3" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE3 
            ,CAST("T$DISC$4" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE4 
            ,CAST("T$DISC$5" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSPA)),'')                                                                                         AS ELEMENT 
            ,T$ELGB.CONSTANTDESCRIPTION                                                                                                          AS ELIGIBLEDESCRIPTION 
            ,CAST(T$ELGB AS INT)                                                                                                                 AS ELIGIBLEID 
            ,CAST(CASE WHEN T$EDAT<= '1/1/1970' THEN NULL ELSE T$EDAT  END AS DATETIME) AS ENDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS ENGINEERINGITEMREVISION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTL)),'')                                                                                         AS EXTENSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                         AS FORWARDINGAGENT 
            ,T$QUAL.CONSTANTDESCRIPTION                                                                                                          AS INSPECTIONDESCRIPTION 
            ,CAST(T$QUAL AS INT)                                                                                                                 AS INSPECTIONID 
            ,T$BTSP.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION 
            ,CAST(T$BTSP AS INT)                                                                                                                 AS INVENTORYPOSTINGSTATUSPURCHASEID 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME) AS INVOICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVN)),'')                                                                                         AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'')                                                                                         AS ITEMGROUP 
            ,CAST(T$LENG AS NUMERIC(15,2))                                                                                                       AS LENGTH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LOGINCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOT 
            ,T$LSEL.CONSTANTDESCRIPTION                                                                                                          AS LotSelectionDescription  
            ,CAST(T$LSEL AS INT)                                                                                                                 AS LotSelectionId  
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'')                                                                                         AS MANUFACTURER 
            ,CAST(T$OPNO AS INT)                                                                                                                 AS OPERATION 
            ,CAST("T$COOP$1" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS1 
            ,CAST("T$COOP$2" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS2 
            ,CAST("T$COOP$3" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS3 
            ,CAST(CASE WHEN T$DDTF<= '1/1/1970' THEN NULL ELSE T$DDTF  END AS DATETIME) AS ORDER_CONFIRMATIONDATE 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME) AS ORDER_DATE 
            ,CAST(T$OQUA AS NUMERIC(15,2))                                                                                                       AS ORDER_EDQUANTITY 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ORDER_LINETEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORPW)),'')                                                                                         AS ORDER_NUMBER 
            ,T$CORG.CONSTANTDESCRIPTION                                                                                                          AS ORIGINDESCRIPTION 
            ,CAST(T$CORG AS INT)                                                                                                                 AS ORIGINID 
            ,T$PCSR.CONSTANTDESCRIPTION                                                                                                          AS PCS_REVALUATIONDESCRIPTION 
            ,CAST(T$PCSR AS INT)                                                                                                                 AS PCS_REVALUATIONID 
            ,CAST(CASE WHEN T$DDTA<= '1/1/1970' THEN NULL ELSE T$DDTA  END AS DATETIME) AS PLANNEDDELIVERYDATE 
            ,CAST(T$OPON AS INT)                                                                                                                 AS POSITIONNUMBER_OPON 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER_PONO 
            ,CAST(T$POSI AS INT)                                                                                                                 AS POSITIONNUMBER_POSI 
            ,CAST(T$QPON AS INT)                                                                                                                 AS POSITIONNUMBER_QPON 
            ,CAST(T$SPON AS INT)                                                                                                                 AS POSITIONNUMBER_SPON 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMDE)),'')                                                                                         AS PRICEMATRIXDEFINITION 
            ,CAST(T$PMSE AS BIGINT)                                                                                                              AS PRICEMATRIXSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCL)),'')                                                                                         AS PRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDNO)),'')                                                                                         AS PRODUCTIONORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLN)),'')                                                                                         AS PRODUCTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                         AS PURCHASEACKNOWLEDGEMENTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PACN)),'')                                                                                         AS PURCHASELEDGERACCOUNTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCOF)),'')                                                                                         AS PURCHASEOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS PURCHASEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPP)),'')                                                                                         AS PURCHASEPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGP)),'')                                                                                         AS PURCHASESTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQP)),'')                                                                                         AS PURCHASEUNIT 
            ,CAST(T$QANA AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,CAST("T$RATP$1" AS NUMERIC(15,2))                                                                                                     AS RATE1 
            ,CAST("T$RATP$2" AS NUMERIC(15,2))                                                                                                     AS RATE2 
            ,CAST("T$RATP$3" AS NUMERIC(15,2))                                                                                                     AS RATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                         AS RATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREJ)),'')                                                                                         AS REASONFORREJECTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RENO)),'')                                                                                         AS RECEIPTNUMBERASN 
            ,T$CKOR.CONSTANTDESCRIPTION                                                                                                          AS RECORDTYPEDESCRIPTION 
            ,CAST(T$CKOR AS INT)                                                                                                                 AS RECORDTYPEID 
            ,CAST(T$QUAD AS NUMERIC(15,2))                                                                                                       AS REJECTEDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QONO)),'')                                                                                         AS REQUESTFORQUOTATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                         AS ROUTEPLAN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SORN)),'')                                                                                         AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SCHN)),'')                                                                                         AS SCHEDULENUMBER 
            ,CAST(T$SCPO AS INT)                                                                                                                 AS SCHEDULEPOSITIONNUMBER 
            ,CAST(T$REVN AS INT)                                                                                                                 AS SCHEDULEREVISIONNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEGC)),'')                                                                                         AS SEGMENTCODE 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,CAST(T$SERN AS BIGINT)                                                                                                              AS SEQUENCENUMBER_SERN 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCENUMBER_SQNB 
            ,CAST(T$SSEQ AS INT)                                                                                                                 AS SEQUENCENUMBER_SSEQ 
            ,CAST(T$SRPO AS INT)                                                                                                                 AS SERVICE_LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SRVO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFAD)),'')                                                                                         AS SHIPFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFBP)),'')                                                                                         AS SHIPFROMBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFCN)),'')                                                                                         AS SHIPFROMCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFWH)),'')                                                                                         AS SLSSFWH 
            ,CAST("T$COPR$1" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTPRICE1 
            ,CAST("T$COPR$2" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTPRICE2 
            ,CAST("T$COPR$3" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTPRICE3 
            ,T$SDSC.CONSTANTDESCRIPTION                                                                                                          AS STANDARDDESCRIPTIONDESCRIPTION 
            ,CAST(T$SDSC AS INT)                                                                                                                 AS STANDARDDESCRIPTIONID 
            ,CAST(CASE WHEN T$SDAT<= '1/1/1970' THEN NULL ELSE T$SDAT  END AS DATETIME) AS STARTDATE 
            ,T$STCD.CONSTANTDESCRIPTION                                                                                                          AS STATUSPROCESSEDDESCRIPTION 
            ,CAST(T$STCD AS INT)                                                                                                                 AS STATUSPROCESSEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,CAST(T$THIC AS NUMERIC(15,2))                                                                                                       AS THICKNESS 
            ,CAST(T$QUAP AS NUMERIC(15,2))                                                                                                       AS TOTALAPPROVEDQUANTITY 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,T$DEST.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFORDERDESCRIPTION 
            ,CAST(T$DEST AS INT)                                                                                                                 AS TYPEOFORDERID 
            ,T$VRPR.CONSTANTDESCRIPTION                                                                                                          AS VENDORRATINGPROCESSINGREQUIREDDESCRIPTION 
            ,CAST(T$VRPR AS INT)                                                                                                                 AS VENDORRATINGPROCESSINGREQUIREDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                         AS WAREHOUSEADDRESS 
            ,CAST(T$WIDT AS NUMERIC(15,2))                                                                                                       AS WIDTH 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPUR451201") }} AS SOURCETABLE  
            /*DETERMINING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTRM 
             ON   T$DTRM.TABLENAME  = 'TDPUR451' 
              AND T$DTRM.COLUMNNAME = 'T$DTRM' 
              AND T$DTRM.CONSTANT   = SOURCETABLE.T$DTRM 
            /*DISCOUNTMATRIXTYPE1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$1" 
             ON   "T$DMTY$1".TABLENAME  = 'TDPUR451' 
              AND "T$DMTY$1".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$1".CONSTANT   = SOURCETABLE."T$DMTY$1" 
            /*DISCOUNTMATRIXTYPE2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$2" 
             ON   "T$DMTY$2".TABLENAME  = 'TDPUR451' 
              AND "T$DMTY$2".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$2".CONSTANT   = SOURCETABLE."T$DMTY$2" 
            /*DISCOUNTMATRIXTYPE3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$3" 
             ON   "T$DMTY$3".TABLENAME  = 'TDPUR451' 
              AND "T$DMTY$3".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$3".CONSTANT   = SOURCETABLE."T$DMTY$3" 
            /*DISCOUNTMATRIXTYPE4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$4" 
             ON   "T$DMTY$4".TABLENAME  = 'TDPUR451' 
              AND "T$DMTY$4".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$4".CONSTANT   = SOURCETABLE."T$DMTY$4" 
            /*DISCOUNTMATRIXTYPE5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$5" 
             ON   "T$DMTY$5".TABLENAME  = 'TDPUR451' 
              AND "T$DMTY$5".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$5".CONSTANT   = SOURCETABLE."T$DMTY$5" 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$1" 
             ON   "T$DMTH$1".TABLENAME  = 'TDPUR451' 
              AND "T$DMTH$1".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$1".CONSTANT   = SOURCETABLE."T$DMTH$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$2" 
             ON   "T$DMTH$2".TABLENAME  = 'TDPUR451' 
              AND "T$DMTH$2".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$2".CONSTANT   = SOURCETABLE."T$DMTH$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$3" 
             ON   "T$DMTH$3".TABLENAME  = 'TDPUR451' 
              AND "T$DMTH$3".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$3".CONSTANT   = SOURCETABLE."T$DMTH$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$4" 
             ON   "T$DMTH$4".TABLENAME  = 'TDPUR451' 
              AND "T$DMTH$4".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$4".CONSTANT   = SOURCETABLE."T$DMTH$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$5" 
             ON   "T$DMTH$5".TABLENAME  = 'TDPUR451' 
              AND "T$DMTH$5".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$5".CONSTANT   = SOURCETABLE."T$DMTH$5" 
            /*ELIGIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ELGB 
             ON   T$ELGB.TABLENAME  = 'TDPUR451' 
              AND T$ELGB.COLUMNNAME = 'T$ELGB' 
              AND T$ELGB.CONSTANT   = SOURCETABLE.T$ELGB 
            /*INSPECTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QUAL 
             ON   T$QUAL.TABLENAME  = 'TDPUR451' 
              AND T$QUAL.COLUMNNAME = 'T$QUAL' 
              AND T$QUAL.CONSTANT   = SOURCETABLE.T$QUAL 
            /*INVENTORYPOSTINGSTATUSPURCHASE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BTSP 
             ON   T$BTSP.TABLENAME  = 'TDPUR451' 
              AND T$BTSP.COLUMNNAME = 'T$BTSP' 
              AND T$BTSP.CONSTANT   = SOURCETABLE.T$BTSP 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'TDPUR451' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*ORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CORG 
             ON   T$CORG.TABLENAME  = 'TDPUR451' 
              AND T$CORG.COLUMNNAME = 'T$CORG' 
              AND T$CORG.CONSTANT   = SOURCETABLE.T$CORG 
            /*PCS_REVALUATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PCSR 
             ON   T$PCSR.TABLENAME  = 'TDPUR451' 
              AND T$PCSR.COLUMNNAME = 'T$PCSR' 
              AND T$PCSR.CONSTANT   = SOURCETABLE.T$PCSR 
            /*RECORDTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CKOR 
             ON   T$CKOR.TABLENAME  = 'TDPUR451' 
              AND T$CKOR.COLUMNNAME = 'T$CKOR' 
              AND T$CKOR.CONSTANT   = SOURCETABLE.T$CKOR 
            /*STANDARDDESCRIPTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SDSC 
             ON   T$SDSC.TABLENAME  = 'TDPUR451' 
              AND T$SDSC.COLUMNNAME = 'T$SDSC' 
              AND T$SDSC.CONSTANT   = SOURCETABLE.T$SDSC 
            /*STATUSPROCESSED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STCD 
             ON   T$STCD.TABLENAME  = 'TDPUR451' 
              AND T$STCD.COLUMNNAME = 'T$STCD' 
              AND T$STCD.CONSTANT   = SOURCETABLE.T$STCD 
            /*TYPEOFORDER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEST 
             ON   T$DEST.TABLENAME  = 'TDPUR451' 
              AND T$DEST.COLUMNNAME = 'T$DEST' 
              AND T$DEST.CONSTANT   = SOURCETABLE.T$DEST 
            /*VENDORRATINGPROCESSINGREQUIRED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VRPR 
             ON   T$VRPR.TABLENAME  = 'TDPUR451' 
              AND T$VRPR.COLUMNNAME = 'T$VRPR' 
              AND T$VRPR.CONSTANT   = SOURCETABLE.T$VRPR 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.ACTUALDELIVERYDATE AS ACTUALDELIVERYDATE, 
        source_data.ALTERNATIVE AS ALTERNATIVE, 
        source_data.AMOUNT AS AMOUNT, 
        source_data.BPORDERREFERENCE AS BPORDERREFERENCE, 
        source_data.BUYFROM_PERCENT_BUSINESSPARTNER AS BUYFROM_PERCENT_BUSINESSPARTNER, 
        source_data.CHANGEDDELIVERYDATE AS CHANGEDDELIVERYDATE, 
        source_data.CHANGEORDERSEQNO AS CHANGEORDERSEQNO, 
        source_data.CHANGEREASONLINES AS CHANGEREASONLINES, 
        source_data.CHANGETYPELINES AS CHANGETYPELINES, 
        source_data.CODEITEMTYPE AS CODEITEMTYPE, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONFIRMEDDELIVERYDATE AS CONFIRMEDDELIVERYDATE, 
        source_data.CONTRACT AS CONTRACT, 
        source_data.CONVERSIONFACTORPRICETOINVENTORYUNIT AS CONVERSIONFACTORPRICETOINVENTORYUNIT, 
        source_data.CONVERSIONFACTORPURCHASETOINVENTORYUNIT AS CONVERSIONFACTORPURCHASETOINVENTORYUNIT, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.COUNTRY AS COUNTRY, 
        source_data.CURRENTPLANNEDDELIVERYDATE AS CURRENTPLANNEDDELIVERYDATE, 
        source_data.DETERMININGDESCRIPTION AS DETERMININGDESCRIPTION, 
        source_data.DETERMININGID AS DETERMININGID, 
        source_data.DIMENSION1 AS DIMENSION1, 
        source_data.DIMENSION2 AS DIMENSION2, 
        source_data.DIMENSION3 AS DIMENSION3, 
        source_data.DIMENSION4 AS DIMENSION4, 
        source_data.DIMENSION5 AS DIMENSION5, 
        source_data.DISCOUNTAMOUNT1 AS DISCOUNTAMOUNT1, 
        source_data.DISCOUNTAMOUNT2 AS DISCOUNTAMOUNT2, 
        source_data.DISCOUNTAMOUNT3 AS DISCOUNTAMOUNT3, 
        source_data.DISCOUNTAMOUNT4 AS DISCOUNTAMOUNT4, 
        source_data.DISCOUNTAMOUNT5 AS DISCOUNTAMOUNT5, 
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
        source_data.ELEMENT AS ELEMENT, 
        source_data.ELIGIBLEDESCRIPTION AS ELIGIBLEDESCRIPTION, 
        source_data.ELIGIBLEID AS ELIGIBLEID, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.ENGINEERINGITEMREVISION AS ENGINEERINGITEMREVISION, 
        source_data.EXTENSION AS EXTENSION, 
        source_data.FORWARDINGAGENT AS FORWARDINGAGENT, 
        source_data.INSPECTIONDESCRIPTION AS INSPECTIONDESCRIPTION, 
        source_data.INSPECTIONID AS INSPECTIONID, 
        source_data.INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION AS INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION, 
        source_data.INVENTORYPOSTINGSTATUSPURCHASEID AS INVENTORYPOSTINGSTATUSPURCHASEID, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMGROUP AS ITEMGROUP, 
        source_data.LENGTH AS LENGTH, 
        source_data.LOGINCODE AS LOGINCODE, 
        source_data.LOT AS LOT, 
        source_data.LOTSELECTIONDESCRIPTION AS LOTSELECTIONDESCRIPTION, 
        source_data.LOTSELECTIONID AS LOTSELECTIONID, 
        source_data.MANUFACTURER AS MANUFACTURER, 
        source_data.OPERATION AS OPERATION, 
        source_data.OPERATIONCOSTS1 AS OPERATIONCOSTS1, 
        source_data.OPERATIONCOSTS2 AS OPERATIONCOSTS2, 
        source_data.OPERATIONCOSTS3 AS OPERATIONCOSTS3, 
        source_data.ORDER_CONFIRMATIONDATE AS ORDER_CONFIRMATIONDATE, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_EDQUANTITY AS ORDER_EDQUANTITY, 
        source_data.ORDER_LINETEXT AS ORDER_LINETEXT, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.ORIGINDESCRIPTION AS ORIGINDESCRIPTION, 
        source_data.ORIGINID AS ORIGINID, 
        source_data.PCS_REVALUATIONDESCRIPTION AS PCS_REVALUATIONDESCRIPTION, 
        source_data.PCS_REVALUATIONID AS PCS_REVALUATIONID, 
        source_data.PLANNEDDELIVERYDATE AS PLANNEDDELIVERYDATE, 
        source_data.POSITIONNUMBER_OPON AS POSITIONNUMBER_OPON, 
        source_data.POSITIONNUMBER_PONO AS POSITIONNUMBER_PONO, 
        source_data.POSITIONNUMBER_POSI AS POSITIONNUMBER_POSI, 
        source_data.POSITIONNUMBER_QPON AS POSITIONNUMBER_QPON, 
        source_data.POSITIONNUMBER_SPON AS POSITIONNUMBER_SPON, 
        source_data.PRICE AS PRICE, 
        source_data.PRICEMATRIXDEFINITION AS PRICEMATRIXDEFINITION, 
        source_data.PRICEMATRIXSEQUENCE AS PRICEMATRIXSEQUENCE, 
        source_data.PRODUCTCLASS AS PRODUCTCLASS, 
        source_data.PRODUCTIONORDER AS PRODUCTIONORDER, 
        source_data.PRODUCTLINE AS PRODUCTLINE, 
        source_data.PROJECT AS PROJECT, 
        source_data.PURCHASEACKNOWLEDGEMENTCODE AS PURCHASEACKNOWLEDGEMENTCODE, 
        source_data.PURCHASELEDGERACCOUNTNUMBER AS PURCHASELEDGERACCOUNTNUMBER, 
        source_data.PURCHASEOFFICE AS PURCHASEOFFICE, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.PURCHASEPRICEUNIT AS PURCHASEPRICEUNIT, 
        source_data.PURCHASESTATISTICSGROUP AS PURCHASESTATISTICSGROUP, 
        source_data.PURCHASEUNIT AS PURCHASEUNIT, 
        source_data.QUANTITY AS QUANTITY, 
        source_data.RATE1 AS RATE1, 
        source_data.RATE2 AS RATE2, 
        source_data.RATE3 AS RATE3, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.RATETYPE AS RATETYPE, 
        source_data.REASONFORREJECTION AS REASONFORREJECTION, 
        source_data.RECEIPTNUMBERASN AS RECEIPTNUMBERASN, 
        source_data.RECORDTYPEDESCRIPTION AS RECORDTYPEDESCRIPTION, 
        source_data.RECORDTYPEID AS RECORDTYPEID, 
        source_data.REJECTEDQUANTITY AS REJECTEDQUANTITY, 
        source_data.REQUESTFORQUOTATION AS REQUESTFORQUOTATION, 
        source_data.ROUTEPLAN AS ROUTEPLAN, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SCHEDULENUMBER AS SCHEDULENUMBER, 
        source_data.SCHEDULEPOSITIONNUMBER AS SCHEDULEPOSITIONNUMBER, 
        source_data.SCHEDULEREVISIONNUMBER AS SCHEDULEREVISIONNUMBER, 
        source_data.SEGMENTCODE AS SEGMENTCODE, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.SEQUENCENUMBER_SERN AS SEQUENCENUMBER_SERN, 
        source_data.SEQUENCENUMBER_SQNB AS SEQUENCENUMBER_SQNB, 
        source_data.SEQUENCENUMBER_SSEQ AS SEQUENCENUMBER_SSEQ, 
        source_data.SERVICE_LINENUMBER AS SERVICE_LINENUMBER, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SHIPFROMADDRESS AS SHIPFROMADDRESS, 
        source_data.SHIPFROMBP AS SHIPFROMBP, 
        source_data.SHIPFROMCONTACT AS SHIPFROMCONTACT, 
        source_data.SLSSFWH AS SLSSFWH, 
        source_data.STANDARDCOSTPRICE1 AS STANDARDCOSTPRICE1, 
        source_data.STANDARDCOSTPRICE2 AS STANDARDCOSTPRICE2, 
        source_data.STANDARDCOSTPRICE3 AS STANDARDCOSTPRICE3, 
        source_data.STANDARDDESCRIPTIONDESCRIPTION AS STANDARDDESCRIPTIONDESCRIPTION, 
        source_data.STANDARDDESCRIPTIONID AS STANDARDDESCRIPTIONID, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.STATUSPROCESSEDDESCRIPTION AS STATUSPROCESSEDDESCRIPTION, 
        source_data.STATUSPROCESSEDID AS STATUSPROCESSEDID, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.THICKNESS AS THICKNESS, 
        source_data.TOTALAPPROVEDQUANTITY AS TOTALAPPROVEDQUANTITY, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.TYPEOFORDERDESCRIPTION AS TYPEOFORDERDESCRIPTION, 
        source_data.TYPEOFORDERID AS TYPEOFORDERID, 
        source_data.VENDORRATINGPROCESSINGREQUIREDDESCRIPTION AS VENDORRATINGPROCESSINGREQUIREDDESCRIPTION, 
        source_data.VENDORRATINGPROCESSINGREQUIREDID AS VENDORRATINGPROCESSINGREQUIREDID, 
        source_data.WAREHOUSE AS WAREHOUSE, 
        source_data.WAREHOUSEADDRESS AS WAREHOUSEADDRESS, 
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
        cast(ACTIVITY as VARCHAR(8)) as ACTIVITY,
        cast(ACTUALDELIVERYDATE as TIMESTAMP_NTZ(9)) as ACTUALDELIVERYDATE,
        cast(ALTERNATIVE as NUMBER(38,0)) as ALTERNATIVE,
        cast(AMOUNT as NUMBER(15,2)) as AMOUNT,
        cast(BPORDERREFERENCE as VARCHAR(30)) as BPORDERREFERENCE,
        cast(BUYFROM_PERCENT_BUSINESSPARTNER as VARCHAR(9)) as BUYFROM_PERCENT_BUSINESSPARTNER,
        cast(CHANGEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as CHANGEDDELIVERYDATE,
        cast(CHANGEORDERSEQNO as VARCHAR(8)) as CHANGEORDERSEQNO,
        cast(CHANGEREASONLINES as VARCHAR(6)) as CHANGEREASONLINES,
        cast(CHANGETYPELINES as VARCHAR(6)) as CHANGETYPELINES,
        cast(CODEITEMTYPE as VARCHAR(3)) as CODEITEMTYPE,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONFIRMEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as CONFIRMEDDELIVERYDATE,
        cast(CONTRACT as VARCHAR(9)) as CONTRACT,
        cast(CONVERSIONFACTORPRICETOINVENTORYUNIT as NUMBER(15,2)) as CONVERSIONFACTORPRICETOINVENTORYUNIT,
        cast(CONVERSIONFACTORPURCHASETOINVENTORYUNIT as NUMBER(15,2)) as CONVERSIONFACTORPURCHASETOINVENTORYUNIT,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(COUNTRY as VARCHAR(3)) as COUNTRY,
        cast(CURRENTPLANNEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as CURRENTPLANNEDDELIVERYDATE,
        cast(DETERMININGDESCRIPTION as VARCHAR(16777216)) as DETERMININGDESCRIPTION,
        cast(DETERMININGID as NUMBER(38,0)) as DETERMININGID,
        cast(DIMENSION1 as VARCHAR(6)) as DIMENSION1,
        cast(DIMENSION2 as VARCHAR(6)) as DIMENSION2,
        cast(DIMENSION3 as VARCHAR(6)) as DIMENSION3,
        cast(DIMENSION4 as VARCHAR(6)) as DIMENSION4,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(DISCOUNTAMOUNT1 as NUMBER(15,2)) as DISCOUNTAMOUNT1,
        cast(DISCOUNTAMOUNT2 as NUMBER(15,2)) as DISCOUNTAMOUNT2,
        cast(DISCOUNTAMOUNT3 as NUMBER(15,2)) as DISCOUNTAMOUNT3,
        cast(DISCOUNTAMOUNT4 as NUMBER(15,2)) as DISCOUNTAMOUNT4,
        cast(DISCOUNTAMOUNT5 as NUMBER(15,2)) as DISCOUNTAMOUNT5,
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
        cast(ELEMENT as VARCHAR(8)) as ELEMENT,
        cast(ELIGIBLEDESCRIPTION as VARCHAR(16777216)) as ELIGIBLEDESCRIPTION,
        cast(ELIGIBLEID as NUMBER(38,0)) as ELIGIBLEID,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(ENGINEERINGITEMREVISION as VARCHAR(6)) as ENGINEERINGITEMREVISION,
        cast(EXTENSION as VARCHAR(4)) as EXTENSION,
        cast(FORWARDINGAGENT as VARCHAR(3)) as FORWARDINGAGENT,
        cast(INSPECTIONDESCRIPTION as VARCHAR(16777216)) as INSPECTIONDESCRIPTION,
        cast(INSPECTIONID as NUMBER(38,0)) as INSPECTIONID,
        cast(INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION as VARCHAR(16777216)) as INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION,
        cast(INVENTORYPOSTINGSTATUSPURCHASEID as NUMBER(38,0)) as INVENTORYPOSTINGSTATUSPURCHASEID,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICENUMBER as VARCHAR(9)) as INVOICENUMBER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ITEMGROUP as VARCHAR(6)) as ITEMGROUP,
        cast(LENGTH as NUMBER(15,2)) as LENGTH,
        cast(LOGINCODE as VARCHAR(16)) as LOGINCODE,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(LOTSELECTIONDESCRIPTION as VARCHAR(16777216)) as LOTSELECTIONDESCRIPTION,
        cast(LOTSELECTIONID as NUMBER(38,0)) as LOTSELECTIONID,
        cast(MANUFACTURER as VARCHAR(6)) as MANUFACTURER,
        cast(OPERATION as NUMBER(38,0)) as OPERATION,
        cast(OPERATIONCOSTS1 as NUMBER(15,2)) as OPERATIONCOSTS1,
        cast(OPERATIONCOSTS2 as NUMBER(15,2)) as OPERATIONCOSTS2,
        cast(OPERATIONCOSTS3 as NUMBER(15,2)) as OPERATIONCOSTS3,
        cast(ORDER_CONFIRMATIONDATE as TIMESTAMP_NTZ(9)) as ORDER_CONFIRMATIONDATE,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_EDQUANTITY as NUMBER(15,2)) as ORDER_EDQUANTITY,
        cast(ORDER_LINETEXT as NUMBER(38,10)) as ORDER_LINETEXT,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORIGINDESCRIPTION as VARCHAR(16777216)) as ORIGINDESCRIPTION,
        cast(ORIGINID as NUMBER(38,0)) as ORIGINID,
        cast(PCS_REVALUATIONDESCRIPTION as VARCHAR(16777216)) as PCS_REVALUATIONDESCRIPTION,
        cast(PCS_REVALUATIONID as NUMBER(38,0)) as PCS_REVALUATIONID,
        cast(PLANNEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as PLANNEDDELIVERYDATE,
        cast(POSITIONNUMBER_OPON as NUMBER(38,0)) as POSITIONNUMBER_OPON,
        cast(POSITIONNUMBER_PONO as NUMBER(38,0)) as POSITIONNUMBER_PONO,
        cast(POSITIONNUMBER_POSI as NUMBER(38,0)) as POSITIONNUMBER_POSI,
        cast(POSITIONNUMBER_QPON as NUMBER(38,0)) as POSITIONNUMBER_QPON,
        cast(POSITIONNUMBER_SPON as NUMBER(38,0)) as POSITIONNUMBER_SPON,
        cast(PRICE as NUMBER(15,2)) as PRICE,
        cast(PRICEMATRIXDEFINITION as VARCHAR(6)) as PRICEMATRIXDEFINITION,
        cast(PRICEMATRIXSEQUENCE as NUMBER(38,0)) as PRICEMATRIXSEQUENCE,
        cast(PRODUCTCLASS as VARCHAR(6)) as PRODUCTCLASS,
        cast(PRODUCTIONORDER as VARCHAR(9)) as PRODUCTIONORDER,
        cast(PRODUCTLINE as VARCHAR(6)) as PRODUCTLINE,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(PURCHASEACKNOWLEDGEMENTCODE as VARCHAR(2)) as PURCHASEACKNOWLEDGEMENTCODE,
        cast(PURCHASELEDGERACCOUNTNUMBER as VARCHAR(12)) as PURCHASELEDGERACCOUNTNUMBER,
        cast(PURCHASEOFFICE as VARCHAR(6)) as PURCHASEOFFICE,
        cast(PURCHASEORDER as VARCHAR(9)) as PURCHASEORDER,
        cast(PURCHASEPRICEUNIT as VARCHAR(3)) as PURCHASEPRICEUNIT,
        cast(PURCHASESTATISTICSGROUP as VARCHAR(6)) as PURCHASESTATISTICSGROUP,
        cast(PURCHASEUNIT as VARCHAR(3)) as PURCHASEUNIT,
        cast(QUANTITY as NUMBER(15,2)) as QUANTITY,
        cast(RATE1 as NUMBER(15,2)) as RATE1,
        cast(RATE2 as NUMBER(15,2)) as RATE2,
        cast(RATE3 as NUMBER(15,2)) as RATE3,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(RATETYPE as VARCHAR(3)) as RATETYPE,
        cast(REASONFORREJECTION as VARCHAR(6)) as REASONFORREJECTION,
        cast(RECEIPTNUMBERASN as VARCHAR(16)) as RECEIPTNUMBERASN,
        cast(RECORDTYPEDESCRIPTION as VARCHAR(16777216)) as RECORDTYPEDESCRIPTION,
        cast(RECORDTYPEID as NUMBER(38,0)) as RECORDTYPEID,
        cast(REJECTEDQUANTITY as NUMBER(15,2)) as REJECTEDQUANTITY,
        cast(REQUESTFORQUOTATION as VARCHAR(9)) as REQUESTFORQUOTATION,
        cast(ROUTEPLAN as VARCHAR(3)) as ROUTEPLAN,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SCHEDULENUMBER as VARCHAR(9)) as SCHEDULENUMBER,
        cast(SCHEDULEPOSITIONNUMBER as NUMBER(38,0)) as SCHEDULEPOSITIONNUMBER,
        cast(SCHEDULEREVISIONNUMBER as NUMBER(38,0)) as SCHEDULEREVISIONNUMBER,
        cast(SEGMENTCODE as VARCHAR(3)) as SEGMENTCODE,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(SEQUENCENUMBER_SERN as NUMBER(38,0)) as SEQUENCENUMBER_SERN,
        cast(SEQUENCENUMBER_SQNB as NUMBER(38,0)) as SEQUENCENUMBER_SQNB,
        cast(SEQUENCENUMBER_SSEQ as NUMBER(38,0)) as SEQUENCENUMBER_SSEQ,
        cast(SERVICE_LINENUMBER as NUMBER(38,0)) as SERVICE_LINENUMBER,
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(SHIPFROMADDRESS as VARCHAR(9)) as SHIPFROMADDRESS,
        cast(SHIPFROMBP as VARCHAR(9)) as SHIPFROMBP,
        cast(SHIPFROMCONTACT as VARCHAR(9)) as SHIPFROMCONTACT,
        cast(SLSSFWH as VARCHAR(6)) as SLSSFWH,
        cast(STANDARDCOSTPRICE1 as NUMBER(15,2)) as STANDARDCOSTPRICE1,
        cast(STANDARDCOSTPRICE2 as NUMBER(15,2)) as STANDARDCOSTPRICE2,
        cast(STANDARDCOSTPRICE3 as NUMBER(15,2)) as STANDARDCOSTPRICE3,
        cast(STANDARDDESCRIPTIONDESCRIPTION as VARCHAR(16777216)) as STANDARDDESCRIPTIONDESCRIPTION,
        cast(STANDARDDESCRIPTIONID as NUMBER(38,0)) as STANDARDDESCRIPTIONID,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(STATUSPROCESSEDDESCRIPTION as VARCHAR(16777216)) as STATUSPROCESSEDDESCRIPTION,
        cast(STATUSPROCESSEDID as NUMBER(38,0)) as STATUSPROCESSEDID,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(THICKNESS as NUMBER(15,2)) as THICKNESS,
        cast(TOTALAPPROVEDQUANTITY as NUMBER(15,2)) as TOTALAPPROVEDQUANTITY,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(TYPEOFORDERDESCRIPTION as VARCHAR(16777216)) as TYPEOFORDERDESCRIPTION,
        cast(TYPEOFORDERID as NUMBER(38,0)) as TYPEOFORDERID,
        cast(VENDORRATINGPROCESSINGREQUIREDDESCRIPTION as VARCHAR(16777216)) as VENDORRATINGPROCESSINGREQUIREDDESCRIPTION,
        cast(VENDORRATINGPROCESSINGREQUIREDID as NUMBER(38,0)) as VENDORRATINGPROCESSINGREQUIREDID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(WAREHOUSEADDRESS as VARCHAR(9)) as WAREHOUSEADDRESS,
        cast(WIDTH as NUMBER(15,2)) as WIDTH,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data