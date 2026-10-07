{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ACTIVITY'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename,
        _Filedate as _Filedate,
        JSONFIELD:Id::STRING AS Id,
        JSONFIELD:RecordType::STRING AS RecordType,
        JSONFIELD:CreationTime::STRING AS CreationTime,
        JSONFIELD:Operation::STRING AS Operation,
        JSONFIELD:OrganizationId::STRING AS OrganizationId,
        JSONFIELD:UserType::STRING AS UserType,
        JSONFIELD:UserKey::STRING AS UserKey,
        JSONFIELD:Workload::STRING AS Workload,
        JSONFIELD:UserId::STRING AS UserId,
        JSONFIELD:ClientIP::STRING AS ClientIP,
        JSONFIELD:UserAgent::STRING AS UserAgent,
        JSONFIELD:Activity::STRING AS Activity,
        JSONFIELD:IsSuccess::STRING AS IsSuccess,
        JSONFIELD:RequestId::STRING AS RequestId,
        JSONFIELD:ActivityId::STRING AS ActivityId,
        JSONFIELD:ItemName::STRING AS ItemName,
        JSONFIELD:WorkSpaceName::STRING AS WorkSpaceName,
        JSONFIELD:DatasetName::STRING AS DatasetName,
        JSONFIELD:ReportName::STRING AS ReportName,
        JSONFIELD:WorkspaceId::STRING AS WorkspaceId,
        JSONFIELD:ObjectId::STRING AS ObjectId,
        JSONFIELD:DatasetId::STRING AS DatasetId,
        JSONFIELD:ReportId::STRING AS ReportId,
        JSONFIELD:ReportType::STRING AS ReportType,
        JSONFIELD:DistributionMethod::STRING AS DistributionMethod,
        JSONFIELD:ConsumptionMethod::STRING AS ConsumptionMethod
    FROM {{ source("POWERBI", "ACTIVITY") }} Activity
        where _Filedate > (select COALESCE(max(_Filedate),'1900-01-01') from {{ this }})
)
,transform_data as
(
    SELECT
        _FILENAME as _FILENAME,
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        Id AS ID,
        RecordType AS RECORDTYPE,
        CreationTime AS CREATIONTIME,
        Operation AS OPERATION,
        OrganizationId AS ORGANIZATIONID,
        UserType AS USERTYPE,
        UserKey AS USERKEY,
        Workload AS WORKLOAD,
        UserId AS USERID,
        ClientIP AS CLIENTIP,
        UserAgent AS USERAGENT,
        Activity AS ACTIVITY,
        IsSuccess AS ISSUCCESS,
        RequestId AS REQUESTID,
        ActivityId AS ACTIVITYID,
        ItemName AS ITEMNAME,
        WorkSpaceName AS WORKSPACENAME,
        DatasetName AS DATASETNAME,
        ReportName AS REPORTNAME,
        WorkspaceId AS WORKSPACEID,
        ObjectId AS OBJECTID,
        DatasetId AS DATASETID,
        ReportId AS REPORTID,
        ReportType AS REPORTTYPE,
        DistributionMethod AS DISTRIBUTIONMETHOD,
        ConsumptionMethod AS CONSUMPTIONMETHOD
    FROM source_data
)
, type_data AS
(
    SELECT
        CAST(_Audit_Log_Id AS VARCHAR(128))  AS _Audit_Log_Id,
        CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        ID,
        RECORDTYPE,
        CAST(CREATIONTIME AS TIMESTAMP_NTZ(9)) AS CREATIONTIME,
        OPERATION,
        ORGANIZATIONID,
        USERTYPE,
        USERKEY,
        WORKLOAD,
        USERID,
        CLIENTIP,
        USERAGENT,
        ACTIVITY,
        ISSUCCESS,
        REQUESTID,
        ACTIVITYID,
        ITEMNAME,
        WORKSPACENAME,
        DATASETNAME,
        REPORTNAME,
        WORKSPACEID,
        OBJECTID,
        DATASETID,
        REPORTID,
        REPORTTYPE,
        DISTRIBUTIONMETHOD,
        CONSUMPTIONMETHOD
    FROM transform_data
)
select * from type_data