/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERACTIVITIES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERACTIVITIES.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEORDERACTIVITIES 
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
    alias='BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDERACTIVITIES',
    unique_key = ['ACTIVITY',
    'SERVICEORDER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITY 
            ,CAST(T$ACDU AS NUMERIC(15,2))                                                                                                       AS ACTIVITYDURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CAGR)),'')                                                                                         AS ACTIVITYGROUP 
            ,T$ASTA.CONSTANTDESCRIPTION                                                                                                          AS ACTIVITYSTATUSDESCRIPTION 
            ,CAST(T$ASTA AS INT)                                                                                                                 AS ACTIVITYSTATUSID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ACTIVITYTEXT 
            ,CAST(T$ADVL AS NUMERIC(15,2))                                                                                                       AS ACTUALDEPENDVALUE 
            ,CAST(T$AIVL AS NUMERIC(15,2))                                                                                                       AS ACTUALINDEPENDENTVALUE 
            ,T$APPO.CONSTANTDESCRIPTION                                                                                                          AS APPOINTMENTDESCRIPTION 
            ,CAST(T$APPO AS INT)                                                                                                                 AS APPOINTMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BFBP)),'')                                                                                         AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCLL)),'')                                                                                         AS CALL 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS CALLTEXT 
            ,T$CHME.CONSTANTDESCRIPTION                                                                                                          AS CHANGEMETHODDESCRIPTION 
            ,CAST(T$CHME AS INT)                                                                                                                 AS CHANGEMETHODID 
            ,CAST(T$CCHL AS INT)                                                                                                                 AS CHECKLIST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,CAST(CASE WHEN T$CVTM<= '1/1/1970' THEN NULL ELSE T$CVTM  END AS DATETIME) AS COVERAGETIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                                                                                       AS CUSTOMERPOLINE 
            ,CAST(T$CUPR AS TINYINT)                                                                                                             AS CUSTOMERPRIORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORAC)),'')                                                                                         AS DERIVEDFROMPLANNEDACTIVITY 
            ,CAST(T$ORAS AS INT)                                                                                                                 AS DERIVEDFROMPLANNEDACTIVITYSEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,CAST(T$DBFC AS NUMERIC(15,2))                                                                                                       AS DOWNTIMERATIO 
            ,CAST(CASE WHEN T$AFTM<= '1/1/1970' THEN NULL ELSE T$AFTM  END AS DATETIME) AS EXECUTIONFINISHTIME 
            ,CAST(CASE WHEN T$ASTM<= '1/1/1970' THEN NULL ELSE T$ASTM  END AS DATETIME) AS EXECUTIONSTARTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FCON)),'')                                                                                         AS FIELDCHANGEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SBIT)),'')                                                                                         AS ITEMCODEFORSUBCONTRACTING 
            ,CAST(T$COVA AS NUMERIC(15,2))                                                                                                       AS MAINCOUNTERVALUE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMEA)),'')                                                                                         AS MEASUREMENTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COME)),'')                                                                                         AS MEASUREMENTTYPEMAINCOUNTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMDL)),'')                                                                                         AS MODELITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRON)),'')                                                                                         AS NEWOBJECT 
            ,CAST(T$OSQN AS INT)                                                                                                                 AS NEWOBJECTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CROB)),'')                                                                                         AS OBJECT 
            ,CAST(T$OSEQ AS INT)                                                                                                                 AS OBJECTNUMBER 
            ,CAST(T$OBPR AS TINYINT)                                                                                                             AS OBJECTPRIORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CROO)),'')                                                                                         AS ORIGINALOBJECT 
            ,CAST(T$OSQO AS INT)                                                                                                                 AS ORIGINALOBJECTNUMBER 
            ,CAST(T$PDVL AS NUMERIC(15,2))                                                                                                       AS PLANNEDDEPENDENTVALUE 
            ,CAST(CASE WHEN T$ESTM<= '1/1/1970' THEN NULL ELSE T$ESTM  END AS DATETIME) AS PLANNEDEARLIESTSTARTTIME 
            ,CAST(CASE WHEN T$PFTM<= '1/1/1970' THEN NULL ELSE T$PFTM  END AS DATETIME) AS PLANNEDFINISHTIME 
            ,CAST(T$NIVL AS NUMERIC(15,2))                                                                                                       AS PLANNEDINDEPENDENTVALUE 
            ,CAST(CASE WHEN T$LFTM<= '1/1/1970' THEN NULL ELSE T$LFTM  END AS DATETIME) AS PLANNEDLATESTFINISHTIME 
            ,CAST(CASE WHEN T$PSTM<= '1/1/1970' THEN NULL ELSE T$PSTM  END AS DATETIME) AS PLANNEDSTARTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRL)),'')                                                                                         AS PROBLEM 
            ,CAST(T$PRPR AS TINYINT)                                                                                                             AS PROBLEMPRIORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRAC)),'')                                                                                         AS REF_percent_ACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTC)),'')                                                                                         AS RESPONSETIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAR)),'')                                                                                         AS SEARCHARGUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSKT)),'')                                                                                         AS SERVICEKIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTP)),'')                                                                                         AS SERVICETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKLA)),'')                                                                                         AS SKILLI 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKLB)),'')                                                                                         AS SKILLII 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKLC)),'')                                                                                         AS SKILLIII 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTN)),'')                                                                                         AS SOLUTION 
            ,SOURCETABLE.T$TXTC   /* TEXT */                                                                                                     AS SOLUTIONTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC210200") }} AS SOURCETABLE  
            /*ACTIVITYSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ASTA 
             ON   T$ASTA.TABLENAME  = 'TSSOC210' 
              AND T$ASTA.COLUMNNAME = 'T$ASTA' 
              AND T$ASTA.CONSTANT   = SOURCETABLE.T$ASTA 
            /*APPOINTMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$APPO 
             ON   T$APPO.TABLENAME  = 'TSSOC210' 
              AND T$APPO.COLUMNNAME = 'T$APPO' 
              AND T$APPO.CONSTANT   = SOURCETABLE.T$APPO 
            /*CHANGEMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHME 
             ON   T$CHME.TABLENAME  = 'TSSOC210' 
              AND T$CHME.COLUMNNAME = 'T$CHME' 
              AND T$CHME.CONSTANT   = SOURCETABLE.T$CHME 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITY 
            ,CAST(T$ACDU AS NUMERIC(15,2))                                                                                                       AS ACTIVITYDURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CAGR)),'')                                                                                         AS ACTIVITYGROUP 
            ,T$ASTA.CONSTANTDESCRIPTION                                                                                                          AS ACTIVITYSTATUSDESCRIPTION 
            ,CAST(T$ASTA AS INT)                                                                                                                 AS ACTIVITYSTATUSID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS ACTIVITYTEXT 
            ,CAST(T$ADVL AS NUMERIC(15,2))                                                                                                       AS ACTUALDEPENDVALUE 
            ,CAST(T$AIVL AS NUMERIC(15,2))                                                                                                       AS ACTUALINDEPENDENTVALUE 
            ,T$APPO.CONSTANTDESCRIPTION                                                                                                          AS APPOINTMENTDESCRIPTION 
            ,CAST(T$APPO AS INT)                                                                                                                 AS APPOINTMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BFBP)),'')                                                                                         AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCLL)),'')                                                                                         AS CALL 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS CALLTEXT 
            ,T$CHME.CONSTANTDESCRIPTION                                                                                                          AS CHANGEMETHODDESCRIPTION 
            ,CAST(T$CHME AS INT)                                                                                                                 AS CHANGEMETHODID 
            ,CAST(T$CCHL AS INT)                                                                                                                 AS CHECKLIST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,CAST(CASE WHEN T$CVTM<= '1/1/1970' THEN NULL ELSE T$CVTM  END AS DATETIME) AS COVERAGETIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CORP$U")),'')                                                                                       AS CUSTOMERPOLINE 
            ,CAST(T$CUPR AS TINYINT)                                                                                                             AS CUSTOMERPRIORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORAC)),'')                                                                                         AS DERIVEDFROMPLANNEDACTIVITY 
            ,CAST(T$ORAS AS INT)                                                                                                                 AS DERIVEDFROMPLANNEDACTIVITYSEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,CAST(T$DBFC AS NUMERIC(15,2))                                                                                                       AS DOWNTIMERATIO 
            ,CAST(CASE WHEN T$AFTM<= '1/1/1970' THEN NULL ELSE T$AFTM  END AS DATETIME) AS EXECUTIONFINISHTIME 
            ,CAST(CASE WHEN T$ASTM<= '1/1/1970' THEN NULL ELSE T$ASTM  END AS DATETIME) AS EXECUTIONSTARTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FCON)),'')                                                                                         AS FIELDCHANGEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SBIT)),'')                                                                                         AS ITEMCODEFORSUBCONTRACTING 
            ,CAST(T$COVA AS NUMERIC(15,2))                                                                                                       AS MAINCOUNTERVALUE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMEA)),'')                                                                                         AS MEASUREMENTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COME)),'')                                                                                         AS MEASUREMENTTYPEMAINCOUNTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMDL)),'')                                                                                         AS MODELITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRON)),'')                                                                                         AS NEWOBJECT 
            ,CAST(T$OSQN AS INT)                                                                                                                 AS NEWOBJECTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CROB)),'')                                                                                         AS OBJECT 
            ,CAST(T$OSEQ AS INT)                                                                                                                 AS OBJECTNUMBER 
            ,CAST(T$OBPR AS TINYINT)                                                                                                             AS OBJECTPRIORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CROO)),'')                                                                                         AS ORIGINALOBJECT 
            ,CAST(T$OSQO AS INT)                                                                                                                 AS ORIGINALOBJECTNUMBER 
            ,CAST(T$PDVL AS NUMERIC(15,2))                                                                                                       AS PLANNEDDEPENDENTVALUE 
            ,CAST(CASE WHEN T$ESTM<= '1/1/1970' THEN NULL ELSE T$ESTM  END AS DATETIME) AS PLANNEDEARLIESTSTARTTIME 
            ,CAST(CASE WHEN T$PFTM<= '1/1/1970' THEN NULL ELSE T$PFTM  END AS DATETIME) AS PLANNEDFINISHTIME 
            ,CAST(T$NIVL AS NUMERIC(15,2))                                                                                                       AS PLANNEDINDEPENDENTVALUE 
            ,CAST(CASE WHEN T$LFTM<= '1/1/1970' THEN NULL ELSE T$LFTM  END AS DATETIME) AS PLANNEDLATESTFINISHTIME 
            ,CAST(CASE WHEN T$PSTM<= '1/1/1970' THEN NULL ELSE T$PSTM  END AS DATETIME) AS PLANNEDSTARTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRL)),'')                                                                                         AS PROBLEM 
            ,CAST(T$PRPR AS TINYINT)                                                                                                             AS PROBLEMPRIORITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRAC)),'')                                                                                         AS REF_percent_ACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTC)),'')                                                                                         AS RESPONSETIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAR)),'')                                                                                         AS SEARCHARGUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSKT)),'')                                                                                         AS SERVICEKIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTP)),'')                                                                                         AS SERVICETYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKLA)),'')                                                                                         AS SKILLI 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKLB)),'')                                                                                         AS SKILLII 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SKLC)),'')                                                                                         AS SKILLIII 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSTN)),'')                                                                                         AS SOLUTION 
            ,SOURCETABLE.T$TXTC   /* TEXT */                                                                                                     AS SOLUTIONTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC210201") }} AS SOURCETABLE  
            /*ACTIVITYSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ASTA 
             ON   T$ASTA.TABLENAME  = 'TSSOC210' 
              AND T$ASTA.COLUMNNAME = 'T$ASTA' 
              AND T$ASTA.CONSTANT   = SOURCETABLE.T$ASTA 
            /*APPOINTMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$APPO 
             ON   T$APPO.TABLENAME  = 'TSSOC210' 
              AND T$APPO.COLUMNNAME = 'T$APPO' 
              AND T$APPO.CONSTANT   = SOURCETABLE.T$APPO 
            /*CHANGEMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHME 
             ON   T$CHME.TABLENAME  = 'TSSOC210' 
              AND T$CHME.COLUMNNAME = 'T$CHME' 
              AND T$CHME.CONSTANT   = SOURCETABLE.T$CHME 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.ACTIVITYDURATION AS ACTIVITYDURATION, 
        source_data.ACTIVITYGROUP AS ACTIVITYGROUP, 
        source_data.ACTIVITYSTATUSDESCRIPTION AS ACTIVITYSTATUSDESCRIPTION, 
        source_data.ACTIVITYSTATUSID AS ACTIVITYSTATUSID, 
        source_data.ACTIVITYTEXT AS ACTIVITYTEXT, 
        source_data.ACTUALDEPENDVALUE AS ACTUALDEPENDVALUE, 
        source_data.ACTUALINDEPENDENTVALUE AS ACTUALINDEPENDENTVALUE, 
        source_data.APPOINTMENTDESCRIPTION AS APPOINTMENTDESCRIPTION, 
        source_data.APPOINTMENTID AS APPOINTMENTID, 
        source_data.BUYFROMBUSINESSPARTNER AS BUYFROMBUSINESSPARTNER, 
        source_data.CALL AS CALL, 
        source_data.CALLTEXT AS CALLTEXT, 
        source_data.CHANGEMETHODDESCRIPTION AS CHANGEMETHODDESCRIPTION, 
        source_data.CHANGEMETHODID AS CHANGEMETHODID, 
        source_data.CHECKLIST AS CHECKLIST, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.COVERAGETIME AS COVERAGETIME, 
        source_data.CUSTOMERPOLINE AS CUSTOMERPOLINE, 
        source_data.CUSTOMERPRIORITY AS CUSTOMERPRIORITY, 
        source_data.DERIVEDFROMPLANNEDACTIVITY AS DERIVEDFROMPLANNEDACTIVITY, 
        source_data.DERIVEDFROMPLANNEDACTIVITYSEQUENCENUMBER AS DERIVEDFROMPLANNEDACTIVITYSEQUENCENUMBER, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.DOWNTIMERATIO AS DOWNTIMERATIO, 
        source_data.EXECUTIONFINISHTIME AS EXECUTIONFINISHTIME, 
        source_data.EXECUTIONSTARTTIME AS EXECUTIONSTARTTIME, 
        source_data.FIELDCHANGEORDER AS FIELDCHANGEORDER, 
        source_data.ITEMCODEFORSUBCONTRACTING AS ITEMCODEFORSUBCONTRACTING, 
        source_data.MAINCOUNTERVALUE AS MAINCOUNTERVALUE, 
        source_data.MEASUREMENTTYPE AS MEASUREMENTTYPE, 
        source_data.MEASUREMENTTYPEMAINCOUNTER AS MEASUREMENTTYPEMAINCOUNTER, 
        source_data.MODELITEM AS MODELITEM, 
        source_data.NEWOBJECT AS NEWOBJECT, 
        source_data.NEWOBJECTNUMBER AS NEWOBJECTNUMBER, 
        source_data.OBJECT AS OBJECT, 
        source_data.OBJECTNUMBER AS OBJECTNUMBER, 
        source_data.OBJECTPRIORITY AS OBJECTPRIORITY, 
        source_data.ORIGINALOBJECT AS ORIGINALOBJECT, 
        source_data.ORIGINALOBJECTNUMBER AS ORIGINALOBJECTNUMBER, 
        source_data.PLANNEDDEPENDENTVALUE AS PLANNEDDEPENDENTVALUE, 
        source_data.PLANNEDEARLIESTSTARTTIME AS PLANNEDEARLIESTSTARTTIME, 
        source_data.PLANNEDFINISHTIME AS PLANNEDFINISHTIME, 
        source_data.PLANNEDINDEPENDENTVALUE AS PLANNEDINDEPENDENTVALUE, 
        source_data.PLANNEDLATESTFINISHTIME AS PLANNEDLATESTFINISHTIME, 
        source_data.PLANNEDSTARTTIME AS PLANNEDSTARTTIME, 
        source_data.PROBLEM AS PROBLEM, 
        source_data.PROBLEMPRIORITY AS PROBLEMPRIORITY, 
        source_data.REF_PERCENT_ACTIVITY AS REF_PERCENT_ACTIVITY, 
        source_data.RESPONSETIME AS RESPONSETIME, 
        source_data.SEARCHARGUMENT AS SEARCHARGUMENT, 
        source_data.SERVICEKIT AS SERVICEKIT, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SERVICETYPE AS SERVICETYPE, 
        source_data.SKILLI AS SKILLI, 
        source_data.SKILLII AS SKILLII, 
        source_data.SKILLIII AS SKILLIII, 
        source_data.SOLUTION AS SOLUTION, 
        source_data.SOLUTIONTEXT AS SOLUTIONTEXT, 
        source_data.TAXCODE AS TAXCODE
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
        cast(ACTIVITY as NUMBER(38,0)) as ACTIVITY,
        cast(ACTIVITYDURATION as NUMBER(15,2)) as ACTIVITYDURATION,
        ACTIVITYGROUP,
        ACTIVITYSTATUSDESCRIPTION,
        cast(ACTIVITYSTATUSID as NUMBER(38,0)) as ACTIVITYSTATUSID,
        cast(ACTIVITYTEXT as NUMBER(38,10)) as ACTIVITYTEXT,
        cast(ACTUALDEPENDVALUE as NUMBER(15,2)) as ACTUALDEPENDVALUE,
        cast(ACTUALINDEPENDENTVALUE as NUMBER(15,2)) as ACTUALINDEPENDENTVALUE,
        APPOINTMENTDESCRIPTION,
        cast(APPOINTMENTID as NUMBER(38,0)) as APPOINTMENTID,
        BUYFROMBUSINESSPARTNER,
        CALL,
        cast(CALLTEXT as NUMBER(38,10)) as CALLTEXT,
        CHANGEMETHODDESCRIPTION,
        cast(CHANGEMETHODID as NUMBER(38,0)) as CHANGEMETHODID,
        cast(CHECKLIST as NUMBER(38,0)) as CHECKLIST,
        CONFIGURATION,
        cast(COVERAGETIME as TIMESTAMP_NTZ(9)) as COVERAGETIME,
        CUSTOMERPOLINE,
        cast(CUSTOMERPRIORITY as NUMBER(38,0)) as CUSTOMERPRIORITY,
        DERIVEDFROMPLANNEDACTIVITY,
        cast(DERIVEDFROMPLANNEDACTIVITYSEQUENCENUMBER as NUMBER(38,0)) as DERIVEDFROMPLANNEDACTIVITYSEQUENCENUMBER,
        DESCRIPTION,
        cast(DOWNTIMERATIO as NUMBER(15,2)) as DOWNTIMERATIO,
        cast(EXECUTIONFINISHTIME as TIMESTAMP_NTZ(9)) as EXECUTIONFINISHTIME,
        cast(EXECUTIONSTARTTIME as TIMESTAMP_NTZ(9)) as EXECUTIONSTARTTIME,
        FIELDCHANGEORDER,
        ITEMCODEFORSUBCONTRACTING,
        cast(MAINCOUNTERVALUE as NUMBER(15,2)) as MAINCOUNTERVALUE,
        MEASUREMENTTYPE,
        MEASUREMENTTYPEMAINCOUNTER,
        MODELITEM,
        NEWOBJECT,
        cast(NEWOBJECTNUMBER as NUMBER(38,0)) as NEWOBJECTNUMBER,
        OBJECT,
        cast(OBJECTNUMBER as NUMBER(38,0)) as OBJECTNUMBER,
        cast(OBJECTPRIORITY as NUMBER(38,0)) as OBJECTPRIORITY,
        ORIGINALOBJECT,
        cast(ORIGINALOBJECTNUMBER as NUMBER(38,0)) as ORIGINALOBJECTNUMBER,
        cast(PLANNEDDEPENDENTVALUE as NUMBER(15,2)) as PLANNEDDEPENDENTVALUE,
        cast(PLANNEDEARLIESTSTARTTIME as TIMESTAMP_NTZ(9)) as PLANNEDEARLIESTSTARTTIME,
        cast(PLANNEDFINISHTIME as TIMESTAMP_NTZ(9)) as PLANNEDFINISHTIME,
        cast(PLANNEDINDEPENDENTVALUE as NUMBER(15,2)) as PLANNEDINDEPENDENTVALUE,
        cast(PLANNEDLATESTFINISHTIME as TIMESTAMP_NTZ(9)) as PLANNEDLATESTFINISHTIME,
        cast(PLANNEDSTARTTIME as TIMESTAMP_NTZ(9)) as PLANNEDSTARTTIME,
        PROBLEM,
        cast(PROBLEMPRIORITY as NUMBER(38,0)) as PROBLEMPRIORITY,
        REF_PERCENT_ACTIVITY,
        RESPONSETIME,
        SEARCHARGUMENT,
        SERVICEKIT,
        SERVICEORDER,
        SERVICETYPE,
        SKILLI,
        SKILLII,
        SKILLIII,
        SOLUTION,
        SOLUTIONTEXT,
        TAXCODE
    from transform_data
    )
select * from type_data