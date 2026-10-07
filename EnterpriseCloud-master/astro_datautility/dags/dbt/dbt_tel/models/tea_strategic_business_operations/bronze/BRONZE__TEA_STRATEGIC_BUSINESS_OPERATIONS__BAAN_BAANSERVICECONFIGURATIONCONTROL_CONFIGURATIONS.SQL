/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS.SQL 
-materialized incremental
-alias BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:54 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS',
    unique_key = ['CONFIGURATION']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                AS _CAPTUREDATETIME 
            ,201                                                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                 AS CALENDAR 
            ,CAST(T$CCHA AS NUMERIC(15,2))                                               AS CALL_OUTCHARGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                 AS CONFIGURATION 
            ,CAST(T$PRIO AS TINYINT)                                                     AS CONFIGURATIONPRIORITY 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                             AS CONFIGURATIONTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                 AS CONTACTPERSON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                 AS CURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                 AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CZON)),'')                                 AS DISTANCEZONE 
            ,CAST(CASE WHEN T$MEDT<= '1/1/1970' THEN NULL ELSE T$MEDT END AS DATE)     AS ENDDATEPREVENTIVEMAINTENANCE 
            ,"T$EXPR$U".CONSTANTDESCRIPTION                                                AS EXPIREDDESCRIPTION 
            ,CAST("T$EXPR$U" AS INT)                                                       AS EXPIREDID 
            ,CAST(CASE WHEN "T$EXDT$U"<= '1/1/1970' THEN NULL ELSE "T$EXDT$U" END AS DATE) AS EXPIRYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PLAN)),'')                                 AS EXTRAINFORMATION 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                             AS HISTORYTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLRT)),'')                                 AS LABORRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                 AS LOCATIONADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MDNR)),'')                                 AS MODEM 
            ,T$OWNR.CONSTANTDESCRIPTION                                                  AS OWNERDESCRIPTION 
            ,CAST(T$OWNR AS INT)                                                         AS OWNERID 
            ,T$PAGE.CONSTANTDESCRIPTION                                                  AS PAGEALLOWEDDESCRIPTION 
            ,CAST(T$PAGE AS INT)                                                         AS PAGEALLOWEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TECA)),'')                                 AS PREFERREDENGINEER1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TECB)),'')                                 AS PREFERREDENGINEER2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TECR)),'')                                 AS RESPONSIBLEENGINEER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAR)),'')                                 AS SEARCHARGUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WSTS)),'')                                 AS SEARCHARGUMENTWORKSITEADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSAR)),'')                                 AS SERVICEAREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                 AS SERVICECENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCOR)),'')                                 AS SOLDTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                 AS SOLDTOBUSINESSPARTNER 
            ,CAST(CASE WHEN T$MSDT<= '1/1/1970' THEN NULL ELSE T$MSDT END AS DATE)     AS STARTDATEPREVENTIVEMAINTENANCE 
            ,CAST(T$DIST AS NUMERIC(15,2))                                               AS TRAVELDISTANCE 
            ,CAST(T$TRTI AS NUMERIC(15,2))                                               AS TRAVELINGTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUSC)),'')                                 AS USAGECLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWTE)),'')                                 AS WARRANTY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPWC)),'')                                 AS WORKCENTER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCFG220201") }} AS SOURCETABLE  
            /*EXPIREDU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$EXPR$U" 
             ON   "T$EXPR$U".TABLENAME  = 'TSCFG220' 
              AND "T$EXPR$U".COLUMNNAME = 'T$EXPR.U' 
              AND "T$EXPR$U".CONSTANT   = SOURCETABLE."T$EXPR$U" 
            /*OWNER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OWNR 
             ON   T$OWNR.TABLENAME  = 'TSCFG220' 
              AND T$OWNR.COLUMNNAME = 'T$OWNR' 
              AND T$OWNR.CONSTANT   = SOURCETABLE.T$OWNR 
            /*PAGEALLOWED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PAGE 
             ON   T$PAGE.TABLENAME  = 'TSCFG220' 
              AND T$PAGE.COLUMNNAME = 'T$PAGE' 
              AND T$PAGE.CONSTANT   = SOURCETABLE.T$PAGE 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CALENDAR AS CALENDAR, 
        source_data.CALL_OUTCHARGE AS CALL_OUTCHARGE, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONFIGURATIONPRIORITY AS CONFIGURATIONPRIORITY, 
        source_data.CONFIGURATIONTEXT AS CONFIGURATIONTEXT, 
        source_data.CONTACTPERSON AS CONTACTPERSON, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.DISTANCEZONE AS DISTANCEZONE, 
        source_data.ENDDATEPREVENTIVEMAINTENANCE AS ENDDATEPREVENTIVEMAINTENANCE, 
        source_data.EXPIREDDESCRIPTION AS EXPIREDDESCRIPTION, 
        source_data.EXPIREDID AS EXPIREDID, 
        source_data.EXPIRYDATE AS EXPIRYDATE, 
        source_data.EXTRAINFORMATION AS EXTRAINFORMATION, 
        source_data.HISTORYTEXT AS HISTORYTEXT, 
        source_data.LABORRATE AS LABORRATE, 
        source_data.LOCATIONADDRESS AS LOCATIONADDRESS, 
        source_data.MODEM AS MODEM, 
        source_data.OWNERDESCRIPTION AS OWNERDESCRIPTION, 
        source_data.OWNERID AS OWNERID, 
        source_data.PAGEALLOWEDDESCRIPTION AS PAGEALLOWEDDESCRIPTION, 
        source_data.PAGEALLOWEDID AS PAGEALLOWEDID, 
        source_data.PREFERREDENGINEER1 AS PREFERREDENGINEER1, 
        source_data.PREFERREDENGINEER2 AS PREFERREDENGINEER2, 
        source_data.RESPONSIBLEENGINEER AS RESPONSIBLEENGINEER, 
        source_data.SEARCHARGUMENT AS SEARCHARGUMENT, 
        source_data.SEARCHARGUMENTWORKSITEADDRESS AS SEARCHARGUMENTWORKSITEADDRESS, 
        source_data.SERVICEAREA AS SERVICEAREA, 
        source_data.SERVICECENTER AS SERVICECENTER, 
        source_data.SOLDTOADDRESS AS SOLDTOADDRESS, 
        source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER, 
        source_data.STARTDATEPREVENTIVEMAINTENANCE AS STARTDATEPREVENTIVEMAINTENANCE, 
        source_data.TRAVELDISTANCE AS TRAVELDISTANCE, 
        source_data.TRAVELINGTIME AS TRAVELINGTIME, 
        source_data.USAGECLASS AS USAGECLASS, 
        source_data.WARRANTY AS WARRANTY, 
        source_data.WORKCENTER AS WORKCENTER
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _FILEDATE,
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH as _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        CALENDAR as CALENDAR,
        cast(CALL_OUTCHARGE as NUMBER(15,2)) as CALL_OUTCHARGE,
        CONFIGURATION as CONFIGURATION,
        cast(CONFIGURATIONPRIORITY as NUMBER(38,0)) as CONFIGURATIONPRIORITY,
        cast(CONFIGURATIONTEXT as NUMBER(38,10)) as CONFIGURATIONTEXT,
        CONTACTPERSON as CONTACTPERSON,
        CURRENCY as CURRENCY,
        DESCRIPTION as DESCRIPTION,
        DISTANCEZONE as DISTANCEZONE,
        cast(ENDDATEPREVENTIVEMAINTENANCE as DATE) as ENDDATEPREVENTIVEMAINTENANCE,
        EXPIREDDESCRIPTION as EXPIREDDESCRIPTION,
        cast(EXPIREDID as NUMBER(38,0)) as EXPIREDID,
        cast(EXPIRYDATE as DATE) as EXPIRYDATE,
        EXTRAINFORMATION as EXTRAINFORMATION,
        cast(HISTORYTEXT as NUMBER(38,10)) as HISTORYTEXT,
        LABORRATE as LABORRATE,
        LOCATIONADDRESS as LOCATIONADDRESS,
        MODEM as MODEM,
        OWNERDESCRIPTION as OWNERDESCRIPTION,
        cast(OWNERID as NUMBER(38,0)) as OWNERID,
        PAGEALLOWEDDESCRIPTION as PAGEALLOWEDDESCRIPTION,
        cast(PAGEALLOWEDID as NUMBER(38,0)) as PAGEALLOWEDID,
        PREFERREDENGINEER1 as PREFERREDENGINEER1,
        PREFERREDENGINEER2 as PREFERREDENGINEER2,
        RESPONSIBLEENGINEER as RESPONSIBLEENGINEER,
        SEARCHARGUMENT as SEARCHARGUMENT,
        SEARCHARGUMENTWORKSITEADDRESS as SEARCHARGUMENTWORKSITEADDRESS,
        SERVICEAREA as SERVICEAREA,
        SERVICECENTER as SERVICECENTER,
        SOLDTOADDRESS as SOLDTOADDRESS,
        SOLDTOBUSINESSPARTNER as SOLDTOBUSINESSPARTNER,
        cast(STARTDATEPREVENTIVEMAINTENANCE as DATE) as STARTDATEPREVENTIVEMAINTENANCE,
        cast(TRAVELDISTANCE as NUMBER(15,2)) as TRAVELDISTANCE,
        cast(TRAVELINGTIME as NUMBER(15,2)) as TRAVELINGTIME,
        USAGECLASS as USAGECLASS,
        WARRANTY as WARRANTY,
        WORKCENTER as WORKCENTER
    from transform_data
    )
select * from type_data