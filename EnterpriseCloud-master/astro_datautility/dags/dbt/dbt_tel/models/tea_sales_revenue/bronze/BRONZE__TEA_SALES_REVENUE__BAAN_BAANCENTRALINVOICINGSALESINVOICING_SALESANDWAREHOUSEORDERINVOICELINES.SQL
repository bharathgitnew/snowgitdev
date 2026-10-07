/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCENTRALINVOICINGSALESINVOICING_SALESANDWAREHOUSEORDERINVOICELINES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCENTRALINVOICINGSALESINVOICING_SALESANDWAREHOUSEORDERINVOICELINES.SQL 
-materialized incremental
-alias BAANCENTRALINVOICINGSALESINVOICING_SALESANDWAREHOUSEORDERINVOICELINES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:47 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCENTRALINVOICINGSALESINVOICING_SALESANDWAREHOUSEORDERINVOICELINES',
    unique_key = ['LINENUMBER',
    'ORDER_TYPEID',
    'PACKINGSLIPNO',
    'SALESWAREHOUSEORDER',
    'SEQUENCENUMBER',
    'SOURCELOGISTICCOMPANY']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY3 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                       AS AMOUNTININVOICECURRENCY 
            ,T$CHTP.CONSTANTDESCRIPTION                                                                                                          AS CHARGETYPEDESCRIPTION 
            ,CAST(T$CHTP AS INT)                                                                                                                 AS CHARGETYPEID 
            ,T$COIV.CONSTANTDESCRIPTION                                                                                                          AS COMPOSEONEINVOICEDESCRIPTION 
            ,CAST(T$COIV AS INT)                                                                                                                 AS COMPOSEONEINVOICEID 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                       AS CONVFACTORPRICEUNIT 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                       AS CONVFACTORQUANTITYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                         AS CUSTOMERORDERNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORP)),'')                                                                                         AS CUSTOMERORDERPOSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORS)),'')                                                                                         AS CUSTOMERORDERSEQUENCE 
            ,CAST(CASE WHEN T$CODT<= '1/1/1970' THEN NULL ELSE T$CODT  END AS DATETIME) AS CUT_OFFDATE 
            ,CAST(T$DQUA AS NUMERIC(15,2))                                                                                                       AS DELIVEREDQUANTITY 
            ,CAST(CASE WHEN T$DDAT<= '1/1/1970' THEN NULL ELSE T$DDAT  END AS DATETIME) AS DELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS DEPARTMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,SOURCETABLE.T$DTXT   /* TEXT */                                                                                                     AS DETAILTEXT 
            ,"T$DISM$1".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD1DESCRIPTION 
            ,CAST("T$DISM$1" AS INT)                                                                                                               AS DISCOUNTMETHOD1ID 
            ,"T$DISM$2".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD2DESCRIPTION 
            ,CAST("T$DISM$2" AS INT)                                                                                                               AS DISCOUNTMETHOD2ID 
            ,"T$DISM$3".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD3DESCRIPTION 
            ,CAST("T$DISM$3" AS INT)                                                                                                               AS DISCOUNTMETHOD3ID 
            ,"T$DISM$4".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD4DESCRIPTION 
            ,CAST("T$DISM$4" AS INT)                                                                                                               AS DISCOUNTMETHOD4ID 
            ,"T$DISM$5".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD5DESCRIPTION 
            ,CAST("T$DISM$5" AS INT)                                                                                                               AS DISCOUNTMETHOD5ID 
            ,CAST("T$DISC$1" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE1 
            ,CAST("T$DISC$2" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE2 
            ,CAST("T$DISC$3" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE3 
            ,CAST("T$DISC$4" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE4 
            ,CAST("T$DISC$5" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,CAST(T$SFCP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,CAST("T$COGN$1" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS1 
            ,CAST("T$COGN$2" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS2 
            ,CAST("T$COGN$3" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS3 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS INVOICESTATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS INVOICESTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,SOURCETABLE.T$ITXT   /* TEXT */                                                                                                     AS ITEMTEXT 
            ,CAST("T$LDAM$1" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT1 
            ,CAST("T$LDAM$2" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT2 
            ,CAST("T$LDAM$3" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT3 
            ,CAST("T$LDAM$4" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT4 
            ,CAST("T$LDAM$5" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT5 
            ,CAST(T$LDAI AS NUMERIC(15,2))                                                                                                       AS LINEDISCOUNTAMOUNT_LDAI 
            ,CAST(T$PONO AS INT)                                                                                                                 AS LINENUMBER 
            ,SOURCETABLE.T$LTXT   /* TEXT */                                                                                                     AS LOTTEXT 
            ,CAST(T$ODAI AS NUMERIC(15,2))                                                                                                       AS ORDER_DISCOUNTAMOUNT 
            ,CAST(T$OQUA AS NUMERIC(15,2))                                                                                                       AS ORDER_EDQUANTITY 
            ,T$ORTP.CONSTANTDESCRIPTION                                                                                                          AS ORDER_TYPEDESCRIPTION 
            ,CAST(T$ORTP AS INT)                                                                                                                 AS ORDER_TYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS PACKINGSLIPNO 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS PRICEUNIT 
            ,CAST(T$CPVA AS BIGINT)                                                                                                              AS PRODUCTVARIANT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,CAST(T$PDOC AS BIGINT)                                                                                                              AS PURCHASEDOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTYP)),'')                                                                                         AS PURCHASEINVOICETRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS QUANTITYUNIT 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS RATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS RATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS RATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS REVISION 
            ,CAST(T$SCMP AS INT)                                                                                                                 AS SALESINVOICECOMPANY 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS SALESINVOICEDOCUMENTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS SALESINVOICETRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SLSO)),'')                                                                                         AS SALESWAREHOUSEORDER 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(T$SETN AS INT)                                                                                                                 AS SETNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFRA)),'')                                                                                         AS SHIPFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STOA)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,CAST(T$SLCP AS INT)                                                                                                                 AS SOURCELOGISTICCOMPANY 
            ,CAST("T$COPR$1" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTS1 
            ,CAST("T$COPR$2" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTS2 
            ,CAST("T$COPR$3" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTS3 
            ,CAST("T$TXAH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$TXAH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$TXAH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,CAST(T$TXAI AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXCT)),'')                                                                                         AS TAXCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXID)),'')                                                                                         AS TAXID 
            ,T$INVT.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFINVOICEDESCRIPTION 
            ,CAST(T$INVT AS INT)                                                                                                                 AS TYPEOFINVOICEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TCISLI245200") }} AS SOURCETABLE  
            /*CHARGETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHTP 
             ON   T$CHTP.TABLENAME  = 'CISLI245' 
              AND T$CHTP.COLUMNNAME = 'T$CHTP' 
              AND T$CHTP.CONSTANT   = SOURCETABLE.T$CHTP 
            /*COMPOSEONEINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COIV 
             ON   T$COIV.TABLENAME  = 'CISLI245' 
              AND T$COIV.COLUMNNAME = 'T$COIV' 
              AND T$COIV.CONSTANT   = SOURCETABLE.T$COIV 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$1" 
             ON   "T$DISM$1".TABLENAME  = 'CISLI245' 
              AND "T$DISM$1".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$1".CONSTANT   = SOURCETABLE."T$DISM$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$2" 
             ON   "T$DISM$2".TABLENAME  = 'CISLI245' 
              AND "T$DISM$2".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$2".CONSTANT   = SOURCETABLE."T$DISM$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$3" 
             ON   "T$DISM$3".TABLENAME  = 'CISLI245' 
              AND "T$DISM$3".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$3".CONSTANT   = SOURCETABLE."T$DISM$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$4" 
             ON   "T$DISM$4".TABLENAME  = 'CISLI245' 
              AND "T$DISM$4".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$4".CONSTANT   = SOURCETABLE."T$DISM$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$5" 
             ON   "T$DISM$5".TABLENAME  = 'CISLI245' 
              AND "T$DISM$5".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$5".CONSTANT   = SOURCETABLE."T$DISM$5" 
            /*INVOICESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'CISLI245' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*ORDERTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ORTP 
             ON   T$ORTP.TABLENAME  = 'CISLI245' 
              AND T$ORTP.COLUMNNAME = 'T$ORTP' 
              AND T$ORTP.CONSTANT   = SOURCETABLE.T$ORTP 
            /*TYPEOFINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INVT 
             ON   T$INVT.TABLENAME  = 'CISLI245' 
              AND T$INVT.COLUMNNAME = 'T$INVT' 
              AND T$INVT.CONSTANT   = SOURCETABLE.T$INVT 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT   
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY3 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                       AS AMOUNTININVOICECURRENCY 
            ,T$CHTP.CONSTANTDESCRIPTION                                                                                                          AS CHARGETYPEDESCRIPTION 
            ,CAST(T$CHTP AS INT)                                                                                                                 AS CHARGETYPEID 
            ,T$COIV.CONSTANTDESCRIPTION                                                                                                          AS COMPOSEONEINVOICEDESCRIPTION 
            ,CAST(T$COIV AS INT)                                                                                                                 AS COMPOSEONEINVOICEID 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                       AS CONVFACTORPRICEUNIT 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                       AS CONVFACTORQUANTITYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                         AS CUSTOMERORDERNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORP)),'')                                                                                         AS CUSTOMERORDERPOSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORS)),'')                                                                                         AS CUSTOMERORDERSEQUENCE 
            ,CAST(CASE WHEN T$CODT<= '1/1/1970' THEN NULL ELSE T$CODT  END AS DATETIME) AS CUT_OFFDATE 
            ,CAST(T$DQUA AS NUMERIC(15,2))                                                                                                       AS DELIVEREDQUANTITY 
            ,CAST(CASE WHEN T$DDAT<= '1/1/1970' THEN NULL ELSE T$DDAT  END AS DATETIME) AS DELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS DEPARTMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,SOURCETABLE.T$DTXT   /* TEXT */                                                                                                     AS DETAILTEXT 
            ,"T$DISM$1".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD1DESCRIPTION 
            ,CAST("T$DISM$1" AS INT)                                                                                                               AS DISCOUNTMETHOD1ID 
            ,"T$DISM$2".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD2DESCRIPTION 
            ,CAST("T$DISM$2" AS INT)                                                                                                               AS DISCOUNTMETHOD2ID 
            ,"T$DISM$3".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD3DESCRIPTION 
            ,CAST("T$DISM$3" AS INT)                                                                                                               AS DISCOUNTMETHOD3ID 
            ,"T$DISM$4".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD4DESCRIPTION 
            ,CAST("T$DISM$4" AS INT)                                                                                                               AS DISCOUNTMETHOD4ID 
            ,"T$DISM$5".CONSTANTDESCRIPTION                                                                                                        AS DISCOUNTMETHOD5DESCRIPTION 
            ,CAST("T$DISM$5" AS INT)                                                                                                               AS DISCOUNTMETHOD5ID 
            ,CAST("T$DISC$1" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE1 
            ,CAST("T$DISC$2" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE2 
            ,CAST("T$DISC$3" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE3 
            ,CAST("T$DISC$4" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE4 
            ,CAST("T$DISC$5" AS NUMERIC(15,2))                                                                                                     AS DISCOUNTPERCENTAGE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,CAST(T$SFCP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,CAST("T$COGN$1" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS1 
            ,CAST("T$COGN$2" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS2 
            ,CAST("T$COGN$3" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS3 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS INVOICESTATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS INVOICESTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,SOURCETABLE.T$ITXT   /* TEXT */                                                                                                     AS ITEMTEXT 
            ,CAST("T$LDAM$1" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT1 
            ,CAST("T$LDAM$2" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT2 
            ,CAST("T$LDAM$3" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT3 
            ,CAST("T$LDAM$4" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT4 
            ,CAST("T$LDAM$5" AS NUMERIC(15,2))                                                                                                     AS LINEDISCOUNTAMOUNT5 
            ,CAST(T$LDAI AS NUMERIC(15,2))                                                                                                       AS LINEDISCOUNTAMOUNT_LDAI 
            ,CAST(T$PONO AS INT)                                                                                                                 AS LINENUMBER 
            ,SOURCETABLE.T$LTXT   /* TEXT */                                                                                                     AS LOTTEXT 
            ,CAST(T$ODAI AS NUMERIC(15,2))                                                                                                       AS ORDER_DISCOUNTAMOUNT 
            ,CAST(T$OQUA AS NUMERIC(15,2))                                                                                                       AS ORDER_EDQUANTITY 
            ,T$ORTP.CONSTANTDESCRIPTION                                                                                                          AS ORDER_TYPEDESCRIPTION 
            ,CAST(T$ORTP AS INT)                                                                                                                 AS ORDER_TYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS PACKINGSLIPNO 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS PRICEUNIT 
            ,CAST(T$CPVA AS BIGINT)                                                                                                              AS PRODUCTVARIANT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,CAST(T$PDOC AS BIGINT)                                                                                                              AS PURCHASEDOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTYP)),'')                                                                                         AS PURCHASEINVOICETRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS QUANTITYUNIT 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS RATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS RATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS RATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS REVISION 
            ,CAST(T$SCMP AS INT)                                                                                                                 AS SALESINVOICECOMPANY 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS SALESINVOICEDOCUMENTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS SALESINVOICETRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SLSO)),'')                                                                                         AS SALESWAREHOUSEORDER 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(T$SETN AS INT)                                                                                                                 AS SETNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFRA)),'')                                                                                         AS SHIPFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STOA)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,CAST(T$SLCP AS INT)                                                                                                                 AS SOURCELOGISTICCOMPANY 
            ,CAST("T$COPR$1" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTS1 
            ,CAST("T$COPR$2" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTS2 
            ,CAST("T$COPR$3" AS NUMERIC(15,2))                                                                                                     AS STANDARDCOSTS3 
            ,CAST("T$TXAH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$TXAH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$TXAH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,CAST(T$TXAI AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXCT)),'')                                                                                         AS TAXCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXID)),'')                                                                                         AS TAXID 
            ,T$INVT.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFINVOICEDESCRIPTION 
            ,CAST(T$INVT AS INT)                                                                                                                 AS TYPEOFINVOICEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TCISLI245201") }} AS SOURCETABLE  
            /*CHARGETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHTP 
             ON   T$CHTP.TABLENAME  = 'CISLI245' 
              AND T$CHTP.COLUMNNAME = 'T$CHTP' 
              AND T$CHTP.CONSTANT   = SOURCETABLE.T$CHTP 
            /*COMPOSEONEINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COIV 
             ON   T$COIV.TABLENAME  = 'CISLI245' 
              AND T$COIV.COLUMNNAME = 'T$COIV' 
              AND T$COIV.CONSTANT   = SOURCETABLE.T$COIV 
            /*DISCOUNTMETHOD1*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$1" 
             ON   "T$DISM$1".TABLENAME  = 'CISLI245' 
              AND "T$DISM$1".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$1".CONSTANT   = SOURCETABLE."T$DISM$1" 
            /*DISCOUNTMETHOD2*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$2" 
             ON   "T$DISM$2".TABLENAME  = 'CISLI245' 
              AND "T$DISM$2".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$2".CONSTANT   = SOURCETABLE."T$DISM$2" 
            /*DISCOUNTMETHOD3*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$3" 
             ON   "T$DISM$3".TABLENAME  = 'CISLI245' 
              AND "T$DISM$3".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$3".CONSTANT   = SOURCETABLE."T$DISM$3" 
            /*DISCOUNTMETHOD4*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$4" 
             ON   "T$DISM$4".TABLENAME  = 'CISLI245' 
              AND "T$DISM$4".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$4".CONSTANT   = SOURCETABLE."T$DISM$4" 
            /*DISCOUNTMETHOD5*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$DISM$5" 
             ON   "T$DISM$5".TABLENAME  = 'CISLI245' 
              AND "T$DISM$5".COLUMNNAME = 'T$DISM' 
              AND "T$DISM$5".CONSTANT   = SOURCETABLE."T$DISM$5" 
            /*INVOICESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'CISLI245' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*ORDERTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ORTP 
             ON   T$ORTP.TABLENAME  = 'CISLI245' 
              AND T$ORTP.COLUMNNAME = 'T$ORTP' 
              AND T$ORTP.CONSTANT   = SOURCETABLE.T$ORTP 
            /*TYPEOFINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INVT 
             ON   T$INVT.TABLENAME  = 'CISLI245' 
              AND T$INVT.COLUMNNAME = 'T$INVT' 
              AND T$INVT.CONSTANT   = SOURCETABLE.T$INVT 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNTINHOMECURRENCY1 AS AMOUNTINHOMECURRENCY1, 
        source_data.AMOUNTINHOMECURRENCY2 AS AMOUNTINHOMECURRENCY2, 
        source_data.AMOUNTINHOMECURRENCY3 AS AMOUNTINHOMECURRENCY3, 
        source_data.AMOUNTININVOICECURRENCY AS AMOUNTININVOICECURRENCY, 
        source_data.CHARGETYPEDESCRIPTION AS CHARGETYPEDESCRIPTION, 
        source_data.CHARGETYPEID AS CHARGETYPEID, 
        source_data.COMPOSEONEINVOICEDESCRIPTION AS COMPOSEONEINVOICEDESCRIPTION, 
        source_data.COMPOSEONEINVOICEID AS COMPOSEONEINVOICEID, 
        source_data.CONVFACTORPRICEUNIT AS CONVFACTORPRICEUNIT, 
        source_data.CONVFACTORQUANTITYUNIT AS CONVFACTORQUANTITYUNIT, 
        source_data.CUSTOMERORDERNUMBER AS CUSTOMERORDERNUMBER, 
        source_data.CUSTOMERORDERPOSITION AS CUSTOMERORDERPOSITION, 
        source_data.CUSTOMERORDERSEQUENCE AS CUSTOMERORDERSEQUENCE, 
        source_data.CUT_OFFDATE AS CUT_OFFDATE, 
        source_data.DELIVEREDQUANTITY AS DELIVEREDQUANTITY, 
        source_data.DELIVERYDATE AS DELIVERYDATE, 
        source_data.DEPARTMENT AS DEPARTMENT, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.DETAILTEXT AS DETAILTEXT, 
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
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.FINANCIALCOMPANY AS FINANCIALCOMPANY, 
        source_data.GENERALCOSTS1 AS GENERALCOSTS1, 
        source_data.GENERALCOSTS2 AS GENERALCOSTS2, 
        source_data.GENERALCOSTS3 AS GENERALCOSTS3, 
        source_data.INVOICESTATUSDESCRIPTION AS INVOICESTATUSDESCRIPTION, 
        source_data.INVOICESTATUSID AS INVOICESTATUSID, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMTEXT AS ITEMTEXT, 
        source_data.LINEDISCOUNTAMOUNT1 AS LINEDISCOUNTAMOUNT1, 
        source_data.LINEDISCOUNTAMOUNT2 AS LINEDISCOUNTAMOUNT2, 
        source_data.LINEDISCOUNTAMOUNT3 AS LINEDISCOUNTAMOUNT3, 
        source_data.LINEDISCOUNTAMOUNT4 AS LINEDISCOUNTAMOUNT4, 
        source_data.LINEDISCOUNTAMOUNT5 AS LINEDISCOUNTAMOUNT5, 
        source_data.LINEDISCOUNTAMOUNT_LDAI AS LINEDISCOUNTAMOUNT_LDAI, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.LOTTEXT AS LOTTEXT, 
        source_data.ORDER_DISCOUNTAMOUNT AS ORDER_DISCOUNTAMOUNT, 
        source_data.ORDER_EDQUANTITY AS ORDER_EDQUANTITY, 
        source_data.ORDER_TYPEDESCRIPTION AS ORDER_TYPEDESCRIPTION, 
        source_data.ORDER_TYPEID AS ORDER_TYPEID, 
        source_data.PACKINGSLIPNO AS PACKINGSLIPNO, 
        source_data.PRICE AS PRICE, 
        source_data.PRICEUNIT AS PRICEUNIT, 
        source_data.PRODUCTVARIANT AS PRODUCTVARIANT, 
        source_data.PROJECT AS PROJECT, 
        source_data.PURCHASEDOCUMENT AS PURCHASEDOCUMENT, 
        source_data.PURCHASEINVOICETRANSACTIONTYPE AS PURCHASEINVOICETRANSACTIONTYPE, 
        source_data.QUANTITYUNIT AS QUANTITYUNIT, 
        source_data.RATE1 AS RATE1, 
        source_data.RATE2 AS RATE2, 
        source_data.RATE3 AS RATE3, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.REVISION AS REVISION, 
        source_data.SALESINVOICECOMPANY AS SALESINVOICECOMPANY, 
        source_data.SALESINVOICEDOCUMENTNUMBER AS SALESINVOICEDOCUMENTNUMBER, 
        source_data.SALESINVOICETRANSACTIONTYPE AS SALESINVOICETRANSACTIONTYPE, 
        source_data.SALESWAREHOUSEORDER AS SALESWAREHOUSEORDER, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SETNUMBER AS SETNUMBER, 
        source_data.SHIPFROMADDRESS AS SHIPFROMADDRESS, 
        source_data.SHIPTOADDRESS AS SHIPTOADDRESS, 
        source_data.SHIPTOBUSINESSPARTNER AS SHIPTOBUSINESSPARTNER, 
        source_data.SOURCELOGISTICCOMPANY AS SOURCELOGISTICCOMPANY, 
        source_data.STANDARDCOSTS1 AS STANDARDCOSTS1, 
        source_data.STANDARDCOSTS2 AS STANDARDCOSTS2, 
        source_data.STANDARDCOSTS3 AS STANDARDCOSTS3, 
        source_data.TAXAMOUNTINHOMECURRENCY1 AS TAXAMOUNTINHOMECURRENCY1, 
        source_data.TAXAMOUNTINHOMECURRENCY2 AS TAXAMOUNTINHOMECURRENCY2, 
        source_data.TAXAMOUNTINHOMECURRENCY3 AS TAXAMOUNTINHOMECURRENCY3, 
        source_data.TAXAMOUNTININVOICECURRENCY AS TAXAMOUNTININVOICECURRENCY, 
        source_data.TAXCOUNTRY AS TAXCOUNTRY, 
        source_data.TAXID AS TAXID, 
        source_data.TYPEOFINVOICEDESCRIPTION AS TYPEOFINVOICEDESCRIPTION, 
        source_data.TYPEOFINVOICEID AS TYPEOFINVOICEID, 
        source_data.WAREHOUSE AS WAREHOUSE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY1,
        cast(AMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY2,
        cast(AMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY3,
        cast(AMOUNTININVOICECURRENCY as NUMBER(15,2)) as AMOUNTININVOICECURRENCY,
        cast(CHARGETYPEDESCRIPTION as VARCHAR(16777216)) as CHARGETYPEDESCRIPTION,
        cast(CHARGETYPEID as NUMBER(38,0)) as CHARGETYPEID,
        cast(COMPOSEONEINVOICEDESCRIPTION as VARCHAR(16777216)) as COMPOSEONEINVOICEDESCRIPTION,
        cast(COMPOSEONEINVOICEID as NUMBER(38,0)) as COMPOSEONEINVOICEID,
        cast(CONVFACTORPRICEUNIT as NUMBER(15,2)) as CONVFACTORPRICEUNIT,
        cast(CONVFACTORQUANTITYUNIT as NUMBER(15,2)) as CONVFACTORQUANTITYUNIT,
        cast(CUSTOMERORDERNUMBER as VARCHAR(30)) as CUSTOMERORDERNUMBER,
        cast(CUSTOMERORDERPOSITION as VARCHAR(16)) as CUSTOMERORDERPOSITION,
        cast(CUSTOMERORDERSEQUENCE as VARCHAR(11)) as CUSTOMERORDERSEQUENCE,
        cast(CUT_OFFDATE as TIMESTAMP_NTZ(9)) as CUT_OFFDATE,
        cast(DELIVEREDQUANTITY as NUMBER(15,2)) as DELIVEREDQUANTITY,
        cast(DELIVERYDATE as TIMESTAMP_NTZ(9)) as DELIVERYDATE,
        cast(DEPARTMENT as VARCHAR(6)) as DEPARTMENT,
        cast(DESCRIPTION as VARCHAR(50)) as DESCRIPTION,
        cast(DETAILTEXT as NUMBER(38,10)) as DETAILTEXT,
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
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(FINANCIALCOMPANY as NUMBER(38,0)) as FINANCIALCOMPANY,
        cast(GENERALCOSTS1 as NUMBER(15,2)) as GENERALCOSTS1,
        cast(GENERALCOSTS2 as NUMBER(15,2)) as GENERALCOSTS2,
        cast(GENERALCOSTS3 as NUMBER(15,2)) as GENERALCOSTS3,
        cast(INVOICESTATUSDESCRIPTION as VARCHAR(16777216)) as INVOICESTATUSDESCRIPTION,
        cast(INVOICESTATUSID as NUMBER(38,0)) as INVOICESTATUSID,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ITEMTEXT as NUMBER(38,10)) as ITEMTEXT,
        cast(LINEDISCOUNTAMOUNT1 as NUMBER(15,2)) as LINEDISCOUNTAMOUNT1,
        cast(LINEDISCOUNTAMOUNT2 as NUMBER(15,2)) as LINEDISCOUNTAMOUNT2,
        cast(LINEDISCOUNTAMOUNT3 as NUMBER(15,2)) as LINEDISCOUNTAMOUNT3,
        cast(LINEDISCOUNTAMOUNT4 as NUMBER(15,2)) as LINEDISCOUNTAMOUNT4,
        cast(LINEDISCOUNTAMOUNT5 as NUMBER(15,2)) as LINEDISCOUNTAMOUNT5,
        cast(LINEDISCOUNTAMOUNT_LDAI as NUMBER(15,2)) as LINEDISCOUNTAMOUNT_LDAI,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(LOTTEXT as NUMBER(38,10)) as LOTTEXT,
        cast(ORDER_DISCOUNTAMOUNT as NUMBER(15,2)) as ORDER_DISCOUNTAMOUNT,
        cast(ORDER_EDQUANTITY as NUMBER(15,2)) as ORDER_EDQUANTITY,
        cast(ORDER_TYPEDESCRIPTION as VARCHAR(16777216)) as ORDER_TYPEDESCRIPTION,
        cast(ORDER_TYPEID as NUMBER(38,0)) as ORDER_TYPEID,
        cast(PACKINGSLIPNO as VARCHAR(9)) as PACKINGSLIPNO,
        cast(PRICE as NUMBER(15,2)) as PRICE,
        cast(PRICEUNIT as VARCHAR(3)) as PRICEUNIT,
        cast(PRODUCTVARIANT as NUMBER(38,0)) as PRODUCTVARIANT,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(PURCHASEDOCUMENT as NUMBER(38,0)) as PURCHASEDOCUMENT,
        cast(PURCHASEINVOICETRANSACTIONTYPE as VARCHAR(3)) as PURCHASEINVOICETRANSACTIONTYPE,
        cast(QUANTITYUNIT as VARCHAR(3)) as QUANTITYUNIT,
        cast(RATE1 as NUMBER(15,2)) as RATE1,
        cast(RATE2 as NUMBER(15,2)) as RATE2,
        cast(RATE3 as NUMBER(15,2)) as RATE3,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(REVISION as VARCHAR(6)) as REVISION,
        cast(SALESINVOICECOMPANY as NUMBER(38,0)) as SALESINVOICECOMPANY,
        cast(SALESINVOICEDOCUMENTNUMBER as NUMBER(38,0)) as SALESINVOICEDOCUMENTNUMBER,
        cast(SALESINVOICETRANSACTIONTYPE as VARCHAR(3)) as SALESINVOICETRANSACTIONTYPE,
        cast(SALESWAREHOUSEORDER as VARCHAR(9)) as SALESWAREHOUSEORDER,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SETNUMBER as NUMBER(38,0)) as SETNUMBER,
        cast(SHIPFROMADDRESS as VARCHAR(9)) as SHIPFROMADDRESS,
        cast(SHIPTOADDRESS as VARCHAR(9)) as SHIPTOADDRESS,
        cast(SHIPTOBUSINESSPARTNER as VARCHAR(9)) as SHIPTOBUSINESSPARTNER,
        cast(SOURCELOGISTICCOMPANY as NUMBER(38,0)) as SOURCELOGISTICCOMPANY,
        cast(STANDARDCOSTS1 as NUMBER(15,2)) as STANDARDCOSTS1,
        cast(STANDARDCOSTS2 as NUMBER(15,2)) as STANDARDCOSTS2,
        cast(STANDARDCOSTS3 as NUMBER(15,2)) as STANDARDCOSTS3,
        cast(TAXAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY1,
        cast(TAXAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY2,
        cast(TAXAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY3,
        cast(TAXAMOUNTININVOICECURRENCY as NUMBER(15,2)) as TAXAMOUNTININVOICECURRENCY,
        cast(TAXCOUNTRY as VARCHAR(3)) as TAXCOUNTRY,
        cast(TAXID as VARCHAR(9)) as TAXID,
        cast(TYPEOFINVOICEDESCRIPTION as VARCHAR(16777216)) as TYPEOFINVOICEDESCRIPTION,
        cast(TYPEOFINVOICEID as NUMBER(38,0)) as TYPEOFINVOICEID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data