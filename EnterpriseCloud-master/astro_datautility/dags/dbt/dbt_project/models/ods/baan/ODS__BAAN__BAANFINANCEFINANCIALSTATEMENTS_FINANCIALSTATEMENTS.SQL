/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTS.SQL 
-materialized incremental
-alias BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:52 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTS',
    unique_key = ['_COMPANYID',
    'FINANCIALSTATEMENT']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,200                                                                       AS _COMPANYID 
            ,CAST(CASE WHEN T$DATC<= '1/1/1970' THEN NULL ELSE T$DATC END AS DATE) AS DATECREATED 
            ,CAST(CASE WHEN T$DATM<= '1/1/1970' THEN NULL ELSE T$DATM END AS DATE) AS DATEMODIFIED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FSTM)),'')                             AS FINANCIALSTATEMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USRM)),'')                             AS LASTMODIFIEDBYUSER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS STATEMENTDESCRIPTION 
            ,CAST(T$TIMC AS BIGINT)                                                  AS TIMECREATED 
            ,CAST(T$TIMM AS BIGINT)                                                  AS TIMEMODIFIED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USRC)),'')                             AS USERCREATED 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFFST100200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                            AS _CAPTUREDATETIME 
            ,201                                                                       AS _COMPANYID 
            ,CAST(CASE WHEN T$DATC<= '1/1/1970' THEN NULL ELSE T$DATC END AS DATE) AS DATECREATED 
            ,CAST(CASE WHEN T$DATM<= '1/1/1970' THEN NULL ELSE T$DATM END AS DATE) AS DATEMODIFIED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FSTM)),'')                             AS FINANCIALSTATEMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USRM)),'')                             AS LASTMODIFIEDBYUSER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                             AS STATEMENTDESCRIPTION 
            ,CAST(T$TIMC AS BIGINT)                                                  AS TIMECREATED 
            ,CAST(T$TIMM AS BIGINT)                                                  AS TIMEMODIFIED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USRC)),'')                             AS USERCREATED 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFFST100201") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.DATECREATED AS DATECREATED, 
        source_data.DATEMODIFIED AS DATEMODIFIED, 
        source_data.FINANCIALSTATEMENT AS FINANCIALSTATEMENT, 
        source_data.LASTMODIFIEDBYUSER AS LASTMODIFIEDBYUSER, 
        source_data.STATEMENTDESCRIPTION AS STATEMENTDESCRIPTION, 
        source_data.TIMECREATED AS TIMECREATED, 
        source_data.TIMEMODIFIED AS TIMEMODIFIED, 
        source_data.USERCREATED AS USERCREATED
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(DATECREATED as DATE) as DATECREATED,
        cast(DATEMODIFIED as DATE) as DATEMODIFIED,
        cast(FINANCIALSTATEMENT as VARCHAR(8)) as FINANCIALSTATEMENT,
        cast(LASTMODIFIEDBYUSER as VARCHAR(16)) as LASTMODIFIEDBYUSER,
        cast(STATEMENTDESCRIPTION as VARCHAR(40)) as STATEMENTDESCRIPTION,
        cast(TIMECREATED as NUMBER(38,0)) as TIMECREATED,
        cast(TIMEMODIFIED as NUMBER(38,0)) as TIMEMODIFIED,
        cast(USERCREATED as VARCHAR(16)) as USERCREATED,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data