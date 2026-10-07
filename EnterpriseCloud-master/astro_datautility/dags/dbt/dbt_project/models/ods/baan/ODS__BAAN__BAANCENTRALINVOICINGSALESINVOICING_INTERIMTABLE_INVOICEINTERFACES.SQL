/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCENTRALINVOICINGSALESINVOICING_INTERIMTABLE_INVOICEINTERFACES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCENTRALINVOICINGSALESINVOICING_INTERIMTABLE_INVOICEINTERFACES.SQL 
-materialized incremental
-alias BAANCENTRALINVOICINGSALESINVOICING_INTERIMTABLE_INVOICEINTERFACES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:47 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCENTRALINVOICINGSALESINVOICING_INTERIMTABLE_INVOICEINTERFACES',
    unique_key = ['BILLTOID',
    'CREATEDDATE',
    'DOCNO',
    'INVOICELINENO',
    'INVOICETYPEID',
    'ORDER_NUMBER',
    'ORDER_SEQACTIVITY',
    'ORDER_TYPEID',
    'SALESINVOICETRANSACTIONTYPE',
    'SHIPMENTID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AGID)),'')                                                                                         AS AGREEMENTID 
            ,CAST(T$TAMT AS NUMERIC(15,2))                                                                                                       AS AMOUNTININVCURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITAD)),'')                                                                                         AS BILLTOADDRESSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS BILLTOID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BVAT)),'')                                                                                         AS BUYERVATID 
            ,SOURCETABLE.T$TEXT   /* TEXT */                                                                                                     AS COMMENTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COM1)),'')                                                                                         AS COMMENTS1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COM2)),'')                                                                                         AS COMMENTS2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREU)),'')                                                                                         AS CREATEDBY 
            ,CAST(CASE WHEN T$CRED<= '1/1/1970' THEN NULL ELSE T$CRED  END AS DATETIME) AS CREATEDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORP)),'')                                                                                         AS CUSTOMERORDERPOSITION 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS DOCNO 
            ,CAST(CASE WHEN T$DCDT<= '1/1/1970' THEN NULL ELSE T$DCDT END AS DATE)                                                             AS DOCUMENTDATE 
            ,CAST(CASE WHEN T$EXPD<= '1/1/1970' THEN NULL ELSE T$EXPD  END AS DATETIME) AS EXPORTEDDATE 
            ,T$FLYN.CONSTANTDESCRIPTION                                                                                                          AS FILEGENERATEDDESCRIPTION 
            ,CAST(T$FLYN AS INT)                                                                                                                 AS FILEGENERATEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS INVOICECURRENCY 
            ,CAST(CASE WHEN T$CODT<= '1/1/1970' THEN NULL ELSE T$CODT  END AS DATETIME) AS INVOICEDATE 
            ,CAST(T$PONO AS INT)                                                                                                                 AS INVOICELINENO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CATE)),'')                                                                                         AS INVOICETAXCATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCC)),'')                                                                                         AS INVOICETAXDESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAME)),'')                                                                                         AS INVOICETOCITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS INVOICETOCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INAM)),'')                                                                                         AS INVOICETONAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PSTC)),'')                                                                                         AS INVOICETOPOSTALCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTE)),'')                                                                                         AS INVOICETOSTATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INAC)),'')                                                                                         AS INVOICETOSTREET 
            ,T$INVT.CONSTANTDESCRIPTION                                                                                                          AS INVOICETYPEDESCRIPTION 
            ,CAST(T$INVT AS INT)                                                                                                                 AS INVOICETYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS ITEMDESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UPDU)),'')                                                                                         AS LASTMODIFIEDBY 
            ,CAST(CASE WHEN T$UPDD<= '1/1/1970' THEN NULL ELSE T$UPDD  END AS DATETIME) AS LASTMODIFIEDDATE 
            ,CAST(T$AMNG AS NUMERIC(15,2))                                                                                                       AS LINEGROSSAMOUNT 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                       AS LINEITEMSUBTOTAL 
            ,CAST(T$AMNN AS NUMERIC(15,2))                                                                                                       AS LINENETAMOUNT 
            ,CAST(T$TXAA AS NUMERIC(15,2))                                                                                                       AS LINETAX 
            ,CAST(T$AMTA AS NUMERIC(15,2))                                                                                                       AS LINETAXABLEAMOUNT 
            ,CAST(T$TXAI AS NUMERIC(15,2))                                                                                                       AS LINETAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LCUR)),'')                                                                                         AS LOCALCURRENCY 
            ,CAST(T$LCTD AS NUMERIC(15,2))                                                                                                       AS LOCALCURRENCYTOTALDUEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOCA)),'')                                                                                         AS LOCALFILENAME 
            ,CAST(CASE WHEN T$ODAT<= '1/1/1970' THEN NULL ELSE T$ODAT  END AS DATETIME) AS ORDER_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                         AS ORDER_ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_NUMBER 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS ORDER_SEQACTIVITY 
            ,T$OTYP.CONSTANTDESCRIPTION                                                                                                          AS ORDER_TYPEDESCRIPTION 
            ,CAST(T$OTYP AS INT)                                                                                                                 AS ORDER_TYPEID 
            ,CAST(T$IDOO AS BIGINT)                                                                                                              AS ORIGINALDOCUMENTNO 
            ,CAST(CASE WHEN T$CODO<= '1/1/1970' THEN NULL ELSE T$CODO  END AS DATETIME) AS ORIGINALINVOICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYO)),'')                                                                                         AS ORIGINALTRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS PRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STCR)),'')                                                                                         AS PURPOSE 
            ,CAST(T$DQUA AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,T$RECR.CONSTANTDESCRIPTION                                                                                                          AS RE_CREATEDDESCRIPTION 
            ,CAST(T$RECR AS INT)                                                                                                                 AS RE_CREATEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REMK)),'')                                                                                         AS REMARKS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FNAM)),'')                                                                                         AS REMITFROMCITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FCCT)),'')                                                                                         AS REMITFROMCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FNCM)),'')                                                                                         AS REMITFROMNAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FPST)),'')                                                                                         AS REMITFROMPOSTALCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FCST)),'')                                                                                         AS REMITFROMSTATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FCAD)),'')                                                                                         AS REMITFROMSTREET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADT)),'')                                                                                         AS REMITTOADDRESSID_CADT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAD)),'')                                                                                         AS REMITTOADDRESSID_CCAD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CNME)),'')                                                                                         AS REMITTOCITY 
            ,CAST(T$CNMP AS INT)                                                                                                                 AS REMITTOCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCCT)),'')                                                                                         AS REMITTOCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CNCM)),'')                                                                                         AS REMITTONAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPST)),'')                                                                                         AS REMITTOPOSTALCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCST)),'')                                                                                         AS REMITTOSTATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CNAM)),'')                                                                                         AS REMITTOSTREET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS SALESINVOICETRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SERV)),'')                                                                                         AS SERVERFILENAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFAD)),'')                                                                                         AS SHIPFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WNAM)),'')                                                                                         AS SHIPFROMCITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WCCT)),'')                                                                                         AS SHIPFROMCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFCO)),'')                                                                                         AS SHIPFROMNAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WPST)),'')                                                                                         AS SHIPFROMPOSTALCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WCST)),'')                                                                                         AS SHIPFROMSTATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS SHIPFROMWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFID)),'')                                                                                         AS SHIPFROMWAREHOUSEADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS SHIPMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAD)),'')                                                                                         AS SHIPTOADDRESSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNME)),'')                                                                                         AS SHIPTOCITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DCCT)),'')                                                                                         AS SHIPTOCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNAM)),'')                                                                                         AS SHIPTONAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DPST)),'')                                                                                         AS SHIPTOPOSTALCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DCST)),'')                                                                                         AS SHIPTOSTATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DNEM)),'')                                                                                         AS SHIPTOSTREET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COM3)),'')                                                                                         AS SLI908TEXT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COM4)),'')                                                                                         AS SLI908TEXT4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFAD)),'')                                                                                         AS SOLDTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SNAM)),'')                                                                                         AS SOLDTOCITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SCCT)),'')                                                                                         AS SOLDTOCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ONAM)),'')                                                                                         AS SOLDTONAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SPST)),'')                                                                                         AS SOLDTOPOSTALCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SCST)),'')                                                                                         AS SOLDTOSTATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ONAC)),'')                                                                                         AS SOLDTOSTREET 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS SUPPLIERPARTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SVAT)),'')                                                                                         AS SUPPLIERVATID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'')                                                                                         AS TAXDESCRIPTION 
            ,CAST(T$TEXR AS NUMERIC(15,2))                                                                                                       AS TAXEXCHANGERATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TINV)),'')                                                                                         AS TAXINVOICE 
            ,CAST(CASE WHEN T$TPDA<= '1/1/1970' THEN NULL ELSE T$TPDA  END AS DATETIME) AS TAXPOINTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS UNITOFMEASURE 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS UNITPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LANG)),'')                                                                                         AS XMLLANGUAGE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TCISLI908201") }} AS SOURCETABLE  
            /*FILEGENERATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FLYN 
             ON   T$FLYN.TABLENAME  = 'CISLI908' 
              AND T$FLYN.COLUMNNAME = 'T$FLYN' 
              AND T$FLYN.CONSTANT   = SOURCETABLE.T$FLYN 
            /*INVOICETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INVT 
             ON   T$INVT.TABLENAME  = 'CISLI908' 
              AND T$INVT.COLUMNNAME = 'T$INVT' 
              AND T$INVT.CONSTANT   = SOURCETABLE.T$INVT 
            /*ORDERTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OTYP 
             ON   T$OTYP.TABLENAME  = 'CISLI908' 
              AND T$OTYP.COLUMNNAME = 'T$OTYP' 
              AND T$OTYP.CONSTANT   = SOURCETABLE.T$OTYP 
            /*RE_CREATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RECR 
             ON   T$RECR.TABLENAME  = 'CISLI908' 
              AND T$RECR.COLUMNNAME = 'T$RECR' 
              AND T$RECR.CONSTANT   = SOURCETABLE.T$RECR 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'CISLI908' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AGREEMENTID AS AGREEMENTID, 
        source_data.AMOUNTININVCURRENCY AS AMOUNTININVCURRENCY, 
        source_data.BILLTOADDRESSID AS BILLTOADDRESSID, 
        source_data.BILLTOID AS BILLTOID, 
        source_data.BUYERVATID AS BUYERVATID, 
        source_data.COMMENTS AS COMMENTS, 
        source_data.COMMENTS1 AS COMMENTS1, 
        source_data.COMMENTS2 AS COMMENTS2, 
        source_data.CREATEDBY AS CREATEDBY, 
        source_data.CREATEDDATE AS CREATEDDATE, 
        source_data.CUSTOMERORDERPOSITION AS CUSTOMERORDERPOSITION, 
        source_data.DOCNO AS DOCNO, 
        source_data.DOCUMENTDATE AS DOCUMENTDATE, 
        source_data.EXPORTEDDATE AS EXPORTEDDATE, 
        source_data.FILEGENERATEDDESCRIPTION AS FILEGENERATEDDESCRIPTION, 
        source_data.FILEGENERATEDID AS FILEGENERATEDID, 
        source_data.INVOICECURRENCY AS INVOICECURRENCY, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICELINENO AS INVOICELINENO, 
        source_data.INVOICETAXCATERY AS INVOICETAXCATERY, 
        source_data.INVOICETAXDESCRIPTION AS INVOICETAXDESCRIPTION, 
        source_data.INVOICETOCITY AS INVOICETOCITY, 
        source_data.INVOICETOCOUNTRY AS INVOICETOCOUNTRY, 
        source_data.INVOICETONAME AS INVOICETONAME, 
        source_data.INVOICETOPOSTALCODE AS INVOICETOPOSTALCODE, 
        source_data.INVOICETOSTATE AS INVOICETOSTATE, 
        source_data.INVOICETOSTREET AS INVOICETOSTREET, 
        source_data.INVOICETYPEDESCRIPTION AS INVOICETYPEDESCRIPTION, 
        source_data.INVOICETYPEID AS INVOICETYPEID, 
        source_data.ITEMDESCRIPTION AS ITEMDESCRIPTION, 
        source_data.LASTMODIFIEDBY AS LASTMODIFIEDBY, 
        source_data.LASTMODIFIEDDATE AS LASTMODIFIEDDATE, 
        source_data.LINEGROSSAMOUNT AS LINEGROSSAMOUNT, 
        source_data.LINEITEMSUBTOTAL AS LINEITEMSUBTOTAL, 
        source_data.LINENETAMOUNT AS LINENETAMOUNT, 
        source_data.LINETAX AS LINETAX, 
        source_data.LINETAXABLEAMOUNT AS LINETAXABLEAMOUNT, 
        source_data.LINETAXAMOUNT AS LINETAXAMOUNT, 
        source_data.LOCALCURRENCY AS LOCALCURRENCY, 
        source_data.LOCALCURRENCYTOTALDUEAMOUNT AS LOCALCURRENCYTOTALDUEAMOUNT, 
        source_data.LOCALFILENAME AS LOCALFILENAME, 
        source_data.ORDER_DATE AS ORDER_DATE, 
        source_data.ORDER_ID AS ORDER_ID, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.ORDER_SEQACTIVITY AS ORDER_SEQACTIVITY, 
        source_data.ORDER_TYPEDESCRIPTION AS ORDER_TYPEDESCRIPTION, 
        source_data.ORDER_TYPEID AS ORDER_TYPEID, 
        source_data.ORIGINALDOCUMENTNO AS ORIGINALDOCUMENTNO, 
        source_data.ORIGINALINVOICEDATE AS ORIGINALINVOICEDATE, 
        source_data.ORIGINALTRANSACTIONTYPE AS ORIGINALTRANSACTIONTYPE, 
        source_data.PRICEUNIT AS PRICEUNIT, 
        source_data.PURPOSE AS PURPOSE, 
        source_data.QUANTITY AS QUANTITY, 
        source_data.RE_CREATEDDESCRIPTION AS RE_CREATEDDESCRIPTION, 
        source_data.RE_CREATEDID AS RE_CREATEDID, 
        source_data.REMARKS AS REMARKS, 
        source_data.REMITFROMCITY AS REMITFROMCITY, 
        source_data.REMITFROMCOUNTRY AS REMITFROMCOUNTRY, 
        source_data.REMITFROMNAME AS REMITFROMNAME, 
        source_data.REMITFROMPOSTALCODE AS REMITFROMPOSTALCODE, 
        source_data.REMITFROMSTATE AS REMITFROMSTATE, 
        source_data.REMITFROMSTREET AS REMITFROMSTREET, 
        source_data.REMITTOADDRESSID_CADT AS REMITTOADDRESSID_CADT, 
        source_data.REMITTOADDRESSID_CCAD AS REMITTOADDRESSID_CCAD, 
        source_data.REMITTOCITY AS REMITTOCITY, 
        source_data.REMITTOCOMPANY AS REMITTOCOMPANY, 
        source_data.REMITTOCOUNTRY AS REMITTOCOUNTRY, 
        source_data.REMITTONAME AS REMITTONAME, 
        source_data.REMITTOPOSTALCODE AS REMITTOPOSTALCODE, 
        source_data.REMITTOSTATE AS REMITTOSTATE, 
        source_data.REMITTOSTREET AS REMITTOSTREET, 
        source_data.SALESINVOICETRANSACTIONTYPE AS SALESINVOICETRANSACTIONTYPE, 
        source_data.SERVERFILENAME AS SERVERFILENAME, 
        source_data.SHIPFROMADDRESS AS SHIPFROMADDRESS, 
        source_data.SHIPFROMCITY AS SHIPFROMCITY, 
        source_data.SHIPFROMCOUNTRY AS SHIPFROMCOUNTRY, 
        source_data.SHIPFROMNAME AS SHIPFROMNAME, 
        source_data.SHIPFROMPOSTALCODE AS SHIPFROMPOSTALCODE, 
        source_data.SHIPFROMSTATE AS SHIPFROMSTATE, 
        source_data.SHIPFROMWAREHOUSE AS SHIPFROMWAREHOUSE, 
        source_data.SHIPFROMWAREHOUSEADDRESS AS SHIPFROMWAREHOUSEADDRESS, 
        source_data.SHIPMENTID AS SHIPMENTID, 
        source_data.SHIPTOADDRESSID AS SHIPTOADDRESSID, 
        source_data.SHIPTOBP AS SHIPTOBP, 
        source_data.SHIPTOCITY AS SHIPTOCITY, 
        source_data.SHIPTOCOUNTRY AS SHIPTOCOUNTRY, 
        source_data.SHIPTONAME AS SHIPTONAME, 
        source_data.SHIPTOPOSTALCODE AS SHIPTOPOSTALCODE, 
        source_data.SHIPTOSTATE AS SHIPTOSTATE, 
        source_data.SHIPTOSTREET AS SHIPTOSTREET, 
        source_data.SLI908TEXT3 AS SLI908TEXT3, 
        source_data.SLI908TEXT4 AS SLI908TEXT4, 
        source_data.SOLDTOADDRESS AS SOLDTOADDRESS, 
        source_data.SOLDTOBP AS SOLDTOBP, 
        source_data.SOLDTOCITY AS SOLDTOCITY, 
        source_data.SOLDTOCOUNTRY AS SOLDTOCOUNTRY, 
        source_data.SOLDTONAME AS SOLDTONAME, 
        source_data.SOLDTOPOSTALCODE AS SOLDTOPOSTALCODE, 
        source_data.SOLDTOSTATE AS SOLDTOSTATE, 
        source_data.SOLDTOSTREET AS SOLDTOSTREET, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.SUPPLIERPARTID AS SUPPLIERPARTID, 
        source_data.SUPPLIERVATID AS SUPPLIERVATID, 
        source_data.TAXDESCRIPTION AS TAXDESCRIPTION, 
        source_data.TAXEXCHANGERATE AS TAXEXCHANGERATE, 
        source_data.TAXINVOICE AS TAXINVOICE, 
        source_data.TAXPOINTDATE AS TAXPOINTDATE, 
        source_data.UNITOFMEASURE AS UNITOFMEASURE, 
        source_data.UNITPRICE AS UNITPRICE, 
        source_data.XMLLANGUAGE AS XMLLANGUAGE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AGREEMENTID as VARCHAR(30)) as AGREEMENTID,
        cast(AMOUNTININVCURRENCY as NUMBER(15,2)) as AMOUNTININVCURRENCY,
        cast(BILLTOADDRESSID as VARCHAR(9)) as BILLTOADDRESSID,
        cast(BILLTOID as VARCHAR(9)) as BILLTOID,
        cast(BUYERVATID as VARCHAR(10)) as BUYERVATID,
        cast(COMMENTS as NUMBER(38,10)) as COMMENTS,
        cast(COMMENTS1 as VARCHAR(100)) as COMMENTS1,
        cast(COMMENTS2 as VARCHAR(100)) as COMMENTS2,
        cast(CREATEDBY as VARCHAR(35)) as CREATEDBY,
        cast(CREATEDDATE as TIMESTAMP_NTZ(9)) as CREATEDDATE,
        cast(CUSTOMERORDERPOSITION as VARCHAR(16)) as CUSTOMERORDERPOSITION,
        cast(DOCNO as NUMBER(38,0)) as DOCNO,
        cast(DOCUMENTDATE as DATE) as DOCUMENTDATE,
        cast(EXPORTEDDATE as TIMESTAMP_NTZ(9)) as EXPORTEDDATE,
        cast(FILEGENERATEDDESCRIPTION as VARCHAR(16777216)) as FILEGENERATEDDESCRIPTION,
        cast(FILEGENERATEDID as NUMBER(38,0)) as FILEGENERATEDID,
        cast(INVOICECURRENCY as VARCHAR(3)) as INVOICECURRENCY,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICELINENO as NUMBER(38,0)) as INVOICELINENO,
        cast(INVOICETAXCATERY as VARCHAR(10)) as INVOICETAXCATERY,
        cast(INVOICETAXDESCRIPTION as VARCHAR(40)) as INVOICETAXDESCRIPTION,
        cast(INVOICETOCITY as VARCHAR(30)) as INVOICETOCITY,
        cast(INVOICETOCOUNTRY as VARCHAR(3)) as INVOICETOCOUNTRY,
        cast(INVOICETONAME as VARCHAR(35)) as INVOICETONAME,
        cast(INVOICETOPOSTALCODE as VARCHAR(10)) as INVOICETOPOSTALCODE,
        cast(INVOICETOSTATE as VARCHAR(2)) as INVOICETOSTATE,
        cast(INVOICETOSTREET as VARCHAR(30)) as INVOICETOSTREET,
        cast(INVOICETYPEDESCRIPTION as VARCHAR(16777216)) as INVOICETYPEDESCRIPTION,
        cast(INVOICETYPEID as NUMBER(38,0)) as INVOICETYPEID,
        cast(ITEMDESCRIPTION as VARCHAR(50)) as ITEMDESCRIPTION,
        cast(LASTMODIFIEDBY as VARCHAR(10)) as LASTMODIFIEDBY,
        cast(LASTMODIFIEDDATE as TIMESTAMP_NTZ(9)) as LASTMODIFIEDDATE,
        cast(LINEGROSSAMOUNT as NUMBER(15,2)) as LINEGROSSAMOUNT,
        cast(LINEITEMSUBTOTAL as NUMBER(15,2)) as LINEITEMSUBTOTAL,
        cast(LINENETAMOUNT as NUMBER(15,2)) as LINENETAMOUNT,
        cast(LINETAX as NUMBER(15,2)) as LINETAX,
        cast(LINETAXABLEAMOUNT as NUMBER(15,2)) as LINETAXABLEAMOUNT,
        cast(LINETAXAMOUNT as NUMBER(15,2)) as LINETAXAMOUNT,
        cast(LOCALCURRENCY as VARCHAR(3)) as LOCALCURRENCY,
        cast(LOCALCURRENCYTOTALDUEAMOUNT as NUMBER(15,2)) as LOCALCURRENCYTOTALDUEAMOUNT,
        cast(LOCALFILENAME as VARCHAR(100)) as LOCALFILENAME,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_ID as VARCHAR(30)) as ORDER_ID,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORDER_SEQACTIVITY as NUMBER(38,0)) as ORDER_SEQACTIVITY,
        cast(ORDER_TYPEDESCRIPTION as VARCHAR(16777216)) as ORDER_TYPEDESCRIPTION,
        cast(ORDER_TYPEID as NUMBER(38,0)) as ORDER_TYPEID,
        cast(ORIGINALDOCUMENTNO as NUMBER(38,0)) as ORIGINALDOCUMENTNO,
        cast(ORIGINALINVOICEDATE as TIMESTAMP_NTZ(9)) as ORIGINALINVOICEDATE,
        cast(ORIGINALTRANSACTIONTYPE as VARCHAR(3)) as ORIGINALTRANSACTIONTYPE,
        cast(PRICEUNIT as VARCHAR(3)) as PRICEUNIT,
        cast(PURPOSE as VARCHAR(15)) as PURPOSE,
        cast(QUANTITY as NUMBER(15,2)) as QUANTITY,
        cast(RE_CREATEDDESCRIPTION as VARCHAR(16777216)) as RE_CREATEDDESCRIPTION,
        cast(RE_CREATEDID as NUMBER(38,0)) as RE_CREATEDID,
        cast(REMARKS as VARCHAR(100)) as REMARKS,
        cast(REMITFROMCITY as VARCHAR(30)) as REMITFROMCITY,
        cast(REMITFROMCOUNTRY as VARCHAR(3)) as REMITFROMCOUNTRY,
        cast(REMITFROMNAME as VARCHAR(35)) as REMITFROMNAME,
        cast(REMITFROMPOSTALCODE as VARCHAR(10)) as REMITFROMPOSTALCODE,
        cast(REMITFROMSTATE as VARCHAR(2)) as REMITFROMSTATE,
        cast(REMITFROMSTREET as VARCHAR(50)) as REMITFROMSTREET,
        cast(REMITTOADDRESSID_CADT as VARCHAR(20)) as REMITTOADDRESSID_CADT,
        cast(REMITTOADDRESSID_CCAD as VARCHAR(9)) as REMITTOADDRESSID_CCAD,
        cast(REMITTOCITY as VARCHAR(30)) as REMITTOCITY,
        cast(REMITTOCOMPANY as NUMBER(38,0)) as REMITTOCOMPANY,
        cast(REMITTOCOUNTRY as VARCHAR(3)) as REMITTOCOUNTRY,
        cast(REMITTONAME as VARCHAR(35)) as REMITTONAME,
        cast(REMITTOPOSTALCODE as VARCHAR(10)) as REMITTOPOSTALCODE,
        cast(REMITTOSTATE as VARCHAR(2)) as REMITTOSTATE,
        cast(REMITTOSTREET as VARCHAR(30)) as REMITTOSTREET,
        cast(SALESINVOICETRANSACTIONTYPE as VARCHAR(3)) as SALESINVOICETRANSACTIONTYPE,
        cast(SERVERFILENAME as VARCHAR(100)) as SERVERFILENAME,
        cast(SHIPFROMADDRESS as VARCHAR(30)) as SHIPFROMADDRESS,
        cast(SHIPFROMCITY as VARCHAR(30)) as SHIPFROMCITY,
        cast(SHIPFROMCOUNTRY as VARCHAR(3)) as SHIPFROMCOUNTRY,
        cast(SHIPFROMNAME as VARCHAR(30)) as SHIPFROMNAME,
        cast(SHIPFROMPOSTALCODE as VARCHAR(10)) as SHIPFROMPOSTALCODE,
        cast(SHIPFROMSTATE as VARCHAR(2)) as SHIPFROMSTATE,
        cast(SHIPFROMWAREHOUSE as VARCHAR(6)) as SHIPFROMWAREHOUSE,
        cast(SHIPFROMWAREHOUSEADDRESS as VARCHAR(9)) as SHIPFROMWAREHOUSEADDRESS,
        cast(SHIPMENTID as VARCHAR(9)) as SHIPMENTID,
        cast(SHIPTOADDRESSID as VARCHAR(9)) as SHIPTOADDRESSID,
        cast(SHIPTOBP as VARCHAR(9)) as SHIPTOBP,
        cast(SHIPTOCITY as VARCHAR(30)) as SHIPTOCITY,
        cast(SHIPTOCOUNTRY as VARCHAR(3)) as SHIPTOCOUNTRY,
        cast(SHIPTONAME as VARCHAR(50)) as SHIPTONAME,
        cast(SHIPTOPOSTALCODE as VARCHAR(10)) as SHIPTOPOSTALCODE,
        cast(SHIPTOSTATE as VARCHAR(2)) as SHIPTOSTATE,
        cast(SHIPTOSTREET as VARCHAR(50)) as SHIPTOSTREET,
        cast(SLI908TEXT3 as VARCHAR(100)) as SLI908TEXT3,
        cast(SLI908TEXT4 as VARCHAR(100)) as SLI908TEXT4,
        cast(SOLDTOADDRESS as VARCHAR(9)) as SOLDTOADDRESS,
        cast(SOLDTOBP as VARCHAR(9)) as SOLDTOBP,
        cast(SOLDTOCITY as VARCHAR(30)) as SOLDTOCITY,
        cast(SOLDTOCOUNTRY as VARCHAR(3)) as SOLDTOCOUNTRY,
        cast(SOLDTONAME as VARCHAR(35)) as SOLDTONAME,
        cast(SOLDTOPOSTALCODE as VARCHAR(10)) as SOLDTOPOSTALCODE,
        cast(SOLDTOSTATE as VARCHAR(2)) as SOLDTOSTATE,
        cast(SOLDTOSTREET as VARCHAR(30)) as SOLDTOSTREET,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(SUPPLIERPARTID as VARCHAR(47)) as SUPPLIERPARTID,
        cast(SUPPLIERVATID as VARCHAR(10)) as SUPPLIERVATID,
        cast(TAXDESCRIPTION as VARCHAR(40)) as TAXDESCRIPTION,
        cast(TAXEXCHANGERATE as NUMBER(15,2)) as TAXEXCHANGERATE,
        cast(TAXINVOICE as VARCHAR(10)) as TAXINVOICE,
        cast(TAXPOINTDATE as TIMESTAMP_NTZ(9)) as TAXPOINTDATE,
        cast(UNITOFMEASURE as VARCHAR(3)) as UNITOFMEASURE,
        cast(UNITPRICE as NUMBER(15,2)) as UNITPRICE,
        cast(XMLLANGUAGE as VARCHAR(2)) as XMLLANGUAGE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data