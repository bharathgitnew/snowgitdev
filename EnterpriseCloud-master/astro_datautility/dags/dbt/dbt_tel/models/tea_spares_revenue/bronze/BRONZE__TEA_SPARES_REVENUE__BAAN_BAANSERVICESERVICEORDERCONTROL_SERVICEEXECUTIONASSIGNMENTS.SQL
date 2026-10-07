/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEEXECUTIONASSIGNMENTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEEXECUTIONASSIGNMENTS.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEEXECUTIONASSIGNMENTS 
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
    alias='BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEEXECUTIONASSIGNMENTS',
    unique_key = ['ASSIGNMENTLINE',
    'SERVICEORDER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$ACTM<= '1/1/1970' THEN NULL ELSE T$ACTM  END AS DATETIME) AS ACCEPTEDTIME 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITY 
            ,CAST(T$ASDU AS NUMERIC(15,2))                                                                                                       AS ASSIGNMENTDURATION 
            ,CAST(T$ASLN AS INT)                                                                                                                 AS ASSIGNMENTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,T$CCHK.CONSTANTDESCRIPTION                                                                                                          AS CALENDARCHECKDESCRIPTION 
            ,CAST(T$CCHK AS INT)                                                                                                                 AS CALENDARCHECKID 
            ,CAST(CASE WHEN T$DLTM<= '1/1/1970' THEN NULL ELSE T$DLTM  END AS DATETIME) AS DOWNLOADEDTIME 
            ,CAST(CASE WHEN T$AFTM<= '1/1/1970' THEN NULL ELSE T$AFTM  END AS DATETIME) AS EXECUTIONFINISHTIME 
            ,CAST(CASE WHEN T$ASTM<= '1/1/1970' THEN NULL ELSE T$ASTM  END AS DATETIME) AS EXECUTIONSTARTTIME 
            ,CAST(CASE WHEN T$JCTM<= '1/1/1970' THEN NULL ELSE T$JCTM  END AS DATETIME) AS JOBSHEETCOMPLETIONTIME 
            ,CAST(CASE WHEN T$LTCT<= '1/1/1970' THEN NULL ELSE T$LTCT  END AS DATETIME) AS LASTCHANGEDTIME 
            ,CAST(CASE WHEN T$PFTM<= '1/1/1970' THEN NULL ELSE T$PFTM  END AS DATETIME) AS PLANNEDFINISHTIME 
            ,CAST(CASE WHEN T$PSTM<= '1/1/1970' THEN NULL ELSE T$PSTM  END AS DATETIME) AS PLANNEDSTARTTIME 
            ,CAST(CASE WHEN T$RJTM<= '1/1/1970' THEN NULL ELSE T$RJTM  END AS DATETIME) AS REJECTIONTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS SERVICEENGINEER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC206200") }} AS SOURCETABLE  
            /*CALENDARCHECK*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CCHK 
             ON   T$CCHK.TABLENAME  = 'TSSOC206' 
              AND T$CCHK.COLUMNNAME = 'T$CCHK' 
              AND T$CCHK.CONSTANT   = SOURCETABLE.T$CCHK 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$ACTM<= '1/1/1970' THEN NULL ELSE T$ACTM  END AS DATETIME) AS ACCEPTEDTIME 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS ACTIVITY 
            ,CAST(T$ASDU AS NUMERIC(15,2))                                                                                                       AS ASSIGNMENTDURATION 
            ,CAST(T$ASLN AS INT)                                                                                                                 AS ASSIGNMENTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,T$CCHK.CONSTANTDESCRIPTION                                                                                                          AS CALENDARCHECKDESCRIPTION 
            ,CAST(T$CCHK AS INT)                                                                                                                 AS CALENDARCHECKID 
            ,CAST(CASE WHEN T$DLTM<= '1/1/1970' THEN NULL ELSE T$DLTM  END AS DATETIME) AS DOWNLOADEDTIME 
            ,CAST(CASE WHEN T$AFTM<= '1/1/1970' THEN NULL ELSE T$AFTM  END AS DATETIME) AS EXECUTIONFINISHTIME 
            ,CAST(CASE WHEN T$ASTM<= '1/1/1970' THEN NULL ELSE T$ASTM  END AS DATETIME) AS EXECUTIONSTARTTIME 
            ,CAST(CASE WHEN T$JCTM<= '1/1/1970' THEN NULL ELSE T$JCTM  END AS DATETIME) AS JOBSHEETCOMPLETIONTIME 
            ,CAST(CASE WHEN T$LTCT<= '1/1/1970' THEN NULL ELSE T$LTCT  END AS DATETIME) AS LASTCHANGEDTIME 
            ,CAST(CASE WHEN T$PFTM<= '1/1/1970' THEN NULL ELSE T$PFTM  END AS DATETIME) AS PLANNEDFINISHTIME 
            ,CAST(CASE WHEN T$PSTM<= '1/1/1970' THEN NULL ELSE T$PSTM  END AS DATETIME) AS PLANNEDSTARTTIME 
            ,CAST(CASE WHEN T$RJTM<= '1/1/1970' THEN NULL ELSE T$RJTM  END AS DATETIME) AS REJECTIONTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS SERVICEENGINEER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC206201") }} AS SOURCETABLE  
            /*CALENDARCHECK*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CCHK 
             ON   T$CCHK.TABLENAME  = 'TSSOC206' 
              AND T$CCHK.COLUMNNAME = 'T$CCHK' 
              AND T$CCHK.CONSTANT   = SOURCETABLE.T$CCHK 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCEPTEDTIME AS ACCEPTEDTIME, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.ASSIGNMENTDURATION AS ASSIGNMENTDURATION, 
        source_data.ASSIGNMENTLINE AS ASSIGNMENTLINE, 
        source_data.SERVICEORDER AS SERVICEORDER,
        source_data.CALENDARCHECKDESCRIPTION AS CALENDARCHECKDESCRIPTION, 
        source_data.CALENDARCHECKID AS CALENDARCHECKID, 
        source_data.DOWNLOADEDTIME AS DOWNLOADEDTIME, 
        source_data.EXECUTIONFINISHTIME AS EXECUTIONFINISHTIME, 
        source_data.EXECUTIONSTARTTIME AS EXECUTIONSTARTTIME, 
        source_data.JOBSHEETCOMPLETIONTIME AS JOBSHEETCOMPLETIONTIME, 
        source_data.LASTCHANGEDTIME AS LASTCHANGEDTIME, 
        source_data.PLANNEDFINISHTIME AS PLANNEDFINISHTIME, 
        source_data.PLANNEDSTARTTIME AS PLANNEDSTARTTIME, 
        source_data.REJECTIONTIME AS REJECTIONTIME, 
        source_data.SERVICEENGINEER AS SERVICEENGINEER 
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
        cast(ACCEPTEDTIME as TIMESTAMP_NTZ(9)) as ACCEPTEDTIME,
        cast(ACTIVITY as NUMBER(38,0)) as ACTIVITY,
        cast(ASSIGNMENTDURATION as NUMBER(15,2)) as ASSIGNMENTDURATION,
        cast(ASSIGNMENTLINE as NUMBER(38,0)) as ASSIGNMENTLINE,
        SERVICEORDER,
        CALENDARCHECKDESCRIPTION,
        cast(CALENDARCHECKID as NUMBER(38,0)) as CALENDARCHECKID,
        cast(DOWNLOADEDTIME as TIMESTAMP_NTZ(9)) as DOWNLOADEDTIME,
        cast(EXECUTIONFINISHTIME as TIMESTAMP_NTZ(9)) as EXECUTIONFINISHTIME,
        cast(EXECUTIONSTARTTIME as TIMESTAMP_NTZ(9)) as EXECUTIONSTARTTIME,
        cast(JOBSHEETCOMPLETIONTIME as TIMESTAMP_NTZ(9)) as JOBSHEETCOMPLETIONTIME,
        cast(LASTCHANGEDTIME as TIMESTAMP_NTZ(9)) as LASTCHANGEDTIME,
        cast(PLANNEDFINISHTIME as TIMESTAMP_NTZ(9)) as PLANNEDFINISHTIME,
        cast(PLANNEDSTARTTIME as TIMESTAMP_NTZ(9)) as PLANNEDSTARTTIME,
        cast(REJECTIONTIME as TIMESTAMP_NTZ(9)) as REJECTIONTIME,
        SERVICEENGINEER
    from transform_data
    )
select * from type_data