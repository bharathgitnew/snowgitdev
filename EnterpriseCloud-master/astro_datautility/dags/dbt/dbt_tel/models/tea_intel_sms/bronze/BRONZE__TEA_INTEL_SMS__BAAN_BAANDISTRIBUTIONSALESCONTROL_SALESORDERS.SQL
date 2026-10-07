/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONSALESCONTROL_SALESORDERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONSALESCONTROL_SALESORDERS.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONSALESCONTROL_SALESORDERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:51 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANDISTRIBUTIONSALESCONTROL_SALESORDERS',
    unique_key = ['SALESORDER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREG)),'')                                                                                         AS AREA 
            ,T$BKYN.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BKYN AS INT)                                                                                                                 AS BLOCKEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPTX)),'')                                                                                         AS BPARTNERTEXTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPPR)),'')                                                                                         AS BPPRICESDISC 
            ,T$CLYN.CONSTANTDESCRIPTION                                                                                                          AS CANCELLEDDESCRIPTION 
            ,CAST(T$CLYN AS INT)                                                                                                                 AS CANCELLEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                         AS CARRIER 
            ,CAST("T$CASE$U" AS BIGINT)                                                                                                            AS CASENOSALESFORCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                         AS CHANGEORDERSEQNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                         AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                         AS CHANGETYPELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRNO)),'')                                                                                         AS CONTRACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRMC$U")),'')                                                                                       AS CRM_CASE_hash_ 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                         AS CUSTOMERORDERNUMBER 
            ,T$AGEN.CONSTANTDESCRIPTION                                                                                                          AS EDIACKNOWLEDGEMENTGENERATEDDESCRIPTION 
            ,CAST(T$AGEN AS INT)                                                                                                                 AS EDIACKNOWLEDGEMENTGENERATEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                         AS EXCHANGERATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFCG)),'')                                                                                         AS FINANCIALCUSTOMERGROUP 
            ,T$FCRT.CONSTANTDESCRIPTION                                                                                                          AS FIXEDRATEDESCRIPTION 
            ,CAST(T$FCRT AS INT)                                                                                                                 AS FIXEDRATEID 
            ,CAST(T$XHKY AS NUMERIC(15,2))                                                                                                       AS FRONTOFFICEHEADER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREP)),'')                                                                                         AS INSIDESALESREP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITAD)),'')                                                                                         AS INVOICETOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITCN)),'')                                                                                         AS INVOICETOCONTACT 
            ,T$FUTO.CONSTANTDESCRIPTION                                                                                                          AS INVOICINGBYINSTALLMENTSDESCRIPTION 
            ,CAST(T$FUTO AS INT)                                                                                                                 AS INVOICINGBYINSTALLMENTSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                         AS LINEOFBUSINESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$LOGN$U")),'')                                                                                       AS LOGINCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS ORDER_CURRENCY 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME) AS ORDER_DATE 
            ,CAST(T$ODIS AS NUMERIC(15,2))                                                                                                       AS ORDER_DISCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ORTP$U")),'')                                                                                       AS ORDER_ENTRYMETHOD 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS ORDER_FOOTERTEXT 
            ,"T$PRIO$U".CONSTANTDESCRIPTION                                                                                                        AS ORDER_PRIORITYDESCRIPTION 
            ,CAST("T$PRIO$U" AS INT)                                                                                                               AS ORDER_PRIORITYID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ORDER_TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ODNO)),'')                                                                                         AS ORIGINALDOCUMENTNUMBER 
            ,T$ODTY.CONSTANTDESCRIPTION                                                                                                          AS ORIGINALDOCUMENTTYPEDESCRIPTION 
            ,CAST(T$ODTY AS INT)                                                                                                                 AS ORIGINALDOCUMENTTYPEID 
            ,T$CORG.CONSTANTDESCRIPTION                                                                                                          AS ORIGINDESCRIPTION 
            ,CAST(T$CORG AS INT)                                                                                                                 AS ORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OSRP)),'')                                                                                         AS OUTSIDESALESREP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFAD)),'')                                                                                         AS PAYBYADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYBYBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFCN)),'')                                                                                         AS PAYBYCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTMETHOD 
            ,CAST(CASE WHEN T$DDAT<= '1/1/1970' THEN NULL ELSE T$DDAT  END AS DATETIME) AS PLANDELDATE 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PLANNEDRECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PLDD)),'')                                                                                         AS PRICELISTFORDIRECTDELIVERY 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFA)),'')                                                                                         AS REFERENCEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFB)),'')                                                                                         AS REFERENCEB 
            ,CAST(T$RCMP AS INT)                                                                                                                 AS RETURNINVOICECOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETR)),'')                                                                                         AS RETURNREASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RETURNTRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'')                                                                                         AS ROUTE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                         AS ROUTEPLAN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                         AS SALESACKNOWLEDGEMENTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS SALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SOTP)),'')                                                                                         AS SALESORDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLS)),'')                                                                                         AS SALESPRICELIST 
            ,T$SBIM.CONSTANTDESCRIPTION                                                                                                          AS SELFBILLEDINVOICEDESCRIPTION 
            ,CAST(T$SBIM AS INT)                                                                                                                 AS SELFBILLEDINVOICEID 
            ,T$SCON.CONSTANTDESCRIPTION                                                                                                          AS SHIPPINGCONSTRAINTDESCRIPTION 
            ,CAST(T$SCON AS INT)                                                                                                                 AS SHIPPINGCONSTRAINTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCN)),'')                                                                                         AS SHIPTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFAD)),'')                                                                                         AS SOLDTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFCN)),'')                                                                                         AS SOLDTOCONTACT 
            ,T$CVYN.CONSTANTDESCRIPTION                                                                                                          AS TAXDESCRIPTION 
            ,CAST(T$CVYN AS INT)                                                                                                                 AS TAXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDEC)),'')                                                                                         AS TERMSOFDELIVERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDSLS400200") }} AS SOURCETABLE  
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BKYN 
             ON   T$BKYN.TABLENAME  = 'TDSLS400' 
              AND T$BKYN.COLUMNNAME = 'T$BKYN' 
              AND T$BKYN.CONSTANT   = SOURCETABLE.T$BKYN 
            /*CANCELLED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLYN 
             ON   T$CLYN.TABLENAME  = 'TDSLS400' 
              AND T$CLYN.COLUMNNAME = 'T$CLYN' 
              AND T$CLYN.CONSTANT   = SOURCETABLE.T$CLYN 
            /*EDIACKNOWLEDGEMENTGENERATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AGEN 
             ON   T$AGEN.TABLENAME  = 'TDSLS400' 
              AND T$AGEN.COLUMNNAME = 'T$AGEN' 
              AND T$AGEN.CONSTANT   = SOURCETABLE.T$AGEN 
            /*FIXEDRATE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FCRT 
             ON   T$FCRT.TABLENAME  = 'TDSLS400' 
              AND T$FCRT.COLUMNNAME = 'T$FCRT' 
              AND T$FCRT.CONSTANT   = SOURCETABLE.T$FCRT 
            /*INVOICINGBYINSTALLMENTS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FUTO 
             ON   T$FUTO.TABLENAME  = 'TDSLS400' 
              AND T$FUTO.COLUMNNAME = 'T$FUTO' 
              AND T$FUTO.CONSTANT   = SOURCETABLE.T$FUTO 
            /*ORDERPRIORITYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRIO$U" 
             ON   "T$PRIO$U".TABLENAME  = 'TDSLS400' 
              AND "T$PRIO$U".COLUMNNAME = 'T$PRIO.U' 
              AND "T$PRIO$U".CONSTANT   = SOURCETABLE."T$PRIO$U" 
            /*ORIGINALDOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ODTY 
             ON   T$ODTY.TABLENAME  = 'TDSLS400' 
              AND T$ODTY.COLUMNNAME = 'T$ODTY' 
              AND T$ODTY.CONSTANT   = SOURCETABLE.T$ODTY 
            /*ORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CORG 
             ON   T$CORG.TABLENAME  = 'TDSLS400' 
              AND T$CORG.COLUMNNAME = 'T$CORG' 
              AND T$CORG.CONSTANT   = SOURCETABLE.T$CORG 
            /*SELFBILLEDINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SBIM 
             ON   T$SBIM.TABLENAME  = 'TDSLS400' 
              AND T$SBIM.COLUMNNAME = 'T$SBIM' 
              AND T$SBIM.CONSTANT   = SOURCETABLE.T$SBIM 
            /*SHIPPINGCONSTRAINT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCON 
             ON   T$SCON.TABLENAME  = 'TDSLS400' 
              AND T$SCON.COLUMNNAME = 'T$SCON' 
              AND T$SCON.CONSTANT   = SOURCETABLE.T$SCON 
            /*TAX*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CVYN 
             ON   T$CVYN.TABLENAME  = 'TDSLS400' 
              AND T$CVYN.COLUMNNAME = 'T$CVYN' 
              AND T$CVYN.CONSTANT   = SOURCETABLE.T$CVYN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREG)),'')                                                                                         AS AREA 
            ,T$BKYN.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BKYN AS INT)                                                                                                                 AS BLOCKEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPTX)),'')                                                                                         AS BPARTNERTEXTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPPR)),'')                                                                                         AS BPPRICESDISC 
            ,T$CLYN.CONSTANTDESCRIPTION                                                                                                          AS CANCELLEDDESCRIPTION 
            ,CAST(T$CLYN AS INT)                                                                                                                 AS CANCELLEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                         AS CARRIER 
            ,CAST("T$CASE$U" AS BIGINT)                                                                                                            AS CASENOSALESFORCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                         AS CHANGEORDERSEQNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                         AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                         AS CHANGETYPELINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRNO)),'')                                                                                         AS CONTRACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRMC$U")),'')                                                                                       AS CRM_CASE_hash_ 
            ,CAST("T$RATS$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES1 
            ,CAST("T$RATS$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES2 
            ,CAST("T$RATS$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATESALES3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                         AS CUSTOMERORDERNUMBER 
            ,T$AGEN.CONSTANTDESCRIPTION                                                                                                          AS EDIACKNOWLEDGEMENTGENERATEDDESCRIPTION 
            ,CAST(T$AGEN AS INT)                                                                                                                 AS EDIACKNOWLEDGEMENTGENERATEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                         AS EXCHANGERATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFCG)),'')                                                                                         AS FINANCIALCUSTOMERGROUP 
            ,T$FCRT.CONSTANTDESCRIPTION                                                                                                          AS FIXEDRATEDESCRIPTION 
            ,CAST(T$FCRT AS INT)                                                                                                                 AS FIXEDRATEID 
            ,CAST(T$XHKY AS NUMERIC(15,2))                                                                                                       AS FRONTOFFICEHEADER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREP)),'')                                                                                         AS INSIDESALESREP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITAD)),'')                                                                                         AS INVOICETOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITCN)),'')                                                                                         AS INVOICETOCONTACT 
            ,T$FUTO.CONSTANTDESCRIPTION                                                                                                          AS INVOICINGBYINSTALLMENTSDESCRIPTION 
            ,CAST(T$FUTO AS INT)                                                                                                                 AS INVOICINGBYINSTALLMENTSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                         AS LINEOFBUSINESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$LOGN$U")),'')                                                                                       AS LOGINCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS ORDER_CURRENCY 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME) AS ORDER_DATE 
            ,CAST(T$ODIS AS NUMERIC(15,2))                                                                                                       AS ORDER_DISCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ORTP$U")),'')                                                                                       AS ORDER_ENTRYMETHOD 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS ORDER_FOOTERTEXT 
            ,"T$PRIO$U".CONSTANTDESCRIPTION                                                                                                        AS ORDER_PRIORITYDESCRIPTION 
            ,CAST("T$PRIO$U" AS INT)                                                                                                               AS ORDER_PRIORITYID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ORDER_TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ODNO)),'')                                                                                         AS ORIGINALDOCUMENTNUMBER 
            ,T$ODTY.CONSTANTDESCRIPTION                                                                                                          AS ORIGINALDOCUMENTTYPEDESCRIPTION 
            ,CAST(T$ODTY AS INT)                                                                                                                 AS ORIGINALDOCUMENTTYPEID 
            ,T$CORG.CONSTANTDESCRIPTION                                                                                                          AS ORIGINDESCRIPTION 
            ,CAST(T$CORG AS INT)                                                                                                                 AS ORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OSRP)),'')                                                                                         AS OUTSIDESALESREP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFAD)),'')                                                                                         AS PAYBYADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYBYBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFCN)),'')                                                                                         AS PAYBYCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTMETHOD 
            ,CAST(CASE WHEN T$DDAT<= '1/1/1970' THEN NULL ELSE T$DDAT  END AS DATETIME) AS PLANDELDATE 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT  END AS DATETIME) AS PLANNEDRECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PLDD)),'')                                                                                         AS PRICELISTFORDIRECTDELIVERY 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFA)),'')                                                                                         AS REFERENCEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFB)),'')                                                                                         AS REFERENCEB 
            ,CAST(T$RCMP AS INT)                                                                                                                 AS RETURNINVOICECOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETR)),'')                                                                                         AS RETURNREASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RETURNTRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'')                                                                                         AS ROUTE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                         AS ROUTEPLAN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                         AS SALESACKNOWLEDGEMENTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS SALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SALESORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SOTP)),'')                                                                                         AS SALESORDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLS)),'')                                                                                         AS SALESPRICELIST 
            ,T$SBIM.CONSTANTDESCRIPTION                                                                                                          AS SELFBILLEDINVOICEDESCRIPTION 
            ,CAST(T$SBIM AS INT)                                                                                                                 AS SELFBILLEDINVOICEID 
            ,T$SCON.CONSTANTDESCRIPTION                                                                                                          AS SHIPPINGCONSTRAINTDESCRIPTION 
            ,CAST(T$SCON AS INT)                                                                                                                 AS SHIPPINGCONSTRAINTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCN)),'')                                                                                         AS SHIPTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFAD)),'')                                                                                         AS SOLDTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFCN)),'')                                                                                         AS SOLDTOCONTACT 
            ,T$CVYN.CONSTANTDESCRIPTION                                                                                                          AS TAXDESCRIPTION 
            ,CAST(T$CVYN AS INT)                                                                                                                 AS TAXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDEC)),'')                                                                                         AS TERMSOFDELIVERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDSLS400201") }} AS SOURCETABLE  
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BKYN 
             ON   T$BKYN.TABLENAME  = 'TDSLS400' 
              AND T$BKYN.COLUMNNAME = 'T$BKYN' 
              AND T$BKYN.CONSTANT   = SOURCETABLE.T$BKYN 
            /*CANCELLED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLYN 
             ON   T$CLYN.TABLENAME  = 'TDSLS400' 
              AND T$CLYN.COLUMNNAME = 'T$CLYN' 
              AND T$CLYN.CONSTANT   = SOURCETABLE.T$CLYN 
            /*EDIACKNOWLEDGEMENTGENERATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AGEN 
             ON   T$AGEN.TABLENAME  = 'TDSLS400' 
              AND T$AGEN.COLUMNNAME = 'T$AGEN' 
              AND T$AGEN.CONSTANT   = SOURCETABLE.T$AGEN 
            /*FIXEDRATE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FCRT 
             ON   T$FCRT.TABLENAME  = 'TDSLS400' 
              AND T$FCRT.COLUMNNAME = 'T$FCRT' 
              AND T$FCRT.CONSTANT   = SOURCETABLE.T$FCRT 
            /*INVOICINGBYINSTALLMENTS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FUTO 
             ON   T$FUTO.TABLENAME  = 'TDSLS400' 
              AND T$FUTO.COLUMNNAME = 'T$FUTO' 
              AND T$FUTO.CONSTANT   = SOURCETABLE.T$FUTO 
            /*ORDERPRIORITYU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$PRIO$U" 
             ON   "T$PRIO$U".TABLENAME  = 'TDSLS400' 
              AND "T$PRIO$U".COLUMNNAME = 'T$PRIO.U' 
              AND "T$PRIO$U".CONSTANT   = SOURCETABLE."T$PRIO$U" 
            /*ORIGINALDOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ODTY 
             ON   T$ODTY.TABLENAME  = 'TDSLS400' 
              AND T$ODTY.COLUMNNAME = 'T$ODTY' 
              AND T$ODTY.CONSTANT   = SOURCETABLE.T$ODTY 
            /*ORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CORG 
             ON   T$CORG.TABLENAME  = 'TDSLS400' 
              AND T$CORG.COLUMNNAME = 'T$CORG' 
              AND T$CORG.CONSTANT   = SOURCETABLE.T$CORG 
            /*SELFBILLEDINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SBIM 
             ON   T$SBIM.TABLENAME  = 'TDSLS400' 
              AND T$SBIM.COLUMNNAME = 'T$SBIM' 
              AND T$SBIM.CONSTANT   = SOURCETABLE.T$SBIM 
            /*SHIPPINGCONSTRAINT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCON 
             ON   T$SCON.TABLENAME  = 'TDSLS400' 
              AND T$SCON.COLUMNNAME = 'T$SCON' 
              AND T$SCON.CONSTANT   = SOURCETABLE.T$SCON 
            /*TAX*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CVYN 
             ON   T$CVYN.TABLENAME  = 'TDSLS400' 
              AND T$CVYN.COLUMNNAME = 'T$CVYN' 
              AND T$CVYN.CONSTANT   = SOURCETABLE.T$CVYN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,	transform_data as
(
    SELECT 
		source_data._CAPTUREDATETIME AS _CAPTUREDATETIME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		source_data.SALESORDER AS SALESORDER,
		source_data._COMPANYID AS _COMPANYID,
		source_data.AREA AS AREA,
		source_data.BLOCKEDDESCRIPTION AS BLOCKEDDESCRIPTION,
		source_data.BLOCKEDID AS BLOCKEDID,
		source_data.BPARTNERTEXTS AS BPARTNERTEXTS,
		source_data.BPPRICESDISC AS BPPRICESDISC,
		source_data.CANCELLEDDESCRIPTION AS CANCELLEDDESCRIPTION,
		source_data.CANCELLEDID AS CANCELLEDID,
		source_data.CARRIER AS CARRIER,
		source_data.CASENOSALESFORCE AS CASENOSALESFORCE,
		source_data.CHANGEORDERSEQNO AS CHANGEORDERSEQNO,
		source_data.CHANGEREASONLINES AS CHANGEREASONLINES,
		source_data.CHANGETYPELINES AS CHANGETYPELINES,
		source_data.CONTRACT AS CONTRACT,
		source_data.COUNTRY AS COUNTRY,
		source_data.CRM_CASE_HASH_ AS CRM_CASE_HASH_,
		source_data.CURRENCYRATESALES1 AS CURRENCYRATESALES1,
		source_data.CURRENCYRATESALES2 AS CURRENCYRATESALES2,
		source_data.CURRENCYRATESALES3 AS CURRENCYRATESALES3,
		source_data.CUSTOMERORDERNUMBER AS CUSTOMERORDERNUMBER,
		source_data.EDIACKNOWLEDGEMENTGENERATEDDESCRIPTION AS EDIACKNOWLEDGEMENTGENERATEDDESCRIPTION,
		source_data.EDIACKNOWLEDGEMENTGENERATEDID AS EDIACKNOWLEDGEMENTGENERATEDID,
		source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE,
		source_data.FINANCIALCUSTOMERGROUP AS FINANCIALCUSTOMERGROUP,
		source_data.FIXEDRATEDESCRIPTION AS FIXEDRATEDESCRIPTION,
		source_data.FIXEDRATEID AS FIXEDRATEID,
		source_data.FRONTOFFICEHEADER AS FRONTOFFICEHEADER,
		source_data.INSIDESALESREP AS INSIDESALESREP,
		source_data.INVOICETOADDRESS AS INVOICETOADDRESS,
		source_data.INVOICETOBP AS INVOICETOBP,
		source_data.INVOICETOCONTACT AS INVOICETOCONTACT,
		source_data.INVOICINGBYINSTALLMENTSDESCRIPTION AS INVOICINGBYINSTALLMENTSDESCRIPTION,
		source_data.INVOICINGBYINSTALLMENTSID AS INVOICINGBYINSTALLMENTSID,
		source_data.LATEPAYMENTSURCHARGE AS LATEPAYMENTSURCHARGE,
		source_data.LINEOFBUSINESS AS LINEOFBUSINESS,
		source_data.LOGINCODE AS LOGINCODE,
		source_data.ORDER_CURRENCY AS ORDER_CURRENCY,
		source_data.ORDER_DATE AS ORDER_DATE,
		source_data.ORDER_DISCOUNT AS ORDER_DISCOUNT,
		source_data.ORDER_ENTRYMETHOD AS ORDER_ENTRYMETHOD,
		source_data.ORDER_FOOTERTEXT AS ORDER_FOOTERTEXT,
		source_data.ORDER_PRIORITYDESCRIPTION AS ORDER_PRIORITYDESCRIPTION,
		source_data.ORDER_PRIORITYID AS ORDER_PRIORITYID,
		source_data.ORDER_TEXT AS ORDER_TEXT,
		source_data.ORIGINALDOCUMENTNUMBER AS ORIGINALDOCUMENTNUMBER,
		source_data.ORIGINALDOCUMENTTYPEDESCRIPTION AS ORIGINALDOCUMENTTYPEDESCRIPTION,
		source_data.ORIGINALDOCUMENTTYPEID AS ORIGINALDOCUMENTTYPEID,
		source_data.ORIGINDESCRIPTION AS ORIGINDESCRIPTION,
		source_data.ORIGINID AS ORIGINID,
		source_data.OUTSIDESALESREP AS OUTSIDESALESREP,
		source_data.PAYBYADDRESS AS PAYBYADDRESS,
		source_data.PAYBYBP AS PAYBYBP,
		source_data.PAYBYCONTACT AS PAYBYCONTACT,
		source_data.PAYMENTMETHOD AS PAYMENTMETHOD,
		source_data.PLANDELDATE AS PLANDELDATE,
		source_data.PLANNEDRECEIPTDATE AS PLANNEDRECEIPTDATE,
		source_data.PRICELISTFORDIRECTDELIVERY AS PRICELISTFORDIRECTDELIVERY,
		source_data.RATEDATE AS RATEDATE,
		source_data.RATEFACTOR1 AS RATEFACTOR1,
		source_data.RATEFACTOR2 AS RATEFACTOR2,
		source_data.RATEFACTOR3 AS RATEFACTOR3,
		source_data.REFERENCEA AS REFERENCEA,
		source_data.REFERENCEB AS REFERENCEB,
		source_data.RETURNINVOICECOMPANY AS RETURNINVOICECOMPANY,
		source_data.RETURNREASON AS RETURNREASON,
		source_data.RETURNTRANSACTIONTYPE AS RETURNTRANSACTIONTYPE,
		source_data.ROUTE AS ROUTE,
		source_data.ROUTEPLAN AS ROUTEPLAN,
		source_data.SALESACKNOWLEDGEMENTCODE AS SALESACKNOWLEDGEMENTCODE,
		source_data.SALESOFFICE AS SALESOFFICE,
		source_data.SALESORDERTYPE AS SALESORDERTYPE,
		source_data.SALESPRICELIST AS SALESPRICELIST,
		source_data.SELFBILLEDINVOICEDESCRIPTION AS SELFBILLEDINVOICEDESCRIPTION,
		source_data.SELFBILLEDINVOICEID AS SELFBILLEDINVOICEID,
		source_data.SHIPPINGCONSTRAINTDESCRIPTION AS SHIPPINGCONSTRAINTDESCRIPTION,
		source_data.SHIPPINGCONSTRAINTID AS SHIPPINGCONSTRAINTID,
		source_data.SHIPTOADDRESS AS SHIPTOADDRESS,
		source_data.SHIPTOBUSINESSPARTNER AS SHIPTOBUSINESSPARTNER,
		source_data.SHIPTOCONTACT AS SHIPTOCONTACT,
		source_data.SOLDTOADDRESS AS SOLDTOADDRESS,
		source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER,
		source_data.SOLDTOCONTACT AS SOLDTOCONTACT,
		source_data.TAXDESCRIPTION AS TAXDESCRIPTION,
		source_data.TAXID AS TAXID,
		source_data.TERMSOFDELIVERY AS TERMSOFDELIVERY,
		source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT,
		source_data.WAREHOUSE AS WAREHOUSE   
        FROM source_data
        )
,	type_data as 
(
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(SALESORDER as VARCHAR(9)) as SALESORDER,
		cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
		cast(AREA as VARCHAR(3)) as AREA,
		cast(BLOCKEDDESCRIPTION as VARCHAR(16777216)) as BLOCKEDDESCRIPTION,
		cast(BLOCKEDID as NUMBER(38,0)) as BLOCKEDID,
		cast(BPARTNERTEXTS as VARCHAR(9)) as BPARTNERTEXTS,
		cast(BPPRICESDISC as VARCHAR(9)) as BPPRICESDISC,
		cast(CANCELLEDDESCRIPTION as VARCHAR(16777216)) as CANCELLEDDESCRIPTION,
		cast(CANCELLEDID as NUMBER(38,0)) as CANCELLEDID,
		cast(CARRIER as VARCHAR(3)) as CARRIER,
		cast(CASENOSALESFORCE as NUMBER(38,0)) as CASENOSALESFORCE,
		cast(CHANGEORDERSEQNO as VARCHAR(8)) as CHANGEORDERSEQNO,
		cast(CHANGEREASONLINES as VARCHAR(6)) as CHANGEREASONLINES,
		cast(CHANGETYPELINES as VARCHAR(6)) as CHANGETYPELINES,
		cast(CONTRACT as VARCHAR(9)) as CONTRACT,
		cast(COUNTRY as VARCHAR(3)) as COUNTRY,
		cast(CRM_CASE_HASH_ as VARCHAR(18)) as CRM_CASE_HASH_,
		cast(CURRENCYRATESALES1 as NUMBER(15,2)) as CURRENCYRATESALES1,
		cast(CURRENCYRATESALES2 as NUMBER(15,2)) as CURRENCYRATESALES2,
		cast(CURRENCYRATESALES3 as NUMBER(15,2)) as CURRENCYRATESALES3,
		cast(CUSTOMERORDERNUMBER as VARCHAR(30)) as CUSTOMERORDERNUMBER,
		cast(EDIACKNOWLEDGEMENTGENERATEDDESCRIPTION as VARCHAR(16777216)) as EDIACKNOWLEDGEMENTGENERATEDDESCRIPTION,
		cast(EDIACKNOWLEDGEMENTGENERATEDID as NUMBER(38,0)) as EDIACKNOWLEDGEMENTGENERATEDID,
		cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
		cast(FINANCIALCUSTOMERGROUP as VARCHAR(3)) as FINANCIALCUSTOMERGROUP,
		cast(FIXEDRATEDESCRIPTION as VARCHAR(16777216)) as FIXEDRATEDESCRIPTION,
		cast(FIXEDRATEID as NUMBER(38,0)) as FIXEDRATEID,
		cast(FRONTOFFICEHEADER as NUMBER(15,2)) as FRONTOFFICEHEADER,
		cast(INSIDESALESREP as VARCHAR(6)) as INSIDESALESREP,
		cast(INVOICETOADDRESS as VARCHAR(9)) as INVOICETOADDRESS,
		cast(INVOICETOBP as VARCHAR(9)) as INVOICETOBP,
		cast(INVOICETOCONTACT as VARCHAR(9)) as INVOICETOCONTACT,
		cast(INVOICINGBYINSTALLMENTSDESCRIPTION as VARCHAR(16777216)) as INVOICINGBYINSTALLMENTSDESCRIPTION,
		cast(INVOICINGBYINSTALLMENTSID as NUMBER(38,0)) as INVOICINGBYINSTALLMENTSID,
		cast(LATEPAYMENTSURCHARGE as VARCHAR(3)) as LATEPAYMENTSURCHARGE,
		cast(LINEOFBUSINESS as VARCHAR(6)) as LINEOFBUSINESS,
		cast(LOGINCODE as VARCHAR(16)) as LOGINCODE,
		cast(ORDER_CURRENCY as VARCHAR(3)) as ORDER_CURRENCY,
		cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
		cast(ORDER_DISCOUNT as NUMBER(15,2)) as ORDER_DISCOUNT,
		cast(ORDER_ENTRYMETHOD as VARCHAR(3)) as ORDER_ENTRYMETHOD,
		cast(ORDER_FOOTERTEXT as NUMBER(38,10)) as ORDER_FOOTERTEXT,
		cast(ORDER_PRIORITYDESCRIPTION as VARCHAR(16777216)) as ORDER_PRIORITYDESCRIPTION,
		cast(ORDER_PRIORITYID as NUMBER(38,0)) as ORDER_PRIORITYID,
		cast(ORDER_TEXT as NUMBER(38,10)) as ORDER_TEXT,
		cast(ORIGINALDOCUMENTNUMBER as VARCHAR(9)) as ORIGINALDOCUMENTNUMBER,
		cast(ORIGINALDOCUMENTTYPEDESCRIPTION as VARCHAR(16777216)) as ORIGINALDOCUMENTTYPEDESCRIPTION,
		cast(ORIGINALDOCUMENTTYPEID as NUMBER(38,0)) as ORIGINALDOCUMENTTYPEID,
		cast(ORIGINDESCRIPTION as VARCHAR(16777216)) as ORIGINDESCRIPTION,
		cast(ORIGINID as NUMBER(38,0)) as ORIGINID,
		cast(OUTSIDESALESREP as VARCHAR(6)) as OUTSIDESALESREP,
		cast(PAYBYADDRESS as VARCHAR(9)) as PAYBYADDRESS,
		cast(PAYBYBP as VARCHAR(9)) as PAYBYBP,
		cast(PAYBYCONTACT as VARCHAR(9)) as PAYBYCONTACT,
		cast(PAYMENTMETHOD as VARCHAR(3)) as PAYMENTMETHOD,
		cast(PLANDELDATE as TIMESTAMP_NTZ(9)) as PLANDELDATE,
		cast(PLANNEDRECEIPTDATE as TIMESTAMP_NTZ(9)) as PLANNEDRECEIPTDATE,
		cast(PRICELISTFORDIRECTDELIVERY as VARCHAR(3)) as PRICELISTFORDIRECTDELIVERY,
		cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
		cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
		cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
		cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
		cast(REFERENCEA as VARCHAR(30)) as REFERENCEA,
		cast(REFERENCEB as VARCHAR(20)) as REFERENCEB,
		cast(RETURNINVOICECOMPANY as NUMBER(38,0)) as RETURNINVOICECOMPANY,
		cast(RETURNREASON as VARCHAR(6)) as RETURNREASON,
		cast(RETURNTRANSACTIONTYPE as VARCHAR(3)) as RETURNTRANSACTIONTYPE,
		cast(ROUTE as VARCHAR(5)) as ROUTE,
		cast(ROUTEPLAN as VARCHAR(3)) as ROUTEPLAN,
		cast(SALESACKNOWLEDGEMENTCODE as VARCHAR(2)) as SALESACKNOWLEDGEMENTCODE,
		cast(SALESOFFICE as VARCHAR(6)) as SALESOFFICE,
		cast(SALESORDERTYPE as VARCHAR(3)) as SALESORDERTYPE,
		cast(SALESPRICELIST as VARCHAR(3)) as SALESPRICELIST,
		cast(SELFBILLEDINVOICEDESCRIPTION as VARCHAR(16777216)) as SELFBILLEDINVOICEDESCRIPTION,
		cast(SELFBILLEDINVOICEID as NUMBER(38,0)) as SELFBILLEDINVOICEID,
		cast(SHIPPINGCONSTRAINTDESCRIPTION as VARCHAR(16777216)) as SHIPPINGCONSTRAINTDESCRIPTION,
		cast(SHIPPINGCONSTRAINTID as NUMBER(38,0)) as SHIPPINGCONSTRAINTID,
		cast(SHIPTOADDRESS as VARCHAR(9)) as SHIPTOADDRESS,
		cast(SHIPTOBUSINESSPARTNER as VARCHAR(9)) as SHIPTOBUSINESSPARTNER,
		cast(SHIPTOCONTACT as VARCHAR(9)) as SHIPTOCONTACT,
		cast(SOLDTOADDRESS as VARCHAR(9)) as SOLDTOADDRESS,
		cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
		cast(SOLDTOCONTACT as VARCHAR(9)) as SOLDTOCONTACT,
		cast(TAXDESCRIPTION as VARCHAR(16777216)) as TAXDESCRIPTION,
		cast(TAXID as NUMBER(38,0)) as TAXID,
		cast(TERMSOFDELIVERY as VARCHAR(3)) as TERMSOFDELIVERY,
		cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT,
		cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE
    from transform_data
    )
select * from type_data