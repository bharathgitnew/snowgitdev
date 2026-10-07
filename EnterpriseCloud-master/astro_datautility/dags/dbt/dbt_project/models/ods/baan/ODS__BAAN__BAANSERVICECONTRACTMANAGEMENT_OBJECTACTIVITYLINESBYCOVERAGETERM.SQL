/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANServiceContractManagement_ObjectActivityLinesByCoverageTerm.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANServiceContractManagement_ObjectActivityLinesByCoverageTerm.SQL 
-materialized incremental
-alias BAANServiceContractManagement_ObjectActivityLinesByCoverageTerm 
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
    alias='BAANServiceContractManagement_ObjectActivityLinesByCoverageTerm',
    unique_key = ['_CompanyId',
    'Configuration_CFGR',
    'CostTypeId',
    'CoverageTermNumber',
    'SequenceNumber',
    'ServiceType',
    'TermId']
) }}


with source_data as 
(
    SELECT 
             SourceTable._capturedatetime                AS _CaptureDatetime 
            ,201                                         AS _CompanyId 
            ,CAST(t$aseq AS INT)                         AS ActivityNumber 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$ccfg)),'') AS Configuration_ccfg 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cfgr)),'') AS Configuration_cfgr 
            ,t$cotp.ConstantDescription                  AS CostTypeDescription 
            ,CAST(t$cotp AS INT)                         AS CostTypeId 
            ,CAST(t$nrbt AS INT)                         AS CoverageTermNumber 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cmdl)),'') AS ModelItem 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$crob)),'') AS Object 
            ,CAST(t$oseq AS INT)                         AS ObjectNumber 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$crac)),'') AS ReferenceActivity 
            ,CAST(t$seqn AS INT)                         AS SequenceNo 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cser)),'') AS SerialNumber 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cstp)),'') AS ServiceType 
            ,CAST(t$term AS BIGINT)                      AS TermID 
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM122201") }} AS SourceTable
            /*CostType*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS t$cotp 
             ON   t$cotp.TableName  = 'tsctm122' 
              AND t$cotp.ColumnName = 't$cotp' 
              AND t$cotp.Constant   = SourceTable.t$cotp 
            WHERE FALSE
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CaptureDateTime, 
        source_data._COMPANYID AS _CompanyId, 
        source_data.ACTIVITYNUMBER AS ActivityNumber, 
        source_data.CONFIGURATION_CCFG AS Configuration_CCFG, 
        source_data.CONFIGURATION_CFGR AS Configuration_CFGR, 
        source_data.COSTTYPEDESCRIPTION AS CostTypeDescription, 
        source_data.COSTTYPEID AS CostTypeId, 
        source_data.COVERAGETERMNUMBER AS CoverageTermNumber, 
        source_data.MODELITEM AS ModelItem, 
        source_data.OBJECT AS Object, 
        source_data.OBJECTNUMBER AS ObjectNumber, 
        source_data.REFERENCEACTIVITY AS ReferenceActivity, 
        source_data.SEQUENCENO AS SequenceNumber, 
        source_data.SERIALNUMBER AS SerialNumber, 
        source_data.SERVICETYPE AS ServiceType, 
        source_data.TERMID AS TermId
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_NTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(38,0)) as _COMPANYID,
        cast(ACTIVITYNUMBER as NUMBER(38,0)) as ACTIVITYNUMBER,
        cast(CONFIGURATION_CCFG as VARCHAR(16777216)) as CONFIGURATION_CCFG,
        cast(CONFIGURATION_CFGR as VARCHAR(16777216)) as CONFIGURATION_CFGR,
        cast(COSTTYPEDESCRIPTION as VARCHAR(16777216)) as COSTTYPEDESCRIPTION,
        cast(COSTTYPEID as NUMBER(38,0)) as COSTTYPEID,
        cast(COVERAGETERMNUMBER as NUMBER(38,0)) as COVERAGETERMNUMBER,
        cast(MODELITEM as VARCHAR(16777216)) as MODELITEM,
        cast(OBJECT as VARCHAR(16777216)) as OBJECT,
        cast(OBJECTNUMBER as NUMBER(38,0)) as OBJECTNUMBER,
        cast(REFERENCEACTIVITY as VARCHAR(16777216)) as REFERENCEACTIVITY,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SERIALNUMBER as VARCHAR(16777216)) as SERIALNUMBER,
        cast(SERVICETYPE as VARCHAR(16777216)) as SERVICETYPE,
        cast(TERMID as NUMBER(38,0)) as TERMID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data