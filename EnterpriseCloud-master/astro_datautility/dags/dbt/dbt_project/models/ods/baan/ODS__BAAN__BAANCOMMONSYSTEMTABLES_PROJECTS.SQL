/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_PROJECTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_PROJECTS.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_PROJECTS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONSYSTEMTABLES_PROJECTS',
    unique_key = ['PROJECT']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION_DSCA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCB)),'') AS DESCRIPTION_DSCB 
            ,T$PPUS.CONSTANTDESCRIPTION                  AS PCSPROJECTUSAGEDESCRIPTION 
            ,CAST(T$PPUS AS INT)                         AS PCSPROJECTUSAGEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'') AS PROJECT 
            ,T$PLNK.CONSTANTDESCRIPTION                  AS PROJECTPACKAGELINKDESCRIPTION 
            ,CAST(T$PLNK AS INT)                         AS PROJECTPACKAGELINKID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAB)),'') AS SEARCHKEY_SEAB 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'') AS SEARCHKEY_SEAK 
            ,SOURCETABLE.T$TXTA   /* TEXT */             AS TEXT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS052201") }} AS SOURCETABLE  
            /*PCSPROJECTUSAGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PPUS 
             ON   T$PPUS.TABLENAME  = 'TCMCS052' 
              AND T$PPUS.COLUMNNAME = 'T$PPUS' 
              AND T$PPUS.CONSTANT   = SOURCETABLE.T$PPUS 
            /*PROJECTPACKAGELINK*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PLNK 
             ON   T$PLNK.TABLENAME  = 'TCMCS052' 
              AND T$PLNK.COLUMNNAME = 'T$PLNK' 
              AND T$PLNK.CONSTANT   = SOURCETABLE.T$PLNK 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.DESCRIPTION_DSCA AS DESCRIPTION_DSCA, 
        source_data.DESCRIPTION_DSCB AS DESCRIPTION_DSCB, 
        source_data.PCSPROJECTUSAGEDESCRIPTION AS PCSPROJECTUSAGEDESCRIPTION, 
        source_data.PCSPROJECTUSAGEID AS PCSPROJECTUSAGEID, 
        source_data.PROJECT AS PROJECT, 
        source_data.PROJECTPACKAGELINKDESCRIPTION AS PROJECTPACKAGELINKDESCRIPTION, 
        source_data.PROJECTPACKAGELINKID AS PROJECTPACKAGELINKID, 
        source_data.SEARCHKEY_SEAB AS SEARCHKEY_SEAB, 
        source_data.SEARCHKEY_SEAK AS SEARCHKEY_SEAK, 
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
        cast(DESCRIPTION_DSCA as VARCHAR(30)) as DESCRIPTION_DSCA,
        cast(DESCRIPTION_DSCB as VARCHAR(30)) as DESCRIPTION_DSCB,
        cast(PCSPROJECTUSAGEDESCRIPTION as VARCHAR(16777216)) as PCSPROJECTUSAGEDESCRIPTION,
        cast(PCSPROJECTUSAGEID as NUMBER(38,0)) as PCSPROJECTUSAGEID,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(PROJECTPACKAGELINKDESCRIPTION as VARCHAR(16777216)) as PROJECTPACKAGELINKDESCRIPTION,
        cast(PROJECTPACKAGELINKID as NUMBER(38,0)) as PROJECTPACKAGELINKID,
        cast(SEARCHKEY_SEAB as VARCHAR(16)) as SEARCHKEY_SEAB,
        cast(SEARCHKEY_SEAK as VARCHAR(16)) as SEARCHKEY_SEAK,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data