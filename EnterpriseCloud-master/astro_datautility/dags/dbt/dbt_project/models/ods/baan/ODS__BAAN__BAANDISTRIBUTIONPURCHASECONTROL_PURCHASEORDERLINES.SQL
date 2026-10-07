/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERLINES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERLINES.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERLINES 
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
    alias='BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERLINES',
    unique_key = ['POSITIONNUMBER',
    'PURCHASEORDER',
    'SEQUENCENUMBER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CACT)),'')                                                                                             AS ACTIVITY 
            ,CAST(CASE WHEN T$DDTE<= '1/1/1970' THEN NULL ELSE T$DDTE  END AS DATETIME)     AS ACTUALDELIVERYDATE 
            ,CAST(T$BQUA AS NUMERIC(15,2))                                                                                                           AS BACKORDERQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                             AS BUYFROM_percent_BUSINESSPARTNER 
            ,T$CLYN.CONSTANTDESCRIPTION                                                                                                              AS CANCELLEDDESCRIPTION 
            ,CAST(T$CLYN AS INT)                                                                                                                     AS CANCELLEDID 
            ,CAST(CASE WHEN T$DDTD<= '1/1/1970' THEN NULL ELSE T$DDTD  END AS DATETIME)     AS CHANGEDDELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                             AS CHANGEORDERSEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                             AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                             AS CHANGETYPELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITT)),'')                                                                                             AS CODEITEMTYPE 
            ,CAST(CASE WHEN T$DDTC<= '1/1/1970' THEN NULL ELSE T$DDTC  END AS DATETIME)     AS CONFIRMEDDELIVERYDATE 
            ,CAST(T$CVPP AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORPRICETOINVENTORYUNIT 
            ,CAST(T$CVQP AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORPURCHASETOINVENTORYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCCO)),'')                                                                                             AS COSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                             AS COSTPRICECOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                             AS COUNTRY 
            ,CAST(CASE WHEN T$DDTB<= '1/1/1970' THEN NULL ELSE T$DDTB  END AS DATETIME)     AS CURRENTPLANNEDDELIVERYDATE 
            ,CAST(T$DAMT AS NUMERIC(15,2))                                                                                                           AS DELIVEREDAMOUNT 
            ,CAST(T$DQUA AS NUMERIC(15,2))                                                                                                           AS DELIVEREDQUANTITY 
            ,T$STSD.CONSTANTDESCRIPTION                                                                                                              AS DELIVERYSTATUSDESCRIPTION 
            ,CAST(T$STSD AS INT)                                                                                                                     AS DELIVERYSTATUSID 
            ,T$DTRM.CONSTANTDESCRIPTION                                                                                                              AS DETERMININGDESCRIPTION 
            ,CAST(T$DTRM AS INT)                                                                                                                     AS DETERMININGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM1)),'')                                                                                             AS DIMENSION1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                             AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                             AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                             AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                             AS DIMENSION5 
            ,CAST("T$LDAM$1" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT1 
            ,CAST("T$LDAM$2" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT2 
            ,CAST("T$LDAM$3" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT3 
            ,CAST("T$LDAM$4" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT4 
            ,CAST("T$LDAM$5" AS NUMERIC(15,2))                                                                                                         AS DISCOUNTAMOUNT5 
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
            ,CAST("T$DMSE$1" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXDEFINITION_DMSE_1 
            ,CAST("T$DMSE$2" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXDEFINITION_DMSE_2 
            ,CAST("T$DMSE$3" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXDEFINITION_DMSE_3 
            ,CAST("T$DMSE$4" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXDEFINITION_DMSE_4 
            ,CAST("T$DMSE$5" AS BIGINT)                                                                                                                AS DISCOUNTMATRIXDEFINITION_DMSE_5 
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
            ,CAST(CASE WHEN "T$ETAD$C"<= '1/1/1970' THEN NULL ELSE "T$ETAD$C"  END AS DATETIME) AS EDIEXTRACTDATE 
            ,"T$EGEN$C".CONSTANTDESCRIPTION                                                                                                            AS EDIGENERATEDDESCRIPTION 
            ,CAST("T$EGEN$C" AS INT)                                                                                                                   AS EDIGENERATEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSPA)),'')                                                                                             AS ELEMENT 
            ,T$ELGB.CONSTANTDESCRIPTION                                                                                                              AS ELIGIBLEDESCRIPTION 
            ,CAST(T$ELGB AS INT)                                                                                                                     AS ELIGIBLEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                             AS ENGINEERINGITEMREVISION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTL)),'')                                                                                             AS EXTENSION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                             AS FORWARDINGAGENT 
            ,T$QUAL.CONSTANTDESCRIPTION                                                                                                              AS INSPECTIONDESCRIPTION 
            ,CAST(T$QUAL AS INT)                                                                                                                     AS INSPECTIONID 
            ,T$BTSP.CONSTANTDESCRIPTION                                                                                                              AS INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION 
            ,CAST(T$BTSP AS INT)                                                                                                                     AS INVENTORYPOSTINGSTATUSPURCHASEID 
            ,CAST(T$IAMT AS NUMERIC(15,2))                                                                                                           AS INVOICEDAMOUNT 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME)     AS INVOICEDATE 
            ,CAST(T$IQAN AS NUMERIC(15,2))                                                                                                           AS INVOICEDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INVN)),'')                                                                                             AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                             AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'')                                                                                             AS ITEMGROUP 
            ,CAST(T$LENG AS NUMERIC(15,2))                                                                                                           AS LENGTH 
            ,CAST("T$DISC$1" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT1 
            ,CAST("T$DISC$2" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT2 
            ,CAST("T$DISC$3" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT3 
            ,CAST("T$DISC$4" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT4 
            ,CAST("T$DISC$5" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT5 
            ,CAST(T$LSEQ AS INT)                                                                                                                     AS LINKEDSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$Clot)),'')                                                                                             AS Lot 
            ,t$lsel.ConstantDescription                                                                                                              AS LotSelectionDescription 
            ,CAST(t$lsel AS INT)                                                                                                                     AS LotSelectionId 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'')                                                                                             AS MANUFACTURER 
            ,CAST("T$COOP$1" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS1 
            ,CAST("T$COOP$2" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS2 
            ,CAST("T$COOP$3" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS3 
            ,CAST(CASE WHEN T$DDTF<= '1/1/1970' THEN NULL ELSE T$DDTF  END AS DATETIME)     AS ORDER_CONFIRMATIONDATE 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME)     AS ORDER_DATE 
            ,CAST(T$AMOD AS NUMERIC(15,2))                                                                                                           AS ORDER_DISCOUNTAMOUNT 
            ,CAST(T$OAMT AS NUMERIC(15,2))                                                                                                           AS ORDER_EDAMOUNT 
            ,CAST(T$OQUA AS NUMERIC(15,2))                                                                                                           AS ORDER_EDQUANTITY 
            ,CAST(T$AMLD AS NUMERIC(15,2))                                                                                                           AS ORDER_LINEDISCOUNTAMOUNT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                         AS ORDER_LINETEXT 
            ,T$OLTP.CONSTANTDESCRIPTION                                                                                                              AS ORDER_LINETYPEDESCRIPTION 
            ,CAST(T$OLTP AS INT)                                                                                                                     AS ORDER_LINETYPEID 
            ,T$CORG.CONSTANTDESCRIPTION                                                                                                              AS ORIGINDESCRIPTION 
            ,CAST(T$CORG AS INT)                                                                                                                     AS ORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DINO)),'')                                                                                             AS PACKINGSLIPNUMBER 
            ,CAST(CASE WHEN T$DDTA<= '1/1/1970' THEN NULL ELSE T$DDTA  END AS DATETIME)     AS PLANNEDDELIVERYDATE 
            ,CAST(T$PONO AS INT)                                                                                                                     AS POSITIONNUMBER 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                           AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMDE)),'')                                                                                             AS PRICEMATRIXDEFINITION_PMDE 
            ,CAST(T$PMSE AS BIGINT)                                                                                                                  AS PRICEMATRIXDEFINITION_PMSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMSK)),'')                                                                                             AS PROCEDUREMASK 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCL)),'')                                                                                             AS PRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLN)),'')                                                                                             AS PRODUCTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                             AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                             AS PURCHASEACKNOWLEDGEMENTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PACN)),'')                                                                                             AS PURCHASELEDGERACCOUNTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                             AS PURCHASEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPP)),'')                                                                                             AS PURCHASEPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGP)),'')                                                                                             AS PURCHASESTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQP)),'')                                                                                             AS PURCHASEUNIT 
            ,CAST(T$DIQU AS NUMERIC(15,2))                                                                                                           AS QUANTITYONPACKINGSLIP 
            ,CAST("T$RATP$1" AS NUMERIC(15,2))                                                                                                         AS RATE1 
            ,CAST("T$RATP$2" AS NUMERIC(15,2))                                                                                                         AS RATE2 
            ,CAST("T$RATP$3" AS NUMERIC(15,2))                                                                                                         AS RATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME)     AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                                AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                                AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                                AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                             AS RATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREJ)),'')                                                                                             AS REASONFORREJECTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCNO)),'')                                                                                             AS RECEIPTNUMBER 
            ,CAST(T$QUAD AS NUMERIC(15,2))                                                                                                           AS REJECTEDQUANTITY 
            ,CAST(CASE WHEN T$RDTA<= '1/1/1970' THEN NULL ELSE T$RDTA  END AS DATETIME)     AS RELEASEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                             AS ROUTEPLAN 
            ,CAST(T$SQNB AS INT)                                                                                                                     AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFAD)),'')                                                                                             AS SHIPFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFBP)),'')                                                                                             AS SHIPFROMBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFCN)),'')                                                                                             AS SHIPFROMCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFWH)),'')                                                                                             AS SHIPFROMWAREHOUSE 
            ,CAST("T$COPR$1" AS NUMERIC(15,2))                                                                                                         AS STANDARDCOSTPRICE1 
            ,CAST("T$COPR$2" AS NUMERIC(15,2))                                                                                                         AS STANDARDCOSTPRICE2 
            ,CAST("T$COPR$3" AS NUMERIC(15,2))                                                                                                         AS STANDARDCOSTPRICE3 
            ,T$SDSC.CONSTANTDESCRIPTION                                                                                                              AS STANDARDDESCRIPTIONDESCRIPTION 
            ,CAST(T$SDSC AS INT)                                                                                                                     AS STANDARDDESCRIPTIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACTI)),'')                                                                                             AS STATUSPURCHASEORDERLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                             AS TAXCODE 
            ,CAST(T$THIC AS NUMERIC(15,2))                                                                                                           AS THICKNESS 
            ,CAST(T$QUAP AS NUMERIC(15,2))                                                                                                           AS TOTALAPPROVEDQUANTITY 
            ,T$STSC.CONSTANTDESCRIPTION                                                                                                              AS UPDATESTATUSOFACTUALPURCHASECOSTSDESCRIPTION 
            ,CAST(T$STSC AS INT)                                                                                                                     AS UPDATESTATUSOFACTUALPURCHASECOSTSID 
            ,T$VRYN.CONSTANTDESCRIPTION                                                                                                              AS VENDORRATINGDESCRIPTION 
            ,CAST(T$VRYN AS INT)                                                                                                                     AS VENDORRATINGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                             AS WAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                             AS WAREHOUSEADDRESS 
            ,CAST(T$WIDT AS NUMERIC(15,2))                                                                                                           AS WIDTH 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPUR401201") }} AS SOURCETABLE  
            /*CANCELLED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLYN 
             ON   T$CLYN.TABLENAME  = 'TDPUR401' 
              AND T$CLYN.COLUMNNAME = 'T$CLYN' 
              AND T$CLYN.CONSTANT   = SOURCETABLE.T$CLYN 
            /*DELIVERYSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STSD 
             ON   T$STSD.TABLENAME  = 'TDPUR401' 
              AND T$STSD.COLUMNNAME = 'T$STSD' 
              AND T$STSD.CONSTANT   = SOURCETABLE.T$STSD 
            /*DETERMINING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTRM 
             ON   T$DTRM.TABLENAME  = 'TDPUR401' 
              AND T$DTRM.COLUMNNAME = 'T$DTRM' 
              AND T$DTRM.CONSTANT   = SOURCETABLE.T$DTRM 
            /*DISCOUNTMATRIXTYPE1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$1" 
             ON   "T$DMTY$1".TABLENAME  = 'TDPUR401' 
              AND "T$DMTY$1".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$1".CONSTANT   = SOURCETABLE."T$DMTY$1" 
            /*DISCOUNTMATRIXTYPE2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$2" 
             ON   "T$DMTY$2".TABLENAME  = 'TDPUR401' 
              AND "T$DMTY$2".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$2".CONSTANT   = SOURCETABLE."T$DMTY$2" 
            /*DISCOUNTMATRIXTYPE3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$3" 
             ON   "T$DMTY$3".TABLENAME  = 'TDPUR401' 
              AND "T$DMTY$3".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$3".CONSTANT   = SOURCETABLE."T$DMTY$3" 
            /*DISCOUNTMATRIXTYPE4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$4" 
             ON   "T$DMTY$4".TABLENAME  = 'TDPUR401' 
              AND "T$DMTY$4".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$4".CONSTANT   = SOURCETABLE."T$DMTY$4" 
            /*DISCOUNTMATRIXTYPE5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$5" 
             ON   "T$DMTY$5".TABLENAME  = 'TDPUR401' 
              AND "T$DMTY$5".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$5".CONSTANT   = SOURCETABLE."T$DMTY$5" 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$1" 
             ON   "T$DMTH$1".TABLENAME  = 'TDPUR401' 
              AND "T$DMTH$1".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$1".CONSTANT   = SOURCETABLE."T$DMTH$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$2" 
             ON   "T$DMTH$2".TABLENAME  = 'TDPUR401' 
              AND "T$DMTH$2".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$2".CONSTANT   = SOURCETABLE."T$DMTH$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$3" 
             ON   "T$DMTH$3".TABLENAME  = 'TDPUR401' 
              AND "T$DMTH$3".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$3".CONSTANT   = SOURCETABLE."T$DMTH$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$4" 
             ON   "T$DMTH$4".TABLENAME  = 'TDPUR401' 
              AND "T$DMTH$4".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$4".CONSTANT   = SOURCETABLE."T$DMTH$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$5" 
             ON   "T$DMTH$5".TABLENAME  = 'TDPUR401' 
              AND "T$DMTH$5".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$5".CONSTANT   = SOURCETABLE."T$DMTH$5" 
            /*EDIGENERATEDC*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$EGEN$C" 
             ON   "T$EGEN$C".TABLENAME  = 'TDPUR401' 
              AND "T$EGEN$C".COLUMNNAME = 'T$EGEN.C' 
              AND "T$EGEN$C".CONSTANT   = SOURCETABLE."T$EGEN$C" 
            /*ELIGIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ELGB 
             ON   T$ELGB.TABLENAME  = 'TDPUR401' 
              AND T$ELGB.COLUMNNAME = 'T$ELGB' 
              AND T$ELGB.CONSTANT   = SOURCETABLE.T$ELGB 
            /*INSPECTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QUAL 
             ON   T$QUAL.TABLENAME  = 'TDPUR401' 
              AND T$QUAL.COLUMNNAME = 'T$QUAL' 
              AND T$QUAL.CONSTANT   = SOURCETABLE.T$QUAL 
            /*INVENTORYPOSTINGSTATUSPURCHASE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BTSP 
             ON   T$BTSP.TABLENAME  = 'TDPUR401' 
              AND T$BTSP.COLUMNNAME = 'T$BTSP' 
              AND T$BTSP.CONSTANT   = SOURCETABLE.T$BTSP 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'TDPUR401' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*ORDERLINETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OLTP 
             ON   T$OLTP.TABLENAME  = 'TDPUR401' 
              AND T$OLTP.COLUMNNAME = 'T$OLTP' 
              AND T$OLTP.CONSTANT   = SOURCETABLE.T$OLTP 
            /*ORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CORG 
             ON   T$CORG.TABLENAME  = 'TDPUR401' 
              AND T$CORG.COLUMNNAME = 'T$CORG' 
              AND T$CORG.CONSTANT   = SOURCETABLE.T$CORG 
            /*STANDARDDESCRIPTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SDSC 
             ON   T$SDSC.TABLENAME  = 'TDPUR401' 
              AND T$SDSC.COLUMNNAME = 'T$SDSC' 
              AND T$SDSC.CONSTANT   = SOURCETABLE.T$SDSC 
            /*UPDATESTATUSOFACTUALPURCHASECOSTS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STSC 
             ON   T$STSC.TABLENAME  = 'TDPUR401' 
              AND T$STSC.COLUMNNAME = 'T$STSC' 
              AND T$STSC.CONSTANT   = SOURCETABLE.T$STSC 
            /*VENDORRATING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VRYN 
             ON   T$VRYN.TABLENAME  = 'TDPUR401' 
              AND T$VRYN.COLUMNNAME = 'T$VRYN' 
              AND T$VRYN.CONSTANT   = SOURCETABLE.T$VRYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.ACTUALDELIVERYDATE AS ACTUALDELIVERYDATE, 
        source_data.BACKORDERQUANTITY AS BACKORDERQUANTITY, 
        source_data.BUYFROM_PERCENT_BUSINESSPARTNER AS BUYFROM_PERCENT_BUSINESSPARTNER, 
        source_data.CANCELLEDDESCRIPTION AS CANCELLEDDESCRIPTION, 
        source_data.CANCELLEDID AS CANCELLEDID, 
        source_data.CHANGEDDELIVERYDATE AS CHANGEDDELIVERYDATE, 
        source_data.CHANGEORDERSEQUENCENUMBER AS CHANGEORDERSEQUENCENUMBER, 
        source_data.CHANGEREASONLINES AS CHANGEREASONLINES, 
        source_data.CHANGETYPELINES AS CHANGETYPELINES, 
        source_data.CODEITEMTYPE AS CODEITEMTYPE, 
        source_data.CONFIRMEDDELIVERYDATE AS CONFIRMEDDELIVERYDATE, 
        source_data.CONVERSIONFACTORPRICETOINVENTORYUNIT AS CONVERSIONFACTORPRICETOINVENTORYUNIT, 
        source_data.CONVERSIONFACTORPURCHASETOINVENTORYUNIT AS CONVERSIONFACTORPURCHASETOINVENTORYUNIT, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.COSTPRICECOMPONENT AS COSTPRICECOMPONENT, 
        source_data.COUNTRY AS COUNTRY, 
        source_data.CURRENTPLANNEDDELIVERYDATE AS CURRENTPLANNEDDELIVERYDATE, 
        source_data.DELIVEREDAMOUNT AS DELIVEREDAMOUNT, 
        source_data.DELIVEREDQUANTITY AS DELIVEREDQUANTITY, 
        source_data.DELIVERYSTATUSDESCRIPTION AS DELIVERYSTATUSDESCRIPTION, 
        source_data.DELIVERYSTATUSID AS DELIVERYSTATUSID, 
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
        source_data.DISCOUNTMATRIXDEFINITION_DMSE_1 AS DISCOUNTMATRIXDEFINITION_DMSE_1, 
        source_data.DISCOUNTMATRIXDEFINITION_DMSE_2 AS DISCOUNTMATRIXDEFINITION_DMSE_2, 
        source_data.DISCOUNTMATRIXDEFINITION_DMSE_3 AS DISCOUNTMATRIXDEFINITION_DMSE_3, 
        source_data.DISCOUNTMATRIXDEFINITION_DMSE_4 AS DISCOUNTMATRIXDEFINITION_DMSE_4, 
        source_data.DISCOUNTMATRIXDEFINITION_DMSE_5 AS DISCOUNTMATRIXDEFINITION_DMSE_5, 
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
        source_data.EDIEXTRACTDATE AS EDIEXTRACTDATE, 
        source_data.EDIGENERATEDDESCRIPTION AS EDIGENERATEDDESCRIPTION, 
        source_data.EDIGENERATEDID AS EDIGENERATEDID, 
        source_data.ELEMENT AS ELEMENT, 
        source_data.ELIGIBLEDESCRIPTION AS ELIGIBLEDESCRIPTION, 
        source_data.ELIGIBLEID AS ELIGIBLEID, 
        source_data.ENGINEERINGITEMREVISION AS ENGINEERINGITEMREVISION, 
        source_data.EXTENSION AS EXTENSION, 
        source_data.FORWARDINGAGENT AS FORWARDINGAGENT, 
        source_data.INSPECTIONDESCRIPTION AS INSPECTIONDESCRIPTION, 
        source_data.INSPECTIONID AS INSPECTIONID, 
        source_data.INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION AS INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION, 
        source_data.INVENTORYPOSTINGSTATUSPURCHASEID AS INVENTORYPOSTINGSTATUSPURCHASEID, 
        source_data.INVOICEDAMOUNT AS INVOICEDAMOUNT, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICEDQUANTITY AS INVOICEDQUANTITY, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMGROUP AS ITEMGROUP, 
        source_data.LENGTH AS LENGTH, 
        source_data.LINEDISCOUNT1 AS LINEDISCOUNT1, 
        source_data.LINEDISCOUNT2 AS LINEDISCOUNT2, 
        source_data.LINEDISCOUNT3 AS LINEDISCOUNT3, 
        source_data.LINEDISCOUNT4 AS LINEDISCOUNT4, 
        source_data.LINEDISCOUNT5 AS LINEDISCOUNT5, 
        source_data.LINKEDSEQUENCE AS LINKEDSEQUENCE, 
        source_data.LOT AS LOT, 
        source_data.LOTSELECTIONDESCRIPTION AS LOTSELECTIONDESCRIPTION, 
        source_data.LOTSELECTIONID AS LOTSELECTIONID, 
        source_data.MANUFACTURER AS MANUFACTURER, 
        source_data.OPERATIONCOSTS1 AS OPERATIONCOSTS1, 
        source_data.OPERATIONCOSTS2 AS OPERATIONCOSTS2, 
        source_data.OPERATIONCOSTS3 AS OPERATIONCOSTS3, 
        source_data.ORDER_CONFIRMATIONDATE AS ORDER_CONFIRMATIONDATE, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_DISCOUNTAMOUNT AS ORDER_DISCOUNTAMOUNT, 
        source_data.ORDER_EDAMOUNT AS ORDER_EDAMOUNT, 
        source_data.ORDER_EDQUANTITY AS ORDER_EDQUANTITY, 
        source_data.ORDER_LINEDISCOUNTAMOUNT AS ORDER_LINEDISCOUNTAMOUNT, 
        source_data.ORDER_LINETEXT AS ORDER_LINETEXT, 
        source_data.ORDER_LINETYPEDESCRIPTION AS ORDER_LINETYPEDESCRIPTION, 
        source_data.ORDER_LINETYPEID AS ORDER_LINETYPEID, 
        source_data.ORIGINDESCRIPTION AS ORIGINDESCRIPTION, 
        source_data.ORIGINID AS ORIGINID, 
        source_data.PACKINGSLIPNUMBER AS PACKINGSLIPNUMBER, 
        source_data.PLANNEDDELIVERYDATE AS PLANNEDDELIVERYDATE, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.PRICE AS PRICE, 
        source_data.PRICEMATRIXDEFINITION_PMDE AS PRICEMATRIXDEFINITION_PMDE, 
        source_data.PRICEMATRIXDEFINITION_PMSE AS PRICEMATRIXDEFINITION_PMSE, 
        source_data.PROCEDUREMASK AS PROCEDUREMASK, 
        source_data.PRODUCTCLASS AS PRODUCTCLASS, 
        source_data.PRODUCTLINE AS PRODUCTLINE, 
        source_data.PROJECT AS PROJECT, 
        source_data.PURCHASEACKNOWLEDGEMENTCODE AS PURCHASEACKNOWLEDGEMENTCODE, 
        source_data.PURCHASELEDGERACCOUNTNUMBER AS PURCHASELEDGERACCOUNTNUMBER, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.PURCHASEPRICEUNIT AS PURCHASEPRICEUNIT, 
        source_data.PURCHASESTATISTICSGROUP AS PURCHASESTATISTICSGROUP, 
        source_data.PURCHASEUNIT AS PURCHASEUNIT, 
        source_data.QUANTITYONPACKINGSLIP AS QUANTITYONPACKINGSLIP, 
        source_data.RATE1 AS RATE1, 
        source_data.RATE2 AS RATE2, 
        source_data.RATE3 AS RATE3, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.RATETYPE AS RATETYPE, 
        source_data.REASONFORREJECTION AS REASONFORREJECTION, 
        source_data.RECEIPTNUMBER AS RECEIPTNUMBER, 
        source_data.REJECTEDQUANTITY AS REJECTEDQUANTITY, 
        source_data.RELEASEDATE AS RELEASEDATE, 
        source_data.ROUTEPLAN AS ROUTEPLAN, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SHIPFROMADDRESS AS SHIPFROMADDRESS, 
        source_data.SHIPFROMBP AS SHIPFROMBP, 
        source_data.SHIPFROMCONTACT AS SHIPFROMCONTACT, 
        source_data.SHIPFROMWAREHOUSE AS SHIPFROMWAREHOUSE, 
        source_data.STANDARDCOSTPRICE1 AS STANDARDCOSTPRICE1, 
        source_data.STANDARDCOSTPRICE2 AS STANDARDCOSTPRICE2, 
        source_data.STANDARDCOSTPRICE3 AS STANDARDCOSTPRICE3, 
        source_data.STANDARDDESCRIPTIONDESCRIPTION AS STANDARDDESCRIPTIONDESCRIPTION, 
        source_data.STANDARDDESCRIPTIONID AS STANDARDDESCRIPTIONID, 
        source_data.STATUSPURCHASEORDERLINE AS STATUSPURCHASEORDERLINE, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.THICKNESS AS THICKNESS, 
        source_data.TOTALAPPROVEDQUANTITY AS TOTALAPPROVEDQUANTITY, 
        source_data.UPDATESTATUSOFACTUALPURCHASECOSTSDESCRIPTION AS UPDATESTATUSOFACTUALPURCHASECOSTSDESCRIPTION, 
        source_data.UPDATESTATUSOFACTUALPURCHASECOSTSID AS UPDATESTATUSOFACTUALPURCHASECOSTSID, 
        source_data.VENDORRATINGDESCRIPTION AS VENDORRATINGDESCRIPTION, 
        source_data.VENDORRATINGID AS VENDORRATINGID, 
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
        cast(BACKORDERQUANTITY as NUMBER(15,2)) as BACKORDERQUANTITY,
        cast(BUYFROM_PERCENT_BUSINESSPARTNER as VARCHAR(9)) as BUYFROM_PERCENT_BUSINESSPARTNER,
        cast(CANCELLEDDESCRIPTION as VARCHAR(16777216)) as CANCELLEDDESCRIPTION,
        cast(CANCELLEDID as NUMBER(38,0)) as CANCELLEDID,
        cast(CHANGEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as CHANGEDDELIVERYDATE,
        cast(CHANGEORDERSEQUENCENUMBER as VARCHAR(8)) as CHANGEORDERSEQUENCENUMBER,
        cast(CHANGEREASONLINES as VARCHAR(6)) as CHANGEREASONLINES,
        cast(CHANGETYPELINES as VARCHAR(6)) as CHANGETYPELINES,
        cast(CODEITEMTYPE as VARCHAR(3)) as CODEITEMTYPE,
        cast(CONFIRMEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as CONFIRMEDDELIVERYDATE,
        cast(CONVERSIONFACTORPRICETOINVENTORYUNIT as NUMBER(15,2)) as CONVERSIONFACTORPRICETOINVENTORYUNIT,
        cast(CONVERSIONFACTORPURCHASETOINVENTORYUNIT as NUMBER(15,2)) as CONVERSIONFACTORPURCHASETOINVENTORYUNIT,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(COSTPRICECOMPONENT as VARCHAR(8)) as COSTPRICECOMPONENT,
        cast(COUNTRY as VARCHAR(3)) as COUNTRY,
        cast(CURRENTPLANNEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as CURRENTPLANNEDDELIVERYDATE,
        cast(DELIVEREDAMOUNT as NUMBER(15,2)) as DELIVEREDAMOUNT,
        cast(DELIVEREDQUANTITY as NUMBER(15,2)) as DELIVEREDQUANTITY,
        cast(DELIVERYSTATUSDESCRIPTION as VARCHAR(16777216)) as DELIVERYSTATUSDESCRIPTION,
        cast(DELIVERYSTATUSID as NUMBER(38,0)) as DELIVERYSTATUSID,
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
        cast(DISCOUNTMATRIXDEFINITION_DMSE_1 as NUMBER(38,0)) as DISCOUNTMATRIXDEFINITION_DMSE_1,
        cast(DISCOUNTMATRIXDEFINITION_DMSE_2 as NUMBER(38,0)) as DISCOUNTMATRIXDEFINITION_DMSE_2,
        cast(DISCOUNTMATRIXDEFINITION_DMSE_3 as NUMBER(38,0)) as DISCOUNTMATRIXDEFINITION_DMSE_3,
        cast(DISCOUNTMATRIXDEFINITION_DMSE_4 as NUMBER(38,0)) as DISCOUNTMATRIXDEFINITION_DMSE_4,
        cast(DISCOUNTMATRIXDEFINITION_DMSE_5 as NUMBER(38,0)) as DISCOUNTMATRIXDEFINITION_DMSE_5,
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
        cast(EDIEXTRACTDATE as TIMESTAMP_NTZ(9)) as EDIEXTRACTDATE,
        cast(EDIGENERATEDDESCRIPTION as VARCHAR(16777216)) as EDIGENERATEDDESCRIPTION,
        cast(EDIGENERATEDID as NUMBER(38,0)) as EDIGENERATEDID,
        cast(ELEMENT as VARCHAR(8)) as ELEMENT,
        cast(ELIGIBLEDESCRIPTION as VARCHAR(16777216)) as ELIGIBLEDESCRIPTION,
        cast(ELIGIBLEID as NUMBER(38,0)) as ELIGIBLEID,
        cast(ENGINEERINGITEMREVISION as VARCHAR(6)) as ENGINEERINGITEMREVISION,
        cast(EXTENSION as VARCHAR(4)) as EXTENSION,
        cast(FORWARDINGAGENT as VARCHAR(3)) as FORWARDINGAGENT,
        cast(INSPECTIONDESCRIPTION as VARCHAR(16777216)) as INSPECTIONDESCRIPTION,
        cast(INSPECTIONID as NUMBER(38,0)) as INSPECTIONID,
        cast(INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION as VARCHAR(16777216)) as INVENTORYPOSTINGSTATUSPURCHASEDESCRIPTION,
        cast(INVENTORYPOSTINGSTATUSPURCHASEID as NUMBER(38,0)) as INVENTORYPOSTINGSTATUSPURCHASEID,
        cast(INVOICEDAMOUNT as NUMBER(15,2)) as INVOICEDAMOUNT,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICEDQUANTITY as NUMBER(15,2)) as INVOICEDQUANTITY,
        cast(INVOICENUMBER as VARCHAR(9)) as INVOICENUMBER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ITEMGROUP as VARCHAR(6)) as ITEMGROUP,
        cast(LENGTH as NUMBER(15,2)) as LENGTH,
        cast(LINEDISCOUNT1 as NUMBER(15,2)) as LINEDISCOUNT1,
        cast(LINEDISCOUNT2 as NUMBER(15,2)) as LINEDISCOUNT2,
        cast(LINEDISCOUNT3 as NUMBER(15,2)) as LINEDISCOUNT3,
        cast(LINEDISCOUNT4 as NUMBER(15,2)) as LINEDISCOUNT4,
        cast(LINEDISCOUNT5 as NUMBER(15,2)) as LINEDISCOUNT5,
        cast(LINKEDSEQUENCE as NUMBER(38,0)) as LINKEDSEQUENCE,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(LOTSELECTIONDESCRIPTION as VARCHAR(16777216)) as LOTSELECTIONDESCRIPTION,
        cast(LOTSELECTIONID as NUMBER(38,0)) as LOTSELECTIONID,
        cast(MANUFACTURER as VARCHAR(6)) as MANUFACTURER,
        cast(OPERATIONCOSTS1 as NUMBER(15,2)) as OPERATIONCOSTS1,
        cast(OPERATIONCOSTS2 as NUMBER(15,2)) as OPERATIONCOSTS2,
        cast(OPERATIONCOSTS3 as NUMBER(15,2)) as OPERATIONCOSTS3,
        cast(ORDER_CONFIRMATIONDATE as TIMESTAMP_NTZ(9)) as ORDER_CONFIRMATIONDATE,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_DISCOUNTAMOUNT as NUMBER(15,2)) as ORDER_DISCOUNTAMOUNT,
        cast(ORDER_EDAMOUNT as NUMBER(15,2)) as ORDER_EDAMOUNT,
        cast(ORDER_EDQUANTITY as NUMBER(15,2)) as ORDER_EDQUANTITY,
        cast(ORDER_LINEDISCOUNTAMOUNT as NUMBER(15,2)) as ORDER_LINEDISCOUNTAMOUNT,
        cast(ORDER_LINETEXT as NUMBER(38,10)) as ORDER_LINETEXT,
        cast(ORDER_LINETYPEDESCRIPTION as VARCHAR(16777216)) as ORDER_LINETYPEDESCRIPTION,
        cast(ORDER_LINETYPEID as NUMBER(38,0)) as ORDER_LINETYPEID,
        cast(ORIGINDESCRIPTION as VARCHAR(16777216)) as ORIGINDESCRIPTION,
        cast(ORIGINID as NUMBER(38,0)) as ORIGINID,
        cast(PACKINGSLIPNUMBER as VARCHAR(30)) as PACKINGSLIPNUMBER,
        cast(PLANNEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as PLANNEDDELIVERYDATE,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(PRICE as NUMBER(15,2)) as PRICE,
        cast(PRICEMATRIXDEFINITION_PMDE as VARCHAR(6)) as PRICEMATRIXDEFINITION_PMDE,
        cast(PRICEMATRIXDEFINITION_PMSE as NUMBER(38,0)) as PRICEMATRIXDEFINITION_PMSE,
        cast(PROCEDUREMASK as VARCHAR(20)) as PROCEDUREMASK,
        cast(PRODUCTCLASS as VARCHAR(6)) as PRODUCTCLASS,
        cast(PRODUCTLINE as VARCHAR(6)) as PRODUCTLINE,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(PURCHASEACKNOWLEDGEMENTCODE as VARCHAR(2)) as PURCHASEACKNOWLEDGEMENTCODE,
        cast(PURCHASELEDGERACCOUNTNUMBER as VARCHAR(12)) as PURCHASELEDGERACCOUNTNUMBER,
        cast(PURCHASEORDER as VARCHAR(9)) as PURCHASEORDER,
        cast(PURCHASEPRICEUNIT as VARCHAR(3)) as PURCHASEPRICEUNIT,
        cast(PURCHASESTATISTICSGROUP as VARCHAR(6)) as PURCHASESTATISTICSGROUP,
        cast(PURCHASEUNIT as VARCHAR(3)) as PURCHASEUNIT,
        cast(QUANTITYONPACKINGSLIP as NUMBER(15,2)) as QUANTITYONPACKINGSLIP,
        cast(RATE1 as NUMBER(15,2)) as RATE1,
        cast(RATE2 as NUMBER(15,2)) as RATE2,
        cast(RATE3 as NUMBER(15,2)) as RATE3,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(RATETYPE as VARCHAR(3)) as RATETYPE,
        cast(REASONFORREJECTION as VARCHAR(6)) as REASONFORREJECTION,
        cast(RECEIPTNUMBER as VARCHAR(9)) as RECEIPTNUMBER,
        cast(REJECTEDQUANTITY as NUMBER(15,2)) as REJECTEDQUANTITY,
        cast(RELEASEDATE as TIMESTAMP_NTZ(9)) as RELEASEDATE,
        cast(ROUTEPLAN as VARCHAR(3)) as ROUTEPLAN,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SHIPFROMADDRESS as VARCHAR(9)) as SHIPFROMADDRESS,
        cast(SHIPFROMBP as VARCHAR(9)) as SHIPFROMBP,
        cast(SHIPFROMCONTACT as VARCHAR(9)) as SHIPFROMCONTACT,
        cast(SHIPFROMWAREHOUSE as VARCHAR(6)) as SHIPFROMWAREHOUSE,
        cast(STANDARDCOSTPRICE1 as NUMBER(15,2)) as STANDARDCOSTPRICE1,
        cast(STANDARDCOSTPRICE2 as NUMBER(15,2)) as STANDARDCOSTPRICE2,
        cast(STANDARDCOSTPRICE3 as NUMBER(15,2)) as STANDARDCOSTPRICE3,
        cast(STANDARDDESCRIPTIONDESCRIPTION as VARCHAR(16777216)) as STANDARDDESCRIPTIONDESCRIPTION,
        cast(STANDARDDESCRIPTIONID as NUMBER(38,0)) as STANDARDDESCRIPTIONID,
        cast(STATUSPURCHASEORDERLINE as VARCHAR(20)) as STATUSPURCHASEORDERLINE,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(THICKNESS as NUMBER(15,2)) as THICKNESS,
        cast(TOTALAPPROVEDQUANTITY as NUMBER(15,2)) as TOTALAPPROVEDQUANTITY,
        cast(UPDATESTATUSOFACTUALPURCHASECOSTSDESCRIPTION as VARCHAR(16777216)) as UPDATESTATUSOFACTUALPURCHASECOSTSDESCRIPTION,
        cast(UPDATESTATUSOFACTUALPURCHASECOSTSID as NUMBER(38,0)) as UPDATESTATUSOFACTUALPURCHASECOSTSID,
        cast(VENDORRATINGDESCRIPTION as VARCHAR(16777216)) as VENDORRATINGDESCRIPTION,
        cast(VENDORRATINGID as NUMBER(38,0)) as VENDORRATINGID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(WAREHOUSEADDRESS as VARCHAR(9)) as WAREHOUSEADDRESS,
        cast(WIDTH as NUMBER(15,2)) as WIDTH,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data