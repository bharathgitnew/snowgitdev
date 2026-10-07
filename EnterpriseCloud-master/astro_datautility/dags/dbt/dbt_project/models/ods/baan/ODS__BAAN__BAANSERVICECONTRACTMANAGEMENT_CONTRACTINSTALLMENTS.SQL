/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_CONTRACTINSTALLMENTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_CONTRACTINSTALLMENTS.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_CONTRACTINSTALLMENTS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANSERVICECONTRACTMANAGEMENT_CONTRACTINSTALLMENTS',
    unique_key = ['INSTALLMENTNUMBER',
    'SERVICE_PERCENT_CONTRACT']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,CAST(T$ASEQ AS INT)                                                     AS ACTIVITYNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                             AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                           AS CUSTOMERPOLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS DESCRIPTION 
            ,CAST(T$DIMT AS NUMERIC(15,2))                                           AS DISCOUNTAMOUNT 
            ,CAST(T$DISC AS NUMERIC(15,2))                                           AS DISCOUNTPERCENTAGE 
            ,CAST(CASE WHEN T$EFDT<= '1/1/1970' THEN NULL ELSE T$EFDT END AS DATE) AS EFFECTIVEDATE 
            ,CAST(CASE WHEN T$EXDT<= '1/1/1970' THEN NULL ELSE T$EXDT END AS DATE) AS EXPIRYDATE 
            ,CAST(T$ICMP AS INT)                                                     AS FINANCIALCOMPANY 
            ,CAST(T$FPER AS INT)                                                     AS FISCALPERIOD 
            ,CAST(T$FYER AS INT)                                                     AS FISCALYEAR 
            ,CAST("T$FCMT$1" AS NUMERIC(15,2))                                         AS FORECASTCOSTAMOUNT1 
            ,CAST("T$FCMT$2" AS NUMERIC(15,2))                                         AS FORECASTCOSTAMOUNT2 
            ,CAST("T$FCMT$3" AS NUMERIC(15,2))                                         AS FORECASTCOSTAMOUNT3 
            ,CAST(T$FCPC AS NUMERIC(15,2))                                           AS FORECASTCOSTPERCENTAGE 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                           AS INSTALLMENTAMOUNT 
            ,CAST(T$INST AS BIGINT)                                                  AS INSTALLMENTNUMBER 
            ,T$STIN.CONSTANTDESCRIPTION                                              AS INSTALLMENTSTATUSDESCRIPTION 
            ,CAST(T$STIN AS INT)                                                     AS INSTALLMENTSTATUSID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                         AS INSTALLMENTTEXT 
            ,T$VINS.CONSTANTDESCRIPTION                                              AS INSTALLMENTVARIANTDESCRIPTION 
            ,CAST(T$VINS AS INT)                                                     AS INSTALLMENTVARIANTID 
            ,T$CRED.CONSTANTDESCRIPTION                                              AS INVOICECREDITDESCRIPTION 
            ,CAST(T$CRED AS INT)                                                     AS INVOICECREDITID 
            ,CAST(CASE WHEN T$INDT<= '1/1/1970' THEN NULL ELSE T$INDT END AS DATE) AS INVOICEDATE 
            ,T$MINV.CONSTANTDESCRIPTION                                              AS INVOICEMETHODDESCRIPTION 
            ,CAST(T$MINV AS INT)                                                     AS INVOICEMETHODID 
            ,CAST(T$IDOC AS BIGINT)                                                  AS INVOICENUMBER 
            ,CAST(T$NTMT AS NUMERIC(15,2))                                           AS NETINSTALLMENTAMOUNT 
            ,CAST(T$NRPF AS INT)                                                     AS NUMBEROFPERIODSFORFINANCIALSPREADING 
            ,CAST(CASE WHEN T$PIDT<= '1/1/1970' THEN NULL ELSE T$PIDT END AS DATE) AS PLANNEDINVOICEDATE 
            ,CAST(CASE WHEN T$PRDT<= '1/1/1970' THEN NULL ELSE T$PRDT END AS DATE) AS POSTINGDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRAC)),'')                             AS REFERENCEACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                             AS SERVICE_percent_CONTRACT 
            ,CAST(T$TXMT AS NUMERIC(15,2))                                           AS TAXAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                             AS TRANSACTIONTYPE 
            ,CAST("T$WCDT$U" AS NUMERIC(15,2))                                         AS WARRANTYCREDIT 
            ,CAST(T$WDMT AS NUMERIC(15,2))                                           AS WARRANTYDISCAMOUNT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM400201") }} AS SOURCETABLE  
            /*INSTALLMENTSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STIN 
             ON   T$STIN.TABLENAME  = 'TSCTM400' 
              AND T$STIN.COLUMNNAME = 'T$STIN' 
              AND T$STIN.CONSTANT   = SOURCETABLE.T$STIN 
            /*INSTALLMENTVARIANT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VINS 
             ON   T$VINS.TABLENAME  = 'TSCTM400' 
              AND T$VINS.COLUMNNAME = 'T$VINS' 
              AND T$VINS.CONSTANT   = SOURCETABLE.T$VINS 
            /*INVOICECREDIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CRED 
             ON   T$CRED.TABLENAME  = 'TSCTM400' 
              AND T$CRED.COLUMNNAME = 'T$CRED' 
              AND T$CRED.CONSTANT   = SOURCETABLE.T$CRED 
            /*INVOICEMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MINV 
             ON   T$MINV.TABLENAME  = 'TSCTM400' 
              AND T$MINV.COLUMNNAME = 'T$MINV' 
              AND T$MINV.CONSTANT   = SOURCETABLE.T$MINV 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITYNUMBER AS ACTIVITYNUMBER, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CUSTOMERPOLINE AS CUSTOMERPOLINE, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.DISCOUNTAMOUNT AS DISCOUNTAMOUNT, 
        source_data.DISCOUNTPERCENTAGE AS DISCOUNTPERCENTAGE, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.EXPIRYDATE AS EXPIRYDATE, 
        source_data.FINANCIALCOMPANY AS FINANCIALCOMPANY, 
        source_data.FISCALPERIOD AS FISCALPERIOD, 
        source_data.FISCALYEAR AS FISCALYEAR, 
        source_data.FORECASTCOSTAMOUNT1 AS FORECASTCOSTAMOUNT1, 
        source_data.FORECASTCOSTAMOUNT2 AS FORECASTCOSTAMOUNT2, 
        source_data.FORECASTCOSTAMOUNT3 AS FORECASTCOSTAMOUNT3, 
        source_data.FORECASTCOSTPERCENTAGE AS FORECASTCOSTPERCENTAGE, 
        source_data.INSTALLMENTAMOUNT AS INSTALLMENTAMOUNT, 
        source_data.INSTALLMENTNUMBER AS INSTALLMENTNUMBER, 
        source_data.INSTALLMENTSTATUSDESCRIPTION AS INSTALLMENTSTATUSDESCRIPTION, 
        source_data.INSTALLMENTSTATUSID AS INSTALLMENTSTATUSID, 
        source_data.INSTALLMENTTEXT AS INSTALLMENTTEXT, 
        source_data.INSTALLMENTVARIANTDESCRIPTION AS INSTALLMENTVARIANTDESCRIPTION, 
        source_data.INSTALLMENTVARIANTID AS INSTALLMENTVARIANTID, 
        source_data.INVOICECREDITDESCRIPTION AS INVOICECREDITDESCRIPTION, 
        source_data.INVOICECREDITID AS INVOICECREDITID, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICEMETHODDESCRIPTION AS INVOICEMETHODDESCRIPTION, 
        source_data.INVOICEMETHODID AS INVOICEMETHODID, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.NETINSTALLMENTAMOUNT AS NETINSTALLMENTAMOUNT, 
        source_data.NUMBEROFPERIODSFORFINANCIALSPREADING AS NUMBEROFPERIODSFORFINANCIALSPREADING, 
        source_data.PLANNEDINVOICEDATE AS PLANNEDINVOICEDATE, 
        source_data.POSTINGDATE AS POSTINGDATE, 
        source_data.REFERENCEACTIVITY AS REFERENCEACTIVITY, 
        source_data.SERVICE_PERCENT_CONTRACT AS SERVICE_PERCENT_CONTRACT, 
        source_data.TAXAMOUNT AS TAXAMOUNT, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE, 
        source_data.WARRANTYCREDIT AS WARRANTYCREDIT, 
        source_data.WARRANTYDISCAMOUNT AS WARRANTYDISCAMOUNT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTIVITYNUMBER as NUMBER(38,0)) as ACTIVITYNUMBER,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CUSTOMERPOLINE as VARCHAR(10)) as CUSTOMERPOLINE,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(DISCOUNTAMOUNT as NUMBER(15,2)) as DISCOUNTAMOUNT,
        cast(DISCOUNTPERCENTAGE as NUMBER(15,2)) as DISCOUNTPERCENTAGE,
        cast(EFFECTIVEDATE as DATE) as EFFECTIVEDATE,
        cast(EXPIRYDATE as DATE) as EXPIRYDATE,
        cast(FINANCIALCOMPANY as NUMBER(38,0)) as FINANCIALCOMPANY,
        cast(FISCALPERIOD as NUMBER(38,0)) as FISCALPERIOD,
        cast(FISCALYEAR as NUMBER(38,0)) as FISCALYEAR,
        cast(FORECASTCOSTAMOUNT1 as NUMBER(15,2)) as FORECASTCOSTAMOUNT1,
        cast(FORECASTCOSTAMOUNT2 as NUMBER(15,2)) as FORECASTCOSTAMOUNT2,
        cast(FORECASTCOSTAMOUNT3 as NUMBER(15,2)) as FORECASTCOSTAMOUNT3,
        cast(FORECASTCOSTPERCENTAGE as NUMBER(15,2)) as FORECASTCOSTPERCENTAGE,
        cast(INSTALLMENTAMOUNT as NUMBER(15,2)) as INSTALLMENTAMOUNT,
        cast(INSTALLMENTNUMBER as NUMBER(38,0)) as INSTALLMENTNUMBER,
        cast(INSTALLMENTSTATUSDESCRIPTION as VARCHAR(16777216)) as INSTALLMENTSTATUSDESCRIPTION,
        cast(INSTALLMENTSTATUSID as NUMBER(38,0)) as INSTALLMENTSTATUSID,
        cast(INSTALLMENTTEXT as NUMBER(38,10)) as INSTALLMENTTEXT,
        cast(INSTALLMENTVARIANTDESCRIPTION as VARCHAR(16777216)) as INSTALLMENTVARIANTDESCRIPTION,
        cast(INSTALLMENTVARIANTID as NUMBER(38,0)) as INSTALLMENTVARIANTID,
        cast(INVOICECREDITDESCRIPTION as VARCHAR(16777216)) as INVOICECREDITDESCRIPTION,
        cast(INVOICECREDITID as NUMBER(38,0)) as INVOICECREDITID,
        cast(INVOICEDATE as DATE) as INVOICEDATE,
        cast(INVOICEMETHODDESCRIPTION as VARCHAR(16777216)) as INVOICEMETHODDESCRIPTION,
        cast(INVOICEMETHODID as NUMBER(38,0)) as INVOICEMETHODID,
        cast(INVOICENUMBER as NUMBER(38,0)) as INVOICENUMBER,
        cast(NETINSTALLMENTAMOUNT as NUMBER(15,2)) as NETINSTALLMENTAMOUNT,
        cast(NUMBEROFPERIODSFORFINANCIALSPREADING as NUMBER(38,0)) as NUMBEROFPERIODSFORFINANCIALSPREADING,
        cast(PLANNEDINVOICEDATE as DATE) as PLANNEDINVOICEDATE,
        cast(POSTINGDATE as DATE) as POSTINGDATE,
        cast(REFERENCEACTIVITY as VARCHAR(8)) as REFERENCEACTIVITY,
        cast(SERVICE_PERCENT_CONTRACT as VARCHAR(9)) as SERVICE_PERCENT_CONTRACT,
        cast(TAXAMOUNT as NUMBER(15,2)) as TAXAMOUNT,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(WARRANTYCREDIT as NUMBER(15,2)) as WARRANTYCREDIT,
        cast(WARRANTYDISCAMOUNT as NUMBER(15,2)) as WARRANTYDISCAMOUNT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data