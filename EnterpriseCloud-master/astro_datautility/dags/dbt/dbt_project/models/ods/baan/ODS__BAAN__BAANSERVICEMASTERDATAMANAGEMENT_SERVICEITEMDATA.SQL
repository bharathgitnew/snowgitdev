/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICEMASTERDATAMANAGEMENT_SERVICEITEMDATA.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICEMASTERDATAMANAGEMENT_SERVICEITEMDATA.SQL 
-materialized incremental
-alias BAANSERVICEMASTERDATAMANAGEMENT_SERVICEITEMDATA 
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
    alias='BAANSERVICEMASTERDATAMANAGEMENT_SERVICEITEMDATA',
    unique_key = ['ITEM']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,T$DLTP.CONSTANTDESCRIPTION                                                                                                          AS DELIVERYTYPEDESCRIPTION 
            ,CAST(T$DLTP AS INT)                                                                                                                 AS DELIVERYTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LTDS<= '1/1/1970' THEN NULL ELSE T$LTDS  END AS DATETIME) AS LASTTRANSACTIONDATESERVICEPRICE 
            ,CAST(T$SRPD AS BIGINT)                                                                                                              AS LIFECYCLE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PERU)),'')                                                                                         AS LIFECYCLEUNIT 
            ,CAST(T$NRPE AS BIGINT)                                                                                                              AS MAINTENANCECYCLE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRUN)),'')                                                                                         AS MAINTENANCECYCLEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMEA)),'')                                                                                         AS MEASUREMENTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COGR)),'')                                                                                         AS OBJECTGROUP 
            ,T$OBTP.CONSTANTDESCRIPTION                                                                                                          AS OBJECTTYPEDESCRIPTION 
            ,CAST(T$OBTP AS INT)                                                                                                                 AS OBJECTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS QUANTITYUNIT 
            ,T$RPYN.CONSTANTDESCRIPTION                                                                                                          AS REPAIRABLEDESCRIPTION 
            ,CAST(T$RPYN AS INT)                                                                                                                 AS REPAIRABLEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAR)),'')                                                                                         AS SEARCHARGUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS SERVICECENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGR)),'')                                                                                         AS SERVICEITEMGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CKGR)),'')                                                                                         AS SERVICEKITTYPE 
            ,CAST(T$PRIS AS NUMERIC(15,2))                                                                                                       AS SERVICEPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWTE)),'')                                                                                         AS WARRANTY 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSMDM200200") }} AS SOURCETABLE  
            /*DELIVERYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DLTP 
             ON   T$DLTP.TABLENAME  = 'TSMDM200' 
              AND T$DLTP.COLUMNNAME = 'T$DLTP' 
              AND T$DLTP.CONSTANT   = SOURCETABLE.T$DLTP 
            /*OBJECTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OBTP 
             ON   T$OBTP.TABLENAME  = 'TSMDM200' 
              AND T$OBTP.COLUMNNAME = 'T$OBTP' 
              AND T$OBTP.CONSTANT   = SOURCETABLE.T$OBTP 
            /*REPAIRABLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RPYN 
             ON   T$RPYN.TABLENAME  = 'TSMDM200' 
              AND T$RPYN.COLUMNNAME = 'T$RPYN' 
              AND T$RPYN.CONSTANT   = SOURCETABLE.T$RPYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,T$DLTP.CONSTANTDESCRIPTION                                                                                                          AS DELIVERYTYPEDESCRIPTION 
            ,CAST(T$DLTP AS INT)                                                                                                                 AS DELIVERYTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LTDS<= '1/1/1970' THEN NULL ELSE T$LTDS  END AS DATETIME) AS LASTTRANSACTIONDATESERVICEPRICE 
            ,CAST(T$SRPD AS BIGINT)                                                                                                              AS LIFECYCLE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PERU)),'')                                                                                         AS LIFECYCLEUNIT 
            ,CAST(T$NRPE AS BIGINT)                                                                                                              AS MAINTENANCECYCLE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRUN)),'')                                                                                         AS MAINTENANCECYCLEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMEA)),'')                                                                                         AS MEASUREMENTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COGR)),'')                                                                                         AS OBJECTGROUP 
            ,T$OBTP.CONSTANTDESCRIPTION                                                                                                          AS OBJECTTYPEDESCRIPTION 
            ,CAST(T$OBTP AS INT)                                                                                                                 AS OBJECTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUQS)),'')                                                                                         AS QUANTITYUNIT 
            ,T$RPYN.CONSTANTDESCRIPTION                                                                                                          AS REPAIRABLEDESCRIPTION 
            ,CAST(T$RPYN AS INT)                                                                                                                 AS REPAIRABLEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPS)),'')                                                                                         AS SALESPRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAR)),'')                                                                                         AS SEARCHARGUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS SERVICECENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSGR)),'')                                                                                         AS SERVICEITEMGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CKGR)),'')                                                                                         AS SERVICEKITTYPE 
            ,CAST(T$PRIS AS NUMERIC(15,2))                                                                                                       AS SERVICEPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWTE)),'')                                                                                         AS WARRANTY 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSMDM200201") }} AS SOURCETABLE  
            /*DELIVERYTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DLTP 
             ON   T$DLTP.TABLENAME  = 'TSMDM200' 
              AND T$DLTP.COLUMNNAME = 'T$DLTP' 
              AND T$DLTP.CONSTANT   = SOURCETABLE.T$DLTP 
            /*OBJECTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OBTP 
             ON   T$OBTP.TABLENAME  = 'TSMDM200' 
              AND T$OBTP.COLUMNNAME = 'T$OBTP' 
              AND T$OBTP.CONSTANT   = SOURCETABLE.T$OBTP 
            /*REPAIRABLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RPYN 
             ON   T$RPYN.TABLENAME  = 'TSMDM200' 
              AND T$RPYN.COLUMNNAME = 'T$RPYN' 
              AND T$RPYN.CONSTANT   = SOURCETABLE.T$RPYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DELIVERYTYPEDESCRIPTION AS DELIVERYTYPEDESCRIPTION, 
        source_data.DELIVERYTYPEID AS DELIVERYTYPEID, 
        source_data.ITEM AS ITEM, 
        source_data.LASTTRANSACTIONDATESERVICEPRICE AS LASTTRANSACTIONDATESERVICEPRICE, 
        source_data.LIFECYCLE AS LIFECYCLE, 
        source_data.LIFECYCLEUNIT AS LIFECYCLEUNIT, 
        source_data.MAINTENANCECYCLE AS MAINTENANCECYCLE, 
        source_data.MAINTENANCECYCLEUNIT AS MAINTENANCECYCLEUNIT, 
        source_data.MEASUREMENTTYPE AS MEASUREMENTTYPE, 
        source_data.OBJECTGROUP AS OBJECTGROUP, 
        source_data.OBJECTTYPEDESCRIPTION AS OBJECTTYPEDESCRIPTION, 
        source_data.OBJECTTYPEID AS OBJECTTYPEID, 
        source_data.QUANTITYUNIT AS QUANTITYUNIT, 
        source_data.REPAIRABLEDESCRIPTION AS REPAIRABLEDESCRIPTION, 
        source_data.REPAIRABLEID AS REPAIRABLEID, 
        source_data.SALESPRICEUNIT AS SALESPRICEUNIT, 
        source_data.SEARCHARGUMENT AS SEARCHARGUMENT, 
        source_data.SERVICECENTER AS SERVICECENTER, 
        source_data.SERVICEITEMGROUP AS SERVICEITEMGROUP, 
        source_data.SERVICEKITTYPE AS SERVICEKITTYPE, 
        source_data.SERVICEPRICE AS SERVICEPRICE, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.TEXT AS TEXT, 
        source_data.WARRANTY AS WARRANTY
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(DELIVERYTYPEDESCRIPTION as VARCHAR(16777216)) as DELIVERYTYPEDESCRIPTION,
        cast(DELIVERYTYPEID as NUMBER(38,0)) as DELIVERYTYPEID,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTTRANSACTIONDATESERVICEPRICE as TIMESTAMP_NTZ(9)) as LASTTRANSACTIONDATESERVICEPRICE,
        cast(LIFECYCLE as NUMBER(38,0)) as LIFECYCLE,
        cast(LIFECYCLEUNIT as VARCHAR(3)) as LIFECYCLEUNIT,
        cast(MAINTENANCECYCLE as NUMBER(38,0)) as MAINTENANCECYCLE,
        cast(MAINTENANCECYCLEUNIT as VARCHAR(3)) as MAINTENANCECYCLEUNIT,
        cast(MEASUREMENTTYPE as VARCHAR(6)) as MEASUREMENTTYPE,
        cast(OBJECTGROUP as VARCHAR(6)) as OBJECTGROUP,
        cast(OBJECTTYPEDESCRIPTION as VARCHAR(16777216)) as OBJECTTYPEDESCRIPTION,
        cast(OBJECTTYPEID as NUMBER(38,0)) as OBJECTTYPEID,
        cast(QUANTITYUNIT as VARCHAR(3)) as QUANTITYUNIT,
        cast(REPAIRABLEDESCRIPTION as VARCHAR(16777216)) as REPAIRABLEDESCRIPTION,
        cast(REPAIRABLEID as NUMBER(38,0)) as REPAIRABLEID,
        cast(SALESPRICEUNIT as VARCHAR(3)) as SALESPRICEUNIT,
        cast(SEARCHARGUMENT as VARCHAR(16)) as SEARCHARGUMENT,
        cast(SERVICECENTER as VARCHAR(6)) as SERVICECENTER,
        cast(SERVICEITEMGROUP as VARCHAR(6)) as SERVICEITEMGROUP,
        cast(SERVICEKITTYPE as VARCHAR(3)) as SERVICEKITTYPE,
        cast(SERVICEPRICE as NUMBER(15,2)) as SERVICEPRICE,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(WARRANTY as VARCHAR(16)) as WARRANTY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data