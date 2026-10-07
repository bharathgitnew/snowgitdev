/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCENTRALINVOICINGSALESINVOICING_SERVICE_ORDERINVOICELINES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCENTRALINVOICINGSALESINVOICING_SERVICE_ORDERINVOICELINES.SQL 
-materialized incremental
-alias BAANCENTRALINVOICINGSALESINVOICING_SERVICE_ORDERINVOICELINES 
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
    alias='BAANCENTRALINVOICINGSALESINVOICING_SERVICE_ORDERINVOICELINES',
    unique_key = ['ACTIVITYLINE',
    'LINENUMBER',
    'SERVICEORDER',
    'SOURCELOGISTICCOMPANY',
    'TYPEOFINVOICEID']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ACQT AS NUMERIC(15,2))                                                                                                       AS ACTCUMTIMEQTY 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITYLINE 
            ,SOURCETABLE.T$ACTX   /* TEXT */                                                                                                     AS ACTIVITYTEXT 
            ,CAST(T$ADVL AS NUMERIC(15,2))                                                                                                       AS ACTUALDEPENDENTVALUE 
            ,CAST(CASE WHEN T$AFTM<= '1/1/1970' THEN NULL ELSE T$AFTM  END AS DATETIME) AS ACTUALFINISHTIME 
            ,CAST(T$ASWR AS NUMERIC(15,2))                                                                                                       AS ACTUALSALESLABOURRATE 
            ,CAST(CASE WHEN T$ASTM<= '1/1/1970' THEN NULL ELSE T$ASTM  END AS DATETIME) AS ACTUALSTARTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AWRH)),'')                                                                                         AS ACTUALWAREHOUSE 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY3 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                       AS AMOUNTININVOICECURRENCY 
            ,T$CHTP.CONSTANTDESCRIPTION                                                                                                          AS CHARGETYPEDESCRIPTION 
            ,CAST(T$CHTP AS INT)                                                                                                                 AS CHARGETYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,CAST(T$CVPS AS NUMERIC(15,2))                                                                                                       AS CONVFACTORPRICEUNIT 
            ,CAST(T$CVQS AS NUMERIC(15,2))                                                                                                       AS CONVFACTORQUANTITYUNIT 
            ,CAST("T$ACIN$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMNTINVOICING1 
            ,CAST("T$ACIN$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMNTINVOICING2 
            ,CAST("T$ACIN$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMNTINVOICING3 
            ,CAST("T$ACCO$1" AS NUMERIC(15,2))                                                                                                     AS COSTAMNTSERVCONTRACTS1 
            ,CAST("T$ACCO$2" AS NUMERIC(15,2))                                                                                                     AS COSTAMNTSERVCONTRACTS2 
            ,CAST("T$ACCO$3" AS NUMERIC(15,2))                                                                                                     AS COSTAMNTSERVCONTRACTS3 
            ,CAST(CASE WHEN T$CODT<= '1/1/1970' THEN NULL ELSE T$CODT  END AS DATETIME) AS CUT_OFFDATE 
            ,CAST(T$DQUA AS NUMERIC(15,2))                                                                                                       AS DELIVEREDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,SOURCETABLE.T$LTXT   /* TEXT */                                                                                                     AS DETAILTEXT 
            ,CAST(T$DISC AS NUMERIC(15,2))                                                                                                       AS DISCOUNTPERCENTAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,CAST(T$SFCP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,CAST("T$COGN$1" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS1 
            ,CAST("T$COGN$2" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS2 
            ,CAST("T$COGN$3" AS NUMERIC(15,2))                                                                                                     AS GENERALCOSTS3 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS INVOICESTATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS INVOICESTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(T$LDAI AS NUMERIC(15,2))                                                                                                       AS LINEDISCOUNTAMOUNT 
            ,CAST(T$LINO AS INT)                                                                                                                 AS LINENUMBER 
            ,CAST("T$COMA$1" AS NUMERIC(15,2))                                                                                                     AS MATERIALCOST1 
            ,CAST("T$COMA$2" AS NUMERIC(15,2))                                                                                                     AS MATERIALCOST2 
            ,CAST("T$COMA$3" AS NUMERIC(15,2))                                                                                                     AS MATERIALCOST3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMEA)),'')                                                                                         AS MEASUREMENTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OJMD)),'')                                                                                         AS OBJECTMODEL 
            ,CAST(T$OSEQ AS INT)                                                                                                                 AS OBJECTSEQUENCENO 
            ,CAST("T$COOP$1" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS1 
            ,CAST("T$COOP$2" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS2 
            ,CAST("T$COOP$3" AS NUMERIC(15,2))                                                                                                     AS OPERATIONCOSTS3 
            ,CAST(T$PRIC AS NUMERIC(15,2))                                                                                                       AS PRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS PRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS QUANTITYUNIT 
            ,CAST("T$COQU$1" AS NUMERIC(15,2))                                                                                                     AS QUOTATIONCOSTS1 
            ,CAST("T$COQU$2" AS NUMERIC(15,2))                                                                                                     AS QUOTATIONCOSTS2 
            ,CAST("T$COQU$3" AS NUMERIC(15,2))                                                                                                     AS QUOTATIONCOSTS3 
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
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SRVO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTP)),'')                                                                                         AS SERVICETYPE 
            ,SOURCETABLE.T$TXTC   /* TEXT */                                                                                                     AS SOLUTIONTEXT 
            ,CAST(T$SLCP AS INT)                                                                                                                 AS SOURCELOGISTICCOMPANY 
            ,CAST("T$SRCH$1" AS NUMERIC(15,2))                                                                                                     AS SURCHARGEAMOUNT1 
            ,CAST("T$SRCH$2" AS NUMERIC(15,2))                                                                                                     AS SURCHARGEAMOUNT2 
            ,CAST("T$SRCH$3" AS NUMERIC(15,2))                                                                                                     AS SURCHARGEAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTSK)),'')                                                                                         AS TASK 
            ,CAST("T$TXAH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$TXAH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$TXAH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,CAST(T$TXAI AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXCT)),'')                                                                                         AS TAXCOUNTRY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXID)),'')                                                                                         AS TAXID 
            ,CAST(T$TNUM AS BIGINT)                                                                                                              AS TOOLNUMBER 
            ,T$INVT.CONSTANTDESCRIPTION                                                                                                          AS TYPEOFINVOICEDESCRIPTION 
            ,CAST(T$INVT AS INT)                                                                                                                 AS TYPEOFINVOICEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNIT 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TCISLI255201") }} AS SOURCETABLE  
            /*CHARGETYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHTP 
             ON   T$CHTP.TABLENAME  = 'CISLI255' 
              AND T$CHTP.COLUMNNAME = 'T$CHTP' 
              AND T$CHTP.CONSTANT   = SOURCETABLE.T$CHTP 
            /*INVOICESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'CISLI255' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*TYPEOFINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INVT 
             ON   T$INVT.TABLENAME  = 'CISLI255' 
              AND T$INVT.COLUMNNAME = 'T$INVT' 
              AND T$INVT.CONSTANT   = SOURCETABLE.T$INVT 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTCUMTIMEQTY AS ACTCUMTIMEQTY, 
        source_data.ACTIVITYLINE AS ACTIVITYLINE, 
        source_data.ACTIVITYTEXT AS ACTIVITYTEXT, 
        source_data.ACTUALDEPENDENTVALUE AS ACTUALDEPENDENTVALUE, 
        source_data.ACTUALFINISHTIME AS ACTUALFINISHTIME, 
        source_data.ACTUALSALESLABOURRATE AS ACTUALSALESLABOURRATE, 
        source_data.ACTUALSTARTTIME AS ACTUALSTARTTIME, 
        source_data.ACTUALWAREHOUSE AS ACTUALWAREHOUSE, 
        source_data.AMOUNTINHOMECURRENCY1 AS AMOUNTINHOMECURRENCY1, 
        source_data.AMOUNTINHOMECURRENCY2 AS AMOUNTINHOMECURRENCY2, 
        source_data.AMOUNTINHOMECURRENCY3 AS AMOUNTINHOMECURRENCY3, 
        source_data.AMOUNTININVOICECURRENCY AS AMOUNTININVOICECURRENCY, 
        source_data.CHARGETYPEDESCRIPTION AS CHARGETYPEDESCRIPTION, 
        source_data.CHARGETYPEID AS CHARGETYPEID, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONVFACTORPRICEUNIT AS CONVFACTORPRICEUNIT, 
        source_data.CONVFACTORQUANTITYUNIT AS CONVFACTORQUANTITYUNIT, 
        source_data.COSTAMNTINVOICING1 AS COSTAMNTINVOICING1, 
        source_data.COSTAMNTINVOICING2 AS COSTAMNTINVOICING2, 
        source_data.COSTAMNTINVOICING3 AS COSTAMNTINVOICING3, 
        source_data.COSTAMNTSERVCONTRACTS1 AS COSTAMNTSERVCONTRACTS1, 
        source_data.COSTAMNTSERVCONTRACTS2 AS COSTAMNTSERVCONTRACTS2, 
        source_data.COSTAMNTSERVCONTRACTS3 AS COSTAMNTSERVCONTRACTS3, 
        source_data.CUT_OFFDATE AS CUT_OFFDATE, 
        source_data.DELIVEREDQUANTITY AS DELIVEREDQUANTITY, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.DETAILTEXT AS DETAILTEXT, 
        source_data.DISCOUNTPERCENTAGE AS DISCOUNTPERCENTAGE, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.FINANCIALCOMPANY AS FINANCIALCOMPANY, 
        source_data.GENERALCOSTS1 AS GENERALCOSTS1, 
        source_data.GENERALCOSTS2 AS GENERALCOSTS2, 
        source_data.GENERALCOSTS3 AS GENERALCOSTS3, 
        source_data.INVOICESTATUSDESCRIPTION AS INVOICESTATUSDESCRIPTION, 
        source_data.INVOICESTATUSID AS INVOICESTATUSID, 
        source_data.ITEM AS ITEM, 
        source_data.LINEDISCOUNTAMOUNT AS LINEDISCOUNTAMOUNT, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.MATERIALCOST1 AS MATERIALCOST1, 
        source_data.MATERIALCOST2 AS MATERIALCOST2, 
        source_data.MATERIALCOST3 AS MATERIALCOST3, 
        source_data.MEASUREMENTTYPE AS MEASUREMENTTYPE, 
        source_data.OBJECTMODEL AS OBJECTMODEL, 
        source_data.OBJECTSEQUENCENO AS OBJECTSEQUENCENO, 
        source_data.OPERATIONCOSTS1 AS OPERATIONCOSTS1, 
        source_data.OPERATIONCOSTS2 AS OPERATIONCOSTS2, 
        source_data.OPERATIONCOSTS3 AS OPERATIONCOSTS3, 
        source_data.PRICE AS PRICE, 
        source_data.PRICEUNIT AS PRICEUNIT, 
        source_data.QUANTITYUNIT AS QUANTITYUNIT, 
        source_data.QUOTATIONCOSTS1 AS QUOTATIONCOSTS1, 
        source_data.QUOTATIONCOSTS2 AS QUOTATIONCOSTS2, 
        source_data.QUOTATIONCOSTS3 AS QUOTATIONCOSTS3, 
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
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SERVICETYPE AS SERVICETYPE, 
        source_data.SOLUTIONTEXT AS SOLUTIONTEXT, 
        source_data.SOURCELOGISTICCOMPANY AS SOURCELOGISTICCOMPANY, 
        source_data.SURCHARGEAMOUNT1 AS SURCHARGEAMOUNT1, 
        source_data.SURCHARGEAMOUNT2 AS SURCHARGEAMOUNT2, 
        source_data.SURCHARGEAMOUNT3 AS SURCHARGEAMOUNT3, 
        source_data.TASK AS TASK, 
        source_data.TAXAMOUNTINHOMECURRENCY1 AS TAXAMOUNTINHOMECURRENCY1, 
        source_data.TAXAMOUNTINHOMECURRENCY2 AS TAXAMOUNTINHOMECURRENCY2, 
        source_data.TAXAMOUNTINHOMECURRENCY3 AS TAXAMOUNTINHOMECURRENCY3, 
        source_data.TAXAMOUNTININVOICECURRENCY AS TAXAMOUNTININVOICECURRENCY, 
        source_data.TAXCOUNTRY AS TAXCOUNTRY, 
        source_data.TAXID AS TAXID, 
        source_data.TOOLNUMBER AS TOOLNUMBER, 
        source_data.TYPEOFINVOICEDESCRIPTION AS TYPEOFINVOICEDESCRIPTION, 
        source_data.TYPEOFINVOICEID AS TYPEOFINVOICEID, 
        source_data.UNIT AS UNIT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTCUMTIMEQTY as NUMBER(15,2)) as ACTCUMTIMEQTY,
        cast(ACTIVITYLINE as NUMBER(38,0)) as ACTIVITYLINE,
        cast(ACTIVITYTEXT as NUMBER(38,10)) as ACTIVITYTEXT,
        cast(ACTUALDEPENDENTVALUE as NUMBER(15,2)) as ACTUALDEPENDENTVALUE,
        cast(ACTUALFINISHTIME as TIMESTAMP_NTZ(9)) as ACTUALFINISHTIME,
        cast(ACTUALSALESLABOURRATE as NUMBER(15,2)) as ACTUALSALESLABOURRATE,
        cast(ACTUALSTARTTIME as TIMESTAMP_NTZ(9)) as ACTUALSTARTTIME,
        cast(ACTUALWAREHOUSE as VARCHAR(6)) as ACTUALWAREHOUSE,
        cast(AMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY1,
        cast(AMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY2,
        cast(AMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY3,
        cast(AMOUNTININVOICECURRENCY as NUMBER(15,2)) as AMOUNTININVOICECURRENCY,
        cast(CHARGETYPEDESCRIPTION as VARCHAR(16777216)) as CHARGETYPEDESCRIPTION,
        cast(CHARGETYPEID as NUMBER(38,0)) as CHARGETYPEID,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONVFACTORPRICEUNIT as NUMBER(15,2)) as CONVFACTORPRICEUNIT,
        cast(CONVFACTORQUANTITYUNIT as NUMBER(15,2)) as CONVFACTORQUANTITYUNIT,
        cast(COSTAMNTINVOICING1 as NUMBER(15,2)) as COSTAMNTINVOICING1,
        cast(COSTAMNTINVOICING2 as NUMBER(15,2)) as COSTAMNTINVOICING2,
        cast(COSTAMNTINVOICING3 as NUMBER(15,2)) as COSTAMNTINVOICING3,
        cast(COSTAMNTSERVCONTRACTS1 as NUMBER(15,2)) as COSTAMNTSERVCONTRACTS1,
        cast(COSTAMNTSERVCONTRACTS2 as NUMBER(15,2)) as COSTAMNTSERVCONTRACTS2,
        cast(COSTAMNTSERVCONTRACTS3 as NUMBER(15,2)) as COSTAMNTSERVCONTRACTS3,
        cast(CUT_OFFDATE as TIMESTAMP_NTZ(9)) as CUT_OFFDATE,
        cast(DELIVEREDQUANTITY as NUMBER(15,2)) as DELIVEREDQUANTITY,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(DETAILTEXT as NUMBER(38,10)) as DETAILTEXT,
        cast(DISCOUNTPERCENTAGE as NUMBER(15,2)) as DISCOUNTPERCENTAGE,
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(FINANCIALCOMPANY as NUMBER(38,0)) as FINANCIALCOMPANY,
        cast(GENERALCOSTS1 as NUMBER(15,2)) as GENERALCOSTS1,
        cast(GENERALCOSTS2 as NUMBER(15,2)) as GENERALCOSTS2,
        cast(GENERALCOSTS3 as NUMBER(15,2)) as GENERALCOSTS3,
        cast(INVOICESTATUSDESCRIPTION as VARCHAR(16777216)) as INVOICESTATUSDESCRIPTION,
        cast(INVOICESTATUSID as NUMBER(38,0)) as INVOICESTATUSID,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LINEDISCOUNTAMOUNT as NUMBER(15,2)) as LINEDISCOUNTAMOUNT,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(MATERIALCOST1 as NUMBER(15,2)) as MATERIALCOST1,
        cast(MATERIALCOST2 as NUMBER(15,2)) as MATERIALCOST2,
        cast(MATERIALCOST3 as NUMBER(15,2)) as MATERIALCOST3,
        cast(MEASUREMENTTYPE as VARCHAR(6)) as MEASUREMENTTYPE,
        cast(OBJECTMODEL as VARCHAR(50)) as OBJECTMODEL,
        cast(OBJECTSEQUENCENO as NUMBER(38,0)) as OBJECTSEQUENCENO,
        cast(OPERATIONCOSTS1 as NUMBER(15,2)) as OPERATIONCOSTS1,
        cast(OPERATIONCOSTS2 as NUMBER(15,2)) as OPERATIONCOSTS2,
        cast(OPERATIONCOSTS3 as NUMBER(15,2)) as OPERATIONCOSTS3,
        cast(PRICE as NUMBER(15,2)) as PRICE,
        cast(PRICEUNIT as VARCHAR(3)) as PRICEUNIT,
        cast(QUANTITYUNIT as VARCHAR(3)) as QUANTITYUNIT,
        cast(QUOTATIONCOSTS1 as NUMBER(15,2)) as QUOTATIONCOSTS1,
        cast(QUOTATIONCOSTS2 as NUMBER(15,2)) as QUOTATIONCOSTS2,
        cast(QUOTATIONCOSTS3 as NUMBER(15,2)) as QUOTATIONCOSTS3,
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
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(SERVICETYPE as VARCHAR(3)) as SERVICETYPE,
        cast(SOLUTIONTEXT as NUMBER(38,10)) as SOLUTIONTEXT,
        cast(SOURCELOGISTICCOMPANY as NUMBER(38,0)) as SOURCELOGISTICCOMPANY,
        cast(SURCHARGEAMOUNT1 as NUMBER(15,2)) as SURCHARGEAMOUNT1,
        cast(SURCHARGEAMOUNT2 as NUMBER(15,2)) as SURCHARGEAMOUNT2,
        cast(SURCHARGEAMOUNT3 as NUMBER(15,2)) as SURCHARGEAMOUNT3,
        cast(TASK as VARCHAR(8)) as TASK,
        cast(TAXAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY1,
        cast(TAXAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY2,
        cast(TAXAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY3,
        cast(TAXAMOUNTININVOICECURRENCY as NUMBER(15,2)) as TAXAMOUNTININVOICECURRENCY,
        cast(TAXCOUNTRY as VARCHAR(3)) as TAXCOUNTRY,
        cast(TAXID as VARCHAR(9)) as TAXID,
        cast(TOOLNUMBER as NUMBER(38,0)) as TOOLNUMBER,
        cast(TYPEOFINVOICEDESCRIPTION as VARCHAR(16777216)) as TYPEOFINVOICEDESCRIPTION,
        cast(TYPEOFINVOICEID as NUMBER(38,0)) as TYPEOFINVOICEID,
        cast(UNIT as VARCHAR(3)) as UNIT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data