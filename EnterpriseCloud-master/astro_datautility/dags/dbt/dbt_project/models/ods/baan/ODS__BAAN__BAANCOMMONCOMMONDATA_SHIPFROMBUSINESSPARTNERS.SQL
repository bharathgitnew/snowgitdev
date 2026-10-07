/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_SHIPFROMBUSINESSPARTNERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_SHIPFROMBUSINESSPARTNERS.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_SHIPFROMBUSINESSPARTNERS 
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
    alias='BAANCOMMONCOMMONDATA_SHIPFROMBUSINESSPARTNERS',
    unique_key = ['SHIPFROMBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                         AS ADDRESSCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBPS)),'')                                                                                         AS BUSINESSPARTNERSIGNAL 
            ,T$BPST.CONSTANTDESCRIPTION                                                                                                          AS BUSINESSPARTNERSTATUSDESCRIPTION 
            ,CAST(T$BPST AS INT)                                                                                                                 AS BUSINESSPARTNERSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBTP)),'')                                                                                         AS BUSINESSPARTNERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDARCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                         AS CARRIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                                                                         AS CONTACTCODE 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME) AS ENDDATE 
            ,T$QUAL.CONSTANTDESCRIPTION                                                                                                          AS INSPECTIONDESCRIPTION 
            ,CAST(T$QUAL AS INT)                                                                                                                 AS INSPECTIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                         AS LANGUAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFBP)),'')                                                                                         AS SHIPFROMBUSINESSPARTNER 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS STARTDATE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,T$VRYN.CONSTANTDESCRIPTION                                                                                                          AS VENDORRATINGDESCRIPTION 
            ,CAST(T$VRYN AS INT)                                                                                                                 AS VENDORRATINGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM121200") }} AS SOURCETABLE  
            /*BUSINESSPARTNERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BPST 
             ON   T$BPST.TABLENAME  = 'TCCOM121' 
              AND T$BPST.COLUMNNAME = 'T$BPST' 
              AND T$BPST.CONSTANT   = SOURCETABLE.T$BPST 
            /*INSPECTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QUAL 
             ON   T$QUAL.TABLENAME  = 'TCCOM121' 
              AND T$QUAL.COLUMNNAME = 'T$QUAL' 
              AND T$QUAL.CONSTANT   = SOURCETABLE.T$QUAL 
            /*VENDORRATING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VRYN 
             ON   T$VRYN.TABLENAME  = 'TCCOM121' 
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
        source_data.BUSINESSPARTNERSIGNAL AS BUSINESSPARTNERSIGNAL, 
        source_data.BUSINESSPARTNERSTATUSDESCRIPTION AS BUSINESSPARTNERSTATUSDESCRIPTION, 
        source_data.BUSINESSPARTNERSTATUSID AS BUSINESSPARTNERSTATUSID, 
        source_data.BUSINESSPARTNERTYPE AS BUSINESSPARTNERTYPE, 
        source_data.BUYFROMBUSINESSPARTNER AS BUYFROMBUSINESSPARTNER, 
        source_data.CALENDARCODE AS CALENDARCODE, 
        source_data.CARRIER AS CARRIER, 
        source_data.CONTACTCODE AS CONTACTCODE, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.INSPECTIONDESCRIPTION AS INSPECTIONDESCRIPTION, 
        source_data.INSPECTIONID AS INSPECTIONID, 
        source_data.LANGUAGE AS LANGUAGE, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.SHIPFROMBUSINESSPARTNER AS SHIPFROMBUSINESSPARTNER, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.TEXT AS TEXT, 
        source_data.VENDORRATINGDESCRIPTION AS VENDORRATINGDESCRIPTION, 
        source_data.VENDORRATINGID AS VENDORRATINGID, 
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
        cast(ADDRESSCODE as VARCHAR(9)) as ADDRESSCODE,
        cast(BUSINESSPARTNERSIGNAL as VARCHAR(3)) as BUSINESSPARTNERSIGNAL,
        cast(BUSINESSPARTNERSTATUSDESCRIPTION as VARCHAR(16777216)) as BUSINESSPARTNERSTATUSDESCRIPTION,
        cast(BUSINESSPARTNERSTATUSID as NUMBER(38,0)) as BUSINESSPARTNERSTATUSID,
        cast(BUSINESSPARTNERTYPE as VARCHAR(3)) as BUSINESSPARTNERTYPE,
        cast(BUYFROMBUSINESSPARTNER as VARCHAR(9)) as BUYFROMBUSINESSPARTNER,
        cast(CALENDARCODE as VARCHAR(9)) as CALENDARCODE,
        cast(CARRIER as VARCHAR(3)) as CARRIER,
        cast(CONTACTCODE as VARCHAR(9)) as CONTACTCODE,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(INSPECTIONDESCRIPTION as VARCHAR(16777216)) as INSPECTIONDESCRIPTION,
        cast(INSPECTIONID as NUMBER(38,0)) as INSPECTIONID,
        cast(LANGUAGE as VARCHAR(3)) as LANGUAGE,
        cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
        cast(SHIPFROMBUSINESSPARTNER as VARCHAR(9)) as SHIPFROMBUSINESSPARTNER,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(VENDORRATINGDESCRIPTION as VARCHAR(16777216)) as VENDORRATINGDESCRIPTION,
        cast(VENDORRATINGID as NUMBER(38,0)) as VENDORRATINGID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data