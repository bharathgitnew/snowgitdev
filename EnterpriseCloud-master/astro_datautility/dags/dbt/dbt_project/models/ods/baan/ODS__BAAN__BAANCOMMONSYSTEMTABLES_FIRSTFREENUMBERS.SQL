/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_FIRSTFREENUMBERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_FIRSTFREENUMBERS.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_FIRSTFREENUMBERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONSYSTEMTABLES_FIRSTFREENUMBERS',
    unique_key = ['NUMBERGROUP',
    'SERIES']
) }}


with source_data as 
(
    SELECT 
             SourceTable._capturedatetime                AS _CaptureDatetime 
            ,201                                           AS _CompanyId 
            ,CAST(t$ffno AS BIGINT)                      AS FirstFreeNumber 
            ,CAST(t$ffst AS TINYINT)                     AS FirstFreeNumberCacheSize 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$nrgr)),'') AS NumberGroup 
        ---- 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$seri)),'') AS Series 
            ,t$blck.ConstantDescription                  AS SeriesBlockedForInputDescription 
            ,CAST(t$blck AS INT)                         AS SeriesBlockedForInputId 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$dsca)),'') AS SeriesDescription 
        ,'Insert' AS Metadata$Action 
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS050201") }} AS SourceTable  
            /*SeriesBlockedForInput*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS t$blck 
             ON   t$blck.TableName  = 'tcmcs050' 
              AND t$blck.ColumnName = 't$blck' 
              AND t$blck.Constant   = SourceTable.t$blck 
            WHERE FALSE
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.FIRSTFREENUMBER AS FIRSTFREENUMBER, 
        source_data.FIRSTFREENUMBERCACHESIZE AS FIRSTFREENUMBERCACHESIZE, 
        source_data.NUMBERGROUP AS NUMBERGROUP, 
        source_data.SERIES AS SERIES, 
        source_data.SERIESBLOCKEDFORINPUTDESCRIPTION AS SERIESBLOCKEDFORINPUTDESCRIPTION, 
        source_data.SERIESBLOCKEDFORINPUTID AS SERIESBLOCKEDFORINPUTID, 
        source_data.SERIESDESCRIPTION AS SERIESDESCRIPTION
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(38,0)) as _COMPANYID,
        cast(FIRSTFREENUMBER as NUMBER(38,0)) as FIRSTFREENUMBER,
        cast(FIRSTFREENUMBERCACHESIZE as NUMBER(38,0)) as FIRSTFREENUMBERCACHESIZE,
        cast(NUMBERGROUP as VARCHAR(16777216)) as NUMBERGROUP,
        cast(SERIES as VARCHAR(16777216)) as SERIES,
        cast(SERIESBLOCKEDFORINPUTDESCRIPTION as VARCHAR(16777216)) as SERIESBLOCKEDFORINPUTDESCRIPTION,
        cast(SERIESBLOCKEDFORINPUTID as NUMBER(38,0)) as SERIESBLOCKEDFORINPUTID,
        cast(SERIESDESCRIPTION as VARCHAR(16777216)) as SERIESDESCRIPTION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data