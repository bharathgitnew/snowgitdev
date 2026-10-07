/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANMANUFACTURINGPROJECTCONTROLSYSTEM_GENERALPROJECTDATA.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANMANUFACTURINGPROJECTCONTROLSYSTEM_GENERALPROJECTDATA.SQL 
-materialized incremental
-alias BAANMANUFACTURINGPROJECTCONTROLSYSTEM_GENERALPROJECTDATA 
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
    alias='BAANMANUFACTURINGPROJECTCONTROLSYSTEM_GENERALPROJECTDATA',
    unique_key = ['PROJECT']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCGR)),'')                                                                                             AS CALCULATIONGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLCO)),'')                                                                                             AS CALCULATIONOFFICE 
            ,CAST(CASE WHEN "T$CSTD$U"<= '1/1/1970' THEN NULL ELSE "T$CSTD$U"  END AS DATETIME) AS CSTACCEPTANCERECEIVED 
            ,T$DTFS.CONSTANTDESCRIPTION                                                                                                              AS DATEFILLEDBYSALESDESCRIPTION 
            ,CAST(T$DTFS AS INT)                                                                                                                     AS DATEFILLEDBYSALESID 
            ,T$PENG.CONSTANTDESCRIPTION                                                                                                              AS ENGINEERINGALLOWEDDESCRIPTION 
            ,CAST(T$PENG AS INT)                                                                                                                     AS ENGINEERINGALLOWEDID 
            ,CAST(T$FFCI AS BIGINT)                                                                                                                  AS FIRSTFREEITEMCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCC)),'')                                                                                             AS PRICECALCULATIONCODE 
            ,CAST(CASE WHEN "T$PSTD$U"<= '1/1/1970' THEN NULL ELSE "T$PSTD$U"  END AS DATETIME) AS PROCESSACCEPTANCERECEIVED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PDNO$U")),'')                                                                                           AS PRODUCTIONORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                             AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PEMP)),'')                                                                                             AS PROJECTEMPLOYEE 
            ,T$KOPR.CONSTANTDESCRIPTION                                                                                                              AS PROJECTTYPEDESCRIPTION 
            ,CAST(T$KOPR AS INT)                                                                                                                     AS PROJECTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFE)),'')                                                                                             AS REFERENCE 
            ,CAST(CASE WHEN T$CFDT<= '1/1/1970' THEN NULL ELSE T$CFDT  END AS DATETIME)     AS REFERENCEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                             AS SEARCHKEY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                             AS SOLDTOBUSINESSPARTNER 
            ,CAST(CASE WHEN "T$TPIC$U"<= '1/1/1970' THEN NULL ELSE "T$TPIC$U"  END AS DATETIME) AS THIRDPARTYINSPECTIONCOMPLETED 
            ,CAST(CASE WHEN "T$TPSH$U"<= '1/1/1970' THEN NULL ELSE "T$TPSH$U"  END AS DATETIME) AS TOOLPHYSICALLYSHIPPED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSER)),'')                                                                                             AS TOOLSERIALNUMBER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTIPCS020201") }} AS SOURCETABLE  
            /*DATEFILLEDBYSALES*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTFS 
             ON   T$DTFS.TABLENAME  = 'TIPCS020' 
              AND T$DTFS.COLUMNNAME = 'T$DTFS' 
              AND T$DTFS.CONSTANT   = SOURCETABLE.T$DTFS 
            /*ENGINEERINGALLOWED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PENG 
             ON   T$PENG.TABLENAME  = 'TIPCS020' 
              AND T$PENG.COLUMNNAME = 'T$PENG' 
              AND T$PENG.CONSTANT   = SOURCETABLE.T$PENG 
            /*PROJECTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$KOPR 
             ON   T$KOPR.TABLENAME  = 'TIPCS020' 
              AND T$KOPR.COLUMNNAME = 'T$KOPR' 
              AND T$KOPR.CONSTANT   = SOURCETABLE.T$KOPR 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CALCULATIONGROUP AS CALCULATIONGROUP, 
        source_data.CALCULATIONOFFICE AS CALCULATIONOFFICE, 
        source_data.CSTACCEPTANCERECEIVED AS CSTACCEPTANCERECEIVED, 
        source_data.DATEFILLEDBYSALESDESCRIPTION AS DATEFILLEDBYSALESDESCRIPTION, 
        source_data.DATEFILLEDBYSALESID AS DATEFILLEDBYSALESID, 
        source_data.ENGINEERINGALLOWEDDESCRIPTION AS ENGINEERINGALLOWEDDESCRIPTION, 
        source_data.ENGINEERINGALLOWEDID AS ENGINEERINGALLOWEDID, 
        source_data.FIRSTFREEITEMCODE AS FIRSTFREEITEMCODE, 
        source_data.PRICECALCULATIONCODE AS PRICECALCULATIONCODE, 
        source_data.PROCESSACCEPTANCERECEIVED AS PROCESSACCEPTANCERECEIVED, 
        source_data.PRODUCTIONORDER AS PRODUCTIONORDER, 
        source_data.PROJECT AS PROJECT, 
        source_data.PROJECTEMPLOYEE AS PROJECTEMPLOYEE, 
        source_data.PROJECTTYPEDESCRIPTION AS PROJECTTYPEDESCRIPTION, 
        source_data.PROJECTTYPEID AS PROJECTTYPEID, 
        source_data.REFERENCE AS REFERENCE, 
        source_data.REFERENCEDATE AS REFERENCEDATE, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER, 
        source_data.THIRDPARTYINSPECTIONCOMPLETED AS THIRDPARTYINSPECTIONCOMPLETED, 
        source_data.TOOLPHYSICALLYSHIPPED AS TOOLPHYSICALLYSHIPPED, 
        source_data.TOOLSERIALNUMBER AS TOOLSERIALNUMBER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CALCULATIONGROUP as VARCHAR(6)) as CALCULATIONGROUP,
        cast(CALCULATIONOFFICE as VARCHAR(6)) as CALCULATIONOFFICE,
        cast(CSTACCEPTANCERECEIVED as TIMESTAMP_NTZ(9)) as CSTACCEPTANCERECEIVED,
        cast(DATEFILLEDBYSALESDESCRIPTION as VARCHAR(16777216)) as DATEFILLEDBYSALESDESCRIPTION,
        cast(DATEFILLEDBYSALESID as NUMBER(38,0)) as DATEFILLEDBYSALESID,
        cast(ENGINEERINGALLOWEDDESCRIPTION as VARCHAR(16777216)) as ENGINEERINGALLOWEDDESCRIPTION,
        cast(ENGINEERINGALLOWEDID as NUMBER(38,0)) as ENGINEERINGALLOWEDID,
        cast(FIRSTFREEITEMCODE as NUMBER(38,0)) as FIRSTFREEITEMCODE,
        cast(PRICECALCULATIONCODE as VARCHAR(3)) as PRICECALCULATIONCODE,
        cast(PROCESSACCEPTANCERECEIVED as TIMESTAMP_NTZ(9)) as PROCESSACCEPTANCERECEIVED,
        cast(PRODUCTIONORDER as VARCHAR(9)) as PRODUCTIONORDER,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(PROJECTEMPLOYEE as VARCHAR(6)) as PROJECTEMPLOYEE,
        cast(PROJECTTYPEDESCRIPTION as VARCHAR(16777216)) as PROJECTTYPEDESCRIPTION,
        cast(PROJECTTYPEID as NUMBER(38,0)) as PROJECTTYPEID,
        cast(REFERENCE as VARCHAR(20)) as REFERENCE,
        cast(REFERENCEDATE as TIMESTAMP_NTZ(9)) as REFERENCEDATE,
        cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
        cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
        cast(THIRDPARTYINSPECTIONCOMPLETED as TIMESTAMP_NTZ(9)) as THIRDPARTYINSPECTIONCOMPLETED,
        cast(TOOLPHYSICALLYSHIPPED as TIMESTAMP_NTZ(9)) as TOOLPHYSICALLYSHIPPED,
        cast(TOOLSERIALNUMBER as VARCHAR(12)) as TOOLSERIALNUMBER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data