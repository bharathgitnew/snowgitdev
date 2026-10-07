/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Ariba\AuditLog__Ariba_AuditLog.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\ariba\AuditLog.SQL
-materialized incremental
-alias AuditLog
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema ARIBA
-sourceDatabase LZ_DEV
-useDistinct yes
model file generated on: 1/10/2022 2:27:23 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='AuditLog',
    unique_key = ['FILENAME',
    'REALM',
    'DOCUMENTTYPE']
) }}


with source_data as
(
    SELECT
             _FileName
            ,REPLACE(_FileName,'F:SharesFilesAribaAuditLog.','') as FileName
            ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) as Realm
            ,regexp_substr(_FileName, '\\.(\\w+)\\.',1,1,'e',1) as DocumentType
        --    ,regexp_substr(_FileName, '\\w{8}\\-*\\w{4}\\-*\\w{4}\\-*\\w{4}\\-*\\w{25}') as JobId
            ,JSonField:Name::STRING AS JobId
            ,JSonField:Value:viewTemplateName::STRING AS ViewTemplateName
        --    ,JSonField:Value::STRING AS ValueString
            ,REPLACE(JSonField:Value:CreatedDatetime::STRING,'T',' ')::TIMESTAMP_NTZ AS DataRequestedDatetime
            ,REPLACE(JSonField:Value:CompletedDatetime::STRING,'T',' ')::TIMESTAMP_NTZ AS CompletedDatetime
            ,REPLACE(JSonField:Value:ProcessedDatetime::STRING,'T',' ')::TIMESTAMP_NTZ AS ProcessedDatetime
            ,JSonField:Value:TotalNumberOfFiles::INTEGER AS TotalNumberOfFiles
            ,JSonField:Value:files::STRING AS FileNameList
            ,JSonField:Value:TotalNumberOfRecords::INTEGER AS TotalNumberOfRecords
            ,REPLACE(JSonField:Value:filter:updatedDateFrom::STRING,'T',' ')::TIMESTAMP_NTZ AS ParameterStartDate
            ,REPLACE(JSonField:Value:filter:updatedDateTo::STRING,'T',' ')::TIMESTAMP_NTZ AS ParameterEndDate
            ,JSonField:Value:Status::STRING AS StatusString
        FROM {{ source("ARIBA", "AUDITLOG") }}
        WHERE _FileName NOT IN (SELECT FileName FROM {{ this }})
)
,transform_data as
(
    SELECT
        source_data.FILENAME AS FILENAME,
        source_data.REALM AS REALM,
        source_data.DOCUMENTTYPE AS DOCUMENTTYPE,
        source_data.VIEWTEMPLATENAME AS VIEWTEMPLATENAME,
        source_data.PARAMETERSTARTDATE AS PARAMETERSTARTDATETIME,
        source_data.PARAMETERENDDATE AS PARAMETERENDDATETIME,
        source_data.DATAREQUESTEDDATETIME AS REQUESTEDDATETIME,
        source_data.COMPLETEDDATETIME AS COMPLETEDDATETIME,
        source_data.PROCESSEDDATETIME AS PROCESSEDDATETIME,
        source_data.TOTALNUMBEROFFILES AS FILECOUNT,
        source_data.FILENAMELIST AS FILENAMELIST,
        source_data.TOTALNUMBEROFRECORDS AS RECORDCOUNT,
        source_data.JOBID AS JOBID,
        source_data.STATUSSTRING AS JOBSTATUS,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(FILENAME as VARCHAR(16777216)) as FILENAME,
        cast(REALM as VARCHAR(16777216)) as REALM,
        cast(DOCUMENTTYPE as VARCHAR(16777216)) as DOCUMENTTYPE,
        cast(VIEWTEMPLATENAME as VARCHAR(16777216)) as VIEWTEMPLATENAME,
        cast(PARAMETERSTARTDATETIME as TIMESTAMP_LTZ(9)) as PARAMETERSTARTDATETIME,
        cast(PARAMETERENDDATETIME as TIMESTAMP_LTZ(9)) as PARAMETERENDDATETIME,
        cast(REQUESTEDDATETIME as TIMESTAMP_LTZ(9)) as REQUESTEDDATETIME,
        cast(COMPLETEDDATETIME as TIMESTAMP_LTZ(9)) as COMPLETEDDATETIME,
        cast(PROCESSEDDATETIME as TIMESTAMP_LTZ(9)) as PROCESSEDDATETIME,
        cast(FILECOUNT as NUMBER(38,0)) as FILECOUNT,
        cast(FILENAMELIST as VARCHAR(16777216)) as FILENAMELIST,
        cast(RECORDCOUNT as NUMBER(38,0)) as RECORDCOUNT,
        cast(JOBID as VARCHAR(16777216)) as JOBID,
        cast(JOBSTATUS as VARCHAR(16777216)) as JOBSTATUS,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data