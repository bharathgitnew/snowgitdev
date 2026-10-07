/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINES.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINES 
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
    alias='BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINES',
    unique_key = ['POSITIONNUMBER',
    'SALESORDER',
    'SEQUENCENUMBER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,200                                                                                                                                       AS _COMPANYID 
            ,CAST(T$DAMT AS NUMERIC(15,2))                                                                                                           AS AMOUNT_DAMT 
            ,CAST(T$OAMT AS NUMERIC(15,2))                                                                                                           AS AMOUNT_OAMT 
            ,CAST(T$BQUA AS NUMERIC(15,2))                                                                                                           AS BACKORDERQUANTITY 
            ,T$BQCO.CONSTANTDESCRIPTION                                                                                                              AS BACKORDERQUANTITYCONFIRMEDDESCRIPTION 
            ,CAST(T$BQCO AS INT)                                                                                                                     AS BACKORDERQUANTITYCONFIRMEDID 
            ,CAST("T$BAPR$U" AS NUMERIC(15,2))                                                                                                         AS BASEPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$BCUR$U")),'')                                                                                           AS BASEPRICECURRENCY 
            ,T$BKYN.CONSTANTDESCRIPTION                                                                                                              AS BLOCKEDDESCRIPTION 
            ,CAST(T$BKYN AS INT)                                                                                                                     AS BLOCKEDID 
            ,T$CLYN.CONSTANTDESCRIPTION                                                                                                              AS CANCELLEDDESCRIPTION 
            ,CAST(T$CLYN AS INT)                                                                                                                     AS CANCELLEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                             AS CHANGEORDERSEQNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                             AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                             AS CHANGETYPELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHAN)),'')                                                                                             AS CHANNELS 
            ,CAST(CASE WHEN "T$CDAT$U"<= '1/1/1970' THEN NULL ELSE "T$CDAT$U"  END AS DATETIME) AS COMMITDATE 
            ,CAST(T$COMQ AS NUMERIC(15,2))                                                                                                           AS COMMITTED 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORPRICETOINVENTORYUNIT 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORSALESTOINVENTORYUNIT 
            ,CAST("T$COPR$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOFODSSOLD1 
            ,CAST("T$COPR$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOFODSSOLD2 
            ,CAST("T$COPR$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOFODSSOLD3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                             AS COSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                             AS COUNTRY 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                         AS CURRENCYRATESALES1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                         AS CURRENCYRATESALES2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                         AS CURRENCYRATESALES3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACTI)),'')                                                                                             AS CURRENTACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                             AS CUSTOMERORDERNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORP)),'')                                                                                             AS CUSTOMERORDERPOSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORS)),'')                                                                                             AS CUSTOMERORDERSEQUENCE 
            ,CAST(CASE WHEN "T$CREQ$U"<= '1/1/1970' THEN NULL ELSE "T$CREQ$U"  END AS DATETIME) AS CUSTREQDELDATE 
            ,CAST("T$DISP$U" AS NUMERIC(15,2))                                                                                                         AS DCPRICE 
            ,CAST(T$DQUA AS NUMERIC(15,2))                                                                                                           AS DELIVEREDQUANTITY 
            ,CAST(CASE WHEN T$DLDT<= '1/1/1970' THEN NULL ELSE T$DLDT  END AS DATETIME)     AS DELIVERYDATE 
            ,T$DTRM.CONSTANTDESCRIPTION                                                                                                              AS DETERMININGDESCRIPTION 
            ,CAST(T$DTRM AS INT)                                                                                                                     AS DETERMININGID 
            ,T$DRCT.CONSTANTDESCRIPTION                                                                                                              AS DIRECTDELIVERYDESCRIPTION 
            ,CAST(T$DRCT AS INT)                                                                                                                     AS DIRECTDELIVERYID 
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
            ,T$ELGB.CONSTANTDESCRIPTION                                                                                                              AS ELIGIBLEDESCRIPTION 
            ,CAST(T$ELGB AS INT)                                                                                                                     AS ELIGIBLEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                             AS ENGINEERINGITEMREVISION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                             AS EXCHANGERATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                             AS FORWARDINGAGENT 
            ,CAST(T$XLKY AS NUMERIC(15,2))                                                                                                           AS FRONTOFFICEORDERLINE 
            ,CAST("T$FCOP$1" AS NUMERIC(15,2))                                                                                                         AS FULLSTANDARDCOSTAMOUNT1 
            ,CAST("T$FCOP$2" AS NUMERIC(15,2))                                                                                                         AS FULLSTANDARDCOSTAMOUNT2 
            ,CAST("T$FCOP$3" AS NUMERIC(15,2))                                                                                                         AS FULLSTANDARDCOSTAMOUNT3 
            ,T$ISSS.CONSTANTDESCRIPTION                                                                                                              AS INVENTORYISSUESTATUSDESCRIPTION 
            ,CAST(T$ISSS AS INT)                                                                                                                     AS INVENTORYISSUESTATUSID 
            ,CAST(T$SCMP AS INT)                                                                                                                     AS INVOICECOMPANY 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME)     AS INVOICEDATE 
            ,CAST(T$INVN AS BIGINT)                                                                                                                  AS INVOICENUMBERRETURN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                             AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITT)),'')                                                                                             AS ITEMCODESYSTEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'')                                                                                             AS ITEMGROUP 
            ,CAST(T$LENG AS NUMERIC(15,2))                                                                                                           AS LENGTH 
            ,CAST("T$DISC$1" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT1 
            ,CAST("T$DISC$2" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT2 
            ,CAST("T$DISC$3" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT3 
            ,CAST("T$DISC$4" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT4 
            ,CAST("T$DISC$5" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT5 
            ,CAST(T$LSEQ AS INT)                                                                                                                     AS LINKEDSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$LOGN$U")),'')                                                                                           AS LOGINCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                             AS LOT 
            ,T$LSEL.CONSTANTDESCRIPTION                                                                                                              AS LotSelectionDescription  
            ,CAST(T$LSEL AS INT)                                                                                                                     AS LotSelectionId  
            ,T$OPOL.CONSTANTDESCRIPTION                                                                                                              AS MAKECUSTOMIZEDDESCRIPTION 
            ,CAST(T$OPOL AS INT)                                                                                                                     AS MAKECUSTOMIZEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'')                                                                                             AS MANUFACTURER 
            ,CAST("T$COOP$1" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS1 
            ,CAST("T$COOP$2" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS2 
            ,CAST("T$COOP$3" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS3 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME)     AS ORDER_DATE 
            ,CAST(T$AMOD AS NUMERIC(15,2))                                                                                                           AS ORDER_DISCOUNTAMOUNT 
            ,CAST(T$OQUA AS NUMERIC(15,2))                                                                                                           AS ORDER_EDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ORTP$U")),'')                                                                                           AS ORDER_ENTRYMETHOD 
            ,CAST(T$AMLD AS NUMERIC(15,2))                                                                                                           AS ORDER_LINEDISCOUNTAMOUNT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                         AS ORDER_LINETEXT 
            ,T$OLTP.CONSTANTDESCRIPTION                                                                                                              AS ORDER_LINETYPEDESCRIPTION 
            ,CAST(T$OLTP AS INT)                                                                                                                     AS ORDER_LINETYPEID 
            ,CAST(T$OPRI AS BIGINT)                                                                                                                  AS ORDER_PRIORITY_OPRI 
            ,"T$PRIO$U".CONSTANTDESCRIPTION                                                                                                            AS ORDER_PRIORITY_PRIO_UDESCRIPTION 
            ,CAST("T$PRIO$U" AS INT)                                                                                                                   AS ORDER_PRIORITY_PRIO_UID 
            ,T$OPRS.CONSTANTDESCRIPTION                                                                                                              AS ORDER_PROMISINGSTATUSDESCRIPTION 
            ,CAST(T$OPRS AS INT)                                                                                                                     AS ORDER_PROMISINGSTATUSID 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME)     AS PLANNED_percent_RECEIPT 
            ,CAST(CASE WHEN T$DDTA<= '1/1/1970' THEN NULL ELSE T$DDTA  END AS DATETIME)     AS PLANNEDDELIVERYDATE 
            ,CAST(T$PONO AS INT)                                                                                                                     AS POSITIONNUMBER 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                           AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMDE)),'')                                                                                             AS PRICEMATRIXDEFINITION 
            ,CAST(T$PMSE AS BIGINT)                                                                                                                  AS PRICEMATRIXSEQUENCE 
            ,T$PROR.CONSTANTDESCRIPTION                                                                                                              AS PRICEORIGINDESCRIPTION 
            ,CAST(T$PROR AS INT)                                                                                                                     AS PRICEORIGINID 
            ,"T$PRSC$U".CONSTANTDESCRIPTION                                                                                                            AS PRICESOURCEDESCRIPTION 
            ,CAST("T$PRSC$U" AS INT)                                                                                                                   AS PRICESOURCEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMSK)),'')                                                                                             AS PROCEDUREMASK 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCL)),'')                                                                                             AS PRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLN)),'')                                                                                             AS PRODUCTLINE 
            ,CAST(T$CPVA AS BIGINT)                                                                                                                  AS PRODUCTVARIANT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                             AS PROJECT 
            ,T$BIND.CONSTANTDESCRIPTION                                                                                                              AS QUANTITYUNITBINDINGDESCRIPTION 
            ,CAST(T$BIND AS INT)                                                                                                                     AS QUANTITYUNITBINDINGID 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME)     AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                                AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                                AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                                AS RATEFACTOR3 
            ,CAST(CASE WHEN T$RDTA<= '1/1/1970' THEN NULL ELSE T$RDTA  END AS DATETIME)     AS RELEASEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'')                                                                                             AS ROUTE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                             AS ROUTEPLAN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                             AS SALESACKNOWLEDGEMENTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                             AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                             AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGS)),'')                                                                                             AS SALESSTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                             AS SALESUNIT 
            ,CAST(T$SQNB AS INT)                                                                                                                     AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SERL$U")),'')                                                                                           AS SERIALNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFWH)),'')                                                                                             AS SHIPFROMWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                             AS SHIPMENTID 
            ,T$SCON.CONSTANTDESCRIPTION                                                                                                              AS SHIPPINGCONSTRAINTDESCRIPTION 
            ,CAST(T$SCON AS INT)                                                                                                                     AS SHIPPINGCONSTRAINTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                             AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                             AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCN)),'')                                                                                             AS SHIPTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                             AS SOLDTOBUSINESSPARTNER 
            ,T$SDSC.CONSTANTDESCRIPTION                                                                                                              AS STANDARDDESCRIPTIONDESCRIPTION 
            ,CAST(T$SDSC AS INT)                                                                                                                     AS STANDARDDESCRIPTIONID 
            ,CAST(T$STDC AS NUMERIC(15,2))                                                                                                           AS STRUCTUREDISCOUNT 
            ,CAST(T$STPR AS NUMERIC(15,2))                                                                                                           AS STRUCTUREPRICE 
            ,CAST(T$SUSI AS INT)                                                                                                                     AS SUPPLYINGSITE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                             AS TAXCODE 
            ,CAST(T$THIC AS NUMERIC(15,2))                                                                                                           AS THICKNESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                             AS TRANSACTIONTYPE 
            ,CAST("T$UNIP$U" AS NUMERIC(15,2))                                                                                                         AS UNITPRICE 
            ,CAST("T$VCOP$1" AS NUMERIC(15,2))                                                                                                         AS VARIABLESTANDARDCOSTAMOUNT1 
            ,CAST("T$VCOP$2" AS NUMERIC(15,2))                                                                                                         AS VARIABLESTANDARDCOSTAMOUNT2 
            ,CAST("T$VCOP$3" AS NUMERIC(15,2))                                                                                                         AS VARIABLESTANDARDCOSTAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                             AS WAREHOUSE 
            ,CAST(T$WIDT AS NUMERIC(15,2))                                                                                                           AS WIDTH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                             AS WORKCENTER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDSLS401200") }} AS SOURCETABLE  
            /*BACKORDERQUANTITYCONFIRMED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BQCO 
             ON   T$BQCO.TABLENAME  = 'TDSLS401' 
              AND T$BQCO.COLUMNNAME = 'T$BQCO' 
              AND T$BQCO.CONSTANT   = SOURCETABLE.T$BQCO 
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BKYN 
             ON   T$BKYN.TABLENAME  = 'TDSLS401' 
              AND T$BKYN.COLUMNNAME = 'T$BKYN' 
              AND T$BKYN.CONSTANT   = SOURCETABLE.T$BKYN 
            /*CANCELLED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLYN 
             ON   T$CLYN.TABLENAME  = 'TDSLS401' 
              AND T$CLYN.COLUMNNAME = 'T$CLYN' 
              AND T$CLYN.CONSTANT   = SOURCETABLE.T$CLYN 
            /*DETERMINING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTRM 
             ON   T$DTRM.TABLENAME  = 'TDSLS401' 
              AND T$DTRM.COLUMNNAME = 'T$DTRM' 
              AND T$DTRM.CONSTANT   = SOURCETABLE.T$DTRM 
            /*DIRECTDELIVERY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DRCT 
             ON   T$DRCT.TABLENAME  = 'TDSLS401' 
              AND T$DRCT.COLUMNNAME = 'T$DRCT' 
              AND T$DRCT.CONSTANT   = SOURCETABLE.T$DRCT 
            /*DISCOUNTMATRIXTYPE1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$1" 
             ON   "T$DMTY$1".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$1".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$1".CONSTANT   = SOURCETABLE."T$DMTY$1" 
            /*DISCOUNTMATRIXTYPE2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$2" 
             ON   "T$DMTY$2".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$2".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$2".CONSTANT   = SOURCETABLE."T$DMTY$2" 
            /*DISCOUNTMATRIXTYPE3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$3" 
             ON   "T$DMTY$3".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$3".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$3".CONSTANT   = SOURCETABLE."T$DMTY$3" 
            /*DISCOUNTMATRIXTYPE4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$4" 
             ON   "T$DMTY$4".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$4".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$4".CONSTANT   = SOURCETABLE."T$DMTY$4" 
            /*DISCOUNTMATRIXTYPE5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$5" 
             ON   "T$DMTY$5".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$5".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$5".CONSTANT   = SOURCETABLE."T$DMTY$5" 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$1" 
             ON   "T$DMTH$1".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$1".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$1".CONSTANT   = SOURCETABLE."T$DMTH$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$2" 
             ON   "T$DMTH$2".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$2".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$2".CONSTANT   = SOURCETABLE."T$DMTH$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$3" 
             ON   "T$DMTH$3".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$3".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$3".CONSTANT   = SOURCETABLE."T$DMTH$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$4" 
             ON   "T$DMTH$4".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$4".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$4".CONSTANT   = SOURCETABLE."T$DMTH$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$5" 
             ON   "T$DMTH$5".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$5".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$5".CONSTANT   = SOURCETABLE."T$DMTH$5" 
            /*ELIGIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ELGB 
             ON   T$ELGB.TABLENAME  = 'TDSLS401' 
              AND T$ELGB.COLUMNNAME = 'T$ELGB' 
              AND T$ELGB.CONSTANT   = SOURCETABLE.T$ELGB 
            /*INVENTORYISSUESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISSS 
             ON   T$ISSS.TABLENAME  = 'TDSLS401' 
              AND T$ISSS.COLUMNNAME = 'T$ISSS' 
              AND T$ISSS.CONSTANT   = SOURCETABLE.T$ISSS 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'TDSLS401' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*MAKECUSTOMIZED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPOL 
             ON   T$OPOL.TABLENAME  = 'TDSLS401' 
              AND T$OPOL.COLUMNNAME = 'T$OPOL' 
              AND T$OPOL.CONSTANT   = SOURCETABLE.T$OPOL 
            /*ORDERLINETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OLTP 
             ON   T$OLTP.TABLENAME  = 'TDSLS401' 
              AND T$OLTP.COLUMNNAME = 'T$OLTP' 
              AND T$OLTP.CONSTANT   = SOURCETABLE.T$OLTP 
            /*ORDERPRIORITYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRIO$U" 
             ON   "T$PRIO$U".TABLENAME  = 'TDSLS401' 
              AND "T$PRIO$U".COLUMNNAME = 'T$PRIO.U' 
              AND "T$PRIO$U".CONSTANT   = SOURCETABLE."T$PRIO$U" 
            /*ORDERPROMISINGSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPRS 
             ON   T$OPRS.TABLENAME  = 'TDSLS401' 
              AND T$OPRS.COLUMNNAME = 'T$OPRS' 
              AND T$OPRS.CONSTANT   = SOURCETABLE.T$OPRS 
            /*PRICEORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PROR 
             ON   T$PROR.TABLENAME  = 'TDSLS401' 
              AND T$PROR.COLUMNNAME = 'T$PROR' 
              AND T$PROR.CONSTANT   = SOURCETABLE.T$PROR 
            /*PRICESOURCEU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRSC$U" 
             ON   "T$PRSC$U".TABLENAME  = 'TDSLS401' 
              AND "T$PRSC$U".COLUMNNAME = 'T$PRSC.U' 
              AND "T$PRSC$U".CONSTANT   = SOURCETABLE."T$PRSC$U" 
            /*QUANTITYUNITBINDING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BIND 
             ON   T$BIND.TABLENAME  = 'TDSLS401' 
              AND T$BIND.COLUMNNAME = 'T$BIND' 
              AND T$BIND.CONSTANT   = SOURCETABLE.T$BIND 
            /*SHIPPINGCONSTRAINT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCON 
             ON   T$SCON.TABLENAME  = 'TDSLS401' 
              AND T$SCON.COLUMNNAME = 'T$SCON' 
              AND T$SCON.CONSTANT   = SOURCETABLE.T$SCON 
            /*STANDARDDESCRIPTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SDSC 
             ON   T$SDSC.TABLENAME  = 'TDSLS401' 
              AND T$SDSC.COLUMNNAME = 'T$SDSC' 
              AND T$SDSC.CONSTANT   = SOURCETABLE.T$SDSC 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,CAST(T$DAMT AS NUMERIC(15,2))                                                                                                           AS AMOUNT_DAMT 
            ,CAST(T$OAMT AS NUMERIC(15,2))                                                                                                           AS AMOUNT_OAMT 
            ,CAST(T$BQUA AS NUMERIC(15,2))                                                                                                           AS BACKORDERQUANTITY 
            ,T$BQCO.CONSTANTDESCRIPTION                                                                                                              AS BACKORDERQUANTITYCONFIRMEDDESCRIPTION 
            ,CAST(T$BQCO AS INT)                                                                                                                     AS BACKORDERQUANTITYCONFIRMEDID 
            ,CAST("T$BAPR$U" AS NUMERIC(15,2))                                                                                                         AS BASEPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$BCUR$U")),'')                                                                                           AS BASEPRICECURRENCY 
            ,T$BKYN.CONSTANTDESCRIPTION                                                                                                              AS BLOCKEDDESCRIPTION 
            ,CAST(T$BKYN AS INT)                                                                                                                     AS BLOCKEDID 
            ,T$CLYN.CONSTANTDESCRIPTION                                                                                                              AS CANCELLEDDESCRIPTION 
            ,CAST(T$CLYN AS INT)                                                                                                                     AS CANCELLEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                             AS CHANGEORDERSEQNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                             AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                             AS CHANGETYPELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHAN)),'')                                                                                             AS CHANNELS 
            ,CAST(CASE WHEN "T$CDAT$U"<= '1/1/1970' THEN NULL ELSE "T$CDAT$U"  END AS DATETIME) AS COMMITDATE 
            ,CAST(T$COMQ AS NUMERIC(15,2))                                                                                                           AS COMMITTED 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORPRICETOINVENTORYUNIT 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                           AS CONVERSIONFACTORSALESTOINVENTORYUNIT 
            ,CAST("T$COPR$1" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOFODSSOLD1 
            ,CAST("T$COPR$2" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOFODSSOLD2 
            ,CAST("T$COPR$3" AS NUMERIC(15,2))                                                                                                         AS COSTAMOUNTOFODSSOLD3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                             AS COSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                             AS COUNTRY 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                         AS CURRENCYRATESALES1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                         AS CURRENCYRATESALES2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                         AS CURRENCYRATESALES3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACTI)),'')                                                                                             AS CURRENTACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                             AS CUSTOMERORDERNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORP)),'')                                                                                             AS CUSTOMERORDERPOSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORS)),'')                                                                                             AS CUSTOMERORDERSEQUENCE 
            ,CAST(CASE WHEN "T$CREQ$U"<= '1/1/1970' THEN NULL ELSE "T$CREQ$U"  END AS DATETIME) AS CUSTREQDELDATE 
            ,CAST("T$DISP$U" AS NUMERIC(15,2))                                                                                                         AS DCPRICE 
            ,CAST(T$DQUA AS NUMERIC(15,2))                                                                                                           AS DELIVEREDQUANTITY 
            ,CAST(CASE WHEN T$DLDT<= '1/1/1970' THEN NULL ELSE T$DLDT  END AS DATETIME)     AS DELIVERYDATE 
            ,T$DTRM.CONSTANTDESCRIPTION                                                                                                              AS DETERMININGDESCRIPTION 
            ,CAST(T$DTRM AS INT)                                                                                                                     AS DETERMININGID 
            ,T$DRCT.CONSTANTDESCRIPTION                                                                                                              AS DIRECTDELIVERYDESCRIPTION 
            ,CAST(T$DRCT AS INT)                                                                                                                     AS DIRECTDELIVERYID 
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
            ,T$ELGB.CONSTANTDESCRIPTION                                                                                                              AS ELIGIBLEDESCRIPTION 
            ,CAST(T$ELGB AS INT)                                                                                                                     AS ELIGIBLEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                             AS ENGINEERINGITEMREVISION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                             AS EXCHANGERATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                             AS FORWARDINGAGENT 
            ,CAST(T$XLKY AS NUMERIC(15,2))                                                                                                           AS FRONTOFFICEORDERLINE 
            ,CAST("T$FCOP$1" AS NUMERIC(15,2))                                                                                                         AS FULLSTANDARDCOSTAMOUNT1 
            ,CAST("T$FCOP$2" AS NUMERIC(15,2))                                                                                                         AS FULLSTANDARDCOSTAMOUNT2 
            ,CAST("T$FCOP$3" AS NUMERIC(15,2))                                                                                                         AS FULLSTANDARDCOSTAMOUNT3 
            ,T$ISSS.CONSTANTDESCRIPTION                                                                                                              AS INVENTORYISSUESTATUSDESCRIPTION 
            ,CAST(T$ISSS AS INT)                                                                                                                     AS INVENTORYISSUESTATUSID 
            ,CAST(T$SCMP AS INT)                                                                                                                     AS INVOICECOMPANY 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME)     AS INVOICEDATE 
            ,CAST(T$INVN AS BIGINT)                                                                                                                  AS INVOICENUMBERRETURN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                             AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITT)),'')                                                                                             AS ITEMCODESYSTEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'')                                                                                             AS ITEMGROUP 
            ,CAST(T$LENG AS NUMERIC(15,2))                                                                                                           AS LENGTH 
            ,CAST("T$DISC$1" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT1 
            ,CAST("T$DISC$2" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT2 
            ,CAST("T$DISC$3" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT3 
            ,CAST("T$DISC$4" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT4 
            ,CAST("T$DISC$5" AS NUMERIC(15,2))                                                                                                         AS LINEDISCOUNT5 
            ,CAST(T$LSEQ AS INT)                                                                                                                     AS LINKEDSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$LOGN$U")),'')                                                                                           AS LOGINCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                             AS LOT 
            ,T$LSEL.CONSTANTDESCRIPTION                                                                                                              AS LotSelectionDescription  
            ,CAST(T$LSEL AS INT)                                                                                                                     AS LotSelectionId  
            ,T$OPOL.CONSTANTDESCRIPTION                                                                                                              AS MAKECUSTOMIZEDDESCRIPTION 
            ,CAST(T$OPOL AS INT)                                                                                                                     AS MAKECUSTOMIZEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'')                                                                                             AS MANUFACTURER 
            ,CAST("T$COOP$1" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS1 
            ,CAST("T$COOP$2" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS2 
            ,CAST("T$COOP$3" AS NUMERIC(15,2))                                                                                                         AS OPERATIONCOSTS3 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME)     AS ORDER_DATE 
            ,CAST(T$AMOD AS NUMERIC(15,2))                                                                                                           AS ORDER_DISCOUNTAMOUNT 
            ,CAST(T$OQUA AS NUMERIC(15,2))                                                                                                           AS ORDER_EDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ORTP$U")),'')                                                                                           AS ORDER_ENTRYMETHOD 
            ,CAST(T$AMLD AS NUMERIC(15,2))                                                                                                           AS ORDER_LINEDISCOUNTAMOUNT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                         AS ORDER_LINETEXT 
            ,T$OLTP.CONSTANTDESCRIPTION                                                                                                              AS ORDER_LINETYPEDESCRIPTION 
            ,CAST(T$OLTP AS INT)                                                                                                                     AS ORDER_LINETYPEID 
            ,CAST(T$OPRI AS BIGINT)                                                                                                                  AS ORDER_PRIORITY_OPRI 
            ,"T$PRIO$U".CONSTANTDESCRIPTION                                                                                                            AS ORDER_PRIORITY_PRIO_UDESCRIPTION 
            ,CAST("T$PRIO$U" AS INT)                                                                                                                   AS ORDER_PRIORITY_PRIO_UID 
            ,T$OPRS.CONSTANTDESCRIPTION                                                                                                              AS ORDER_PROMISINGSTATUSDESCRIPTION 
            ,CAST(T$OPRS AS INT)                                                                                                                     AS ORDER_PROMISINGSTATUSID 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME)     AS PLANNED_percent_RECEIPT 
            ,CAST(CASE WHEN T$DDTA<= '1/1/1970' THEN NULL ELSE T$DDTA  END AS DATETIME)     AS PLANNEDDELIVERYDATE 
            ,CAST(T$PONO AS INT)                                                                                                                     AS POSITIONNUMBER 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                           AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMDE)),'')                                                                                             AS PRICEMATRIXDEFINITION 
            ,CAST(T$PMSE AS BIGINT)                                                                                                                  AS PRICEMATRIXSEQUENCE 
            ,T$PROR.CONSTANTDESCRIPTION                                                                                                              AS PRICEORIGINDESCRIPTION 
            ,CAST(T$PROR AS INT)                                                                                                                     AS PRICEORIGINID 
            ,"T$PRSC$U".CONSTANTDESCRIPTION                                                                                                            AS PRICESOURCEDESCRIPTION 
            ,CAST("T$PRSC$U" AS INT)                                                                                                                   AS PRICESOURCEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMSK)),'')                                                                                             AS PROCEDUREMASK 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCL)),'')                                                                                             AS PRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLN)),'')                                                                                             AS PRODUCTLINE 
            ,CAST(T$CPVA AS BIGINT)                                                                                                                  AS PRODUCTVARIANT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                             AS PROJECT 
            ,T$BIND.CONSTANTDESCRIPTION                                                                                                              AS QUANTITYUNITBINDINGDESCRIPTION 
            ,CAST(T$BIND AS INT)                                                                                                                     AS QUANTITYUNITBINDINGID 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME)     AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                                AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                                AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                                AS RATEFACTOR3 
            ,CAST(CASE WHEN T$RDTA<= '1/1/1970' THEN NULL ELSE T$RDTA  END AS DATETIME)     AS RELEASEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'')                                                                                             AS ROUTE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                             AS ROUTEPLAN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                             AS SALESACKNOWLEDGEMENTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                             AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                             AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGS)),'')                                                                                             AS SALESSTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                             AS SALESUNIT 
            ,CAST(T$SQNB AS INT)                                                                                                                     AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SERL$U")),'')                                                                                           AS SERIALNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFWH)),'')                                                                                             AS SHIPFROMWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                             AS SHIPMENTID 
            ,T$SCON.CONSTANTDESCRIPTION                                                                                                              AS SHIPPINGCONSTRAINTDESCRIPTION 
            ,CAST(T$SCON AS INT)                                                                                                                     AS SHIPPINGCONSTRAINTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                             AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                             AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCN)),'')                                                                                             AS SHIPTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                             AS SOLDTOBUSINESSPARTNER 
            ,T$SDSC.CONSTANTDESCRIPTION                                                                                                              AS STANDARDDESCRIPTIONDESCRIPTION 
            ,CAST(T$SDSC AS INT)                                                                                                                     AS STANDARDDESCRIPTIONID 
            ,CAST(T$STDC AS NUMERIC(15,2))                                                                                                           AS STRUCTUREDISCOUNT 
            ,CAST(T$STPR AS NUMERIC(15,2))                                                                                                           AS STRUCTUREPRICE 
            ,CAST(T$SUSI AS INT)                                                                                                                     AS SUPPLYINGSITE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                             AS TAXCODE 
            ,CAST(T$THIC AS NUMERIC(15,2))                                                                                                           AS THICKNESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                             AS TRANSACTIONTYPE 
            ,CAST("T$UNIP$U" AS NUMERIC(15,2))                                                                                                         AS UNITPRICE 
            ,CAST("T$VCOP$1" AS NUMERIC(15,2))                                                                                                         AS VARIABLESTANDARDCOSTAMOUNT1 
            ,CAST("T$VCOP$2" AS NUMERIC(15,2))                                                                                                         AS VARIABLESTANDARDCOSTAMOUNT2 
            ,CAST("T$VCOP$3" AS NUMERIC(15,2))                                                                                                         AS VARIABLESTANDARDCOSTAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                             AS WAREHOUSE 
            ,CAST(T$WIDT AS NUMERIC(15,2))                                                                                                           AS WIDTH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                             AS WORKCENTER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDSLS401201") }} AS SOURCETABLE  
            /*BACKORDERQUANTITYCONFIRMED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BQCO 
             ON   T$BQCO.TABLENAME  = 'TDSLS401' 
              AND T$BQCO.COLUMNNAME = 'T$BQCO' 
              AND T$BQCO.CONSTANT   = SOURCETABLE.T$BQCO 
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BKYN 
             ON   T$BKYN.TABLENAME  = 'TDSLS401' 
              AND T$BKYN.COLUMNNAME = 'T$BKYN' 
              AND T$BKYN.CONSTANT   = SOURCETABLE.T$BKYN 
            /*CANCELLED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLYN 
             ON   T$CLYN.TABLENAME  = 'TDSLS401' 
              AND T$CLYN.COLUMNNAME = 'T$CLYN' 
              AND T$CLYN.CONSTANT   = SOURCETABLE.T$CLYN 
            /*DETERMINING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTRM 
             ON   T$DTRM.TABLENAME  = 'TDSLS401' 
              AND T$DTRM.COLUMNNAME = 'T$DTRM' 
              AND T$DTRM.CONSTANT   = SOURCETABLE.T$DTRM 
            /*DIRECTDELIVERY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DRCT 
             ON   T$DRCT.TABLENAME  = 'TDSLS401' 
              AND T$DRCT.COLUMNNAME = 'T$DRCT' 
              AND T$DRCT.CONSTANT   = SOURCETABLE.T$DRCT 
            /*DISCOUNTMATRIXTYPE1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$1" 
             ON   "T$DMTY$1".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$1".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$1".CONSTANT   = SOURCETABLE."T$DMTY$1" 
            /*DISCOUNTMATRIXTYPE2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$2" 
             ON   "T$DMTY$2".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$2".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$2".CONSTANT   = SOURCETABLE."T$DMTY$2" 
            /*DISCOUNTMATRIXTYPE3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$3" 
             ON   "T$DMTY$3".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$3".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$3".CONSTANT   = SOURCETABLE."T$DMTY$3" 
            /*DISCOUNTMATRIXTYPE4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$4" 
             ON   "T$DMTY$4".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$4".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$4".CONSTANT   = SOURCETABLE."T$DMTY$4" 
            /*DISCOUNTMATRIXTYPE5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$5" 
             ON   "T$DMTY$5".TABLENAME  = 'TDSLS401' 
              AND "T$DMTY$5".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$5".CONSTANT   = SOURCETABLE."T$DMTY$5" 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$1" 
             ON   "T$DMTH$1".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$1".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$1".CONSTANT   = SOURCETABLE."T$DMTH$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$2" 
             ON   "T$DMTH$2".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$2".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$2".CONSTANT   = SOURCETABLE."T$DMTH$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$3" 
             ON   "T$DMTH$3".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$3".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$3".CONSTANT   = SOURCETABLE."T$DMTH$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$4" 
             ON   "T$DMTH$4".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$4".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$4".CONSTANT   = SOURCETABLE."T$DMTH$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$5" 
             ON   "T$DMTH$5".TABLENAME  = 'TDSLS401' 
              AND "T$DMTH$5".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$5".CONSTANT   = SOURCETABLE."T$DMTH$5" 
            /*ELIGIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ELGB 
             ON   T$ELGB.TABLENAME  = 'TDSLS401' 
              AND T$ELGB.COLUMNNAME = 'T$ELGB' 
              AND T$ELGB.CONSTANT   = SOURCETABLE.T$ELGB 
            /*INVENTORYISSUESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISSS 
             ON   T$ISSS.TABLENAME  = 'TDSLS401' 
              AND T$ISSS.COLUMNNAME = 'T$ISSS' 
              AND T$ISSS.CONSTANT   = SOURCETABLE.T$ISSS 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'TDSLS401' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*MAKECUSTOMIZED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPOL 
             ON   T$OPOL.TABLENAME  = 'TDSLS401' 
              AND T$OPOL.COLUMNNAME = 'T$OPOL' 
              AND T$OPOL.CONSTANT   = SOURCETABLE.T$OPOL 
            /*ORDERLINETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OLTP 
             ON   T$OLTP.TABLENAME  = 'TDSLS401' 
              AND T$OLTP.COLUMNNAME = 'T$OLTP' 
              AND T$OLTP.CONSTANT   = SOURCETABLE.T$OLTP 
            /*ORDERPRIORITYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRIO$U" 
             ON   "T$PRIO$U".TABLENAME  = 'TDSLS401' 
              AND "T$PRIO$U".COLUMNNAME = 'T$PRIO.U' 
              AND "T$PRIO$U".CONSTANT   = SOURCETABLE."T$PRIO$U" 
            /*ORDERPROMISINGSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPRS 
             ON   T$OPRS.TABLENAME  = 'TDSLS401' 
              AND T$OPRS.COLUMNNAME = 'T$OPRS' 
              AND T$OPRS.CONSTANT   = SOURCETABLE.T$OPRS 
            /*PRICEORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PROR 
             ON   T$PROR.TABLENAME  = 'TDSLS401' 
              AND T$PROR.COLUMNNAME = 'T$PROR' 
              AND T$PROR.CONSTANT   = SOURCETABLE.T$PROR 
            /*PRICESOURCEU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRSC$U" 
             ON   "T$PRSC$U".TABLENAME  = 'TDSLS401' 
              AND "T$PRSC$U".COLUMNNAME = 'T$PRSC.U' 
              AND "T$PRSC$U".CONSTANT   = SOURCETABLE."T$PRSC$U" 
            /*QUANTITYUNITBINDING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BIND 
             ON   T$BIND.TABLENAME  = 'TDSLS401' 
              AND T$BIND.COLUMNNAME = 'T$BIND' 
              AND T$BIND.CONSTANT   = SOURCETABLE.T$BIND 
            /*SHIPPINGCONSTRAINT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCON 
             ON   T$SCON.TABLENAME  = 'TDSLS401' 
              AND T$SCON.COLUMNNAME = 'T$SCON' 
              AND T$SCON.CONSTANT   = SOURCETABLE.T$SCON 
            /*STANDARDDESCRIPTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SDSC 
             ON   T$SDSC.TABLENAME  = 'TDSLS401' 
              AND T$SDSC.COLUMNNAME = 'T$SDSC' 
              AND T$SDSC.CONSTANT   = SOURCETABLE.T$SDSC 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNT_DAMT AS AMOUNT_DAMT, 
        source_data.AMOUNT_OAMT AS AMOUNT_OAMT, 
        source_data.BACKORDERQUANTITY AS BACKORDERQUANTITY, 
        source_data.BACKORDERQUANTITYCONFIRMEDDESCRIPTION AS BACKORDERQUANTITYCONFIRMEDDESCRIPTION, 
        source_data.BACKORDERQUANTITYCONFIRMEDID AS BACKORDERQUANTITYCONFIRMEDID, 
        source_data.BASEPRICE AS BASEPRICE, 
        source_data.BASEPRICECURRENCY AS BASEPRICECURRENCY, 
        source_data.BLOCKEDDESCRIPTION AS BLOCKEDDESCRIPTION, 
        source_data.BLOCKEDID AS BLOCKEDID, 
        source_data.CANCELLEDDESCRIPTION AS CANCELLEDDESCRIPTION, 
        source_data.CANCELLEDID AS CANCELLEDID, 
        source_data.CHANGEORDERSEQNO AS CHANGEORDERSEQNO, 
        source_data.CHANGEREASONLINES AS CHANGEREASONLINES, 
        source_data.CHANGETYPELINES AS CHANGETYPELINES, 
        source_data.CHANNELS AS CHANNELS, 
        source_data.COMMITDATE AS COMMITDATE, 
        source_data.COMMITTED AS COMMITTED, 
        source_data.CONVERSIONFACTORPRICETOINVENTORYUNIT AS CONVERSIONFACTORPRICETOINVENTORYUNIT, 
        source_data.CONVERSIONFACTORSALESTOINVENTORYUNIT AS CONVERSIONFACTORSALESTOINVENTORYUNIT, 
        source_data.COSTAMOUNTOFODSSOLD1 AS COSTAMOUNTOFODSSOLD1, 
        source_data.COSTAMOUNTOFODSSOLD2 AS COSTAMOUNTOFODSSOLD2, 
        source_data.COSTAMOUNTOFODSSOLD3 AS COSTAMOUNTOFODSSOLD3, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.COUNTRY AS COUNTRY, 
        source_data.CURRENCYRATESALES1 AS CURRENCYRATESALES1, 
        source_data.CURRENCYRATESALES2 AS CURRENCYRATESALES2, 
        source_data.CURRENCYRATESALES3 AS CURRENCYRATESALES3, 
        source_data.CURRENTACTIVITY AS CURRENTACTIVITY, 
        source_data.CUSTOMERORDERNUMBER AS CUSTOMERORDERNUMBER, 
        source_data.CUSTOMERORDERPOSITION AS CUSTOMERORDERPOSITION, 
        source_data.CUSTOMERORDERSEQUENCE AS CUSTOMERORDERSEQUENCE, 
        source_data.CUSTREQDELDATE AS CUSTREQDELDATE, 
        source_data.DCPRICE AS DCPRICE, 
        source_data.DELIVEREDQUANTITY AS DELIVEREDQUANTITY, 
        source_data.DELIVERYDATE AS DELIVERYDATE, 
        source_data.DETERMININGDESCRIPTION AS DETERMININGDESCRIPTION, 
        source_data.DETERMININGID AS DETERMININGID, 
        source_data.DIRECTDELIVERYDESCRIPTION AS DIRECTDELIVERYDESCRIPTION, 
        source_data.DIRECTDELIVERYID AS DIRECTDELIVERYID, 
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
        source_data.ELIGIBLEDESCRIPTION AS ELIGIBLEDESCRIPTION, 
        source_data.ELIGIBLEID AS ELIGIBLEID, 
        source_data.ENGINEERINGITEMREVISION AS ENGINEERINGITEMREVISION, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.FORWARDINGAGENT AS FORWARDINGAGENT, 
        source_data.FRONTOFFICEORDERLINE AS FRONTOFFICEORDERLINE, 
        source_data.FULLSTANDARDCOSTAMOUNT1 AS FULLSTANDARDCOSTAMOUNT1, 
        source_data.FULLSTANDARDCOSTAMOUNT2 AS FULLSTANDARDCOSTAMOUNT2, 
        source_data.FULLSTANDARDCOSTAMOUNT3 AS FULLSTANDARDCOSTAMOUNT3, 
        source_data.INVENTORYISSUESTATUSDESCRIPTION AS INVENTORYISSUESTATUSDESCRIPTION, 
        source_data.INVENTORYISSUESTATUSID AS INVENTORYISSUESTATUSID, 
        source_data.INVOICECOMPANY AS INVOICECOMPANY, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICENUMBERRETURN AS INVOICENUMBERRETURN, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMCODESYSTEM AS ITEMCODESYSTEM, 
        source_data.ITEMGROUP AS ITEMGROUP, 
        source_data.LENGTH AS LENGTH, 
        source_data.LINEDISCOUNT1 AS LINEDISCOUNT1, 
        source_data.LINEDISCOUNT2 AS LINEDISCOUNT2, 
        source_data.LINEDISCOUNT3 AS LINEDISCOUNT3, 
        source_data.LINEDISCOUNT4 AS LINEDISCOUNT4, 
        source_data.LINEDISCOUNT5 AS LINEDISCOUNT5, 
        source_data.LINKEDSEQUENCE AS LINKEDSEQUENCE, 
        source_data.LOGINCODE AS LOGINCODE, 
        source_data.LOT AS LOT, 
        source_data.LOTSELECTIONDESCRIPTION AS LOTSELECTIONDESCRIPTION, 
        source_data.LOTSELECTIONID AS LOTSELECTIONID, 
        source_data.MAKECUSTOMIZEDDESCRIPTION AS MAKECUSTOMIZEDDESCRIPTION, 
        source_data.MAKECUSTOMIZEDID AS MAKECUSTOMIZEDID, 
        source_data.MANUFACTURER AS MANUFACTURER, 
        source_data.OPERATIONCOSTS1 AS OPERATIONCOSTS1, 
        source_data.OPERATIONCOSTS2 AS OPERATIONCOSTS2, 
        source_data.OPERATIONCOSTS3 AS OPERATIONCOSTS3, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_DISCOUNTAMOUNT AS ORDER_DISCOUNTAMOUNT, 
        source_data.ORDER_EDQUANTITY AS ORDER_EDQUANTITY, 
        source_data.ORDER_ENTRYMETHOD AS ORDER_ENTRYMETHOD, 
        source_data.ORDER_LINEDISCOUNTAMOUNT AS ORDER_LINEDISCOUNTAMOUNT, 
        source_data.ORDER_LINETEXT AS ORDER_LINETEXT, 
        source_data.ORDER_LINETYPEDESCRIPTION AS ORDER_LINETYPEDESCRIPTION, 
        source_data.ORDER_LINETYPEID AS ORDER_LINETYPEID, 
        source_data.ORDER_PRIORITY_OPRI AS ORDER_PRIORITY_OPRI, 
        source_data.ORDER_PRIORITY_PRIO_UDESCRIPTION AS ORDER_PRIORITY_PRIO_UDESCRIPTION, 
        source_data.ORDER_PRIORITY_PRIO_UID AS ORDER_PRIORITY_PRIO_UID, 
        source_data.ORDER_PROMISINGSTATUSDESCRIPTION AS ORDER_PROMISINGSTATUSDESCRIPTION, 
        source_data.ORDER_PROMISINGSTATUSID AS ORDER_PROMISINGSTATUSID, 
        source_data.PLANNED_PERCENT_RECEIPT AS PLANNED_PERCENT_RECEIPT, 
        source_data.PLANNEDDELIVERYDATE AS PLANNEDDELIVERYDATE, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.PRICE AS PRICE, 
        source_data.PRICEMATRIXDEFINITION AS PRICEMATRIXDEFINITION, 
        source_data.PRICEMATRIXSEQUENCE AS PRICEMATRIXSEQUENCE, 
        source_data.PRICEORIGINDESCRIPTION AS PRICEORIGINDESCRIPTION, 
        source_data.PRICEORIGINID AS PRICEORIGINID, 
        source_data.PRICESOURCEDESCRIPTION AS PRICESOURCEDESCRIPTION, 
        source_data.PRICESOURCEID AS PRICESOURCEID, 
        source_data.PROCEDUREMASK AS PROCEDUREMASK, 
        source_data.PRODUCTCLASS AS PRODUCTCLASS, 
        source_data.PRODUCTLINE AS PRODUCTLINE, 
        source_data.PRODUCTVARIANT AS PRODUCTVARIANT, 
        source_data.PROJECT AS PROJECT, 
        source_data.QUANTITYUNITBINDINGDESCRIPTION AS QUANTITYUNITBINDINGDESCRIPTION, 
        source_data.QUANTITYUNITBINDINGID AS QUANTITYUNITBINDINGID, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.RELEASEDATE AS RELEASEDATE, 
        source_data.ROUTE AS ROUTE, 
        source_data.ROUTEPLAN AS ROUTEPLAN, 
        source_data.SALESACKNOWLEDGEMENTCODE AS SALESACKNOWLEDGEMENTCODE, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SALESPRICEUNIT AS SALESPRICEUNIT, 
        source_data.SALESSTATISTICSGROUP AS SALESSTATISTICSGROUP, 
        source_data.SALESUNIT AS SALESUNIT, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SERIALNO AS SERIALNO, 
        source_data.SHIPFROMWAREHOUSE AS SHIPFROMWAREHOUSE, 
        source_data.SHIPMENTID AS SHIPMENTID, 
        source_data.SHIPPINGCONSTRAINTDESCRIPTION AS SHIPPINGCONSTRAINTDESCRIPTION, 
        source_data.SHIPPINGCONSTRAINTID AS SHIPPINGCONSTRAINTID, 
        source_data.SHIPTOADDRESS AS SHIPTOADDRESS, 
        source_data.SHIPTOBUSINESSPARTNER AS SHIPTOBUSINESSPARTNER, 
        source_data.SHIPTOCONTACT AS SHIPTOCONTACT, 
        source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER, 
        source_data.STANDARDDESCRIPTIONDESCRIPTION AS STANDARDDESCRIPTIONDESCRIPTION, 
        source_data.STANDARDDESCRIPTIONID AS STANDARDDESCRIPTIONID, 
        source_data.STRUCTUREDISCOUNT AS STRUCTUREDISCOUNT, 
        source_data.STRUCTUREPRICE AS STRUCTUREPRICE, 
        source_data.SUPPLYINGSITE AS SUPPLYINGSITE, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.THICKNESS AS THICKNESS, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE, 
        source_data.UNITPRICE AS UNITPRICE, 
        source_data.VARIABLESTANDARDCOSTAMOUNT1 AS VARIABLESTANDARDCOSTAMOUNT1, 
        source_data.VARIABLESTANDARDCOSTAMOUNT2 AS VARIABLESTANDARDCOSTAMOUNT2, 
        source_data.VARIABLESTANDARDCOSTAMOUNT3 AS VARIABLESTANDARDCOSTAMOUNT3, 
        source_data.WAREHOUSE AS WAREHOUSE, 
        source_data.WIDTH AS WIDTH, 
        source_data.WORKCENTER AS WORKCENTER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AMOUNT_DAMT as NUMBER(15,2)) as AMOUNT_DAMT,
        cast(AMOUNT_OAMT as NUMBER(15,2)) as AMOUNT_OAMT,
        cast(BACKORDERQUANTITY as NUMBER(15,2)) as BACKORDERQUANTITY,
        cast(BACKORDERQUANTITYCONFIRMEDDESCRIPTION as VARCHAR(16777216)) as BACKORDERQUANTITYCONFIRMEDDESCRIPTION,
        cast(BACKORDERQUANTITYCONFIRMEDID as NUMBER(38,0)) as BACKORDERQUANTITYCONFIRMEDID,
        cast(BASEPRICE as NUMBER(15,2)) as BASEPRICE,
        cast(BASEPRICECURRENCY as VARCHAR(3)) as BASEPRICECURRENCY,
        cast(BLOCKEDDESCRIPTION as VARCHAR(16777216)) as BLOCKEDDESCRIPTION,
        cast(BLOCKEDID as NUMBER(38,0)) as BLOCKEDID,
        cast(CANCELLEDDESCRIPTION as VARCHAR(16777216)) as CANCELLEDDESCRIPTION,
        cast(CANCELLEDID as NUMBER(38,0)) as CANCELLEDID,
        cast(CHANGEORDERSEQNO as VARCHAR(8)) as CHANGEORDERSEQNO,
        cast(CHANGEREASONLINES as VARCHAR(6)) as CHANGEREASONLINES,
        cast(CHANGETYPELINES as VARCHAR(6)) as CHANGETYPELINES,
        cast(CHANNELS as VARCHAR(3)) as CHANNELS,
        cast(COMMITDATE as TIMESTAMP_NTZ(9)) as COMMITDATE,
        cast(COMMITTED as NUMBER(15,2)) as COMMITTED,
        cast(CONVERSIONFACTORPRICETOINVENTORYUNIT as NUMBER(15,2)) as CONVERSIONFACTORPRICETOINVENTORYUNIT,
        cast(CONVERSIONFACTORSALESTOINVENTORYUNIT as NUMBER(15,2)) as CONVERSIONFACTORSALESTOINVENTORYUNIT,
        cast(COSTAMOUNTOFODSSOLD1 as NUMBER(15,2)) as COSTAMOUNTOFODSSOLD1,
        cast(COSTAMOUNTOFODSSOLD2 as NUMBER(15,2)) as COSTAMOUNTOFODSSOLD2,
        cast(COSTAMOUNTOFODSSOLD3 as NUMBER(15,2)) as COSTAMOUNTOFODSSOLD3,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(COUNTRY as VARCHAR(3)) as COUNTRY,
        cast(CURRENCYRATESALES1 as NUMBER(15,2)) as CURRENCYRATESALES1,
        cast(CURRENCYRATESALES2 as NUMBER(15,2)) as CURRENCYRATESALES2,
        cast(CURRENCYRATESALES3 as NUMBER(15,2)) as CURRENCYRATESALES3,
        cast(CURRENTACTIVITY as VARCHAR(20)) as CURRENTACTIVITY,
        cast(CUSTOMERORDERNUMBER as VARCHAR(30)) as CUSTOMERORDERNUMBER,
        cast(CUSTOMERORDERPOSITION as VARCHAR(16)) as CUSTOMERORDERPOSITION,
        cast(CUSTOMERORDERSEQUENCE as VARCHAR(11)) as CUSTOMERORDERSEQUENCE,
        cast(CUSTREQDELDATE as TIMESTAMP_NTZ(9)) as CUSTREQDELDATE,
        cast(DCPRICE as NUMBER(15,2)) as DCPRICE,
        cast(DELIVEREDQUANTITY as NUMBER(15,2)) as DELIVEREDQUANTITY,
        cast(DELIVERYDATE as TIMESTAMP_NTZ(9)) as DELIVERYDATE,
        cast(DETERMININGDESCRIPTION as VARCHAR(16777216)) as DETERMININGDESCRIPTION,
        cast(DETERMININGID as NUMBER(38,0)) as DETERMININGID,
        cast(DIRECTDELIVERYDESCRIPTION as VARCHAR(16777216)) as DIRECTDELIVERYDESCRIPTION,
        cast(DIRECTDELIVERYID as NUMBER(38,0)) as DIRECTDELIVERYID,
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
        cast(ELIGIBLEDESCRIPTION as VARCHAR(16777216)) as ELIGIBLEDESCRIPTION,
        cast(ELIGIBLEID as NUMBER(38,0)) as ELIGIBLEID,
        cast(ENGINEERINGITEMREVISION as VARCHAR(6)) as ENGINEERINGITEMREVISION,
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(FORWARDINGAGENT as VARCHAR(3)) as FORWARDINGAGENT,
        cast(FRONTOFFICEORDERLINE as NUMBER(15,2)) as FRONTOFFICEORDERLINE,
        cast(FULLSTANDARDCOSTAMOUNT1 as NUMBER(15,2)) as FULLSTANDARDCOSTAMOUNT1,
        cast(FULLSTANDARDCOSTAMOUNT2 as NUMBER(15,2)) as FULLSTANDARDCOSTAMOUNT2,
        cast(FULLSTANDARDCOSTAMOUNT3 as NUMBER(15,2)) as FULLSTANDARDCOSTAMOUNT3,
        cast(INVENTORYISSUESTATUSDESCRIPTION as VARCHAR(16777216)) as INVENTORYISSUESTATUSDESCRIPTION,
        cast(INVENTORYISSUESTATUSID as NUMBER(38,0)) as INVENTORYISSUESTATUSID,
        cast(INVOICECOMPANY as NUMBER(38,0)) as INVOICECOMPANY,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICENUMBERRETURN as NUMBER(38,0)) as INVOICENUMBERRETURN,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ITEMCODESYSTEM as VARCHAR(3)) as ITEMCODESYSTEM,
        cast(ITEMGROUP as VARCHAR(6)) as ITEMGROUP,
        cast(LENGTH as NUMBER(15,2)) as LENGTH,
        cast(LINEDISCOUNT1 as NUMBER(15,2)) as LINEDISCOUNT1,
        cast(LINEDISCOUNT2 as NUMBER(15,2)) as LINEDISCOUNT2,
        cast(LINEDISCOUNT3 as NUMBER(15,2)) as LINEDISCOUNT3,
        cast(LINEDISCOUNT4 as NUMBER(15,2)) as LINEDISCOUNT4,
        cast(LINEDISCOUNT5 as NUMBER(15,2)) as LINEDISCOUNT5,
        cast(LINKEDSEQUENCE as NUMBER(38,0)) as LINKEDSEQUENCE,
        cast(LOGINCODE as VARCHAR(16)) as LOGINCODE,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(LOTSELECTIONDESCRIPTION as VARCHAR(16777216)) as LOTSELECTIONDESCRIPTION,
        cast(LOTSELECTIONID as NUMBER(38,0)) as LOTSELECTIONID,
        cast(MAKECUSTOMIZEDDESCRIPTION as VARCHAR(16777216)) as MAKECUSTOMIZEDDESCRIPTION,
        cast(MAKECUSTOMIZEDID as NUMBER(38,0)) as MAKECUSTOMIZEDID,
        cast(MANUFACTURER as VARCHAR(6)) as MANUFACTURER,
        cast(OPERATIONCOSTS1 as NUMBER(15,2)) as OPERATIONCOSTS1,
        cast(OPERATIONCOSTS2 as NUMBER(15,2)) as OPERATIONCOSTS2,
        cast(OPERATIONCOSTS3 as NUMBER(15,2)) as OPERATIONCOSTS3,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_DISCOUNTAMOUNT as NUMBER(15,2)) as ORDER_DISCOUNTAMOUNT,
        cast(ORDER_EDQUANTITY as NUMBER(15,2)) as ORDER_EDQUANTITY,
        cast(ORDER_ENTRYMETHOD as VARCHAR(3)) as ORDER_ENTRYMETHOD,
        cast(ORDER_LINEDISCOUNTAMOUNT as NUMBER(15,2)) as ORDER_LINEDISCOUNTAMOUNT,
        cast(ORDER_LINETEXT as NUMBER(38,10)) as ORDER_LINETEXT,
        cast(ORDER_LINETYPEDESCRIPTION as VARCHAR(16777216)) as ORDER_LINETYPEDESCRIPTION,
        cast(ORDER_LINETYPEID as NUMBER(38,0)) as ORDER_LINETYPEID,
        cast(ORDER_PRIORITY_OPRI as NUMBER(38,0)) as ORDER_PRIORITY_OPRI,
        cast(ORDER_PRIORITY_PRIO_UDESCRIPTION as VARCHAR(16777216)) as ORDER_PRIORITY_PRIO_UDESCRIPTION,
        cast(ORDER_PRIORITY_PRIO_UID as NUMBER(38,0)) as ORDER_PRIORITY_PRIO_UID,
        cast(ORDER_PROMISINGSTATUSDESCRIPTION as VARCHAR(16777216)) as ORDER_PROMISINGSTATUSDESCRIPTION,
        cast(ORDER_PROMISINGSTATUSID as NUMBER(38,0)) as ORDER_PROMISINGSTATUSID,
        cast(PLANNED_PERCENT_RECEIPT as TIMESTAMP_NTZ(9)) as PLANNED_PERCENT_RECEIPT,
        cast(PLANNEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as PLANNEDDELIVERYDATE,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(PRICE as NUMBER(15,2)) as PRICE,
        cast(PRICEMATRIXDEFINITION as VARCHAR(6)) as PRICEMATRIXDEFINITION,
        cast(PRICEMATRIXSEQUENCE as NUMBER(38,0)) as PRICEMATRIXSEQUENCE,
        cast(PRICEORIGINDESCRIPTION as VARCHAR(16777216)) as PRICEORIGINDESCRIPTION,
        cast(PRICEORIGINID as NUMBER(38,0)) as PRICEORIGINID,
        cast(PRICESOURCEDESCRIPTION as VARCHAR(16777216)) as PRICESOURCEDESCRIPTION,
        cast(PRICESOURCEID as NUMBER(38,0)) as PRICESOURCEID,
        cast(PROCEDUREMASK as VARCHAR(20)) as PROCEDUREMASK,
        cast(PRODUCTCLASS as VARCHAR(6)) as PRODUCTCLASS,
        cast(PRODUCTLINE as VARCHAR(6)) as PRODUCTLINE,
        cast(PRODUCTVARIANT as NUMBER(38,0)) as PRODUCTVARIANT,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(QUANTITYUNITBINDINGDESCRIPTION as VARCHAR(16777216)) as QUANTITYUNITBINDINGDESCRIPTION,
        cast(QUANTITYUNITBINDINGID as NUMBER(38,0)) as QUANTITYUNITBINDINGID,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(RELEASEDATE as TIMESTAMP_NTZ(9)) as RELEASEDATE,
        cast(ROUTE as VARCHAR(5)) as ROUTE,
        cast(ROUTEPLAN as VARCHAR(3)) as ROUTEPLAN,
        cast(SALESACKNOWLEDGEMENTCODE as VARCHAR(2)) as SALESACKNOWLEDGEMENTCODE,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SALESPRICEUNIT as VARCHAR(3)) as SALESPRICEUNIT,
        cast(SALESSTATISTICSGROUP as VARCHAR(6)) as SALESSTATISTICSGROUP,
        cast(SALESUNIT as VARCHAR(3)) as SALESUNIT,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SERIALNO as VARCHAR(20)) as SERIALNO,
        cast(SHIPFROMWAREHOUSE as VARCHAR(6)) as SHIPFROMWAREHOUSE,
        cast(SHIPMENTID as VARCHAR(9)) as SHIPMENTID,
        cast(SHIPPINGCONSTRAINTDESCRIPTION as VARCHAR(16777216)) as SHIPPINGCONSTRAINTDESCRIPTION,
        cast(SHIPPINGCONSTRAINTID as NUMBER(38,0)) as SHIPPINGCONSTRAINTID,
        cast(SHIPTOADDRESS as VARCHAR(9)) as SHIPTOADDRESS,
        cast(SHIPTOBUSINESSPARTNER as VARCHAR(9)) as SHIPTOBUSINESSPARTNER,
        cast(SHIPTOCONTACT as VARCHAR(9)) as SHIPTOCONTACT,
        cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
        cast(STANDARDDESCRIPTIONDESCRIPTION as VARCHAR(16777216)) as STANDARDDESCRIPTIONDESCRIPTION,
        cast(STANDARDDESCRIPTIONID as NUMBER(38,0)) as STANDARDDESCRIPTIONID,
        cast(STRUCTUREDISCOUNT as NUMBER(15,2)) as STRUCTUREDISCOUNT,
        cast(STRUCTUREPRICE as NUMBER(15,2)) as STRUCTUREPRICE,
        cast(SUPPLYINGSITE as NUMBER(38,0)) as SUPPLYINGSITE,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(THICKNESS as NUMBER(15,2)) as THICKNESS,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(UNITPRICE as NUMBER(15,2)) as UNITPRICE,
        cast(VARIABLESTANDARDCOSTAMOUNT1 as NUMBER(15,2)) as VARIABLESTANDARDCOSTAMOUNT1,
        cast(VARIABLESTANDARDCOSTAMOUNT2 as NUMBER(15,2)) as VARIABLESTANDARDCOSTAMOUNT2,
        cast(VARIABLESTANDARDCOSTAMOUNT3 as NUMBER(15,2)) as VARIABLESTANDARDCOSTAMOUNT3,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(WIDTH as NUMBER(15,2)) as WIDTH,
        cast(WORKCENTER as VARCHAR(6)) as WORKCENTER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data