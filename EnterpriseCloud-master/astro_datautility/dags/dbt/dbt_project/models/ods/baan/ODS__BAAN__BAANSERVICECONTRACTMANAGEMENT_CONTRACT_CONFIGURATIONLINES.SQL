/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_CONTRACT_CONFIGURATIONLINES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_CONTRACT_CONFIGURATIONLINES.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_CONTRACT_CONFIGURATIONLINES 
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
    alias='BAANSERVICECONTRACTMANAGEMENT_CONTRACT_CONFIGURATIONLINES',
    unique_key = ['CONTRACTTERMS',
    'LINE',
    'SERVICECONTRACT']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,CAST(T$UPRC AS NUMERIC(15,2))                                           AS AGREEDUPTIMEPERCENTAGE 
            ,CAST(T$AMDY AS NUMERIC(15,2))                                           AS AMOUNTPERDAY 
            ,CAST(CASE WHEN T$BSDT<= '1/1/1970' THEN NULL ELSE T$BSDT END AS DATE) AS BILLINGSTARTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                             AS CONFIGURATION 
            ,CAST(T$TERM AS BIGINT)                                                  AS CONTRACTTERMS 
            ,CAST(T$ERFA AS NUMERIC(15,2))                                           AS EARNEDREVENUEFACTOR 
            ,CAST(CASE WHEN T$EFDT<= '1/1/1970' THEN NULL ELSE T$EFDT END AS DATE) AS EFFECTIVEDATE 
            ,CAST(CASE WHEN T$EXDT<= '1/1/1970' THEN NULL ELSE T$EXDT END AS DATE) AS EXPIRYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTIN)),'')                             AS INSTALLMENTTEMPLATE 
            ,CAST(T$SEQN AS INT)                                                     AS LINE 
            ,CAST(T$NPER AS BIGINT)                                                  AS NUMBEROFPERIODS 
            ,CAST(T$PERC AS NUMERIC(15,2))                                           AS PERCENTAGEOFSALESVALUE 
            ,T$PRMT.CONSTANTDESCRIPTION                                              AS PRICINGMETHODDESCRIPTION 
            ,CAST(T$PRMT AS INT)                                                     AS PRICINGMETHODID 
            ,CAST(T$SAMT AS NUMERIC(15,2))                                           AS SERVICEAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                             AS SERVICECONTRACT 
            ,T$PERU.CONSTANTDESCRIPTION                                              AS SERVICEPERIODUNITDESCRIPTION 
            ,CAST(T$PERU AS INT)                                                     AS SERVICEPERIODUNITID 
            ,CAST(T$TAMT AS NUMERIC(15,2))                                           AS TOTALADD_ONAMOUNT 
            ,CAST(T$TDMT AS NUMERIC(15,2))                                           AS TOTALADD_ONDISCOUNTAMOUNT 
            ,CAST(T$UETM AS INT)                                                     AS UPTIMECOVERAGEENDTIME 
            ,CAST(T$USTM AS INT)                                                     AS UPTIMECOVERAGESTARTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWDS)),'')                             AS WARRANTYDISCOUNTSCHEME 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM310201") }} AS SOURCETABLE  
            /*PRICINGMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PRMT 
             ON   T$PRMT.TABLENAME  = 'TSCTM310' 
              AND T$PRMT.COLUMNNAME = 'T$PRMT' 
              AND T$PRMT.CONSTANT   = SOURCETABLE.T$PRMT 
            /*SERVICEPERIODUNIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PERU 
             ON   T$PERU.TABLENAME  = 'TSCTM310' 
              AND T$PERU.COLUMNNAME = 'T$PERU' 
              AND T$PERU.CONSTANT   = SOURCETABLE.T$PERU 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AGREEDUPTIMEPERCENTAGE AS AGREEDUPTIMEPERCENTAGE, 
        source_data.AMOUNTPERDAY AS AMOUNTPERDAY, 
        source_data.BILLINGSTARTDATE AS BILLINGSTARTDATE, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTRACTTERMS AS CONTRACTTERMS, 
        source_data.EARNEDREVENUEFACTOR AS EARNEDREVENUEFACTOR, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.EXPIRYDATE AS EXPIRYDATE, 
        source_data.INSTALLMENTTEMPLATE AS INSTALLMENTTEMPLATE, 
        source_data.LINE AS LINE, 
        source_data.NUMBEROFPERIODS AS NUMBEROFPERIODS, 
        source_data.PERCENTAGEOFSALESVALUE AS PERCENTAGEOFSALESVALUE, 
        source_data.PRICINGMETHODDESCRIPTION AS PRICINGMETHODDESCRIPTION, 
        source_data.PRICINGMETHODID AS PRICINGMETHODID, 
        source_data.SERVICEAMOUNT AS SERVICEAMOUNT, 
        source_data.SERVICECONTRACT AS SERVICECONTRACT, 
        source_data.SERVICEPERIODUNITDESCRIPTION AS SERVICEPERIODUNITDESCRIPTION, 
        source_data.SERVICEPERIODUNITID AS SERVICEPERIODUNITID, 
        source_data.TOTALADD_ONAMOUNT AS TOTALADD_ONAMOUNT, 
        source_data.TOTALADD_ONDISCOUNTAMOUNT AS TOTALADD_ONDISCOUNTAMOUNT, 
        source_data.UPTIMECOVERAGEENDTIME AS UPTIMECOVERAGEENDTIME, 
        source_data.UPTIMECOVERAGESTARTTIME AS UPTIMECOVERAGESTARTTIME, 
        source_data.WARRANTYDISCOUNTSCHEME AS WARRANTYDISCOUNTSCHEME
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AGREEDUPTIMEPERCENTAGE as NUMBER(15,2)) as AGREEDUPTIMEPERCENTAGE,
        cast(AMOUNTPERDAY as NUMBER(15,2)) as AMOUNTPERDAY,
        cast(BILLINGSTARTDATE as DATE) as BILLINGSTARTDATE,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTRACTTERMS as NUMBER(38,0)) as CONTRACTTERMS,
        cast(EARNEDREVENUEFACTOR as NUMBER(15,2)) as EARNEDREVENUEFACTOR,
        cast(EFFECTIVEDATE as DATE) as EFFECTIVEDATE,
        cast(EXPIRYDATE as DATE) as EXPIRYDATE,
        cast(INSTALLMENTTEMPLATE as VARCHAR(3)) as INSTALLMENTTEMPLATE,
        cast(LINE as NUMBER(38,0)) as LINE,
        cast(NUMBEROFPERIODS as NUMBER(38,0)) as NUMBEROFPERIODS,
        cast(PERCENTAGEOFSALESVALUE as NUMBER(15,2)) as PERCENTAGEOFSALESVALUE,
        cast(PRICINGMETHODDESCRIPTION as VARCHAR(16777216)) as PRICINGMETHODDESCRIPTION,
        cast(PRICINGMETHODID as NUMBER(38,0)) as PRICINGMETHODID,
        cast(SERVICEAMOUNT as NUMBER(15,2)) as SERVICEAMOUNT,
        cast(SERVICECONTRACT as VARCHAR(9)) as SERVICECONTRACT,
        cast(SERVICEPERIODUNITDESCRIPTION as VARCHAR(16777216)) as SERVICEPERIODUNITDESCRIPTION,
        cast(SERVICEPERIODUNITID as NUMBER(38,0)) as SERVICEPERIODUNITID,
        cast(TOTALADD_ONAMOUNT as NUMBER(15,2)) as TOTALADD_ONAMOUNT,
        cast(TOTALADD_ONDISCOUNTAMOUNT as NUMBER(15,2)) as TOTALADD_ONDISCOUNTAMOUNT,
        cast(UPTIMECOVERAGEENDTIME as NUMBER(38,0)) as UPTIMECOVERAGEENDTIME,
        cast(UPTIMECOVERAGESTARTTIME as NUMBER(38,0)) as UPTIMECOVERAGESTARTTIME,
        cast(WARRANTYDISCOUNTSCHEME as VARCHAR(3)) as WARRANTYDISCOUNTSCHEME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data