/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGEDILOGISTICS_USAREGN_UPSEDI214MESSAGE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGEDILOGISTICS_USAREGN_UPSEDI214MESSAGE.SQL 
-materialized incremental
-alias BAANWAREHOUSINGEDILOGISTICS_USAREGN_UPSEDI214MESSAGE 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:56 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANWAREHOUSINGEDILOGISTICS_USAREGN_UPSEDI214MESSAGE',
    unique_key = ['MESSAGEID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACCT)),'')                                                                                         AS ACCOUNTNO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTN)),'')                                                                                         AS CARRIERTRACKINGNO 
            ,CAST(CASE WHEN T$CRDT<= '1/1/1970' THEN NULL ELSE T$CRDT  END AS DATETIME) AS CREATIONTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ETAN)),'')                                                                                         AS ETACHANGENOTE 
            ,CAST(CASE WHEN T$ETAD<= '1/1/1970' THEN NULL ELSE T$ETAD  END AS DATETIME) AS ETADATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(T$MSID AS BIGINT)                                                                                                              AS MESSAGEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_NUMBER 
            ,T$OORG.CONSTANTDESCRIPTION                                                                                                          AS ORDER_ORIGINDESCRIPTION 
            ,CAST(T$OORG AS INT)                                                                                                                 AS ORDER_ORIGINID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$QUAN AS NUMERIC(15,2))                                                                                                       AS QUANTITYSHIPPED 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,T$STEN.CONSTANTDESCRIPTION                                                                                                          AS SHIPMENTSTATUSDESCRIPTION 
            ,CAST(T$STEN AS INT)                                                                                                                 AS SHIPMENTSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAT)),'')                                                                                         AS STATUSCODE 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS STATUSTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SNJN)),'')                                                                                         AS UPSJOBNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SWAR)),'')                                                                                         AS UPSWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHEDI225201") }} AS SOURCETABLE  
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OORG 
             ON   T$OORG.TABLENAME  = 'WHEDI225' 
              AND T$OORG.COLUMNNAME = 'T$OORG' 
              AND T$OORG.CONSTANT   = SOURCETABLE.T$OORG 
            /*SHIPMENTSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STEN 
             ON   T$STEN.TABLENAME  = 'WHEDI225' 
              AND T$STEN.COLUMNNAME = 'T$STEN' 
              AND T$STEN.CONSTANT   = SOURCETABLE.T$STEN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCOUNTNO AS ACCOUNTNO, 
        source_data.CARRIERTRACKINGNO AS CARRIERTRACKINGNO, 
        source_data.CREATIONTIME AS CREATIONTIME, 
        source_data.ETACHANGENOTE AS ETACHANGENOTE, 
        source_data.ETADATE AS ETADATE, 
        source_data.ITEM AS ITEM, 
        source_data.MESSAGEID AS MESSAGEID, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.ORDER_ORIGINDESCRIPTION AS ORDER_ORIGINDESCRIPTION, 
        source_data.ORDER_ORIGINID AS ORDER_ORIGINID, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.QUANTITYSHIPPED AS QUANTITYSHIPPED, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SHIPMENTSTATUSDESCRIPTION AS SHIPMENTSTATUSDESCRIPTION, 
        source_data.SHIPMENTSTATUSID AS SHIPMENTSTATUSID, 
        source_data.STATUSCODE AS STATUSCODE, 
        source_data.STATUSTIME AS STATUSTIME, 
        source_data.UPSJOBNUMBER AS UPSJOBNUMBER, 
        source_data.UPSWAREHOUSE AS UPSWAREHOUSE, 
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
        cast(ACCOUNTNO as VARCHAR(10)) as ACCOUNTNO,
        cast(CARRIERTRACKINGNO as VARCHAR(30)) as CARRIERTRACKINGNO,
        cast(CREATIONTIME as TIMESTAMP_NTZ(9)) as CREATIONTIME,
        cast(ETACHANGENOTE as VARCHAR(100)) as ETACHANGENOTE,
        cast(ETADATE as TIMESTAMP_NTZ(9)) as ETADATE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(MESSAGEID as NUMBER(38,0)) as MESSAGEID,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORDER_ORIGINDESCRIPTION as VARCHAR(16777216)) as ORDER_ORIGINDESCRIPTION,
        cast(ORDER_ORIGINID as NUMBER(38,0)) as ORDER_ORIGINID,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(QUANTITYSHIPPED as NUMBER(15,2)) as QUANTITYSHIPPED,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SHIPMENTSTATUSDESCRIPTION as VARCHAR(16777216)) as SHIPMENTSTATUSDESCRIPTION,
        cast(SHIPMENTSTATUSID as NUMBER(38,0)) as SHIPMENTSTATUSID,
        cast(STATUSCODE as VARCHAR(2)) as STATUSCODE,
        cast(STATUSTIME as TIMESTAMP_NTZ(9)) as STATUSTIME,
        cast(UPSJOBNUMBER as VARCHAR(30)) as UPSJOBNUMBER,
        cast(UPSWAREHOUSE as VARCHAR(6)) as UPSWAREHOUSE,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data