/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINEHISTORY.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINEHISTORY.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINEHISTORY 
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
    alias='BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINEHISTORY',
    unique_key = ['POSITIONNUMBER_PONO',
    'RECORDTYPE1_3ID',
    'SALESORDER',
    'SEQUENCENUMBER_SERN',
    'TRANSACTIONDATE']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$SRNB AS INT)                                                                                                                 AS ALTERNATIVE 
            ,CAST(T$AMTA AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,T$BIND.CONSTANTDESCRIPTION                                                                                                          AS BINDINGDESCRIPTION 
            ,CAST(T$BIND AS INT)                                                                                                                 AS BINDINGID 
            ,T$BKYN.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BKYN AS INT)                                                                                                                 AS BLOCKEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                         AS CHANGEORDERSEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                         AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                         AS CHANGETYPELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHAN)),'')                                                                                         AS CHANNELS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CONO)),'')                                                                                         AS CONTRACT 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTORPRICETOINVENTORYUNIT 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTORSALESTOINVENTORYUNIT 
            ,CAST("T$COPR$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOFODSSOLD1 
            ,CAST("T$COPR$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOFODSSOLD2 
            ,CAST("T$COPR$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOFODSSOLD3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,T$CUCM.CONSTANTDESCRIPTION                                                                                                          AS CUMMUPDATEDFORCOMMDESCRIPTION 
            ,CAST(T$CUCM AS INT)                                                                                                                 AS CUMMUPDATEDFORCOMMID 
            ,T$CURB.CONSTANTDESCRIPTION                                                                                                          AS CUMMUPDATEFORREBTDESCRIPTION 
            ,CAST(T$CURB AS INT)                                                                                                                 AS CUMMUPDATEFORREBTID 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                         AS CUSTOMERORDERNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORP)),'')                                                                                         AS CUSTOMERPOSITIONNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORS)),'')                                                                                         AS CUSTOMERSEQUENCENUMBER 
            ,CAST(CASE WHEN T$DDTB<= '1/1/1970' THEN NULL ELSE T$DDTB  END AS DATETIME) AS DELIVERYDATE 
            ,T$DEMD.CONSTANTDESCRIPTION                                                                                                          AS DEMANDUPDATEDDESCRIPTION 
            ,CAST(T$DEMD AS INT)                                                                                                                 AS DEMANDUPDATEDID 
            ,T$DTRM.CONSTANTDESCRIPTION                                                                                                          AS DETERMININGDESCRIPTION 
            ,CAST(T$DTRM AS INT)                                                                                                                 AS DETERMININGID 
            ,T$DRCT.CONSTANTDESCRIPTION                                                                                                          AS DIRECTDELIVERYDESCRIPTION 
            ,CAST(T$DRCT AS INT)                                                                                                                 AS DIRECTDELIVERYID 
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
            ,T$ELGB.CONSTANTDESCRIPTION                                                                                                          AS ELIGIBLEDESCRIPTION 
            ,CAST(T$ELGB AS INT)                                                                                                                 AS ELIGIBLEID 
            ,CAST(CASE WHEN T$EDAT<= '1/1/1970' THEN NULL ELSE T$EDAT  END AS DATETIME) AS ENDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS ENGINEERINGITEMREVISION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                         AS EXCHANGERATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                         AS FORWARDINGAGENT 
            ,CAST(T$XLKY AS NUMERIC(15,2))                                                                                                       AS FRONTOFFICEORDERLINE 
            ,CAST("T$FCOP$1" AS NUMERIC(15,2))                                                                                                     AS FULLSTANDARDCOSTAMOUNT1 
            ,CAST("T$FCOP$2" AS NUMERIC(15,2))                                                                                                     AS FULLSTANDARDCOSTAMOUNT2 
            ,CAST("T$FCOP$3" AS NUMERIC(15,2))                                                                                                     AS FULLSTANDARDCOSTAMOUNT3 
            ,T$ISSS.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYISSUESTATUSDESCRIPTION 
            ,CAST(T$ISSS AS INT)                                                                                                                 AS INVENTORYISSUESTATUSID 
            ,CAST(T$SCMP AS INT)                                                                                                                 AS INVOICECOMPANY 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME) AS INVOICEDATE 
            ,CAST(T$INVN AS BIGINT)                                                                                                              AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITT)),'')                                                                                         AS ITEMCODESYSTEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'')                                                                                         AS ITEMGROUP 
            ,CAST(T$LENG AS NUMERIC(15,2))                                                                                                       AS LENGTH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LOGNAME 
            ,T$LOST.CONSTANTDESCRIPTION                                                                                                          AS LOSTSALESUPDATEDDESCRIPTION 
            ,CAST(T$LOST AS INT)                                                                                                                 AS LOSTSALESUPDATEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOT 
            ,T$LSEL.CONSTANTDESCRIPTION                                                                                                          AS LotSelectionDescription  
            ,CAST(T$LSEL AS INT)                                                                                                                 AS LotSelectionId  
            ,T$OPOL.CONSTANTDESCRIPTION                                                                                                          AS MAKECUSTOMIZEDDESCRIPTION 
            ,CAST(T$OPOL AS INT)                                                                                                                 AS MAKECUSTOMIZEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'')                                                                                         AS MANUFACTURER 
            ,CAST("T$COOP$1" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS1 
            ,CAST("T$COOP$2" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS2 
            ,CAST("T$COOP$3" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                         AS ORDER_ACKNOWLEDGEMENT 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME) AS ORDER_DATE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ORDER_LINETEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORPW)),'')                                                                                         AS ORDER_NUMBER 
            ,T$OPRS.CONSTANTDESCRIPTION                                                                                                          AS ORDER_PROMISINGSTATUSDESCRIPTION 
            ,CAST(T$OPRS AS INT)                                                                                                                 AS ORDER_PROMISINGSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ODNO)),'')                                                                                         AS ORIGINALDOCUMENTNUMBER 
            ,T$ODTY.CONSTANTDESCRIPTION                                                                                                          AS ORIGINALDOCUMENTTYPEDESCRIPTION 
            ,CAST(T$ODTY AS INT)                                                                                                                 AS ORIGINALDOCUMENTTYPEID 
            ,T$PCSR.CONSTANTDESCRIPTION                                                                                                          AS PCS_REVALUATIONDESCRIPTION 
            ,CAST(T$PCSR AS INT)                                                                                                                 AS PCS_REVALUATIONID 
            ,CAST(CASE WHEN T$DDTA<= '1/1/1970' THEN NULL ELSE T$DDTA  END AS DATETIME) AS PLANNEDDELIVERYDATE 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PLANNEDRECEIPTDATE 
            ,CAST(T$OPON AS INT)                                                                                                                 AS POSITIONNUMBER_OPON 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER_PONO 
            ,CAST(T$POSI AS INT)                                                                                                                 AS POSITIONNUMBER_POSI 
            ,CAST(T$PPON AS INT)                                                                                                                 AS POSITIONNUMBER_PPON 
            ,CAST(T$RETP AS INT)                                                                                                                 AS POSITIONNUMBER_RETP 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMDE)),'')                                                                                         AS PRICEMATRIXDEFINITION 
            ,CAST(T$PMSE AS BIGINT)                                                                                                              AS PRICEMATRIXSEQUENCE 
            ,T$PROR.CONSTANTDESCRIPTION                                                                                                          AS PRICEORIGINDESCRIPTION 
            ,CAST(T$PROR AS INT)                                                                                                                 AS PRICEORIGINID 
            ,T$STCD.CONSTANTDESCRIPTION                                                                                                          AS PROCESSEDDESCRIPTION 
            ,CAST(T$STCD AS INT)                                                                                                                 AS PROCESSEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCL)),'')                                                                                         AS PRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLN)),'')                                                                                         AS PRODUCTLINE 
            ,CAST(T$CPVA AS BIGINT)                                                                                                              AS PRODUCTVARIANT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PORN)),'')                                                                                         AS PURCHASEORDER 
            ,CAST(T$QANA AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QONO)),'')                                                                                         AS QUOTATIONNUMBER 
            ,CAST(T$QPON AS INT)                                                                                                                 AS QUOTATIONPOSITION 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,T$CKOR.CONSTANTDESCRIPTION                                                                                                          AS RECORDTYPE1_3DESCRIPTION 
            ,CAST(T$CKOR AS INT)                                                                                                                 AS RECORDTYPE1_3ID 
            ,CAST(CASE WHEN T$RDTA<= '1/1/1970' THEN NULL ELSE T$RDTA  END AS DATETIME) AS RELEASEDATE 
            ,CAST(T$STDC AS NUMERIC(15,2))                                                                                                       AS REMOVE 
            ,CAST(T$RCMP AS INT)                                                                                                                 AS RETURNINVOICECOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETO)),'')                                                                                         AS RETURNORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RETURNTRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'')                                                                                         AS ROUTE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                         AS ROUTEPLAN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS SALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGS)),'')                                                                                         AS SALESSTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS SALESUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEGC)),'')                                                                                         AS SEGMENTCODE 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,CAST(T$PSEQ AS INT)                                                                                                                 AS SEQUENCENUMBER_PSEQ 
            ,CAST(T$RETS AS INT)                                                                                                                 AS SEQUENCENUMBER_RETS 
            ,CAST(T$SERN AS BIGINT)                                                                                                              AS SEQUENCENUMBER_SERN 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCENUMBER_SQNB 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFWH)),'')                                                                                         AS SHIPFROMWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DLNO)),'')                                                                                         AS SHIPMENTID_DLNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS SHIPMENTID_SHPM 
            ,T$SCON.CONSTANTDESCRIPTION                                                                                                          AS SHIPPINGCONSTRAINTDESCRIPTION 
            ,CAST(T$SCON AS INT)                                                                                                                 AS SHIPPINGCONSTRAINTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCN)),'')                                                                                         AS SHIPTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,T$SDSC.CONSTANTDESCRIPTION                                                                                                          AS STANDARDDESCRIPTIONDESCRIPTION 
            ,CAST(T$SDSC AS INT)                                                                                                                 AS STANDARDDESCRIPTIONID 
            ,CAST(CASE WHEN T$SDAT<= '1/1/1970' THEN NULL ELSE T$SDAT  END AS DATETIME) AS STARTDATE 
            ,CAST(T$STPR AS NUMERIC(15,2))                                                                                                       AS STRUCTUREPRICE 
            ,CAST(T$SUSI AS INT)                                                                                                                 AS SUPPLYINGSITE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,CAST(T$THIC AS NUMERIC(15,2))                                                                                                       AS THICKNESS 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,T$DEST.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFORDERDESCRIPTION 
            ,CAST(T$DEST AS INT)                                                                                                                 AS TYPEOFORDERID 
            ,CAST("T$VCOP$1" AS NUMERIC(15,2))                                                                                                     AS VARIABLESTANDARDCOSTAMOUNT1 
            ,CAST("T$VCOP$2" AS NUMERIC(15,2))                                                                                                     AS VARIABLESTANDARDCOSTAMOUNT2 
            ,CAST("T$VCOP$3" AS NUMERIC(15,2))                                                                                                     AS VARIABLESTANDARDCOSTAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
            ,CAST(T$WIDT AS NUMERIC(15,2))                                                                                                       AS WIDTH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS WORKCENTER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDSLS451200") }} AS SOURCETABLE  
            /*BINDING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BIND 
             ON   T$BIND.TABLENAME  = 'TDSLS451' 
              AND T$BIND.COLUMNNAME = 'T$BIND' 
              AND T$BIND.CONSTANT   = SOURCETABLE.T$BIND 
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BKYN 
             ON   T$BKYN.TABLENAME  = 'TDSLS451' 
              AND T$BKYN.COLUMNNAME = 'T$BKYN' 
              AND T$BKYN.CONSTANT   = SOURCETABLE.T$BKYN 
            /*CUMMUPDATEDFORCOMM*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CUCM 
             ON   T$CUCM.TABLENAME  = 'TDSLS451' 
              AND T$CUCM.COLUMNNAME = 'T$CUCM' 
              AND T$CUCM.CONSTANT   = SOURCETABLE.T$CUCM 
            /*CUMMUPDATEFORREBT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CURB 
             ON   T$CURB.TABLENAME  = 'TDSLS451' 
              AND T$CURB.COLUMNNAME = 'T$CURB' 
              AND T$CURB.CONSTANT   = SOURCETABLE.T$CURB 
            /*DEMANDUPDATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEMD 
             ON   T$DEMD.TABLENAME  = 'TDSLS451' 
              AND T$DEMD.COLUMNNAME = 'T$DEMD' 
              AND T$DEMD.CONSTANT   = SOURCETABLE.T$DEMD 
            /*DETERMINING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTRM 
             ON   T$DTRM.TABLENAME  = 'TDSLS451' 
              AND T$DTRM.COLUMNNAME = 'T$DTRM' 
              AND T$DTRM.CONSTANT   = SOURCETABLE.T$DTRM 
            /*DIRECTDELIVERY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DRCT 
             ON   T$DRCT.TABLENAME  = 'TDSLS451' 
              AND T$DRCT.COLUMNNAME = 'T$DRCT' 
              AND T$DRCT.CONSTANT   = SOURCETABLE.T$DRCT 
            /*DISCOUNTMATRIXTYPE1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$1" 
             ON   "T$DMTY$1".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$1".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$1".CONSTANT   = SOURCETABLE."T$DMTY$1" 
            /*DISCOUNTMATRIXTYPE2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$2" 
             ON   "T$DMTY$2".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$2".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$2".CONSTANT   = SOURCETABLE."T$DMTY$2" 
            /*DISCOUNTMATRIXTYPE3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$3" 
             ON   "T$DMTY$3".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$3".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$3".CONSTANT   = SOURCETABLE."T$DMTY$3" 
            /*DISCOUNTMATRIXTYPE4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$4" 
             ON   "T$DMTY$4".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$4".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$4".CONSTANT   = SOURCETABLE."T$DMTY$4" 
            /*DISCOUNTMATRIXTYPE5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$5" 
             ON   "T$DMTY$5".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$5".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$5".CONSTANT   = SOURCETABLE."T$DMTY$5" 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$1" 
             ON   "T$DMTH$1".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$1".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$1".CONSTANT   = SOURCETABLE."T$DMTH$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$2" 
             ON   "T$DMTH$2".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$2".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$2".CONSTANT   = SOURCETABLE."T$DMTH$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$3" 
             ON   "T$DMTH$3".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$3".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$3".CONSTANT   = SOURCETABLE."T$DMTH$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$4" 
             ON   "T$DMTH$4".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$4".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$4".CONSTANT   = SOURCETABLE."T$DMTH$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$5" 
             ON   "T$DMTH$5".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$5".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$5".CONSTANT   = SOURCETABLE."T$DMTH$5" 
            /*ELIGIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ELGB 
             ON   T$ELGB.TABLENAME  = 'TDSLS451' 
              AND T$ELGB.COLUMNNAME = 'T$ELGB' 
              AND T$ELGB.CONSTANT   = SOURCETABLE.T$ELGB 
            /*INVENTORYISSUESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISSS 
             ON   T$ISSS.TABLENAME  = 'TDSLS451' 
              AND T$ISSS.COLUMNNAME = 'T$ISSS' 
              AND T$ISSS.CONSTANT   = SOURCETABLE.T$ISSS 
            /*LOSTSALESUPDATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LOST 
             ON   T$LOST.TABLENAME  = 'TDSLS451' 
              AND T$LOST.COLUMNNAME = 'T$LOST' 
              AND T$LOST.CONSTANT   = SOURCETABLE.T$LOST 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'TDSLS451' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*MAKECUSTOMIZED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPOL 
             ON   T$OPOL.TABLENAME  = 'TDSLS451' 
              AND T$OPOL.COLUMNNAME = 'T$OPOL' 
              AND T$OPOL.CONSTANT   = SOURCETABLE.T$OPOL 
            /*ORDERPROMISINGSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPRS 
             ON   T$OPRS.TABLENAME  = 'TDSLS451' 
              AND T$OPRS.COLUMNNAME = 'T$OPRS' 
              AND T$OPRS.CONSTANT   = SOURCETABLE.T$OPRS 
            /*ORIGINALDOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ODTY 
             ON   T$ODTY.TABLENAME  = 'TDSLS451' 
              AND T$ODTY.COLUMNNAME = 'T$ODTY' 
              AND T$ODTY.CONSTANT   = SOURCETABLE.T$ODTY 
            /*PCS_REVALUATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PCSR 
             ON   T$PCSR.TABLENAME  = 'TDSLS451' 
              AND T$PCSR.COLUMNNAME = 'T$PCSR' 
              AND T$PCSR.CONSTANT   = SOURCETABLE.T$PCSR 
            /*PRICEORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PROR 
             ON   T$PROR.TABLENAME  = 'TDSLS451' 
              AND T$PROR.COLUMNNAME = 'T$PROR' 
              AND T$PROR.CONSTANT   = SOURCETABLE.T$PROR 
            /*PROCESSED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STCD 
             ON   T$STCD.TABLENAME  = 'TDSLS451' 
              AND T$STCD.COLUMNNAME = 'T$STCD' 
              AND T$STCD.CONSTANT   = SOURCETABLE.T$STCD 
            /*RECORDTYPE1_3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CKOR 
             ON   T$CKOR.TABLENAME  = 'TDSLS451' 
              AND T$CKOR.COLUMNNAME = 'T$CKOR' 
              AND T$CKOR.CONSTANT   = SOURCETABLE.T$CKOR 
            /*SHIPPINGCONSTRAINT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCON 
             ON   T$SCON.TABLENAME  = 'TDSLS451' 
              AND T$SCON.COLUMNNAME = 'T$SCON' 
              AND T$SCON.CONSTANT   = SOURCETABLE.T$SCON 
            /*STANDARDDESCRIPTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SDSC 
             ON   T$SDSC.TABLENAME  = 'TDSLS451' 
              AND T$SDSC.COLUMNNAME = 'T$SDSC' 
              AND T$SDSC.CONSTANT   = SOURCETABLE.T$SDSC 
            /*TYPEOFORDER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEST 
             ON   T$DEST.TABLENAME  = 'TDSLS451' 
              AND T$DEST.COLUMNNAME = 'T$DEST' 
              AND T$DEST.CONSTANT   = SOURCETABLE.T$DEST 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$SRNB AS INT)                                                                                                                 AS ALTERNATIVE 
            ,CAST(T$AMTA AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,T$BIND.CONSTANTDESCRIPTION                                                                                                          AS BINDINGDESCRIPTION 
            ,CAST(T$BIND AS INT)                                                                                                                 AS BINDINGID 
            ,T$BKYN.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BKYN AS INT)                                                                                                                 AS BLOCKEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                         AS CHANGEORDERSEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                         AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                         AS CHANGETYPELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHAN)),'')                                                                                         AS CHANNELS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CONO)),'')                                                                                         AS CONTRACT 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTORPRICETOINVENTORYUNIT 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTORSALESTOINVENTORYUNIT 
            ,CAST("T$COPR$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOFODSSOLD1 
            ,CAST("T$COPR$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOFODSSOLD2 
            ,CAST("T$COPR$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOFODSSOLD3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,T$CUCM.CONSTANTDESCRIPTION                                                                                                          AS CUMMUPDATEDFORCOMMDESCRIPTION 
            ,CAST(T$CUCM AS INT)                                                                                                                 AS CUMMUPDATEDFORCOMMID 
            ,T$CURB.CONSTANTDESCRIPTION                                                                                                          AS CUMMUPDATEFORREBTDESCRIPTION 
            ,CAST(T$CURB AS INT)                                                                                                                 AS CUMMUPDATEFORREBTID 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                         AS CUSTOMERORDERNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORP)),'')                                                                                         AS CUSTOMERPOSITIONNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORS)),'')                                                                                         AS CUSTOMERSEQUENCENUMBER 
            ,CAST(CASE WHEN T$DDTB<= '1/1/1970' THEN NULL ELSE T$DDTB  END AS DATETIME) AS DELIVERYDATE 
            ,T$DEMD.CONSTANTDESCRIPTION                                                                                                          AS DEMANDUPDATEDDESCRIPTION 
            ,CAST(T$DEMD AS INT)                                                                                                                 AS DEMANDUPDATEDID 
            ,T$DTRM.CONSTANTDESCRIPTION                                                                                                          AS DETERMININGDESCRIPTION 
            ,CAST(T$DTRM AS INT)                                                                                                                 AS DETERMININGID 
            ,T$DRCT.CONSTANTDESCRIPTION                                                                                                          AS DIRECTDELIVERYDESCRIPTION 
            ,CAST(T$DRCT AS INT)                                                                                                                 AS DIRECTDELIVERYID 
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
            ,T$ELGB.CONSTANTDESCRIPTION                                                                                                          AS ELIGIBLEDESCRIPTION 
            ,CAST(T$ELGB AS INT)                                                                                                                 AS ELIGIBLEID 
            ,CAST(CASE WHEN T$EDAT<= '1/1/1970' THEN NULL ELSE T$EDAT  END AS DATETIME) AS ENDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS ENGINEERINGITEMREVISION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                         AS EXCHANGERATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                         AS FORWARDINGAGENT 
            ,CAST(T$XLKY AS NUMERIC(15,2))                                                                                                       AS FRONTOFFICEORDERLINE 
            ,CAST("T$FCOP$1" AS NUMERIC(15,2))                                                                                                     AS FULLSTANDARDCOSTAMOUNT1 
            ,CAST("T$FCOP$2" AS NUMERIC(15,2))                                                                                                     AS FULLSTANDARDCOSTAMOUNT2 
            ,CAST("T$FCOP$3" AS NUMERIC(15,2))                                                                                                     AS FULLSTANDARDCOSTAMOUNT3 
            ,T$ISSS.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYISSUESTATUSDESCRIPTION 
            ,CAST(T$ISSS AS INT)                                                                                                                 AS INVENTORYISSUESTATUSID 
            ,CAST(T$SCMP AS INT)                                                                                                                 AS INVOICECOMPANY 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME) AS INVOICEDATE 
            ,CAST(T$INVN AS BIGINT)                                                                                                              AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITT)),'')                                                                                         AS ITEMCODESYSTEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'')                                                                                         AS ITEMGROUP 
            ,CAST(T$LENG AS NUMERIC(15,2))                                                                                                       AS LENGTH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LOGNAME 
            ,T$LOST.CONSTANTDESCRIPTION                                                                                                          AS LOSTSALESUPDATEDDESCRIPTION 
            ,CAST(T$LOST AS INT)                                                                                                                 AS LOSTSALESUPDATEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOT 
            ,T$LSEL.CONSTANTDESCRIPTION                                                                                                          AS LotSelectionDescription  
            ,CAST(T$LSEL AS INT)                                                                                                                 AS LotSelectionId   
            ,T$OPOL.CONSTANTDESCRIPTION                                                                                                          AS MAKECUSTOMIZEDDESCRIPTION 
            ,CAST(T$OPOL AS INT)                                                                                                                 AS MAKECUSTOMIZEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'')                                                                                         AS MANUFACTURER 
            ,CAST("T$COOP$1" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS1 
            ,CAST("T$COOP$2" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS2 
            ,CAST("T$COOP$3" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                         AS ORDER_ACKNOWLEDGEMENT 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME) AS ORDER_DATE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ORDER_LINETEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORPW)),'')                                                                                         AS ORDER_NUMBER 
            ,T$OPRS.CONSTANTDESCRIPTION                                                                                                          AS ORDER_PROMISINGSTATUSDESCRIPTION 
            ,CAST(T$OPRS AS INT)                                                                                                                 AS ORDER_PROMISINGSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ODNO)),'')                                                                                         AS ORIGINALDOCUMENTNUMBER 
            ,T$ODTY.CONSTANTDESCRIPTION                                                                                                          AS ORIGINALDOCUMENTTYPEDESCRIPTION 
            ,CAST(T$ODTY AS INT)                                                                                                                 AS ORIGINALDOCUMENTTYPEID 
            ,T$PCSR.CONSTANTDESCRIPTION                                                                                                          AS PCS_REVALUATIONDESCRIPTION 
            ,CAST(T$PCSR AS INT)                                                                                                                 AS PCS_REVALUATIONID 
            ,CAST(CASE WHEN T$DDTA<= '1/1/1970' THEN NULL ELSE T$DDTA  END AS DATETIME) AS PLANNEDDELIVERYDATE 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PLANNEDRECEIPTDATE 
            ,CAST(T$OPON AS INT)                                                                                                                 AS POSITIONNUMBER_OPON 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER_PONO 
            ,CAST(T$POSI AS INT)                                                                                                                 AS POSITIONNUMBER_POSI 
            ,CAST(T$PPON AS INT)                                                                                                                 AS POSITIONNUMBER_PPON 
            ,CAST(T$RETP AS INT)                                                                                                                 AS POSITIONNUMBER_RETP 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMDE)),'')                                                                                         AS PRICEMATRIXDEFINITION 
            ,CAST(T$PMSE AS BIGINT)                                                                                                              AS PRICEMATRIXSEQUENCE 
            ,T$PROR.CONSTANTDESCRIPTION                                                                                                          AS PRICEORIGINDESCRIPTION 
            ,CAST(T$PROR AS INT)                                                                                                                 AS PRICEORIGINID 
            ,T$STCD.CONSTANTDESCRIPTION                                                                                                          AS PROCESSEDDESCRIPTION 
            ,CAST(T$STCD AS INT)                                                                                                                 AS PROCESSEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCL)),'')                                                                                         AS PRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLN)),'')                                                                                         AS PRODUCTLINE 
            ,CAST(T$CPVA AS BIGINT)                                                                                                              AS PRODUCTVARIANT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PORN)),'')                                                                                         AS PURCHASEORDER 
            ,CAST(T$QANA AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QONO)),'')                                                                                         AS QUOTATIONNUMBER 
            ,CAST(T$QPON AS INT)                                                                                                                 AS QUOTATIONPOSITION 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,T$CKOR.CONSTANTDESCRIPTION                                                                                                          AS RECORDTYPE1_3DESCRIPTION 
            ,CAST(T$CKOR AS INT)                                                                                                                 AS RECORDTYPE1_3ID 
            ,CAST(CASE WHEN T$RDTA<= '1/1/1970' THEN NULL ELSE T$RDTA  END AS DATETIME) AS RELEASEDATE 
            ,CAST(T$STDC AS NUMERIC(15,2))                                                                                                       AS REMOVE 
            ,CAST(T$RCMP AS INT)                                                                                                                 AS RETURNINVOICECOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETO)),'')                                                                                         AS RETURNORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RETURNTRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'')                                                                                         AS ROUTE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                         AS ROUTEPLAN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS SALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGS)),'')                                                                                         AS SALESSTATISTICSGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS SALESUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEGC)),'')                                                                                         AS SEGMENTCODE 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,CAST(T$PSEQ AS INT)                                                                                                                 AS SEQUENCENUMBER_PSEQ 
            ,CAST(T$RETS AS INT)                                                                                                                 AS SEQUENCENUMBER_RETS 
            ,CAST(T$SERN AS BIGINT)                                                                                                              AS SEQUENCENUMBER_SERN 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCENUMBER_SQNB 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFWH)),'')                                                                                         AS SHIPFROMWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DLNO)),'')                                                                                         AS SHIPMENTID_DLNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS SHIPMENTID_SHPM 
            ,T$SCON.CONSTANTDESCRIPTION                                                                                                          AS SHIPPINGCONSTRAINTDESCRIPTION 
            ,CAST(T$SCON AS INT)                                                                                                                 AS SHIPPINGCONSTRAINTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCN)),'')                                                                                         AS SHIPTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,T$SDSC.CONSTANTDESCRIPTION                                                                                                          AS STANDARDDESCRIPTIONDESCRIPTION 
            ,CAST(T$SDSC AS INT)                                                                                                                 AS STANDARDDESCRIPTIONID 
            ,CAST(CASE WHEN T$SDAT<= '1/1/1970' THEN NULL ELSE T$SDAT  END AS DATETIME) AS STARTDATE 
            ,CAST(T$STPR AS NUMERIC(15,2))                                                                                                       AS STRUCTUREPRICE 
            ,CAST(T$SUSI AS INT)                                                                                                                 AS SUPPLYINGSITE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,CAST(T$THIC AS NUMERIC(15,2))                                                                                                       AS THICKNESS 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,T$DEST.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFORDERDESCRIPTION 
            ,CAST(T$DEST AS INT)                                                                                                                 AS TYPEOFORDERID 
            ,CAST("T$VCOP$1" AS NUMERIC(15,2))                                                                                                     AS VARIABLESTANDARDCOSTAMOUNT1 
            ,CAST("T$VCOP$2" AS NUMERIC(15,2))                                                                                                     AS VARIABLESTANDARDCOSTAMOUNT2 
            ,CAST("T$VCOP$3" AS NUMERIC(15,2))                                                                                                     AS VARIABLESTANDARDCOSTAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
            ,CAST(T$WIDT AS NUMERIC(15,2))                                                                                                       AS WIDTH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS WORKCENTER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDSLS451201") }} AS SOURCETABLE  
            /*BINDING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BIND 
             ON   T$BIND.TABLENAME  = 'TDSLS451' 
              AND T$BIND.COLUMNNAME = 'T$BIND' 
              AND T$BIND.CONSTANT   = SOURCETABLE.T$BIND 
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BKYN 
             ON   T$BKYN.TABLENAME  = 'TDSLS451' 
              AND T$BKYN.COLUMNNAME = 'T$BKYN' 
              AND T$BKYN.CONSTANT   = SOURCETABLE.T$BKYN 
            /*CUMMUPDATEDFORCOMM*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CUCM 
             ON   T$CUCM.TABLENAME  = 'TDSLS451' 
              AND T$CUCM.COLUMNNAME = 'T$CUCM' 
              AND T$CUCM.CONSTANT   = SOURCETABLE.T$CUCM 
            /*CUMMUPDATEFORREBT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CURB 
             ON   T$CURB.TABLENAME  = 'TDSLS451' 
              AND T$CURB.COLUMNNAME = 'T$CURB' 
              AND T$CURB.CONSTANT   = SOURCETABLE.T$CURB 
            /*DEMANDUPDATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEMD 
             ON   T$DEMD.TABLENAME  = 'TDSLS451' 
              AND T$DEMD.COLUMNNAME = 'T$DEMD' 
              AND T$DEMD.CONSTANT   = SOURCETABLE.T$DEMD 
            /*DETERMINING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTRM 
             ON   T$DTRM.TABLENAME  = 'TDSLS451' 
              AND T$DTRM.COLUMNNAME = 'T$DTRM' 
              AND T$DTRM.CONSTANT   = SOURCETABLE.T$DTRM 
            /*DIRECTDELIVERY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DRCT 
             ON   T$DRCT.TABLENAME  = 'TDSLS451' 
              AND T$DRCT.COLUMNNAME = 'T$DRCT' 
              AND T$DRCT.CONSTANT   = SOURCETABLE.T$DRCT 
            /*DISCOUNTMATRIXTYPE1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$1" 
             ON   "T$DMTY$1".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$1".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$1".CONSTANT   = SOURCETABLE."T$DMTY$1" 
            /*DISCOUNTMATRIXTYPE2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$2" 
             ON   "T$DMTY$2".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$2".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$2".CONSTANT   = SOURCETABLE."T$DMTY$2" 
            /*DISCOUNTMATRIXTYPE3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$3" 
             ON   "T$DMTY$3".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$3".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$3".CONSTANT   = SOURCETABLE."T$DMTY$3" 
            /*DISCOUNTMATRIXTYPE4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$4" 
             ON   "T$DMTY$4".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$4".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$4".CONSTANT   = SOURCETABLE."T$DMTY$4" 
            /*DISCOUNTMATRIXTYPE5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTY$5" 
             ON   "T$DMTY$5".TABLENAME  = 'TDSLS451' 
              AND "T$DMTY$5".COLUMNNAME = 'T$DMTY' 
              AND "T$DMTY$5".CONSTANT   = SOURCETABLE."T$DMTY$5" 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$1" 
             ON   "T$DMTH$1".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$1".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$1".CONSTANT   = SOURCETABLE."T$DMTH$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$2" 
             ON   "T$DMTH$2".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$2".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$2".CONSTANT   = SOURCETABLE."T$DMTH$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$3" 
             ON   "T$DMTH$3".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$3".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$3".CONSTANT   = SOURCETABLE."T$DMTH$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$4" 
             ON   "T$DMTH$4".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$4".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$4".CONSTANT   = SOURCETABLE."T$DMTH$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DMTH$5" 
             ON   "T$DMTH$5".TABLENAME  = 'TDSLS451' 
              AND "T$DMTH$5".COLUMNNAME = 'T$DMTH' 
              AND "T$DMTH$5".CONSTANT   = SOURCETABLE."T$DMTH$5" 
            /*ELIGIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ELGB 
             ON   T$ELGB.TABLENAME  = 'TDSLS451' 
              AND T$ELGB.COLUMNNAME = 'T$ELGB' 
              AND T$ELGB.CONSTANT   = SOURCETABLE.T$ELGB 
            /*INVENTORYISSUESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISSS 
             ON   T$ISSS.TABLENAME  = 'TDSLS451' 
              AND T$ISSS.COLUMNNAME = 'T$ISSS' 
              AND T$ISSS.CONSTANT   = SOURCETABLE.T$ISSS 
            /*LOSTSALESUPDATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LOST 
             ON   T$LOST.TABLENAME  = 'TDSLS451' 
              AND T$LOST.COLUMNNAME = 'T$LOST' 
              AND T$LOST.CONSTANT   = SOURCETABLE.T$LOST 
            /*LOTSELECT TOP 10*/  
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LSEL 
             ON   T$LSEL.TABLENAME  = 'TDSLS451' 
              AND T$LSEL.COLUMNNAME = 'T$LSEL' 
              AND T$LSEL.CONSTANT   = SOURCETABLE.T$LSEL 
            /*MAKECUSTOMIZED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPOL 
             ON   T$OPOL.TABLENAME  = 'TDSLS451' 
              AND T$OPOL.COLUMNNAME = 'T$OPOL' 
              AND T$OPOL.CONSTANT   = SOURCETABLE.T$OPOL 
            /*ORDERPROMISINGSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OPRS 
             ON   T$OPRS.TABLENAME  = 'TDSLS451' 
              AND T$OPRS.COLUMNNAME = 'T$OPRS' 
              AND T$OPRS.CONSTANT   = SOURCETABLE.T$OPRS 
            /*ORIGINALDOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ODTY 
             ON   T$ODTY.TABLENAME  = 'TDSLS451' 
              AND T$ODTY.COLUMNNAME = 'T$ODTY' 
              AND T$ODTY.CONSTANT   = SOURCETABLE.T$ODTY 
            /*PCS_REVALUATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PCSR 
             ON   T$PCSR.TABLENAME  = 'TDSLS451' 
              AND T$PCSR.COLUMNNAME = 'T$PCSR' 
              AND T$PCSR.CONSTANT   = SOURCETABLE.T$PCSR 
            /*PRICEORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PROR 
             ON   T$PROR.TABLENAME  = 'TDSLS451' 
              AND T$PROR.COLUMNNAME = 'T$PROR' 
              AND T$PROR.CONSTANT   = SOURCETABLE.T$PROR 
            /*PROCESSED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STCD 
             ON   T$STCD.TABLENAME  = 'TDSLS451' 
              AND T$STCD.COLUMNNAME = 'T$STCD' 
              AND T$STCD.CONSTANT   = SOURCETABLE.T$STCD 
            /*RECORDTYPE1_3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CKOR 
             ON   T$CKOR.TABLENAME  = 'TDSLS451' 
              AND T$CKOR.COLUMNNAME = 'T$CKOR' 
              AND T$CKOR.CONSTANT   = SOURCETABLE.T$CKOR 
            /*SHIPPINGCONSTRAINT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCON 
             ON   T$SCON.TABLENAME  = 'TDSLS451' 
              AND T$SCON.COLUMNNAME = 'T$SCON' 
              AND T$SCON.CONSTANT   = SOURCETABLE.T$SCON 
            /*STANDARDDESCRIPTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SDSC 
             ON   T$SDSC.TABLENAME  = 'TDSLS451' 
              AND T$SDSC.COLUMNNAME = 'T$SDSC' 
              AND T$SDSC.CONSTANT   = SOURCETABLE.T$SDSC 
            /*TYPEOFORDER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEST 
             ON   T$DEST.TABLENAME  = 'TDSLS451' 
              AND T$DEST.COLUMNNAME = 'T$DEST' 
              AND T$DEST.CONSTANT   = SOURCETABLE.T$DEST 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ALTERNATIVE AS ALTERNATIVE, 
        source_data.AMOUNT AS AMOUNT, 
        source_data.BINDINGDESCRIPTION AS BINDINGDESCRIPTION, 
        source_data.BINDINGID AS BINDINGID, 
        source_data.BLOCKEDDESCRIPTION AS BLOCKEDDESCRIPTION, 
        source_data.BLOCKEDID AS BLOCKEDID, 
        source_data.CHANGEORDERSEQUENCENUMBER AS CHANGEORDERSEQUENCENUMBER, 
        source_data.CHANGEREASONLINES AS CHANGEREASONLINES, 
        source_data.CHANGETYPELINES AS CHANGETYPELINES, 
        source_data.CHANNELS AS CHANNELS, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTRACT AS CONTRACT, 
        source_data.CONVERSIONFACTORPRICETOINVENTORYUNIT AS CONVERSIONFACTORPRICETOINVENTORYUNIT, 
        source_data.CONVERSIONFACTORSALESTOINVENTORYUNIT AS CONVERSIONFACTORSALESTOINVENTORYUNIT, 
        source_data.COSTAMOUNTOFODSSOLD1 AS COSTAMOUNTOFODSSOLD1, 
        source_data.COSTAMOUNTOFODSSOLD2 AS COSTAMOUNTOFODSSOLD2, 
        source_data.COSTAMOUNTOFODSSOLD3 AS COSTAMOUNTOFODSSOLD3, 
        source_data.COUNTRY AS COUNTRY, 
        source_data.CUMMUPDATEDFORCOMMDESCRIPTION AS CUMMUPDATEDFORCOMMDESCRIPTION, 
        source_data.CUMMUPDATEDFORCOMMID AS CUMMUPDATEDFORCOMMID, 
        source_data.CUMMUPDATEFORREBTDESCRIPTION AS CUMMUPDATEFORREBTDESCRIPTION, 
        source_data.CUMMUPDATEFORREBTID AS CUMMUPDATEFORREBTID, 
        source_data.CURRENCYRATESALES1 AS CURRENCYRATESALES1, 
        source_data.CURRENCYRATESALES2 AS CURRENCYRATESALES2, 
        source_data.CURRENCYRATESALES3 AS CURRENCYRATESALES3, 
        source_data.CUSTOMERORDERNUMBER AS CUSTOMERORDERNUMBER, 
        source_data.CUSTOMERPOSITIONNUMBER AS CUSTOMERPOSITIONNUMBER, 
        source_data.CUSTOMERSEQUENCENUMBER AS CUSTOMERSEQUENCENUMBER, 
        source_data.DELIVERYDATE AS DELIVERYDATE, 
        source_data.DEMANDUPDATEDDESCRIPTION AS DEMANDUPDATEDDESCRIPTION, 
        source_data.DEMANDUPDATEDID AS DEMANDUPDATEDID, 
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
        source_data.DISCOUNTPERCENTAGE1 AS DISCOUNTPERCENTAGE1, 
        source_data.DISCOUNTPERCENTAGE2 AS DISCOUNTPERCENTAGE2, 
        source_data.DISCOUNTPERCENTAGE3 AS DISCOUNTPERCENTAGE3, 
        source_data.DISCOUNTPERCENTAGE4 AS DISCOUNTPERCENTAGE4, 
        source_data.DISCOUNTPERCENTAGE5 AS DISCOUNTPERCENTAGE5, 
        source_data.ELIGIBLEDESCRIPTION AS ELIGIBLEDESCRIPTION, 
        source_data.ELIGIBLEID AS ELIGIBLEID, 
        source_data.ENDDATE AS ENDDATE, 
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
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMCODESYSTEM AS ITEMCODESYSTEM, 
        source_data.ITEMGROUP AS ITEMGROUP, 
        source_data.LENGTH AS LENGTH, 
        source_data.LOGNAME AS LOGNAME, 
        source_data.LOSTSALESUPDATEDDESCRIPTION AS LOSTSALESUPDATEDDESCRIPTION, 
        source_data.LOSTSALESUPDATEDID AS LOSTSALESUPDATEDID, 
        source_data.LOT AS LOT, 
        source_data.LOTSELECTIONDESCRIPTION AS LOTSELECTIONDESCRIPTION, 
        source_data.LOTSELECTIONID AS LOTSELECTIONID, 
        source_data.MAKECUSTOMIZEDDESCRIPTION AS MAKECUSTOMIZEDDESCRIPTION, 
        source_data.MAKECUSTOMIZEDID AS MAKECUSTOMIZEDID, 
        source_data.MANUFACTURER AS MANUFACTURER, 
        source_data.OPERATIONCOSTS1 AS OPERATIONCOSTS1, 
        source_data.OPERATIONCOSTS2 AS OPERATIONCOSTS2, 
        source_data.OPERATIONCOSTS3 AS OPERATIONCOSTS3, 
        source_data.ORDER_ACKNOWLEDGEMENT AS ORDER_ACKNOWLEDGEMENT, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_LINETEXT AS ORDER_LINETEXT, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.ORDER_PROMISINGSTATUSDESCRIPTION AS ORDER_PROMISINGSTATUSDESCRIPTION, 
        source_data.ORDER_PROMISINGSTATUSID AS ORDER_PROMISINGSTATUSID, 
        source_data.ORIGINALDOCUMENTNUMBER AS ORIGINALDOCUMENTNUMBER, 
        source_data.ORIGINALDOCUMENTTYPEDESCRIPTION AS ORIGINALDOCUMENTTYPEDESCRIPTION, 
        source_data.ORIGINALDOCUMENTTYPEID AS ORIGINALDOCUMENTTYPEID, 
        source_data.PCS_REVALUATIONDESCRIPTION AS PCS_REVALUATIONDESCRIPTION, 
        source_data.PCS_REVALUATIONID AS PCS_REVALUATIONID, 
        source_data.PLANNEDDELIVERYDATE AS PLANNEDDELIVERYDATE, 
        source_data.PLANNEDRECEIPTDATE AS PLANNEDRECEIPTDATE, 
        source_data.POSITIONNUMBER_OPON AS POSITIONNUMBER_OPON, 
        source_data.POSITIONNUMBER_PONO AS POSITIONNUMBER_PONO, 
        source_data.POSITIONNUMBER_POSI AS POSITIONNUMBER_POSI, 
        source_data.POSITIONNUMBER_PPON AS POSITIONNUMBER_PPON, 
        source_data.POSITIONNUMBER_RETP AS POSITIONNUMBER_RETP, 
        source_data.PRICE AS PRICE, 
        source_data.PRICEMATRIXDEFINITION AS PRICEMATRIXDEFINITION, 
        source_data.PRICEMATRIXSEQUENCE AS PRICEMATRIXSEQUENCE, 
        source_data.PRICEORIGINDESCRIPTION AS PRICEORIGINDESCRIPTION, 
        source_data.PRICEORIGINID AS PRICEORIGINID, 
        source_data.PROCESSEDDESCRIPTION AS PROCESSEDDESCRIPTION, 
        source_data.PROCESSEDID AS PROCESSEDID, 
        source_data.PRODUCTCLASS AS PRODUCTCLASS, 
        source_data.PRODUCTLINE AS PRODUCTLINE, 
        source_data.PRODUCTVARIANT AS PRODUCTVARIANT, 
        source_data.PROJECT AS PROJECT, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.QUANTITY AS QUANTITY, 
        source_data.QUOTATIONNUMBER AS QUOTATIONNUMBER, 
        source_data.QUOTATIONPOSITION AS QUOTATIONPOSITION, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.RECORDTYPE1_3DESCRIPTION AS RECORDTYPE1_3DESCRIPTION, 
        source_data.RECORDTYPE1_3ID AS RECORDTYPE1_3ID, 
        source_data.RELEASEDATE AS RELEASEDATE, 
        source_data.REMOVE AS REMOVE, 
        source_data.RETURNINVOICECOMPANY AS RETURNINVOICECOMPANY, 
        source_data.RETURNORDER AS RETURNORDER, 
        source_data.RETURNTRANSACTIONTYPE AS RETURNTRANSACTIONTYPE, 
        source_data.ROUTE AS ROUTE, 
        source_data.ROUTEPLAN AS ROUTEPLAN, 
        source_data.SALESOFFICE AS SALESOFFICE, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SALESPRICEUNIT AS SALESPRICEUNIT, 
        source_data.SALESSTATISTICSGROUP AS SALESSTATISTICSGROUP, 
        source_data.SALESUNIT AS SALESUNIT, 
        source_data.SEGMENTCODE AS SEGMENTCODE, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.SEQUENCENUMBER_PSEQ AS SEQUENCENUMBER_PSEQ, 
        source_data.SEQUENCENUMBER_RETS AS SEQUENCENUMBER_RETS, 
        source_data.SEQUENCENUMBER_SERN AS SEQUENCENUMBER_SERN, 
        source_data.SEQUENCENUMBER_SQNB AS SEQUENCENUMBER_SQNB, 
        source_data.SHIPFROMWAREHOUSE AS SHIPFROMWAREHOUSE, 
        source_data.SHIPMENTID_DLNO AS SHIPMENTID_DLNO, 
        source_data.SHIPMENTID_SHPM AS SHIPMENTID_SHPM, 
        source_data.SHIPPINGCONSTRAINTDESCRIPTION AS SHIPPINGCONSTRAINTDESCRIPTION, 
        source_data.SHIPPINGCONSTRAINTID AS SHIPPINGCONSTRAINTID, 
        source_data.SHIPTOADDRESS AS SHIPTOADDRESS, 
        source_data.SHIPTOBUSINESSPARTNER AS SHIPTOBUSINESSPARTNER, 
        source_data.SHIPTOCONTACT AS SHIPTOCONTACT, 
        source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER, 
        source_data.STANDARDDESCRIPTIONDESCRIPTION AS STANDARDDESCRIPTIONDESCRIPTION, 
        source_data.STANDARDDESCRIPTIONID AS STANDARDDESCRIPTIONID, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.STRUCTUREPRICE AS STRUCTUREPRICE, 
        source_data.SUPPLYINGSITE AS SUPPLYINGSITE, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.THICKNESS AS THICKNESS, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE, 
        source_data.TYPEOFORDERDESCRIPTION AS TYPEOFORDERDESCRIPTION, 
        source_data.TYPEOFORDERID AS TYPEOFORDERID, 
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
        cast(ALTERNATIVE as NUMBER(38,0)) as ALTERNATIVE,
        cast(AMOUNT as NUMBER(15,2)) as AMOUNT,
        cast(BINDINGDESCRIPTION as VARCHAR(16777216)) as BINDINGDESCRIPTION,
        cast(BINDINGID as NUMBER(38,0)) as BINDINGID,
        cast(BLOCKEDDESCRIPTION as VARCHAR(16777216)) as BLOCKEDDESCRIPTION,
        cast(BLOCKEDID as NUMBER(38,0)) as BLOCKEDID,
        cast(CHANGEORDERSEQUENCENUMBER as VARCHAR(8)) as CHANGEORDERSEQUENCENUMBER,
        cast(CHANGEREASONLINES as VARCHAR(6)) as CHANGEREASONLINES,
        cast(CHANGETYPELINES as VARCHAR(6)) as CHANGETYPELINES,
        cast(CHANNELS as VARCHAR(3)) as CHANNELS,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTRACT as VARCHAR(9)) as CONTRACT,
        cast(CONVERSIONFACTORPRICETOINVENTORYUNIT as NUMBER(15,2)) as CONVERSIONFACTORPRICETOINVENTORYUNIT,
        cast(CONVERSIONFACTORSALESTOINVENTORYUNIT as NUMBER(15,2)) as CONVERSIONFACTORSALESTOINVENTORYUNIT,
        cast(COSTAMOUNTOFODSSOLD1 as NUMBER(15,2)) as COSTAMOUNTOFODSSOLD1,
        cast(COSTAMOUNTOFODSSOLD2 as NUMBER(15,2)) as COSTAMOUNTOFODSSOLD2,
        cast(COSTAMOUNTOFODSSOLD3 as NUMBER(15,2)) as COSTAMOUNTOFODSSOLD3,
        cast(COUNTRY as VARCHAR(3)) as COUNTRY,
        cast(CUMMUPDATEDFORCOMMDESCRIPTION as VARCHAR(16777216)) as CUMMUPDATEDFORCOMMDESCRIPTION,
        cast(CUMMUPDATEDFORCOMMID as NUMBER(38,0)) as CUMMUPDATEDFORCOMMID,
        cast(CUMMUPDATEFORREBTDESCRIPTION as VARCHAR(16777216)) as CUMMUPDATEFORREBTDESCRIPTION,
        cast(CUMMUPDATEFORREBTID as NUMBER(38,0)) as CUMMUPDATEFORREBTID,
        cast(CURRENCYRATESALES1 as NUMBER(15,2)) as CURRENCYRATESALES1,
        cast(CURRENCYRATESALES2 as NUMBER(15,2)) as CURRENCYRATESALES2,
        cast(CURRENCYRATESALES3 as NUMBER(15,2)) as CURRENCYRATESALES3,
        cast(CUSTOMERORDERNUMBER as VARCHAR(30)) as CUSTOMERORDERNUMBER,
        cast(CUSTOMERPOSITIONNUMBER as VARCHAR(16)) as CUSTOMERPOSITIONNUMBER,
        cast(CUSTOMERSEQUENCENUMBER as VARCHAR(11)) as CUSTOMERSEQUENCENUMBER,
        cast(DELIVERYDATE as TIMESTAMP_NTZ(9)) as DELIVERYDATE,
        cast(DEMANDUPDATEDDESCRIPTION as VARCHAR(16777216)) as DEMANDUPDATEDDESCRIPTION,
        cast(DEMANDUPDATEDID as NUMBER(38,0)) as DEMANDUPDATEDID,
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
        cast(DISCOUNTPERCENTAGE1 as NUMBER(15,2)) as DISCOUNTPERCENTAGE1,
        cast(DISCOUNTPERCENTAGE2 as NUMBER(15,2)) as DISCOUNTPERCENTAGE2,
        cast(DISCOUNTPERCENTAGE3 as NUMBER(15,2)) as DISCOUNTPERCENTAGE3,
        cast(DISCOUNTPERCENTAGE4 as NUMBER(15,2)) as DISCOUNTPERCENTAGE4,
        cast(DISCOUNTPERCENTAGE5 as NUMBER(15,2)) as DISCOUNTPERCENTAGE5,
        cast(ELIGIBLEDESCRIPTION as VARCHAR(16777216)) as ELIGIBLEDESCRIPTION,
        cast(ELIGIBLEID as NUMBER(38,0)) as ELIGIBLEID,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
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
        cast(INVOICENUMBER as NUMBER(38,0)) as INVOICENUMBER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ITEMCODESYSTEM as VARCHAR(3)) as ITEMCODESYSTEM,
        cast(ITEMGROUP as VARCHAR(6)) as ITEMGROUP,
        cast(LENGTH as NUMBER(15,2)) as LENGTH,
        cast(LOGNAME as VARCHAR(16)) as LOGNAME,
        cast(LOSTSALESUPDATEDDESCRIPTION as VARCHAR(16777216)) as LOSTSALESUPDATEDDESCRIPTION,
        cast(LOSTSALESUPDATEDID as NUMBER(38,0)) as LOSTSALESUPDATEDID,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(LOTSELECTIONDESCRIPTION as VARCHAR(16777216)) as LOTSELECTIONDESCRIPTION,
        cast(LOTSELECTIONID as NUMBER(38,0)) as LOTSELECTIONID,
        cast(MAKECUSTOMIZEDDESCRIPTION as VARCHAR(16777216)) as MAKECUSTOMIZEDDESCRIPTION,
        cast(MAKECUSTOMIZEDID as NUMBER(38,0)) as MAKECUSTOMIZEDID,
        cast(MANUFACTURER as VARCHAR(6)) as MANUFACTURER,
        cast(OPERATIONCOSTS1 as NUMBER(15,2)) as OPERATIONCOSTS1,
        cast(OPERATIONCOSTS2 as NUMBER(15,2)) as OPERATIONCOSTS2,
        cast(OPERATIONCOSTS3 as NUMBER(15,2)) as OPERATIONCOSTS3,
        cast(ORDER_ACKNOWLEDGEMENT as VARCHAR(2)) as ORDER_ACKNOWLEDGEMENT,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_LINETEXT as NUMBER(38,10)) as ORDER_LINETEXT,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORDER_PROMISINGSTATUSDESCRIPTION as VARCHAR(16777216)) as ORDER_PROMISINGSTATUSDESCRIPTION,
        cast(ORDER_PROMISINGSTATUSID as NUMBER(38,0)) as ORDER_PROMISINGSTATUSID,
        cast(ORIGINALDOCUMENTNUMBER as VARCHAR(9)) as ORIGINALDOCUMENTNUMBER,
        cast(ORIGINALDOCUMENTTYPEDESCRIPTION as VARCHAR(16777216)) as ORIGINALDOCUMENTTYPEDESCRIPTION,
        cast(ORIGINALDOCUMENTTYPEID as NUMBER(38,0)) as ORIGINALDOCUMENTTYPEID,
        cast(PCS_REVALUATIONDESCRIPTION as VARCHAR(16777216)) as PCS_REVALUATIONDESCRIPTION,
        cast(PCS_REVALUATIONID as NUMBER(38,0)) as PCS_REVALUATIONID,
        cast(PLANNEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as PLANNEDDELIVERYDATE,
        cast(PLANNEDRECEIPTDATE as TIMESTAMP_NTZ(9)) as PLANNEDRECEIPTDATE,
        cast(POSITIONNUMBER_OPON as NUMBER(38,0)) as POSITIONNUMBER_OPON,
        cast(POSITIONNUMBER_PONO as NUMBER(38,0)) as POSITIONNUMBER_PONO,
        cast(POSITIONNUMBER_POSI as NUMBER(38,0)) as POSITIONNUMBER_POSI,
        cast(POSITIONNUMBER_PPON as NUMBER(38,0)) as POSITIONNUMBER_PPON,
        cast(POSITIONNUMBER_RETP as NUMBER(38,0)) as POSITIONNUMBER_RETP,
        cast(PRICE as NUMBER(15,2)) as PRICE,
        cast(PRICEMATRIXDEFINITION as VARCHAR(6)) as PRICEMATRIXDEFINITION,
        cast(PRICEMATRIXSEQUENCE as NUMBER(38,0)) as PRICEMATRIXSEQUENCE,
        cast(PRICEORIGINDESCRIPTION as VARCHAR(16777216)) as PRICEORIGINDESCRIPTION,
        cast(PRICEORIGINID as NUMBER(38,0)) as PRICEORIGINID,
        cast(PROCESSEDDESCRIPTION as VARCHAR(16777216)) as PROCESSEDDESCRIPTION,
        cast(PROCESSEDID as NUMBER(38,0)) as PROCESSEDID,
        cast(PRODUCTCLASS as VARCHAR(6)) as PRODUCTCLASS,
        cast(PRODUCTLINE as VARCHAR(6)) as PRODUCTLINE,
        cast(PRODUCTVARIANT as NUMBER(38,0)) as PRODUCTVARIANT,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(PURCHASEORDER as VARCHAR(9)) as PURCHASEORDER,
        cast(QUANTITY as NUMBER(15,2)) as QUANTITY,
        cast(QUOTATIONNUMBER as VARCHAR(9)) as QUOTATIONNUMBER,
        cast(QUOTATIONPOSITION as NUMBER(38,0)) as QUOTATIONPOSITION,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(RECORDTYPE1_3DESCRIPTION as VARCHAR(16777216)) as RECORDTYPE1_3DESCRIPTION,
        cast(RECORDTYPE1_3ID as NUMBER(38,0)) as RECORDTYPE1_3ID,
        cast(RELEASEDATE as TIMESTAMP_NTZ(9)) as RELEASEDATE,
        cast(REMOVE as NUMBER(15,2)) as REMOVE,
        cast(RETURNINVOICECOMPANY as NUMBER(38,0)) as RETURNINVOICECOMPANY,
        cast(RETURNORDER as VARCHAR(9)) as RETURNORDER,
        cast(RETURNTRANSACTIONTYPE as VARCHAR(3)) as RETURNTRANSACTIONTYPE,
        cast(ROUTE as VARCHAR(5)) as ROUTE,
        cast(ROUTEPLAN as VARCHAR(3)) as ROUTEPLAN,
        cast(SALESOFFICE as VARCHAR(6)) as SALESOFFICE,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SALESPRICEUNIT as VARCHAR(3)) as SALESPRICEUNIT,
        cast(SALESSTATISTICSGROUP as VARCHAR(6)) as SALESSTATISTICSGROUP,
        cast(SALESUNIT as VARCHAR(3)) as SALESUNIT,
        cast(SEGMENTCODE as VARCHAR(3)) as SEGMENTCODE,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(SEQUENCENUMBER_PSEQ as NUMBER(38,0)) as SEQUENCENUMBER_PSEQ,
        cast(SEQUENCENUMBER_RETS as NUMBER(38,0)) as SEQUENCENUMBER_RETS,
        cast(SEQUENCENUMBER_SERN as NUMBER(38,0)) as SEQUENCENUMBER_SERN,
        cast(SEQUENCENUMBER_SQNB as NUMBER(38,0)) as SEQUENCENUMBER_SQNB,
        cast(SHIPFROMWAREHOUSE as VARCHAR(6)) as SHIPFROMWAREHOUSE,
        cast(SHIPMENTID_DLNO as VARCHAR(16)) as SHIPMENTID_DLNO,
        cast(SHIPMENTID_SHPM as VARCHAR(9)) as SHIPMENTID_SHPM,
        cast(SHIPPINGCONSTRAINTDESCRIPTION as VARCHAR(16777216)) as SHIPPINGCONSTRAINTDESCRIPTION,
        cast(SHIPPINGCONSTRAINTID as NUMBER(38,0)) as SHIPPINGCONSTRAINTID,
        cast(SHIPTOADDRESS as VARCHAR(9)) as SHIPTOADDRESS,
        cast(SHIPTOBUSINESSPARTNER as VARCHAR(9)) as SHIPTOBUSINESSPARTNER,
        cast(SHIPTOCONTACT as VARCHAR(9)) as SHIPTOCONTACT,
        cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
        cast(STANDARDDESCRIPTIONDESCRIPTION as VARCHAR(16777216)) as STANDARDDESCRIPTIONDESCRIPTION,
        cast(STANDARDDESCRIPTIONID as NUMBER(38,0)) as STANDARDDESCRIPTIONID,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(STRUCTUREPRICE as NUMBER(15,2)) as STRUCTUREPRICE,
        cast(SUPPLYINGSITE as NUMBER(38,0)) as SUPPLYINGSITE,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(THICKNESS as NUMBER(15,2)) as THICKNESS,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(TYPEOFORDERDESCRIPTION as VARCHAR(16777216)) as TYPEOFORDERDESCRIPTION,
        cast(TYPEOFORDERID as NUMBER(38,0)) as TYPEOFORDERID,
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