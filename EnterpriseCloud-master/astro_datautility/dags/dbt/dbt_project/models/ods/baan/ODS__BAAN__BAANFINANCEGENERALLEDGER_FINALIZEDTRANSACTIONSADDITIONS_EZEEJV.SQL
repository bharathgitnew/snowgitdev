/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONSADDITIONS_EZEEJV.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONSADDITIONS_EZEEJV.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONSADDITIONS_EZEEJV 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:53 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONSADDITIONS_EZEEJV',
    unique_key = ['BACKGROUNDSEQUENCENO',
    'DOCUMENT',
    'LINENUMBER',
    'SEQUENCENUMBER',
    'TRANSACTIONTYPE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$OSRN AS TINYINT)                                                                                                             AS BACKGROUNDSEQUENCENO 
            ,CAST(CASE WHEN T$SDAT<= '1/1/1970' THEN NULL ELSE T$SDAT  END AS DATETIME) AS DATEMODIFIED 
            ,CAST(T$ODOC AS BIGINT)                                                                                                              AS DOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOBUSINESSPARTNER 
            ,CAST(T$OLIN AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSER)),'')                                                                                         AS MACHINESRNO 
            ,CAST(T$OSRL AS BIGINT)                                                                                                              AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                                                                                         AS SERVICECONTRACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTYP)),'')                                                                                         AS TRANSACTIONTYPE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD911200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$OSRN AS TINYINT)                                                                                                             AS BACKGROUNDSEQUENCENO 
            ,CAST(CASE WHEN T$SDAT<= '1/1/1970' THEN NULL ELSE T$SDAT  END AS DATETIME) AS DATEMODIFIED 
            ,CAST(T$ODOC AS BIGINT)                                                                                                              AS DOCUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOBUSINESSPARTNER 
            ,CAST(T$OLIN AS BIGINT)                                                                                                              AS LINENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSER)),'')                                                                                         AS MACHINESRNO 
            ,CAST(T$OSRL AS BIGINT)                                                                                                              AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                                                                                         AS SERVICECONTRACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTYP)),'')                                                                                         AS TRANSACTIONTYPE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD911201") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BACKGROUNDSEQUENCENO AS BACKGROUNDSEQUENCENO, 
        source_data.DATEMODIFIED AS DATEMODIFIED, 
        source_data.DOCUMENT AS DOCUMENT, 
        source_data.INVOICETOBUSINESSPARTNER AS INVOICETOBUSINESSPARTNER, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.MACHINESRNO AS MACHINESRNO, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SERVICECONTRACT AS SERVICECONTRACT, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(BACKGROUNDSEQUENCENO as NUMBER(38,0)) as BACKGROUNDSEQUENCENO,
        cast(DATEMODIFIED as TIMESTAMP_NTZ(9)) as DATEMODIFIED,
        cast(DOCUMENT as NUMBER(38,0)) as DOCUMENT,
        cast(INVOICETOBUSINESSPARTNER as VARCHAR(9)) as INVOICETOBUSINESSPARTNER,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(MACHINESRNO as VARCHAR(20)) as MACHINESRNO,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SERVICECONTRACT as VARCHAR(9)) as SERVICECONTRACT,
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
        cast(TRANSACTIONTYPE as VARCHAR(3)) as TRANSACTIONTYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data