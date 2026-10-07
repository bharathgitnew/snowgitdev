/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_BUNDLECONTRACTTERMS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_BUNDLECONTRACTTERMS.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_BUNDLECONTRACTTERMS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANSERVICECONTRACTMANAGEMENT_BUNDLECONTRACTTERMS',
    unique_key = ['_COMPANYID',
    'SEQUENCENUMBER',
    'SERVICECONTRACT']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,CAST("T$AMNT$1" AS NUMERIC(15,2))                                         AS AMOUNT1 
            ,CAST("T$AMNT$10" AS NUMERIC(15,2))                                        AS AMOUNT10 
            ,CAST("T$AMNT$2" AS NUMERIC(15,2))                                         AS AMOUNT2 
            ,CAST("T$AMNT$3" AS NUMERIC(15,2))                                         AS AMOUNT3 
            ,CAST("T$AMNT$4" AS NUMERIC(15,2))                                         AS AMOUNT4 
            ,CAST("T$AMNT$5" AS NUMERIC(15,2))                                         AS AMOUNT5 
            ,CAST("T$AMNT$6" AS NUMERIC(15,2))                                         AS AMOUNT6 
            ,CAST("T$AMNT$7" AS NUMERIC(15,2))                                         AS AMOUNT7 
            ,CAST("T$AMNT$8" AS NUMERIC(15,2))                                         AS AMOUNT8 
            ,CAST("T$AMNT$9" AS NUMERIC(15,2))                                         AS AMOUNT9 
            ,CAST(CASE WHEN T$EFDT<= '1/1/1970' THEN NULL ELSE T$EFDT END AS DATE) AS CONTRACTEFFECTIVEDATE 
            ,CAST(CASE WHEN T$EXDT<= '1/1/1970' THEN NULL ELSE T$EXDT END AS DATE) AS CONTRACTEXPIRYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$1")),'')                           AS CONTRACTTERM1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$10")),'')                          AS CONTRACTTERM10 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$2")),'')                           AS CONTRACTTERM2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$3")),'')                           AS CONTRACTTERM3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$4")),'')                           AS CONTRACTTERM4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$5")),'')                           AS CONTRACTTERM5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$6")),'')                           AS CONTRACTTERM6 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$7")),'')                           AS CONTRACTTERM7 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$8")),'')                           AS CONTRACTTERM8 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTP$9")),'')                           AS CONTRACTTERM9 
            ,CAST(T$SUHR AS BIGINT)                                                  AS FLEXSUPPORTHOURS 
            ,CAST("T$PERC$1" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_1 
            ,CAST("T$PERC$10" AS NUMERIC(15,2))                                        AS INSTALLMENT_percent_10 
            ,CAST("T$PERC$2" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_2 
            ,CAST("T$PERC$3" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_3 
            ,CAST("T$PERC$4" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_4 
            ,CAST("T$PERC$5" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_5 
            ,CAST("T$PERC$6" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_6 
            ,CAST("T$PERC$7" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_7 
            ,CAST("T$PERC$8" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_8 
            ,CAST("T$PERC$9" AS NUMERIC(15,2))                                         AS INSTALLMENT_percent_9 
            ,CAST(T$NOFE AS BIGINT)                                                  AS NOOFFES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$1")),'')                           AS PRODUCTTYPE1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$10")),'')                          AS PRODUCTTYPE10 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$2")),'')                           AS PRODUCTTYPE2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$3")),'')                           AS PRODUCTTYPE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$4")),'')                           AS PRODUCTTYPE4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$5")),'')                           AS PRODUCTTYPE5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$6")),'')                           AS PRODUCTTYPE6 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$7")),'')                           AS PRODUCTTYPE7 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$8")),'')                           AS PRODUCTTYPE8 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PTYP$9")),'')                           AS PRODUCTTYPE9 
            ,CAST(T$SEQN AS INT)                                                     AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                             AS SERVICECONTRACT 
            ,T$STAT.CONSTANTDESCRIPTION                                              AS STATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                     AS STATUSID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM900201") }} AS SOURCETABLE  
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'TSCTM900' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNT1 AS AMOUNT1, 
        source_data.AMOUNT10 AS AMOUNT10, 
        source_data.AMOUNT2 AS AMOUNT2, 
        source_data.AMOUNT3 AS AMOUNT3, 
        source_data.AMOUNT4 AS AMOUNT4, 
        source_data.AMOUNT5 AS AMOUNT5, 
        source_data.AMOUNT6 AS AMOUNT6, 
        source_data.AMOUNT7 AS AMOUNT7, 
        source_data.AMOUNT8 AS AMOUNT8, 
        source_data.AMOUNT9 AS AMOUNT9, 
        source_data.CONTRACTEFFECTIVEDATE AS CONTRACTEFFECTIVEDATE, 
        source_data.CONTRACTEXPIRYDATE AS CONTRACTEXPIRYDATE, 
        source_data.CONTRACTTERM1 AS CONTRACTTERM1, 
        source_data.CONTRACTTERM10 AS CONTRACTTERM10, 
        source_data.CONTRACTTERM2 AS CONTRACTTERM2, 
        source_data.CONTRACTTERM3 AS CONTRACTTERM3, 
        source_data.CONTRACTTERM4 AS CONTRACTTERM4, 
        source_data.CONTRACTTERM5 AS CONTRACTTERM5, 
        source_data.CONTRACTTERM6 AS CONTRACTTERM6, 
        source_data.CONTRACTTERM7 AS CONTRACTTERM7, 
        source_data.CONTRACTTERM8 AS CONTRACTTERM8, 
        source_data.CONTRACTTERM9 AS CONTRACTTERM9, 
        source_data.FLEXSUPPORTHOURS AS FLEXSUPPORTHOURS, 
        source_data.INSTALLMENT_PERCENT_1 AS INSTALLMENT_PERCENT_1, 
        source_data.INSTALLMENT_PERCENT_10 AS INSTALLMENT_PERCENT_10, 
        source_data.INSTALLMENT_PERCENT_2 AS INSTALLMENT_PERCENT_2, 
        source_data.INSTALLMENT_PERCENT_3 AS INSTALLMENT_PERCENT_3, 
        source_data.INSTALLMENT_PERCENT_4 AS INSTALLMENT_PERCENT_4, 
        source_data.INSTALLMENT_PERCENT_5 AS INSTALLMENT_PERCENT_5, 
        source_data.INSTALLMENT_PERCENT_6 AS INSTALLMENT_PERCENT_6, 
        source_data.INSTALLMENT_PERCENT_7 AS INSTALLMENT_PERCENT_7, 
        source_data.INSTALLMENT_PERCENT_8 AS INSTALLMENT_PERCENT_8, 
        source_data.INSTALLMENT_PERCENT_9 AS INSTALLMENT_PERCENT_9, 
        source_data.NOOFFES AS NOOFFES, 
        source_data.PRODUCTTYPE1 AS PRODUCTTYPE1, 
        source_data.PRODUCTTYPE10 AS PRODUCTTYPE10, 
        source_data.PRODUCTTYPE2 AS PRODUCTTYPE2, 
        source_data.PRODUCTTYPE3 AS PRODUCTTYPE3, 
        source_data.PRODUCTTYPE4 AS PRODUCTTYPE4, 
        source_data.PRODUCTTYPE5 AS PRODUCTTYPE5, 
        source_data.PRODUCTTYPE6 AS PRODUCTTYPE6, 
        source_data.PRODUCTTYPE7 AS PRODUCTTYPE7, 
        source_data.PRODUCTTYPE8 AS PRODUCTTYPE8, 
        source_data.PRODUCTTYPE9 AS PRODUCTTYPE9, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SERVICECONTRACT AS SERVICECONTRACT, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AMOUNT1 as NUMBER(15,2)) as AMOUNT1,
        cast(AMOUNT10 as NUMBER(15,2)) as AMOUNT10,
        cast(AMOUNT2 as NUMBER(15,2)) as AMOUNT2,
        cast(AMOUNT3 as NUMBER(15,2)) as AMOUNT3,
        cast(AMOUNT4 as NUMBER(15,2)) as AMOUNT4,
        cast(AMOUNT5 as NUMBER(15,2)) as AMOUNT5,
        cast(AMOUNT6 as NUMBER(15,2)) as AMOUNT6,
        cast(AMOUNT7 as NUMBER(15,2)) as AMOUNT7,
        cast(AMOUNT8 as NUMBER(15,2)) as AMOUNT8,
        cast(AMOUNT9 as NUMBER(15,2)) as AMOUNT9,
        cast(CONTRACTEFFECTIVEDATE as DATE) as CONTRACTEFFECTIVEDATE,
        cast(CONTRACTEXPIRYDATE as DATE) as CONTRACTEXPIRYDATE,
        cast(CONTRACTTERM1 as VARCHAR(3)) as CONTRACTTERM1,
        cast(CONTRACTTERM10 as VARCHAR(3)) as CONTRACTTERM10,
        cast(CONTRACTTERM2 as VARCHAR(3)) as CONTRACTTERM2,
        cast(CONTRACTTERM3 as VARCHAR(3)) as CONTRACTTERM3,
        cast(CONTRACTTERM4 as VARCHAR(3)) as CONTRACTTERM4,
        cast(CONTRACTTERM5 as VARCHAR(3)) as CONTRACTTERM5,
        cast(CONTRACTTERM6 as VARCHAR(3)) as CONTRACTTERM6,
        cast(CONTRACTTERM7 as VARCHAR(3)) as CONTRACTTERM7,
        cast(CONTRACTTERM8 as VARCHAR(3)) as CONTRACTTERM8,
        cast(CONTRACTTERM9 as VARCHAR(3)) as CONTRACTTERM9,
        cast(FLEXSUPPORTHOURS as NUMBER(38,0)) as FLEXSUPPORTHOURS,
        cast(INSTALLMENT_PERCENT_1 as NUMBER(15,2)) as INSTALLMENT_PERCENT_1,
        cast(INSTALLMENT_PERCENT_10 as NUMBER(15,2)) as INSTALLMENT_PERCENT_10,
        cast(INSTALLMENT_PERCENT_2 as NUMBER(15,2)) as INSTALLMENT_PERCENT_2,
        cast(INSTALLMENT_PERCENT_3 as NUMBER(15,2)) as INSTALLMENT_PERCENT_3,
        cast(INSTALLMENT_PERCENT_4 as NUMBER(15,2)) as INSTALLMENT_PERCENT_4,
        cast(INSTALLMENT_PERCENT_5 as NUMBER(15,2)) as INSTALLMENT_PERCENT_5,
        cast(INSTALLMENT_PERCENT_6 as NUMBER(15,2)) as INSTALLMENT_PERCENT_6,
        cast(INSTALLMENT_PERCENT_7 as NUMBER(15,2)) as INSTALLMENT_PERCENT_7,
        cast(INSTALLMENT_PERCENT_8 as NUMBER(15,2)) as INSTALLMENT_PERCENT_8,
        cast(INSTALLMENT_PERCENT_9 as NUMBER(15,2)) as INSTALLMENT_PERCENT_9,
        cast(NOOFFES as NUMBER(38,0)) as NOOFFES,
        cast(PRODUCTTYPE1 as VARCHAR(6)) as PRODUCTTYPE1,
        cast(PRODUCTTYPE10 as VARCHAR(6)) as PRODUCTTYPE10,
        cast(PRODUCTTYPE2 as VARCHAR(6)) as PRODUCTTYPE2,
        cast(PRODUCTTYPE3 as VARCHAR(6)) as PRODUCTTYPE3,
        cast(PRODUCTTYPE4 as VARCHAR(6)) as PRODUCTTYPE4,
        cast(PRODUCTTYPE5 as VARCHAR(6)) as PRODUCTTYPE5,
        cast(PRODUCTTYPE6 as VARCHAR(6)) as PRODUCTTYPE6,
        cast(PRODUCTTYPE7 as VARCHAR(6)) as PRODUCTTYPE7,
        cast(PRODUCTTYPE8 as VARCHAR(6)) as PRODUCTTYPE8,
        cast(PRODUCTTYPE9 as VARCHAR(6)) as PRODUCTTYPE9,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SERVICECONTRACT as VARCHAR(9)) as SERVICECONTRACT,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data