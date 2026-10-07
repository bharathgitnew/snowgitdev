/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_ADDRESSES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_ADDRESSES.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_ADDRESSES 
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
    alias='BAAN_BAANCOMMONCOMMONDATA_ADDRESSES',
    unique_key = ['ADDRESSCODE']
) }}


with source_data as 
(
    SELECT   
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAMC)),'')                                                                                         AS ADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAMD)),'')                                                                                         AS ADDRESS2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                         AS ADDRESSCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COAF)),'')                                                                                         AS ADDRESSFORMAT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDARCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAME)),'')                                                                                         AS CITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAMF)),'')                                                                                         AS CITY2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,CAST(CASE WHEN T$DTLM<= '1/1/1970' THEN NULL ELSE T$DTLM  END AS DATETIME) AS DATELASTMODIFICATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INFO)),'')                                                                                         AS E_MAIL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TEFX)),'')                                                                                         AS FAX 
            ,CAST(T$XKEY AS NUMERIC(15,2))                                                                                                       AS FRONTOFFICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$GEOC)),'')                                                                                         AS GEOCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$HONO)),'')                                                                                         AS HOUSENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INET)),'')                                                                                         AS INTERNET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAMA)),'')                                                                                         AS NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAMB)),'')                                                                                         AS NAME2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$POBN)),'')                                                                                         AS POBOXNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'')                                                                                         AS ROUTE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTE)),'')                                                                                         AS STATEPROVINCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FOVN)),'')                                                                                         AS TAXNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TELP)),'')                                                                                         AS TELEPHONE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TELX)),'')                                                                                         AS TELEX 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TZID)),'')                                                                                         AS TIMEZONE 
            ,CAST(CASE WHEN T$LVDT<= '1/1/1970' THEN NULL ELSE T$LVDT  END AS DATETIME) AS VERIFICATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PSTC)),'')                                                                                         AS ZIPCODEPOSTALCODE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM130200") }} AS SOURCETABLE 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh. 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDRESS AS ADDRESS, 
        source_data.ADDRESS2 AS ADDRESS2, 
        source_data.ADDRESSCODE AS ADDRESSCODE, 
        source_data.ADDRESSFORMAT AS ADDRESSFORMAT, 
        source_data.CALENDARCODE AS CALENDARCODE, 
        source_data.CITY AS CITY, 
        source_data.CITY2 AS CITY2, 
        source_data.COUNTRY AS COUNTRY, 
        source_data.DATELASTMODIFICATION AS DATELASTMODIFICATION, 
        source_data.E_MAIL AS E_MAIL, 
        source_data.FAX AS FAX, 
        source_data.FRONTOFFICENUMBER AS FRONTOFFICENUMBER, 
        source_data.GEOCODE AS GEOCODE, 
        source_data.HOUSENUMBER AS HOUSENUMBER, 
        source_data.INTERNET AS INTERNET, 
        source_data.NAME AS NAME, 
        source_data.NAME2 AS NAME2, 
        source_data.POBOXNUMBER AS POBOXNUMBER, 
        source_data.ROUTE AS ROUTE, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.STATEPROVINCE AS STATEPROVINCE, 
        source_data.TAXNUMBER AS TAXNUMBER, 
        source_data.TELEPHONE AS TELEPHONE, 
        source_data.TELEX AS TELEX, 
        source_data.TEXT AS TEXT, 
        source_data.TIMEZONE AS TIMEZONE, 
        source_data.VERIFICATIONDATE AS VERIFICATIONDATE, 
        source_data.ZIPCODEPOSTALCODE AS ZIPCODEPOSTALCODE 
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
        ADDRESS,
        ADDRESS2,
        ADDRESSCODE,
        ADDRESSFORMAT,
        CALENDARCODE,
        CITY,
        CITY2,
        COUNTRY,
        cast(DATELASTMODIFICATION as TIMESTAMP_NTZ(9)) as DATELASTMODIFICATION,
        E_MAIL,
        FAX,
        cast(FRONTOFFICENUMBER as NUMBER(15,2)) as FRONTOFFICENUMBER,
        GEOCODE,
        HOUSENUMBER,
        INTERNET,
        NAME,
        NAME2,
        POBOXNUMBER,
        ROUTE,
        SEARCHKEY,
        STATEPROVINCE,
        TAXNUMBER,
        TELEPHONE,
        TELEX,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        TIMEZONE,
        cast(VERIFICATIONDATE as TIMESTAMP_NTZ(9)) as VERIFICATIONDATE,
        ZIPCODEPOSTALCODE
    from transform_data
    )
select * from type_data