/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEORDEROTHERCOSTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEORDEROTHERCOSTS.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEORDEROTHERCOSTS 
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
    alias='BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDEROTHERCOSTS',
    unique_key = ['LINENUMBER',
    'SERVICEORDER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITY 
            ,CAST("T$ACPR$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE1 
            ,CAST("T$ACPR$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE2 
            ,CAST("T$ACPR$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE3 
            ,CAST(T$AFRQ AS BIGINT)                                                                                                              AS ACTUALFREQUENCY 
            ,CAST(T$AQAN AS NUMERIC(15,2))                                                                                                       AS ACTUALQUANTITY 
            ,CAST("T$CASE$U" AS BIGINT)                                                                                                            AS CASENUMBER 
            ,T$CTYN.CONSTANTDESCRIPTION                                                                                                          AS CONTRACTCOVERAGEDESCRIPTION 
            ,CAST(T$CTYN AS INT)                                                                                                                 AS CONTRACTCOVERAGEID 
            ,CAST("T$ACFC$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTFIELDCHANGEORDERS1 
            ,CAST("T$ACFC$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTFIELDCHANGEORDERS2 
            ,CAST("T$ACFC$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTFIELDCHANGEORDERS3 
            ,CAST("T$ACOC$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOTHERCOSTS1 
            ,CAST("T$ACOC$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOTHERCOSTS2 
            ,CAST("T$ACOC$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOTHERCOSTS3 
            ,CAST("T$ACCO$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICECONTRACT1 
            ,CAST("T$ACCO$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICECONTRACT2 
            ,CAST("T$ACCO$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICECONTRACT3 
            ,CAST("T$ACIN$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERINVOICING1 
            ,CAST("T$ACIN$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERINVOICING2 
            ,CAST("T$ACIN$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERINVOICING3 
            ,CAST("T$ACQU$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERQUOTATION1 
            ,CAST("T$ACQU$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERQUOTATION2 
            ,CAST("T$ACQU$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERQUOTATION3 
            ,CAST("T$ACWA$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTWARRANTY1 
            ,CAST("T$ACWA$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTWARRANTY2 
            ,CAST("T$ACWA$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTWARRANTY3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCMP)),'')                                                                                         AS COSTCOMPONENT 
            ,T$CLST.CONSTANTDESCRIPTION                                                                                                          AS COSTLINESTATUSDESCRIPTION 
            ,CAST(T$CLST AS INT)                                                                                                                 AS COSTLINESTATUSID 
            ,T$COTP.CONSTANTDESCRIPTION                                                                                                          AS COSTTYPEDESCRIPTION 
            ,CAST(T$COTP AS INT)                                                                                                                 AS COSTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRMC$U")),'')                                                                                       AS CRM_CASE_hash_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                                                                                       AS CUSTOMERPOLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,CAST(T$DISC AS NUMERIC(15,2))                                                                                                       AS DISCOUNT 
            ,CAST(T$IDCN AS BIGINT)                                                                                                              AS DOCUMENT 
            ,CAST("T$ECPR$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE1 
            ,CAST("T$ECPR$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE2 
            ,CAST("T$ECPR$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE3 
            ,CAST(T$EFRQ AS BIGINT)                                                                                                              AS ESTIMATEDFREQUENCY 
            ,CAST(T$EQAN AS NUMERIC(15,2))                                                                                                       AS ESTIMATEDQUANTITY 
            ,CAST(T$ICMP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,CAST(T$INAM AS NUMERIC(15,2))                                                                                                       AS INVOICEAMOUNT 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD END AS DATE)                                                             AS INVOICEDATE 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS INVOICENUMBER 
            ,CAST(CASE WHEN T$LTDT<= '1/1/1970' THEN NULL ELSE T$LTDT  END AS DATETIME) AS LASTTRANSACTIONDATEACTUALCOSTLINE 
            ,CAST(T$ILIN AS BIGINT)                                                                                                              AS LINE 
            ,CAST(T$LINO AS INT)                                                                                                                 AS LINENUMBER 
            ,"T$OACK$U".CONSTANTDESCRIPTION                                                                                                        AS ORDER_ACKNOWLEDGEMENTDESCRIPTION 
            ,CAST("T$OACK$U" AS INT)                                                                                                               AS ORDER_ACKNOWLEDGEMENTID 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT END AS DATE)                                                             AS POSTINGDATE 
            ,T$QTYN.CONSTANTDESCRIPTION                                                                                                          AS QUOTATIONCOVERAGEDESCRIPTION 
            ,CAST(T$QTYN AS INT)                                                                                                                 AS QUOTATIONCOVERAGEID 
            ,CAST(T$ASFC AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTFIELDCHANGEORDERS 
            ,CAST(T$ASOC AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTOTHERCOSTS 
            ,CAST(T$ASCO AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICECONTRACT 
            ,CAST(T$ASIN AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICEORDERINVOICING 
            ,CAST(T$ASQU AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICEORDERQUOTATIONS 
            ,CAST(T$ASWA AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTWARRANTY 
            ,CAST(T$PRIS AS NUMERIC(15,2))                                                                                                       AS SALESPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,CAST(T$TXAM AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,CAST(T$TNUM AS BIGINT)                                                                                                              AS TOOLNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TLTP)),'')                                                                                         AS TOOLTYPE 
            ,CAST(T$ASTO AS NUMERIC(15,2))                                                                                                       AS TOTALSALESAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,T$TSPT.CONSTANTDESCRIPTION                                                                                                          AS TRAVELINGSPECIFICATIONTYPEDESCRIPTION 
            ,CAST(T$TSPT AS INT)                                                                                                                 AS TRAVELINGSPECIFICATIONTYPEID 
            ,CAST(T$ASDI AS NUMERIC(15,2))                                                                                                       AS TSSOC220ASDI 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNIT 
            ,T$WTYN.CONSTANTDESCRIPTION                                                                                                          AS WARRANTYCOVERAGEDESCRIPTION 
            ,CAST(T$WTYN AS INT)                                                                                                                 AS WARRANTYCOVERAGEID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC240200") }} AS SOURCETABLE  
            /*CONTRACTCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYN 
             ON   T$CTYN.TABLENAME  = 'TSSOC240' 
              AND T$CTYN.COLUMNNAME = 'T$CTYN' 
              AND T$CTYN.CONSTANT   = SOURCETABLE.T$CTYN 
            /*COSTLINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLST 
             ON   T$CLST.TABLENAME  = 'TSSOC240' 
              AND T$CLST.COLUMNNAME = 'T$CLST' 
              AND T$CLST.CONSTANT   = SOURCETABLE.T$CLST 
            /*COSTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COTP 
             ON   T$COTP.TABLENAME  = 'TSSOC240' 
              AND T$COTP.COLUMNNAME = 'T$COTP' 
              AND T$COTP.CONSTANT   = SOURCETABLE.T$COTP 
            /*ORDERACKNOWLEDGEMENTU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$OACK$U" 
             ON   "T$OACK$U".TABLENAME  = 'TSSOC240' 
              AND "T$OACK$U".COLUMNNAME = 'T$OACK.U' 
              AND "T$OACK$U".CONSTANT   = SOURCETABLE."T$OACK$U" 
            /*QUOTATIONCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QTYN 
             ON   T$QTYN.TABLENAME  = 'TSSOC240' 
              AND T$QTYN.COLUMNNAME = 'T$QTYN' 
              AND T$QTYN.CONSTANT   = SOURCETABLE.T$QTYN 
            /*TRAVELINGSPECIFICATIONTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TSPT 
             ON   T$TSPT.TABLENAME  = 'TSSOC240' 
              AND T$TSPT.COLUMNNAME = 'T$TSPT' 
              AND T$TSPT.CONSTANT   = SOURCETABLE.T$TSPT 
            /*WARRANTYCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WTYN 
             ON   T$WTYN.TABLENAME  = 'TSSOC240' 
              AND T$WTYN.COLUMNNAME = 'T$WTYN' 
              AND T$WTYN.CONSTANT   = SOURCETABLE.T$WTYN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITY 
            ,CAST("T$ACPR$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE1 
            ,CAST("T$ACPR$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE2 
            ,CAST("T$ACPR$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE3 
            ,CAST(T$AFRQ AS BIGINT)                                                                                                              AS ACTUALFREQUENCY 
            ,CAST(T$AQAN AS NUMERIC(15,2))                                                                                                       AS ACTUALQUANTITY 
            ,CAST("T$CASE$U" AS BIGINT)                                                                                                            AS CASENUMBER 
            ,T$CTYN.CONSTANTDESCRIPTION                                                                                                          AS CONTRACTCOVERAGEDESCRIPTION 
            ,CAST(T$CTYN AS INT)                                                                                                                 AS CONTRACTCOVERAGEID 
            ,CAST("T$ACFC$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTFIELDCHANGEORDERS1 
            ,CAST("T$ACFC$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTFIELDCHANGEORDERS2 
            ,CAST("T$ACFC$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTFIELDCHANGEORDERS3 
            ,CAST("T$ACOC$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOTHERCOSTS1 
            ,CAST("T$ACOC$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOTHERCOSTS2 
            ,CAST("T$ACOC$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTOTHERCOSTS3 
            ,CAST("T$ACCO$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICECONTRACT1 
            ,CAST("T$ACCO$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICECONTRACT2 
            ,CAST("T$ACCO$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICECONTRACT3 
            ,CAST("T$ACIN$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERINVOICING1 
            ,CAST("T$ACIN$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERINVOICING2 
            ,CAST("T$ACIN$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERINVOICING3 
            ,CAST("T$ACQU$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERQUOTATION1 
            ,CAST("T$ACQU$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERQUOTATION2 
            ,CAST("T$ACQU$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTSERVICEORDERQUOTATION3 
            ,CAST("T$ACWA$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTWARRANTY1 
            ,CAST("T$ACWA$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTWARRANTY2 
            ,CAST("T$ACWA$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMOUNTWARRANTY3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCMP)),'')                                                                                         AS COSTCOMPONENT 
            ,T$CLST.CONSTANTDESCRIPTION                                                                                                          AS COSTLINESTATUSDESCRIPTION 
            ,CAST(T$CLST AS INT)                                                                                                                 AS COSTLINESTATUSID 
            ,T$COTP.CONSTANTDESCRIPTION                                                                                                          AS COSTTYPEDESCRIPTION 
            ,CAST(T$COTP AS INT)                                                                                                                 AS COSTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CRMC$U")),'')                                                                                       AS CRM_CASE_hash_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                                                                                       AS CUSTOMERPOLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,CAST(T$DISC AS NUMERIC(15,2))                                                                                                       AS DISCOUNT 
            ,CAST(T$IDCN AS BIGINT)                                                                                                              AS DOCUMENT 
            ,CAST("T$ECPR$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE1 
            ,CAST("T$ECPR$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE2 
            ,CAST("T$ECPR$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE3 
            ,CAST(T$EFRQ AS BIGINT)                                                                                                              AS ESTIMATEDFREQUENCY 
            ,CAST(T$EQAN AS NUMERIC(15,2))                                                                                                       AS ESTIMATEDQUANTITY 
            ,CAST(T$ICMP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,CAST(T$INAM AS NUMERIC(15,2))                                                                                                       AS INVOICEAMOUNT 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD END AS DATE)                                                             AS INVOICEDATE 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS INVOICENUMBER 
            ,CAST(CASE WHEN T$LTDT<= '1/1/1970' THEN NULL ELSE T$LTDT  END AS DATETIME) AS LASTTRANSACTIONDATEACTUALCOSTLINE 
            ,CAST(T$ILIN AS BIGINT)                                                                                                              AS LINE 
            ,CAST(T$LINO AS INT)                                                                                                                 AS LINENUMBER 
            ,"T$OACK$U".CONSTANTDESCRIPTION                                                                                                        AS ORDER_ACKNOWLEDGEMENTDESCRIPTION 
            ,CAST("T$OACK$U" AS INT)                                                                                                               AS ORDER_ACKNOWLEDGEMENTID 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT END AS DATE)                                                             AS POSTINGDATE 
            ,T$QTYN.CONSTANTDESCRIPTION                                                                                                          AS QUOTATIONCOVERAGEDESCRIPTION 
            ,CAST(T$QTYN AS INT)                                                                                                                 AS QUOTATIONCOVERAGEID 
            ,CAST(T$ASFC AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTFIELDCHANGEORDERS 
            ,CAST(T$ASOC AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTOTHERCOSTS 
            ,CAST(T$ASCO AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICECONTRACT 
            ,CAST(T$ASIN AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICEORDERINVOICING 
            ,CAST(T$ASQU AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICEORDERQUOTATIONS 
            ,CAST(T$ASWA AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTWARRANTY 
            ,CAST(T$PRIS AS NUMERIC(15,2))                                                                                                       AS SALESPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,CAST(T$TXAM AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,CAST(T$TNUM AS BIGINT)                                                                                                              AS TOOLNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TLTP)),'')                                                                                         AS TOOLTYPE 
            ,CAST(T$ASTO AS NUMERIC(15,2))                                                                                                       AS TOTALSALESAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,T$TSPT.CONSTANTDESCRIPTION                                                                                                          AS TRAVELINGSPECIFICATIONTYPEDESCRIPTION 
            ,CAST(T$TSPT AS INT)                                                                                                                 AS TRAVELINGSPECIFICATIONTYPEID 
            ,CAST(T$ASDI AS NUMERIC(15,2))                                                                                                       AS TSSOC220ASDI 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNIT 
            ,T$WTYN.CONSTANTDESCRIPTION                                                                                                          AS WARRANTYCOVERAGEDESCRIPTION 
            ,CAST(T$WTYN AS INT)                                                                                                                 AS WARRANTYCOVERAGEID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC240201") }} AS SOURCETABLE  
            /*CONTRACTCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYN 
             ON   T$CTYN.TABLENAME  = 'TSSOC240' 
              AND T$CTYN.COLUMNNAME = 'T$CTYN' 
              AND T$CTYN.CONSTANT   = SOURCETABLE.T$CTYN 
            /*COSTLINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLST 
             ON   T$CLST.TABLENAME  = 'TSSOC240' 
              AND T$CLST.COLUMNNAME = 'T$CLST' 
              AND T$CLST.CONSTANT   = SOURCETABLE.T$CLST 
            /*COSTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COTP 
             ON   T$COTP.TABLENAME  = 'TSSOC240' 
              AND T$COTP.COLUMNNAME = 'T$COTP' 
              AND T$COTP.CONSTANT   = SOURCETABLE.T$COTP 
            /*ORDERACKNOWLEDGEMENTU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$OACK$U" 
             ON   "T$OACK$U".TABLENAME  = 'TSSOC240' 
              AND "T$OACK$U".COLUMNNAME = 'T$OACK.U' 
              AND "T$OACK$U".CONSTANT   = SOURCETABLE."T$OACK$U" 
            /*QUOTATIONCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QTYN 
             ON   T$QTYN.TABLENAME  = 'TSSOC240' 
              AND T$QTYN.COLUMNNAME = 'T$QTYN' 
              AND T$QTYN.CONSTANT   = SOURCETABLE.T$QTYN 
            /*TRAVELINGSPECIFICATIONTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TSPT 
             ON   T$TSPT.TABLENAME  = 'TSSOC240' 
              AND T$TSPT.COLUMNNAME = 'T$TSPT' 
              AND T$TSPT.CONSTANT   = SOURCETABLE.T$TSPT 
            /*WARRANTYCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WTYN 
             ON   T$WTYN.TABLENAME  = 'TSSOC240' 
              AND T$WTYN.COLUMNNAME = 'T$WTYN' 
              AND T$WTYN.CONSTANT   = SOURCETABLE.T$WTYN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
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
        source_data.ACTUALFREQUENCY AS ACTUALFREQUENCY, 
        source_data.ACTUALQUANTITY AS ACTUALQUANTITY, 
        source_data.CASENUMBER AS CASENUMBER, 
        source_data.CONTRACTCOVERAGEDESCRIPTION AS CONTRACTCOVERAGEDESCRIPTION, 
        source_data.CONTRACTCOVERAGEID AS CONTRACTCOVERAGEID, 
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
        source_data.COSTTYPEDESCRIPTION AS COSTTYPEDESCRIPTION, 
        source_data.COSTTYPEID AS COSTTYPEID, 
        source_data.CRM_CASE_HASH_ AS CRM_CASE_HASH_, 
        source_data.CUSTOMERPOLINE AS CUSTOMERPOLINE, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.DISCOUNT AS DISCOUNT, 
        source_data.DOCUMENT AS DOCUMENT, 
        source_data.ESTIMATEDCOSTPRICE1 AS ESTIMATEDCOSTPRICE1, 
        source_data.ESTIMATEDCOSTPRICE2 AS ESTIMATEDCOSTPRICE2, 
        source_data.ESTIMATEDCOSTPRICE3 AS ESTIMATEDCOSTPRICE3, 
        source_data.ESTIMATEDFREQUENCY AS ESTIMATEDFREQUENCY, 
        source_data.ESTIMATEDQUANTITY AS ESTIMATEDQUANTITY, 
        source_data.FINANCIALCOMPANY AS FINANCIALCOMPANY, 
        source_data.INVOICEAMOUNT AS INVOICEAMOUNT, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.LASTTRANSACTIONDATEACTUALCOSTLINE AS LASTTRANSACTIONDATEACTUALCOSTLINE, 
        source_data.LINE AS LINE, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.ORDER_ACKNOWLEDGEMENTDESCRIPTION AS ORDER_ACKNOWLEDGEMENTDESCRIPTION, 
        source_data.ORDER_ACKNOWLEDGEMENTID AS ORDER_ACKNOWLEDGEMENTID, 
        source_data.POSTINGDATE AS POSTINGDATE, 
        source_data.QUOTATIONCOVERAGEDESCRIPTION AS QUOTATIONCOVERAGEDESCRIPTION, 
        source_data.QUOTATIONCOVERAGEID AS QUOTATIONCOVERAGEID, 
        source_data.SALESAMOUNTFIELDCHANGEORDERS AS SALESAMOUNTFIELDCHANGEORDERS, 
        source_data.SALESAMOUNTOTHERCOSTS AS SALESAMOUNTOTHERCOSTS, 
        source_data.SALESAMOUNTSERVICECONTRACT AS SALESAMOUNTSERVICECONTRACT, 
        source_data.SALESAMOUNTSERVICEORDERINVOICING AS SALESAMOUNTSERVICEORDERINVOICING, 
        source_data.SALESAMOUNTSERVICEORDERQUOTATIONS AS SALESAMOUNTSERVICEORDERQUOTATIONS, 
        source_data.SALESAMOUNTWARRANTY AS SALESAMOUNTWARRANTY, 
        source_data.SALESPRICE AS SALESPRICE, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.TAXAMOUNT AS TAXAMOUNT, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TEXT AS TEXT, 
        source_data.TOOLNUMBER AS TOOLNUMBER, 
        source_data.TOOLTYPE AS TOOLTYPE, 
        source_data.TOTALSALESAMOUNT AS TOTALSALESAMOUNT, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE, 
        source_data.TRAVELINGSPECIFICATIONTYPEDESCRIPTION AS TRAVELINGSPECIFICATIONTYPEDESCRIPTION, 
        source_data.TRAVELINGSPECIFICATIONTYPEID AS TRAVELINGSPECIFICATIONTYPEID, 
        source_data.TSSOC220ASDI AS TSSOC220ASDI, 
        source_data.UNIT AS UNIT, 
        source_data.WARRANTYCOVERAGEDESCRIPTION AS WARRANTYCOVERAGEDESCRIPTION, 
        source_data.WARRANTYCOVERAGEID AS WARRANTYCOVERAGEID
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTIVITY as NUMBER(38,0)) as ACTIVITY,
        cast(ACTUALCOSTPRICE1 as NUMBER(15,2)) as ACTUALCOSTPRICE1,
        cast(ACTUALCOSTPRICE2 as NUMBER(15,2)) as ACTUALCOSTPRICE2,
        cast(ACTUALCOSTPRICE3 as NUMBER(15,2)) as ACTUALCOSTPRICE3,
        cast(ACTUALFREQUENCY as NUMBER(38,0)) as ACTUALFREQUENCY,
        cast(ACTUALQUANTITY as NUMBER(15,2)) as ACTUALQUANTITY,
        cast(CASENUMBER as NUMBER(38,0)) as CASENUMBER,
        cast(CONTRACTCOVERAGEDESCRIPTION as VARCHAR(16777216)) as CONTRACTCOVERAGEDESCRIPTION,
        cast(CONTRACTCOVERAGEID as NUMBER(38,0)) as CONTRACTCOVERAGEID,
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
        cast(COSTTYPEDESCRIPTION as VARCHAR(16777216)) as COSTTYPEDESCRIPTION,
        cast(COSTTYPEID as NUMBER(38,0)) as COSTTYPEID,
        cast(CRM_CASE_HASH_ as VARCHAR(18)) as CRM_CASE_HASH_,
        cast(CUSTOMERPOLINE as VARCHAR(10)) as CUSTOMERPOLINE,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(DISCOUNT as NUMBER(15,2)) as DISCOUNT,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(ESTIMATEDCOSTPRICE1 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE1,
        cast(ESTIMATEDCOSTPRICE2 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE2,
        cast(ESTIMATEDCOSTPRICE3 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE3,
        cast(ESTIMATEDFREQUENCY as NUMBER(38,0)) as ESTIMATEDFREQUENCY,
        cast(ESTIMATEDQUANTITY as NUMBER(15,2)) as ESTIMATEDQUANTITY,
        cast(FINANCIALCOMPANY as NUMBER(38,0)) as FINANCIALCOMPANY,
        cast(INVOICEAMOUNT as NUMBER(15,2)) as INVOICEAMOUNT,
        cast(INVOICEDATE as DATE) as INVOICEDATE,
        cast(INVOICENUMBER as NUMBER(38,0)) as INVOICENUMBER,
        cast(LASTTRANSACTIONDATEACTUALCOSTLINE as TIMESTAMP_NTZ(9)) as LASTTRANSACTIONDATEACTUALCOSTLINE,
        cast(LINE as NUMBER(38,0)) as LINE,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(ORDER_ACKNOWLEDGEMENTDESCRIPTION as VARCHAR(16777216)) as ORDER_ACKNOWLEDGEMENTDESCRIPTION,
        cast(ORDER_ACKNOWLEDGEMENTID as NUMBER(38,0)) as ORDER_ACKNOWLEDGEMENTID,
        cast(POSTINGDATE as DATE) as POSTINGDATE,
        cast(QUOTATIONCOVERAGEDESCRIPTION as VARCHAR(16777216)) as QUOTATIONCOVERAGEDESCRIPTION,
        cast(QUOTATIONCOVERAGEID as NUMBER(38,0)) as QUOTATIONCOVERAGEID,
        cast(SALESAMOUNTFIELDCHANGEORDERS as NUMBER(15,2)) as SALESAMOUNTFIELDCHANGEORDERS,
        cast(SALESAMOUNTOTHERCOSTS as NUMBER(15,2)) as SALESAMOUNTOTHERCOSTS,
        cast(SALESAMOUNTSERVICECONTRACT as NUMBER(15,2)) as SALESAMOUNTSERVICECONTRACT,
        cast(SALESAMOUNTSERVICEORDERINVOICING as NUMBER(15,2)) as SALESAMOUNTSERVICEORDERINVOICING,
        cast(SALESAMOUNTSERVICEORDERQUOTATIONS as NUMBER(15,2)) as SALESAMOUNTSERVICEORDERQUOTATIONS,
        cast(SALESAMOUNTWARRANTY as NUMBER(15,2)) as SALESAMOUNTWARRANTY,
        cast(SALESPRICE as NUMBER(15,2)) as SALESPRICE,
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(TAXAMOUNT as NUMBER(15,2)) as TAXAMOUNT,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(TOOLNUMBER as NUMBER(38,0)) as TOOLNUMBER,
        cast(TOOLTYPE as VARCHAR(47)) as TOOLTYPE,
        cast(TOTALSALESAMOUNT as NUMBER(15,2)) as TOTALSALESAMOUNT,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(TRAVELINGSPECIFICATIONTYPEDESCRIPTION as VARCHAR(16777216)) as TRAVELINGSPECIFICATIONTYPEDESCRIPTION,
        cast(TRAVELINGSPECIFICATIONTYPEID as NUMBER(38,0)) as TRAVELINGSPECIFICATIONTYPEID,
        cast(TSSOC220ASDI as NUMBER(15,2)) as TSSOC220ASDI,
        cast(UNIT as VARCHAR(3)) as UNIT,
        cast(WARRANTYCOVERAGEDESCRIPTION as VARCHAR(16777216)) as WARRANTYCOVERAGEDESCRIPTION,
        cast(WARRANTYCOVERAGEID as NUMBER(38,0)) as WARRANTYCOVERAGEID
    from transform_data
    )
select * from type_data