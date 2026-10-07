/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNERS.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNERS 
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
    alias='BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNERS',
    unique_key = ['DEPARTMENT',
    'PAYTOBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                         AS ADDRESSCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBAN)),'')                                                                                         AS BANK 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBFC)),'')                                                                                         AS BANKFACTORINGCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBPS)),'')                                                                                         AS BUSINESSPARTNERSIGNAL 
            ,T$BPST.CONSTANTDESCRIPTION                                                                                                          AS BUSINESSPARTNERSTATUSDESCRIPTION 
            ,CAST(T$BPST AS INT)                                                                                                                 AS BUSINESSPARTNERSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBTP)),'')                                                                                         AS BUSINESSPARTNERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDARCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                                                                         AS CONTACTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FANO)),'')                                                                                         AS CUSTOMERNUMBERATFACTOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS DEPARTMENT 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME) AS ENDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,CAST(T$EDED AS INT)                                                                                                                 AS EXTRADAYSAFTERDUEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFCC)),'')                                                                                         AS FACTORINGCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                         AS LANGUAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PTBP)),'')                                                                                         AS PAYTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEY 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS STARTDATE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,T$VRYN.CONSTANTDESCRIPTION                                                                                                          AS VENDORRATINGDESCRIPTION 
            ,CAST(T$VRYN AS INT)                                                                                                                 AS VENDORRATINGID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM124200") }} AS SOURCETABLE  
            /*BUSINESSPARTNERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BPST 
             ON   T$BPST.TABLENAME  = 'TCCOM124' 
              AND T$BPST.COLUMNNAME = 'T$BPST' 
              AND T$BPST.CONSTANT   = SOURCETABLE.T$BPST 
            /*VENDORRATING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VRYN 
             ON   T$VRYN.TABLENAME  = 'TCCOM124' 
              AND T$VRYN.COLUMNNAME = 'T$VRYN' 
              AND T$VRYN.CONSTANT   = SOURCETABLE.T$VRYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDRESSCODE AS ADDRESSCODE, 
        source_data.BANK AS BANK, 
        source_data.BANKFACTORINGCOMPANY AS BANKFACTORINGCOMPANY, 
        source_data.BUSINESSPARTNERSIGNAL AS BUSINESSPARTNERSIGNAL, 
        source_data.BUSINESSPARTNERSTATUSDESCRIPTION AS BUSINESSPARTNERSTATUSDESCRIPTION, 
        source_data.BUSINESSPARTNERSTATUSID AS BUSINESSPARTNERSTATUSID, 
        source_data.BUSINESSPARTNERTYPE AS BUSINESSPARTNERTYPE, 
        source_data.CALENDARCODE AS CALENDARCODE, 
        source_data.CONTACTCODE AS CONTACTCODE, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.CUSTOMERNUMBERATFACTOR AS CUSTOMERNUMBERATFACTOR, 
        source_data.DEPARTMENT AS DEPARTMENT, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.EXTRADAYSAFTERDUEDATE AS EXTRADAYSAFTERDUEDATE, 
        source_data.FACTORINGCOMPANY AS FACTORINGCOMPANY, 
        source_data.LANGUAGE AS LANGUAGE, 
        source_data.PAYTOBUSINESSPARTNER AS PAYTOBUSINESSPARTNER, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.TEXT AS TEXT, 
        source_data.VENDORRATINGDESCRIPTION AS VENDORRATINGDESCRIPTION, 
        source_data.VENDORRATINGID AS VENDORRATINGID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADDRESSCODE as VARCHAR(9)) as ADDRESSCODE,
        cast(BANK as VARCHAR(3)) as BANK,
        cast(BANKFACTORINGCOMPANY as VARCHAR(3)) as BANKFACTORINGCOMPANY,
        cast(BUSINESSPARTNERSIGNAL as VARCHAR(3)) as BUSINESSPARTNERSIGNAL,
        cast(BUSINESSPARTNERSTATUSDESCRIPTION as VARCHAR(16777216)) as BUSINESSPARTNERSTATUSDESCRIPTION,
        cast(BUSINESSPARTNERSTATUSID as NUMBER(38,0)) as BUSINESSPARTNERSTATUSID,
        cast(BUSINESSPARTNERTYPE as VARCHAR(3)) as BUSINESSPARTNERTYPE,
        cast(CALENDARCODE as VARCHAR(9)) as CALENDARCODE,
        cast(CONTACTCODE as VARCHAR(9)) as CONTACTCODE,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(CUSTOMERNUMBERATFACTOR as VARCHAR(10)) as CUSTOMERNUMBERATFACTOR,
        cast(DEPARTMENT as VARCHAR(6)) as DEPARTMENT,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(EXTRADAYSAFTERDUEDATE as NUMBER(38,0)) as EXTRADAYSAFTERDUEDATE,
        cast(FACTORINGCOMPANY as VARCHAR(3)) as FACTORINGCOMPANY,
        cast(LANGUAGE as VARCHAR(3)) as LANGUAGE,
        cast(PAYTOBUSINESSPARTNER as VARCHAR(9)) as PAYTOBUSINESSPARTNER,
        cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(VENDORRATINGDESCRIPTION as VARCHAR(16777216)) as VENDORRATINGDESCRIPTION,
        cast(VENDORRATINGID as NUMBER(38,0)) as VENDORRATINGID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data