/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_CURRENCYRATES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_CURRENCYRATES.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_CURRENCYRATES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONSYSTEMTABLES_CURRENCYRATES',
    unique_key = ['CURRENCY',
    'CURRENCYBASE',
    'EFFECTIVEDATE',
    'EXCHANGERATETYPE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BCUR)),'')                                                                                         AS CURRENCYBASE 
            ,CAST(T$RATE AS NUMERIC(15,2))                                                                                                       AS CURRENCYRATE 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS EFFECTIVEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,T$EXCB.CONSTANTDESCRIPTION                                                                                                          AS EXPRESSINBASECURRENCYDESCRIPTION 
            ,CAST(T$EXCB AS INT)                                                                                                                 AS EXPRESSINBASECURRENCYID 
            ,CAST(T$RATF AS BIGINT)                                                                                                              AS RATEFACTOR 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS008200") }} AS SOURCETABLE  
            /*EXPRESSINBASECURRENCY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$EXCB 
             ON   T$EXCB.TABLENAME  = 'TCMCS008' 
              AND T$EXCB.COLUMNNAME = 'T$EXCB' 
              AND T$EXCB.CONSTANT   = SOURCETABLE.T$EXCB 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.CURRENCYBASE AS CURRENCYBASE, 
        source_data.CURRENCYRATE AS CURRENCYRATE, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.EXPRESSINBASECURRENCYDESCRIPTION AS EXPRESSINBASECURRENCYDESCRIPTION, 
        source_data.EXPRESSINBASECURRENCYID AS EXPRESSINBASECURRENCYID, 
        source_data.RATEFACTOR AS RATEFACTOR
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(CURRENCYBASE as VARCHAR(3)) as CURRENCYBASE,
        cast(CURRENCYRATE as NUMBER(15,2)) as CURRENCYRATE,
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(EXPRESSINBASECURRENCYDESCRIPTION as VARCHAR(16777216)) as EXPRESSINBASECURRENCYDESCRIPTION,
        cast(EXPRESSINBASECURRENCYID as NUMBER(38,0)) as EXPRESSINBASECURRENCYID,
        cast(RATEFACTOR as NUMBER(38,0)) as RATEFACTOR,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data