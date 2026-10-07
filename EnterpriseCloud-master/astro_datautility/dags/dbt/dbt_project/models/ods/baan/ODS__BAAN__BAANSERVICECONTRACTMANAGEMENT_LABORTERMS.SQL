/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_LABORTERMS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_LABORTERMS.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_LABORTERMS 
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
    alias='BAANSERVICECONTRACTMANAGEMENT_LABORTERMS',
    unique_key = ['CONFIGURATION',
    'CONTRACTSEQNO',
    'COSTTYPEID',
    'COVERAGETERMNUMBER',
    'SERVICETYPE',
    'TERMID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,CAST("T$ALCO$1" AS NUMERIC(15,2))             AS ALLOCATEDCOSTS1 
            ,CAST("T$ALCO$2" AS NUMERIC(15,2))             AS ALLOCATEDCOSTS2 
            ,CAST("T$ALCO$3" AS NUMERIC(15,2))             AS ALLOCATEDCOSTS3 
            ,CAST(T$ALHR AS NUMERIC(15,2))               AS ALLOCATEDHOURS 
            ,CAST(T$ALSA AS NUMERIC(15,2))               AS ALLOCATEDSALES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'') AS CONFIGURATION 
            ,CAST(T$CSEQ AS INT)                         AS CONTRACTSEQNO 
            ,CAST("T$CAMT$1" AS NUMERIC(15,2))             AS COSTAMOUNT1 
            ,CAST("T$CAMT$2" AS NUMERIC(15,2))             AS COSTAMOUNT2 
            ,CAST("T$CAMT$3" AS NUMERIC(15,2))             AS COSTAMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCMP)),'') AS COSTCOMPONENT 
            ,CAST("T$WRAC$1" AS NUMERIC(15,2))             AS COSTRATE1 
            ,CAST("T$WRAC$2" AS NUMERIC(15,2))             AS COSTRATE2 
            ,CAST("T$WRAC$3" AS NUMERIC(15,2))             AS COSTRATE3 
            ,T$COTP.CONSTANTDESCRIPTION                  AS COSTTYPEDESCRIPTION 
            ,CAST(T$COTP AS INT)                         AS COSTTYPEID 
            ,CAST(T$NRBT AS INT)                         AS COVERAGETERMNUMBER 
            ,CAST(T$NRHR AS NUMERIC(15,2))               AS COVEREDTIME 
            ,T$DSPC.CONSTANTDESCRIPTION                  AS DERIVEDFROMSPCDESCRIPTION 
            ,CAST(T$DSPC AS INT)                         AS DERIVEDFROMSPCID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHLT)),'') AS HOURLYLABORTYPE 
            ,T$INCL.CONSTANTDESCRIPTION                  AS INCLUDEDDESCRIPTION 
            ,CAST(T$INCL AS INT)                         AS INCLUDEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLRT)),'') AS LABORRATE 
            ,CAST(T$AMNT AS NUMERIC(15,2))               AS SALESAMOUNT 
            ,CAST(T$WRAS AS NUMERIC(15,2))               AS SALESRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTP)),'') AS SERVICETYPE 
            ,CAST("T$SPCO$1" AS NUMERIC(15,2))             AS SPENTCOSTS1 
            ,CAST("T$SPCO$2" AS NUMERIC(15,2))             AS SPENTCOSTS2 
            ,CAST("T$SPCO$3" AS NUMERIC(15,2))             AS SPENTCOSTS3 
            ,CAST(T$SPHR AS NUMERIC(15,2))               AS SPENTHOURS 
            ,CAST(T$SPSA AS NUMERIC(15,2))               AS SPENTSALES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTSK)),'') AS TASK 
            ,CAST(T$TERM AS BIGINT)                      AS TERMID 
            ,SOURCETABLE.T$TXTA   /* TEXT */             AS TEXT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM132201") }} AS SOURCETABLE  
            /*COSTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COTP 
             ON   T$COTP.TABLENAME  = 'TSCTM132' 
              AND T$COTP.COLUMNNAME = 'T$COTP' 
              AND T$COTP.CONSTANT   = SOURCETABLE.T$COTP 
            /*DERIVEDFROMSPC*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DSPC 
             ON   T$DSPC.TABLENAME  = 'TSCTM132' 
              AND T$DSPC.COLUMNNAME = 'T$DSPC' 
              AND T$DSPC.CONSTANT   = SOURCETABLE.T$DSPC 
            /*INCLUDED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INCL 
             ON   T$INCL.TABLENAME  = 'TSCTM132' 
              AND T$INCL.COLUMNNAME = 'T$INCL' 
              AND T$INCL.CONSTANT   = SOURCETABLE.T$INCL 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ALLOCATEDCOSTS1 AS ALLOCATEDCOSTS1, 
        source_data.ALLOCATEDCOSTS2 AS ALLOCATEDCOSTS2, 
        source_data.ALLOCATEDCOSTS3 AS ALLOCATEDCOSTS3, 
        source_data.ALLOCATEDHOURS AS ALLOCATEDHOURS, 
        source_data.ALLOCATEDSALES AS ALLOCATEDSALES, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTRACTSEQNO AS CONTRACTSEQNO, 
        source_data.COSTAMOUNT1 AS COSTAMOUNT1, 
        source_data.COSTAMOUNT2 AS COSTAMOUNT2, 
        source_data.COSTAMOUNT3 AS COSTAMOUNT3, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.COSTRATE1 AS COSTRATE1, 
        source_data.COSTRATE2 AS COSTRATE2, 
        source_data.COSTRATE3 AS COSTRATE3, 
        source_data.COSTTYPEDESCRIPTION AS COSTTYPEDESCRIPTION, 
        source_data.COSTTYPEID AS COSTTYPEID, 
        source_data.COVERAGETERMNUMBER AS COVERAGETERMNUMBER, 
        source_data.COVEREDTIME AS COVEREDTIME, 
        source_data.DERIVEDFROMSPCDESCRIPTION AS DERIVEDFROMSPCDESCRIPTION, 
        source_data.DERIVEDFROMSPCID AS DERIVEDFROMSPCID, 
        source_data.HOURLYLABORTYPE AS HOURLYLABORTYPE, 
        source_data.INCLUDEDDESCRIPTION AS INCLUDEDDESCRIPTION, 
        source_data.INCLUDEDID AS INCLUDEDID, 
        source_data.LABORRATE AS LABORRATE, 
        source_data.SALESAMOUNT AS SALESAMOUNT, 
        source_data.SALESRATE AS SALESRATE, 
        source_data.SERVICETYPE AS SERVICETYPE, 
        source_data.SPENTCOSTS1 AS SPENTCOSTS1, 
        source_data.SPENTCOSTS2 AS SPENTCOSTS2, 
        source_data.SPENTCOSTS3 AS SPENTCOSTS3, 
        source_data.SPENTHOURS AS SPENTHOURS, 
        source_data.SPENTSALES AS SPENTSALES, 
        source_data.TASK AS TASK, 
        source_data.TERMID AS TERMID, 
        source_data.TEXT AS TEXT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ALLOCATEDCOSTS1 as NUMBER(15,2)) as ALLOCATEDCOSTS1,
        cast(ALLOCATEDCOSTS2 as NUMBER(15,2)) as ALLOCATEDCOSTS2,
        cast(ALLOCATEDCOSTS3 as NUMBER(15,2)) as ALLOCATEDCOSTS3,
        cast(ALLOCATEDHOURS as NUMBER(15,2)) as ALLOCATEDHOURS,
        cast(ALLOCATEDSALES as NUMBER(15,2)) as ALLOCATEDSALES,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTRACTSEQNO as NUMBER(38,0)) as CONTRACTSEQNO,
        cast(COSTAMOUNT1 as NUMBER(15,2)) as COSTAMOUNT1,
        cast(COSTAMOUNT2 as NUMBER(15,2)) as COSTAMOUNT2,
        cast(COSTAMOUNT3 as NUMBER(15,2)) as COSTAMOUNT3,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(COSTRATE1 as NUMBER(15,2)) as COSTRATE1,
        cast(COSTRATE2 as NUMBER(15,2)) as COSTRATE2,
        cast(COSTRATE3 as NUMBER(15,2)) as COSTRATE3,
        cast(COSTTYPEDESCRIPTION as VARCHAR(16777216)) as COSTTYPEDESCRIPTION,
        cast(COSTTYPEID as NUMBER(38,0)) as COSTTYPEID,
        cast(COVERAGETERMNUMBER as NUMBER(38,0)) as COVERAGETERMNUMBER,
        cast(COVEREDTIME as NUMBER(15,2)) as COVEREDTIME,
        cast(DERIVEDFROMSPCDESCRIPTION as VARCHAR(16777216)) as DERIVEDFROMSPCDESCRIPTION,
        cast(DERIVEDFROMSPCID as NUMBER(38,0)) as DERIVEDFROMSPCID,
        cast(HOURLYLABORTYPE as VARCHAR(3)) as HOURLYLABORTYPE,
        cast(INCLUDEDDESCRIPTION as VARCHAR(16777216)) as INCLUDEDDESCRIPTION,
        cast(INCLUDEDID as NUMBER(38,0)) as INCLUDEDID,
        cast(LABORRATE as VARCHAR(3)) as LABORRATE,
        cast(SALESAMOUNT as NUMBER(15,2)) as SALESAMOUNT,
        cast(SALESRATE as NUMBER(15,2)) as SALESRATE,
        cast(SERVICETYPE as VARCHAR(3)) as SERVICETYPE,
        cast(SPENTCOSTS1 as NUMBER(15,2)) as SPENTCOSTS1,
        cast(SPENTCOSTS2 as NUMBER(15,2)) as SPENTCOSTS2,
        cast(SPENTCOSTS3 as NUMBER(15,2)) as SPENTCOSTS3,
        cast(SPENTHOURS as NUMBER(15,2)) as SPENTHOURS,
        cast(SPENTSALES as NUMBER(15,2)) as SPENTSALES,
        cast(TASK as VARCHAR(8)) as TASK,
        cast(TERMID as NUMBER(38,0)) as TERMID,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data