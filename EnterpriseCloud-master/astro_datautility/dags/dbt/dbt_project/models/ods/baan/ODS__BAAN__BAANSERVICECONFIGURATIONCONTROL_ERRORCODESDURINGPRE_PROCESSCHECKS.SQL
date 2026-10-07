/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONFIGURATIONCONTROL_ERRORCODESDURINGPRE_PROCESSCHECKS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONFIGURATIONCONTROL_ERRORCODESDURINGPRE_PROCESSCHECKS.SQL 
-materialized incremental
-alias BAANSERVICECONFIGURATIONCONTROL_ERRORCODESDURINGPRE_PROCESSCHECKS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:54 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANSERVICECONFIGURATIONCONTROL_ERRORCODESDURINGPRE_PROCESSCHECKS',
    unique_key = ['TRANSACTIONID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                   AS _CAPTUREDATETIME 
            ,201                                              AS _COMPANYID 
            ,CAST("T$ERCD$1" AS INT)                          AS ERRORCODE1 
            ,CAST("T$ERCD$10" AS INT)                         AS ERRORCODE10 
            ,CAST("T$ERCD$11" AS INT)                         AS ERRORCODE11 
            ,CAST("T$ERCD$12" AS INT)                         AS ERRORCODE12 
            ,CAST("T$ERCD$13" AS INT)                         AS ERRORCODE13 
            ,CAST("T$ERCD$14" AS INT)                         AS ERRORCODE14 
            ,CAST("T$ERCD$15" AS INT)                         AS ERRORCODE15 
            ,CAST("T$ERCD$2" AS INT)                          AS ERRORCODE2 
            ,CAST("T$ERCD$3" AS INT)                          AS ERRORCODE3 
            ,CAST("T$ERCD$4" AS INT)                          AS ERRORCODE4 
            ,CAST("T$ERCD$5" AS INT)                          AS ERRORCODE5 
            ,CAST("T$ERCD$6" AS INT)                          AS ERRORCODE6 
            ,CAST("T$ERCD$7" AS INT)                          AS ERRORCODE7 
            ,CAST("T$ERCD$8" AS INT)                          AS ERRORCODE8 
            ,CAST("T$ERCD$9" AS INT)                          AS ERRORCODE9 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$1")),'')  AS ERRORMESSAGE1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$10")),'') AS ERRORMESSAGE10 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$11")),'') AS ERRORMESSAGE11 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$12")),'') AS ERRORMESSAGE12 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$13")),'') AS ERRORMESSAGE13 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$14")),'') AS ERRORMESSAGE14 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$15")),'') AS ERRORMESSAGE15 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$2")),'')  AS ERRORMESSAGE2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$3")),'')  AS ERRORMESSAGE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$4")),'')  AS ERRORMESSAGE4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$5")),'')  AS ERRORMESSAGE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$6")),'')  AS ERRORMESSAGE6 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$7")),'')  AS ERRORMESSAGE7 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$8")),'')  AS ERRORMESSAGE8 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ERDS$9")),'')  AS ERRORMESSAGE9 
            ,CAST("T$TRID$U" AS BIGINT)                       AS TRANSACTIONID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCFG909201") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ERRORCODE1 AS ERRORCODE1, 
        source_data.ERRORCODE10 AS ERRORCODE10, 
        source_data.ERRORCODE11 AS ERRORCODE11, 
        source_data.ERRORCODE12 AS ERRORCODE12, 
        source_data.ERRORCODE13 AS ERRORCODE13, 
        source_data.ERRORCODE14 AS ERRORCODE14, 
        source_data.ERRORCODE15 AS ERRORCODE15, 
        source_data.ERRORCODE2 AS ERRORCODE2, 
        source_data.ERRORCODE3 AS ERRORCODE3, 
        source_data.ERRORCODE4 AS ERRORCODE4, 
        source_data.ERRORCODE5 AS ERRORCODE5, 
        source_data.ERRORCODE6 AS ERRORCODE6, 
        source_data.ERRORCODE7 AS ERRORCODE7, 
        source_data.ERRORCODE8 AS ERRORCODE8, 
        source_data.ERRORCODE9 AS ERRORCODE9, 
        source_data.ERRORMESSAGE1 AS ERRORMESSAGE1, 
        source_data.ERRORMESSAGE10 AS ERRORMESSAGE10, 
        source_data.ERRORMESSAGE11 AS ERRORMESSAGE11, 
        source_data.ERRORMESSAGE12 AS ERRORMESSAGE12, 
        source_data.ERRORMESSAGE13 AS ERRORMESSAGE13, 
        source_data.ERRORMESSAGE14 AS ERRORMESSAGE14, 
        source_data.ERRORMESSAGE15 AS ERRORMESSAGE15, 
        source_data.ERRORMESSAGE2 AS ERRORMESSAGE2, 
        source_data.ERRORMESSAGE3 AS ERRORMESSAGE3, 
        source_data.ERRORMESSAGE4 AS ERRORMESSAGE4, 
        source_data.ERRORMESSAGE5 AS ERRORMESSAGE5, 
        source_data.ERRORMESSAGE6 AS ERRORMESSAGE6, 
        source_data.ERRORMESSAGE7 AS ERRORMESSAGE7, 
        source_data.ERRORMESSAGE8 AS ERRORMESSAGE8, 
        source_data.ERRORMESSAGE9 AS ERRORMESSAGE9, 
        source_data.TRANSACTIONID AS TRANSACTIONID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ERRORCODE1 as NUMBER(38,0)) as ERRORCODE1,
        cast(ERRORCODE10 as NUMBER(38,0)) as ERRORCODE10,
        cast(ERRORCODE11 as NUMBER(38,0)) as ERRORCODE11,
        cast(ERRORCODE12 as NUMBER(38,0)) as ERRORCODE12,
        cast(ERRORCODE13 as NUMBER(38,0)) as ERRORCODE13,
        cast(ERRORCODE14 as NUMBER(38,0)) as ERRORCODE14,
        cast(ERRORCODE15 as NUMBER(38,0)) as ERRORCODE15,
        cast(ERRORCODE2 as NUMBER(38,0)) as ERRORCODE2,
        cast(ERRORCODE3 as NUMBER(38,0)) as ERRORCODE3,
        cast(ERRORCODE4 as NUMBER(38,0)) as ERRORCODE4,
        cast(ERRORCODE5 as NUMBER(38,0)) as ERRORCODE5,
        cast(ERRORCODE6 as NUMBER(38,0)) as ERRORCODE6,
        cast(ERRORCODE7 as NUMBER(38,0)) as ERRORCODE7,
        cast(ERRORCODE8 as NUMBER(38,0)) as ERRORCODE8,
        cast(ERRORCODE9 as NUMBER(38,0)) as ERRORCODE9,
        cast(ERRORMESSAGE1 as VARCHAR(100)) as ERRORMESSAGE1,
        cast(ERRORMESSAGE10 as VARCHAR(100)) as ERRORMESSAGE10,
        cast(ERRORMESSAGE11 as VARCHAR(100)) as ERRORMESSAGE11,
        cast(ERRORMESSAGE12 as VARCHAR(100)) as ERRORMESSAGE12,
        cast(ERRORMESSAGE13 as VARCHAR(100)) as ERRORMESSAGE13,
        cast(ERRORMESSAGE14 as VARCHAR(100)) as ERRORMESSAGE14,
        cast(ERRORMESSAGE15 as VARCHAR(100)) as ERRORMESSAGE15,
        cast(ERRORMESSAGE2 as VARCHAR(100)) as ERRORMESSAGE2,
        cast(ERRORMESSAGE3 as VARCHAR(100)) as ERRORMESSAGE3,
        cast(ERRORMESSAGE4 as VARCHAR(100)) as ERRORMESSAGE4,
        cast(ERRORMESSAGE5 as VARCHAR(100)) as ERRORMESSAGE5,
        cast(ERRORMESSAGE6 as VARCHAR(100)) as ERRORMESSAGE6,
        cast(ERRORMESSAGE7 as VARCHAR(100)) as ERRORMESSAGE7,
        cast(ERRORMESSAGE8 as VARCHAR(100)) as ERRORMESSAGE8,
        cast(ERRORMESSAGE9 as VARCHAR(100)) as ERRORMESSAGE9,
        cast(TRANSACTIONID as NUMBER(38,0)) as TRANSACTIONID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data