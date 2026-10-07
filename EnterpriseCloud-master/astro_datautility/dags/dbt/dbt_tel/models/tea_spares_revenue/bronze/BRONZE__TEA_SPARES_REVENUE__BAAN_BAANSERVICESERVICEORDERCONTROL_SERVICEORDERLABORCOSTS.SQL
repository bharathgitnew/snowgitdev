/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERLABORCOSTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERLABORCOSTS.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEORDERLABORCOSTS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDERLABORCOSTS',
    unique_key = ['LINENUMBER',
    'SERVICEORDER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITY 
            ,CAST("T$ACWR$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTRATE1 
            ,CAST("T$ACWR$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTRATE2 
            ,CAST("T$ACWR$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTRATE3 
            ,CAST(T$ACQT AS NUMERIC(15,2))                                                                                                       AS ACTUALCUMULATIVETIMEQUANTITY 
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
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                                                                                       AS CUSTOMERPOLINE 
            ,CAST(T$DISC AS NUMERIC(15,2))                                                                                                       AS DISCOUNT 
            ,CAST(T$ASDI AS NUMERIC(15,2))                                                                                                       AS DISCOUNTAMOUNT 
            ,CAST(T$OCCF AS NUMERIC(15,2))                                                                                                       AS EFFICIENCYRATE 
            ,CAST("T$ECWR$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDLABORRATE1 
            ,CAST("T$ECWR$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDLABORRATE2 
            ,CAST("T$ECWR$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDLABORRATE3 
            ,CAST(T$EQTM AS NUMERIC(15,2))                                                                                                       AS ESTIMATEDTIMEQUANTITY 
            ,CAST(T$ICMP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHLT)),'')                                                                                         AS HOURLYLABORTYPE 
            ,CAST(T$INAM AS NUMERIC(15,2))                                                                                                       AS INVOICEAMOUNT 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD END AS DATE)                                                             AS INVOICEDATE 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLRT)),'')                                                                                         AS LABORRATE 
            ,CAST(CASE WHEN T$LTTM<= '1/1/1970' THEN NULL ELSE T$LTTM  END AS DATETIME) AS LASTTRANSACTIONDATEACTUALCOSTLINE 
            ,CAST(T$LINO AS INT)                                                                                                                 AS LINENUMBER 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT END AS DATE)                                                             AS POSTINGDATE 
            ,T$QTYN.CONSTANTDESCRIPTION                                                                                                          AS QUOTATIONCOVERAGEDESCRIPTION 
            ,CAST(T$QTYN AS INT)                                                                                                                 AS QUOTATIONCOVERAGEID 
            ,CAST(T$ASFC AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTFIELDCHANGEORDERS 
            ,CAST(T$ASOC AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTOTHERCOSTS 
            ,CAST(T$ASCO AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICECONTRACT 
            ,CAST(T$ASIN AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICEORDERINVOICING 
            ,CAST(T$ASQU AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICEORDERQUOTATIONS 
            ,CAST(T$ASWA AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTWARRANTY 
            ,CAST(T$ASWR AS NUMERIC(15,2))                                                                                                       AS SALESRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTSK)),'')                                                                                         AS TASK 
            ,CAST(T$TXAM AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,CAST(T$ASTO AS NUMERIC(15,2))                                                                                                       AS TOTALSALESAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,T$WTYN.CONSTANTDESCRIPTION                                                                                                          AS WARRANTYCOVERAGEDESCRIPTION 
            ,CAST(T$WTYN AS INT)                                                                                                                 AS WARRANTYCOVERAGEID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC230200") }} AS SOURCETABLE  
            /*CONTRACTCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYN 
             ON   T$CTYN.TABLENAME  = 'TSSOC230' 
              AND T$CTYN.COLUMNNAME = 'T$CTYN' 
              AND T$CTYN.CONSTANT   = SOURCETABLE.T$CTYN 
            /*COSTLINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLST 
             ON   T$CLST.TABLENAME  = 'TSSOC230' 
              AND T$CLST.COLUMNNAME = 'T$CLST' 
              AND T$CLST.CONSTANT   = SOURCETABLE.T$CLST 
            /*QUOTATIONCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QTYN 
             ON   T$QTYN.TABLENAME  = 'TSSOC230' 
              AND T$QTYN.COLUMNNAME = 'T$QTYN' 
              AND T$QTYN.CONSTANT   = SOURCETABLE.T$QTYN 
            /*WARRANTYCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WTYN 
             ON   T$WTYN.TABLENAME  = 'TSSOC230' 
              AND T$WTYN.COLUMNNAME = 'T$WTYN' 
              AND T$WTYN.CONSTANT   = SOURCETABLE.T$WTYN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITY 
            ,CAST("T$ACWR$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTRATE1 
            ,CAST("T$ACWR$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTRATE2 
            ,CAST("T$ACWR$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTRATE3 
            ,CAST(T$ACQT AS NUMERIC(15,2))                                                                                                       AS ACTUALCUMULATIVETIMEQUANTITY 
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
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                                                                                       AS CUSTOMERPOLINE 
            ,CAST(T$DISC AS NUMERIC(15,2))                                                                                                       AS DISCOUNT 
            ,CAST(T$ASDI AS NUMERIC(15,2))                                                                                                       AS DISCOUNTAMOUNT 
            ,CAST(T$OCCF AS NUMERIC(15,2))                                                                                                       AS EFFICIENCYRATE 
            ,CAST("T$ECWR$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDLABORRATE1 
            ,CAST("T$ECWR$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDLABORRATE2 
            ,CAST("T$ECWR$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDLABORRATE3 
            ,CAST(T$EQTM AS NUMERIC(15,2))                                                                                                       AS ESTIMATEDTIMEQUANTITY 
            ,CAST(T$ICMP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHLT)),'')                                                                                         AS HOURLYLABORTYPE 
            ,CAST(T$INAM AS NUMERIC(15,2))                                                                                                       AS INVOICEAMOUNT 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD END AS DATE)                                                             AS INVOICEDATE 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLRT)),'')                                                                                         AS LABORRATE 
            ,CAST(CASE WHEN T$LTTM<= '1/1/1970' THEN NULL ELSE T$LTTM  END AS DATETIME) AS LASTTRANSACTIONDATEACTUALCOSTLINE 
            ,CAST(T$LINO AS INT)                                                                                                                 AS LINENUMBER 
            ,CAST(CASE WHEN T$PSDT<= '1/1/1970' THEN NULL ELSE T$PSDT END AS DATE)                                                             AS POSTINGDATE 
            ,T$QTYN.CONSTANTDESCRIPTION                                                                                                          AS QUOTATIONCOVERAGEDESCRIPTION 
            ,CAST(T$QTYN AS INT)                                                                                                                 AS QUOTATIONCOVERAGEID 
            ,CAST(T$ASFC AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTFIELDCHANGEORDERS 
            ,CAST(T$ASOC AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTOTHERCOSTS 
            ,CAST(T$ASCO AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICECONTRACT 
            ,CAST(T$ASIN AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICEORDERINVOICING 
            ,CAST(T$ASQU AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTSERVICEORDERQUOTATIONS 
            ,CAST(T$ASWA AS NUMERIC(15,2))                                                                                                       AS SALESAMOUNTWARRANTY 
            ,CAST(T$ASWR AS NUMERIC(15,2))                                                                                                       AS SALESRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTSK)),'')                                                                                         AS TASK 
            ,CAST(T$TXAM AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,CAST(T$ASTO AS NUMERIC(15,2))                                                                                                       AS TOTALSALESAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS TRANSACTIONTYPE 
            ,T$WTYN.CONSTANTDESCRIPTION                                                                                                          AS WARRANTYCOVERAGEDESCRIPTION 
            ,CAST(T$WTYN AS INT)                                                                                                                 AS WARRANTYCOVERAGEID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC230201") }} AS SOURCETABLE  
            /*CONTRACTCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CTYN 
             ON   T$CTYN.TABLENAME  = 'TSSOC230' 
              AND T$CTYN.COLUMNNAME = 'T$CTYN' 
              AND T$CTYN.CONSTANT   = SOURCETABLE.T$CTYN 
            /*COSTLINESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CLST 
             ON   T$CLST.TABLENAME  = 'TSSOC230' 
              AND T$CLST.COLUMNNAME = 'T$CLST' 
              AND T$CLST.CONSTANT   = SOURCETABLE.T$CLST 
            /*QUOTATIONCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QTYN 
             ON   T$QTYN.TABLENAME  = 'TSSOC230' 
              AND T$QTYN.COLUMNNAME = 'T$QTYN' 
              AND T$QTYN.CONSTANT   = SOURCETABLE.T$QTYN 
            /*WARRANTYCOVERAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WTYN 
             ON   T$WTYN.TABLENAME  = 'TSSOC230' 
              AND T$WTYN.COLUMNNAME = 'T$WTYN' 
              AND T$WTYN.CONSTANT   = SOURCETABLE.T$WTYN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.ACTUALCOSTRATE1 AS ACTUALCOSTRATE1, 
        source_data.ACTUALCOSTRATE2 AS ACTUALCOSTRATE2, 
        source_data.ACTUALCOSTRATE3 AS ACTUALCOSTRATE3, 
        source_data.ACTUALCUMULATIVETIMEQUANTITY AS ACTUALCUMULATIVETIMEQUANTITY, 
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
        source_data.CUSTOMERPOLINE AS CUSTOMERPOLINE, 
        source_data.DISCOUNT AS DISCOUNT, 
        source_data.DISCOUNTAMOUNT AS DISCOUNTAMOUNT, 
        source_data.EFFICIENCYRATE AS EFFICIENCYRATE, 
        source_data.ESTIMATEDLABORRATE1 AS ESTIMATEDLABORRATE1, 
        source_data.ESTIMATEDLABORRATE2 AS ESTIMATEDLABORRATE2, 
        source_data.ESTIMATEDLABORRATE3 AS ESTIMATEDLABORRATE3, 
        source_data.ESTIMATEDTIMEQUANTITY AS ESTIMATEDTIMEQUANTITY, 
        source_data.FINANCIALCOMPANY AS FINANCIALCOMPANY, 
        source_data.HOURLYLABORTYPE AS HOURLYLABORTYPE, 
        source_data.INVOICEAMOUNT AS INVOICEAMOUNT, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.LABORRATE AS LABORRATE, 
        source_data.LASTTRANSACTIONDATEACTUALCOSTLINE AS LASTTRANSACTIONDATEACTUALCOSTLINE, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.POSTINGDATE AS POSTINGDATE, 
        source_data.QUOTATIONCOVERAGEDESCRIPTION AS QUOTATIONCOVERAGEDESCRIPTION, 
        source_data.QUOTATIONCOVERAGEID AS QUOTATIONCOVERAGEID, 
        source_data.SALESAMOUNTFIELDCHANGEORDERS AS SALESAMOUNTFIELDCHANGEORDERS, 
        source_data.SALESAMOUNTOTHERCOSTS AS SALESAMOUNTOTHERCOSTS, 
        source_data.SALESAMOUNTSERVICECONTRACT AS SALESAMOUNTSERVICECONTRACT, 
        source_data.SALESAMOUNTSERVICEORDERINVOICING AS SALESAMOUNTSERVICEORDERINVOICING, 
        source_data.SALESAMOUNTSERVICEORDERQUOTATIONS AS SALESAMOUNTSERVICEORDERQUOTATIONS, 
        source_data.SALESAMOUNTWARRANTY AS SALESAMOUNTWARRANTY, 
        source_data.SALESRATE AS SALESRATE, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.TASK AS TASK, 
        source_data.TAXAMOUNT AS TAXAMOUNT, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TEXT AS TEXT, 
        source_data.TOTALSALESAMOUNT AS TOTALSALESAMOUNT, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE, 
        source_data.WARRANTYCOVERAGEDESCRIPTION AS WARRANTYCOVERAGEDESCRIPTION, 
        source_data.WARRANTYCOVERAGEID AS WARRANTYCOVERAGEID
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTIVITY as NUMBER(38,0)) as ACTIVITY,
        cast(ACTUALCOSTRATE1 as NUMBER(15,2)) as ACTUALCOSTRATE1,
        cast(ACTUALCOSTRATE2 as NUMBER(15,2)) as ACTUALCOSTRATE2,
        cast(ACTUALCOSTRATE3 as NUMBER(15,2)) as ACTUALCOSTRATE3,
        cast(ACTUALCUMULATIVETIMEQUANTITY as NUMBER(15,2)) as ACTUALCUMULATIVETIMEQUANTITY,
        CONTRACTCOVERAGEDESCRIPTION,
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
        COSTCOMPONENT,
        COSTLINESTATUSDESCRIPTION,
        cast(COSTLINESTATUSID as NUMBER(38,0)) as COSTLINESTATUSID,
        CUSTOMERPOLINE,
        cast(DISCOUNT as NUMBER(15,2)) as DISCOUNT,
        cast(DISCOUNTAMOUNT as NUMBER(15,2)) as DISCOUNTAMOUNT,
        cast(EFFICIENCYRATE as NUMBER(15,2)) as EFFICIENCYRATE,
        cast(ESTIMATEDLABORRATE1 as NUMBER(15,2)) as ESTIMATEDLABORRATE1,
        cast(ESTIMATEDLABORRATE2 as NUMBER(15,2)) as ESTIMATEDLABORRATE2,
        cast(ESTIMATEDLABORRATE3 as NUMBER(15,2)) as ESTIMATEDLABORRATE3,
        cast(ESTIMATEDTIMEQUANTITY as NUMBER(15,2)) as ESTIMATEDTIMEQUANTITY,
        cast(FINANCIALCOMPANY as NUMBER(38,0)) as FINANCIALCOMPANY,
        HOURLYLABORTYPE,
        cast(INVOICEAMOUNT as NUMBER(15,2)) as INVOICEAMOUNT,
        cast(INVOICEDATE as DATE) as INVOICEDATE,
        cast(INVOICENUMBER as NUMBER(38,0)) as INVOICENUMBER,
        LABORRATE,
        cast(LASTTRANSACTIONDATEACTUALCOSTLINE as TIMESTAMP_NTZ(9)) as LASTTRANSACTIONDATEACTUALCOSTLINE,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(POSTINGDATE as DATE) as POSTINGDATE,
        QUOTATIONCOVERAGEDESCRIPTION,
        cast(QUOTATIONCOVERAGEID as NUMBER(38,0)) as QUOTATIONCOVERAGEID,
        cast(SALESAMOUNTFIELDCHANGEORDERS as NUMBER(15,2)) as SALESAMOUNTFIELDCHANGEORDERS,
        cast(SALESAMOUNTOTHERCOSTS as NUMBER(15,2)) as SALESAMOUNTOTHERCOSTS,
        cast(SALESAMOUNTSERVICECONTRACT as NUMBER(15,2)) as SALESAMOUNTSERVICECONTRACT,
        cast(SALESAMOUNTSERVICEORDERINVOICING as NUMBER(15,2)) as SALESAMOUNTSERVICEORDERINVOICING,
        cast(SALESAMOUNTSERVICEORDERQUOTATIONS as NUMBER(15,2)) as SALESAMOUNTSERVICEORDERQUOTATIONS,
        cast(SALESAMOUNTWARRANTY as NUMBER(15,2)) as SALESAMOUNTWARRANTY,
        cast(SALESRATE as NUMBER(15,2)) as SALESRATE,
        SERVICEORDER,
        TASK,
        cast(TAXAMOUNT as NUMBER(15,2)) as TAXAMOUNT,
        TAXCODE,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(TOTALSALESAMOUNT as NUMBER(15,2)) as TOTALSALESAMOUNT,
        TRANSACTIONTYPE,
        WARRANTYCOVERAGEDESCRIPTION,
        cast(WARRANTYCOVERAGEID as NUMBER(38,0)) as WARRANTYCOVERAGEID
    from transform_data
    )
select * from type_data