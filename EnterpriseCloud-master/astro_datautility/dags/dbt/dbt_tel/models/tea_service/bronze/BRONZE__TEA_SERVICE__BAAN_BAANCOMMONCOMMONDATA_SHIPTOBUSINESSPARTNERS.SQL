/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_SHIPTOBUSINESSPARTNERS.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_SHIPTOBUSINESSPARTNERS.SQL
-materialized incremental
-alias BAANCOMMONCOMMONDATA_SHIPTOBUSINESSPARTNERS
-incremental_strategy insert_overwrite
-envVariable <<LZ>>
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no
model file generated on: 1/17/2022 10:15:18 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='BAAN_BAANCOMMONCOMMONDATA_SHIPTOBUSINESSPARTNERS',
    unique_key = []
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
    ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDARCODE
    ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                                                                         AS CONTACTCODE
    ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME) AS ENDDATE

    ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                         AS FORWARDINGAGENT
    ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                         AS LANGUAGE
    ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEY
    ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER
    ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER

    ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS STARTDATE
    ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT
    ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE
    --
    FROM {{ source("BAAN_ORACLE_LIVE","TTCCOM111200") }} AS SOURCETABLE

    /*BUSINESSPARTNERSTATUS*/
    LEFT OUTER JOIN  {{ source("BAAN", "ENUMERATIONS") }} AS T$BPST
     ON   T$BPST.TABLENAME  = 'TCCOM111'
      AND T$BPST.COLUMNNAME = 'T$BPST'
      AND T$BPST.CONSTANT   = SOURCETABLE.T$BPST
    )
,transform_data as
(
    SELECT
    source_data.ADDRESSCODE,
    source_data.BUSINESSPARTNERSIGNAL,
    source_data.BUSINESSPARTNERSTATUSDESCRIPTION,
    source_data.BUSINESSPARTNERSTATUSID,
    source_data.BUSINESSPARTNERTYPE,
    source_data.CALENDARCODE,
    source_data.CONTACTCODE,
    source_data.ENDDATE,
    source_data.FORWARDINGAGENT,
    source_data.LANGUAGE,
    source_data.SEARCHKEY,
    source_data.SHIPTOBUSINESSPARTNER,
    source_data.SOLDTOBUSINESSPARTNER,
    source_data.STARTDATE,
    source_data.TEXT,
    source_data.WAREHOUSE,
    source_data._CAPTUREDATETIME,
    source_data._COMPANYID
    ,'{{ invocation_id }}' AS AUDIT_LOG_ID
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
        cast(CALENDARCODE as VARCHAR(9)) as CALENDARCODE,
        cast(CONTACTCODE as VARCHAR(9)) as CONTACTCODE,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(FORWARDINGAGENT as VARCHAR(3)) as FORWARDINGAGENT,
        cast(LANGUAGE as VARCHAR(3)) as LANGUAGE,
        cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
        cast(SHIPTOBUSINESSPARTNER as VARCHAR(9)) as SHIPTOBUSINESSPARTNER,
        cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data