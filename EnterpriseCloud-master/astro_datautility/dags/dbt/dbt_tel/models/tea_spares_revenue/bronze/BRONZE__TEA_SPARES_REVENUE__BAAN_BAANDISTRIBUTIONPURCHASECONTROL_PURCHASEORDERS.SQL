/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERS.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:50 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANDISTRIBUTIONPURCHASECONTROL_PURCHASEORDERS',
    unique_key = ['PURCHASEORDER']
) }}


with source_data as 
(
    SELECT   
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AKCD)),'')                                                                                             AS ACKNOWLEDGCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREG)),'')                                                                                             AS AREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPPR)),'')                                                                                             AS BPPRICESDISCOUNTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPTX)),'')                                                                                             AS BPTEXTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCON)),'')                                                                                             AS BUYER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                             AS BUYFROM_percent_BUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTAD)),'')                                                                                             AS BUYFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTCN)),'')                                                                                             AS BUYFROMCONTACT 
            ,T$CLYN.CONSTANTDESCRIPTION                                                                                                              AS CANCELLEDDESCRIPTION 
            ,CAST(T$CLYN AS INT)                                                                                                                     AS CANCELLEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                             AS CARRIER 
            ,CAST("T$CASE$U" AS BIGINT)                                                                                                                AS CASENOSALESFORCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COSN)),'')                                                                                             AS CHANGEORDERSEQNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRCD)),'')                                                                                             AS CHANGEREASONLINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTCD)),'')                                                                                             AS CHANGETYPELINES 
            ,CAST(CASE WHEN T$DDTC<= '1/1/1970' THEN NULL ELSE T$DDTC  END AS DATETIME)     AS CONFIRMEDDELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRNO)),'')                                                                                             AS CONTRACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                             AS COUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRMC$U")),'')                                                                                           AS CRM_CASE_hash_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                             AS CURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                             AS DELADDRESS 
            ,CAST(CASE WHEN T$DDAT<= '1/1/1970' THEN NULL ELSE T$DDAT  END AS DATETIME)     AS DELIVERYDATE 
            ,T$EGEN.CONSTANTDESCRIPTION                                                                                                              AS EDIMESSAGEGENERATEDDESCRIPTION 
            ,CAST(T$EGEN AS INT)                                                                                                                     AS EDIMESSAGEGENERATEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFSG)),'')                                                                                             AS FINANCIALSUPPLIERGROUP 
            ,T$MCFR.CONSTANTDESCRIPTION                                                                                                              AS FIXEDRATEDESCRIPTION 
            ,CAST(T$MCFR AS INT)                                                                                                                     AS FIXEDRATEID 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                         AS FOOTERTEXT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                         AS HEADERTEXT 
            ,CAST(CASE WHEN "T$EDEX$C"<= '1/1/1970' THEN NULL ELSE "T$EDEX$C"  END AS DATETIME) AS INITIALEDIEXTRACTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IFAD)),'')                                                                                             AS INVOICEFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IFBP)),'')                                                                                             AS INVOICEFROMBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IFCN)),'')                                                                                             AS INVOICEFROMCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                             AS LATEPAYMENTSURCHARGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                             AS LINEOFBUSINESS 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME)     AS ORDER_DATE 
            ,CAST(T$ODIS AS NUMERIC(15,2))                                                                                                           AS ORDER_DISCOUNT 
            ,"T$OPRI$C".CONSTANTDESCRIPTION                                                                                                            AS ORDER_PRIORITYDESCRIPTION 
            ,CAST("T$OPRI$C" AS INT)                                                                                                                   AS ORDER_PRIORITYID 
            ,T$ODTY.CONSTANTDESCRIPTION                                                                                                              AS ORIGDOCTYPEDESCRIPTION 
            ,CAST(T$ODTY AS INT)                                                                                                                     AS ORIGDOCTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ODNO)),'')                                                                                             AS ORIGINALORDER 
            ,T$CORG.CONSTANTDESCRIPTION                                                                                                              AS ORIGINDESCRIPTION 
            ,CAST(T$CORG AS INT)                                                                                                                     AS ORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTAD)),'')                                                                                             AS PAYTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTBP)),'')                                                                                             AS PAYTOBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTCN)),'')                                                                                             AS PAYTOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                             AS PURCHASEOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                             AS PURCHASEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COTP)),'')                                                                                             AS PURCHASEORDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLP)),'')                                                                                             AS PURCHASEPRICELIST 
            ,CAST("T$RATP$1" AS NUMERIC(15,2))                                                                                                         AS PURCHASERATE1 
            ,CAST("T$RATP$2" AS NUMERIC(15,2))                                                                                                         AS PURCHASERATE2 
            ,CAST("T$RATP$3" AS NUMERIC(15,2))                                                                                                         AS PURCHASERATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME)     AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                                AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                                AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                                AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RATT)),'')                                                                                             AS RATETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFA)),'')                                                                                             AS REFERENCEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFB)),'')                                                                                             AS REFERENCEB 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RAGR)),'')                                                                                             AS REMITTANCEAGREEMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RETR)),'')                                                                                             AS RETURNREASON 
            ,CAST(CASE WHEN "T$REXD$C"<= '1/1/1970' THEN NULL ELSE "T$REXD$C"  END AS DATETIME) AS REVISEDEXTRACTDATE 
            ,"T$REVF$C".CONSTANTDESCRIPTION                                                                                                            AS REVISEFLAGDESCRIPTION 
            ,CAST("T$REVF$C" AS INT)                                                                                                                   AS REVISEFLAGID 
            ,CAST("T$REVC$C" AS INT)                                                                                                                   AS REVISIONCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRJ)),'')                                                                                             AS ROUTEPLAN 
            ,T$SBIM.CONSTANTDESCRIPTION                                                                                                              AS SELFBILLEDINVOICEDESCRIPTION 
            ,CAST(T$SBIM AS INT)                                                                                                                     AS SELFBILLEDINVOICEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFAD)),'')                                                                                             AS SHIPFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFBP)),'')                                                                                             AS SHIPFROMBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFCN)),'')                                                                                             AS SHIPFROMCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SIGB$C")),'')                                                                                           AS SIGNEDBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SORN)),'')                                                                                             AS SUPPLIERORDERNUMBER 
            ,T$CVYN.CONSTANTDESCRIPTION                                                                                                              AS TAXDESCRIPTION 
            ,CAST(T$CVYN AS INT)                                                                                                                     AS TAXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDEC)),'')                                                                                             AS TERMSOFDELIVERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                             AS TERMSOFPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                             AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPUR400201") }} AS SOURCETABLE  
            /*CANCELLED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLYN 
             ON   T$CLYN.TABLENAME  = 'TDPUR400' 
              AND T$CLYN.COLUMNNAME = 'T$CLYN' 
              AND T$CLYN.CONSTANT   = SOURCETABLE.T$CLYN 
            /*EDIMESSAGEGENERATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$EGEN 
             ON   T$EGEN.TABLENAME  = 'TDPUR400' 
              AND T$EGEN.COLUMNNAME = 'T$EGEN' 
              AND T$EGEN.CONSTANT   = SOURCETABLE.T$EGEN 
            /*FIXEDRATE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MCFR 
             ON   T$MCFR.TABLENAME  = 'TDPUR400' 
              AND T$MCFR.COLUMNNAME = 'T$MCFR' 
              AND T$MCFR.CONSTANT   = SOURCETABLE.T$MCFR 
            /*ORDERPRIORITYC*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$OPRI$C" 
             ON   "T$OPRI$C".TABLENAME  = 'TDPUR400' 
              AND "T$OPRI$C".COLUMNNAME = 'T$OPRI.C' 
              AND "T$OPRI$C".CONSTANT   = SOURCETABLE."T$OPRI$C" 
            /*ORIGDOCTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ODTY 
             ON   T$ODTY.TABLENAME  = 'TDPUR400' 
              AND T$ODTY.COLUMNNAME = 'T$ODTY' 
              AND T$ODTY.CONSTANT   = SOURCETABLE.T$ODTY 
            /*ORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CORG 
             ON   T$CORG.TABLENAME  = 'TDPUR400' 
              AND T$CORG.COLUMNNAME = 'T$CORG' 
              AND T$CORG.CONSTANT   = SOURCETABLE.T$CORG 
            /*REVISEFLAGC*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$REVF$C" 
             ON   "T$REVF$C".TABLENAME  = 'TDPUR400' 
              AND "T$REVF$C".COLUMNNAME = 'T$REVF.C' 
              AND "T$REVF$C".CONSTANT   = SOURCETABLE."T$REVF$C" 
            /*SELFBILLEDINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SBIM 
             ON   T$SBIM.TABLENAME  = 'TDPUR400' 
              AND T$SBIM.COLUMNNAME = 'T$SBIM' 
              AND T$SBIM.CONSTANT   = SOURCETABLE.T$SBIM 
            /*TAX*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CVYN 
             ON   T$CVYN.TABLENAME  = 'TDPUR400' 
              AND T$CVYN.COLUMNNAME = 'T$CVYN' 
              AND T$CVYN.CONSTANT   = SOURCETABLE.T$CVYN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACKNOWLEDGCODE AS ACKNOWLEDGCODE, 
        source_data.AREA AS AREA, 
        source_data.BPPRICESDISCOUNTS AS BPPRICESDISCOUNTS, 
        source_data.BPTEXTS AS BPTEXTS, 
        source_data.BUYER AS BUYER, 
        source_data.BUYFROM_PERCENT_BUSINESSPARTNER AS BUYFROM_PERCENT_BUSINESSPARTNER, 
        source_data.BUYFROMADDRESS AS BUYFROMADDRESS, 
        source_data.BUYFROMCONTACT AS BUYFROMCONTACT, 
        source_data.CANCELLEDDESCRIPTION AS CANCELLEDDESCRIPTION, 
        source_data.CANCELLEDID AS CANCELLEDID, 
        source_data.CARRIER AS CARRIER, 
        source_data.CASENOSALESFORCE AS CASENOSALESFORCE, 
        source_data.CHANGEORDERSEQNO AS CHANGEORDERSEQNO, 
        source_data.CHANGEREASONLINES AS CHANGEREASONLINES, 
        source_data.CHANGETYPELINES AS CHANGETYPELINES, 
        source_data.CONFIRMEDDELIVERYDATE AS CONFIRMEDDELIVERYDATE, 
        source_data.CONTRACT AS CONTRACT, 
        source_data.COUNTRY AS COUNTRY, 
        source_data.CRM_CASE_HASH_ AS CRM_CASE_HASH_, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DELADDRESS AS DELADDRESS, 
        source_data.DELIVERYDATE AS DELIVERYDATE, 
        source_data.EDIMESSAGEGENERATEDDESCRIPTION AS EDIMESSAGEGENERATEDDESCRIPTION, 
        source_data.EDIMESSAGEGENERATEDID AS EDIMESSAGEGENERATEDID, 
        source_data.FINANCIALSUPPLIERGROUP AS FINANCIALSUPPLIERGROUP, 
        source_data.FIXEDRATEDESCRIPTION AS FIXEDRATEDESCRIPTION, 
        source_data.FIXEDRATEID AS FIXEDRATEID, 
        source_data.FOOTERTEXT AS FOOTERTEXT, 
        source_data.HEADERTEXT AS HEADERTEXT, 
        source_data.INITIALEDIEXTRACTDATE AS INITIALEDIEXTRACTDATE, 
        source_data.INVOICEFROMADDRESS AS INVOICEFROMADDRESS, 
        source_data.INVOICEFROMBP AS INVOICEFROMBP, 
        source_data.INVOICEFROMCONTACT AS INVOICEFROMCONTACT, 
        source_data.LATEPAYMENTSURCHARGE AS LATEPAYMENTSURCHARGE, 
        source_data.LINEOFBUSINESS AS LINEOFBUSINESS, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_DISCOUNT AS ORDER_DISCOUNT, 
        source_data.ORDER_PRIORITYDESCRIPTION AS ORDER_PRIORITYDESCRIPTION, 
        source_data.ORDER_PRIORITYID AS ORDER_PRIORITYID, 
        source_data.ORIGDOCTYPEDESCRIPTION AS ORIGDOCTYPEDESCRIPTION, 
        source_data.ORIGDOCTYPEID AS ORIGDOCTYPEID, 
        source_data.ORIGINALORDER AS ORIGINALORDER, 
        source_data.ORIGINDESCRIPTION AS ORIGINDESCRIPTION, 
        source_data.ORIGINID AS ORIGINID, 
        source_data.PAYTOADDRESS AS PAYTOADDRESS, 
        source_data.PAYTOBP AS PAYTOBP, 
        source_data.PAYTOCONTACT AS PAYTOCONTACT, 
        source_data.PURCHASEOFFICE AS PURCHASEOFFICE, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.PURCHASEORDERTYPE AS PURCHASEORDERTYPE, 
        source_data.PURCHASEPRICELIST AS PURCHASEPRICELIST, 
        source_data.PURCHASERATE1 AS PURCHASERATE1, 
        source_data.PURCHASERATE2 AS PURCHASERATE2, 
        source_data.PURCHASERATE3 AS PURCHASERATE3, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.RATETYPE AS RATETYPE, 
        source_data.REFERENCEA AS REFERENCEA, 
        source_data.REFERENCEB AS REFERENCEB, 
        source_data.REMITTANCEAGREEMENT AS REMITTANCEAGREEMENT, 
        source_data.RETURNREASON AS RETURNREASON, 
        source_data.REVISEDEXTRACTDATE AS REVISEDEXTRACTDATE, 
        source_data.REVISEFLAGDESCRIPTION AS REVISEFLAGDESCRIPTION, 
        source_data.REVISEFLAGID AS REVISEFLAGID, 
        source_data.REVISIONCOUNT AS REVISIONCOUNT, 
        source_data.ROUTEPLAN AS ROUTEPLAN, 
        source_data.SELFBILLEDINVOICEDESCRIPTION AS SELFBILLEDINVOICEDESCRIPTION, 
        source_data.SELFBILLEDINVOICEID AS SELFBILLEDINVOICEID, 
        source_data.SHIPFROMADDRESS AS SHIPFROMADDRESS, 
        source_data.SHIPFROMBP AS SHIPFROMBP, 
        source_data.SHIPFROMCONTACT AS SHIPFROMCONTACT, 
        source_data.SIGNEDBY AS SIGNEDBY, 
        source_data.SUPPLIERORDERNUMBER AS SUPPLIERORDERNUMBER, 
        source_data.TAXDESCRIPTION AS TAXDESCRIPTION, 
        source_data.TAXID AS TAXID, 
        source_data.TERMSOFDELIVERY AS TERMSOFDELIVERY, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.WAREHOUSE AS WAREHOUSE
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        _COMPANYID,
        ACKNOWLEDGCODE,
        AREA,
        BPPRICESDISCOUNTS,
        BPTEXTS,
        BUYER,
        BUYFROM_PERCENT_BUSINESSPARTNER,
        BUYFROMADDRESS,
        BUYFROMCONTACT,
        CANCELLEDDESCRIPTION,
        CANCELLEDID,
        CARRIER,
        cast(CASENOSALESFORCE as NUMBER(38,0)) as CASENOSALESFORCE,
        CHANGEORDERSEQNO,
        CHANGEREASONLINES,
        CHANGETYPELINES,
        cast(CONFIRMEDDELIVERYDATE as TIMESTAMP_NTZ(9)) as CONFIRMEDDELIVERYDATE,
        CONTRACT,
        COUNTRY,
        CRM_CASE_HASH_,
        CURRENCY,
        DELADDRESS,
        cast(DELIVERYDATE as TIMESTAMP_NTZ(9)) as DELIVERYDATE,
        EDIMESSAGEGENERATEDDESCRIPTION,
        cast(EDIMESSAGEGENERATEDID as NUMBER(38,0)) as EDIMESSAGEGENERATEDID,
        FINANCIALSUPPLIERGROUP,
        FIXEDRATEDESCRIPTION,
        cast(FIXEDRATEID as NUMBER(38,0)) as FIXEDRATEID,
        cast(FOOTERTEXT as NUMBER(38,10)) as FOOTERTEXT,
        cast(HEADERTEXT as NUMBER(38,10)) as HEADERTEXT,
        cast(INITIALEDIEXTRACTDATE as TIMESTAMP_NTZ(9)) as INITIALEDIEXTRACTDATE,
        INVOICEFROMADDRESS,
        INVOICEFROMBP,
        INVOICEFROMCONTACT,
        LATEPAYMENTSURCHARGE,
        LINEOFBUSINESS,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_DISCOUNT as NUMBER(15,2)) as ORDER_DISCOUNT,
        ORDER_PRIORITYDESCRIPTION,
        cast(ORDER_PRIORITYID as NUMBER(38,0)) as ORDER_PRIORITYID,
        ORIGDOCTYPEDESCRIPTION,
        cast(ORIGDOCTYPEID as NUMBER(38,0)) as ORIGDOCTYPEID,
        ORIGINALORDER,
        ORIGINDESCRIPTION,
        cast(ORIGINID as NUMBER(38,0)) as ORIGINID,
        PAYTOADDRESS,
        PAYTOBP,
        PAYTOCONTACT,
        PURCHASEOFFICE,
        PURCHASEORDER,
        PURCHASEORDERTYPE,
        PURCHASEPRICELIST,
        cast(PURCHASERATE1 as NUMBER(15,2)) as PURCHASERATE1,
        cast(PURCHASERATE2 as NUMBER(15,2)) as PURCHASERATE2,
        cast(PURCHASERATE3 as NUMBER(15,2)) as PURCHASERATE3,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        RATETYPE,
        REFERENCEA,
        REFERENCEB,
        REMITTANCEAGREEMENT,
        RETURNREASON,
        cast(REVISEDEXTRACTDATE as TIMESTAMP_NTZ(9)) as REVISEDEXTRACTDATE,
        REVISEFLAGDESCRIPTION,
        cast(REVISEFLAGID as NUMBER(38,0)) as REVISEFLAGID,
        cast(REVISIONCOUNT as NUMBER(38,0)) as REVISIONCOUNT,
        ROUTEPLAN,
        SELFBILLEDINVOICEDESCRIPTION,
        cast(SELFBILLEDINVOICEID as NUMBER(38,0)) as SELFBILLEDINVOICEID,
        SHIPFROMADDRESS,
        SHIPFROMBP,
        SHIPFROMCONTACT,
        SIGNEDBY,
        SUPPLIERORDERNUMBER,
        TAXDESCRIPTION,
        cast(TAXID as NUMBER(38,0)) as TAXID,
        TERMSOFDELIVERY,
        TERMSOFPAYMENT,
        WAREHOUSE
    from transform_data
    )
select * from type_data