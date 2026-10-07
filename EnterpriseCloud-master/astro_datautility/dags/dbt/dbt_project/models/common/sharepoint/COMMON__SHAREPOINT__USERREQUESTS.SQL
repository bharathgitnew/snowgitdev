/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-Sharepoint\USERREQUESTS.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\sharepoint\USERREQUESTS.SQL
-materialized incremental
-alias USERREQUESTS
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema SHAREPOINT
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 03-Feb-22 6:51:36 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='USERREQUESTS',
    unique_key = ['RequestUniqueId',
    'RequestId']
) }}

with
source_data as
(
 SELECT
ODSUserRequests.RequestUniqueId AS RequestUniqueId,
ODSUserRequests.RequestId AS RequestId,
ODSUserRequests.RequestAction AS RequestAction,
ODSUserRequests.GroupId AS GroupId,
ODSUserRequests.EmployeeEmail AS EmployeeEmail,
ODSUserRequests.RequestStatus AS RequestStatus,
ODSUserRequests.ApproverDate1 AS ApproverDate1,
ODSUserRequests.ApproverDate2 AS ApproverDate2,
ODSUserRequests.ApproverDate3 AS ApproverDate3,
ODSUserRequests.CreatedDatetime AS CreatedDatetime,
ODSUserRequests.CompletedDatetime AS CompletedDatetime,
ODSUserRequests.LastModifiedDatetime AS LastModifiedDatetime,
ODSUserRequests.DataStewardEmail AS DataStewardEmail,
ODSUserRequests.ExecutiveEmail AS ExecutiveEmail,
ODSUserRequests.ManagerEmail AS ManagerEmail
        FROM
            {{ ref('ODS__SHAREPOINT__USERREQUESTS') }} AS ODSUserRequests
    )

,
    transform_data
    as
(
        SELECT
RequestUniqueId,
RequestId,
RequestAction,
GroupId,
EmployeeEmail,
RequestStatus,
ApproverDate1,
ApproverDate2,
ApproverDate3,
CreatedDatetime,
CompletedDatetime,
LastModifiedDatetime,
DataStewardEmail,
ExecutiveEmail,
ManagerEmail,
    '{{ invocation_id }}' AS AUDIT_LOG_ID
        , SHA2('hash_me') as _ROW_HASH
-- Adds column to table on full refresh.
FROM source_data
    )

,type_data as 
(
    select
        cast(REQUESTUNIQUEID as VARCHAR(16777216)) as REQUESTUNIQUEID,
        cast(REQUESTID as VARCHAR(16777216)) as REQUESTID,
        cast(REQUESTACTION as VARCHAR(16777216)) as REQUESTACTION,
        cast(GROUPID as VARCHAR(16777216)) as GROUPID,
        cast(EMPLOYEEEMAIL as VARCHAR(16777216)) as EMPLOYEEEMAIL,
        cast(REQUESTSTATUS as VARCHAR(16777216)) as REQUESTSTATUS,
        cast(APPROVERDATE1 as TIMESTAMP_NTZ(9)) as APPROVERDATE1,
        cast(APPROVERDATE2 as TIMESTAMP_NTZ(9)) as APPROVERDATE2,
        cast(APPROVERDATE3 as TIMESTAMP_NTZ(9)) as APPROVERDATE3,
        cast(CREATEDDATETIME as TIMESTAMP_NTZ(9)) as CREATEDDATETIME,
        cast(COMPLETEDDATETIME as TIMESTAMP_NTZ(9)) as COMPLETEDDATETIME,
        cast(LASTMODIFIEDDATETIME as TIMESTAMP_NTZ(9)) as LASTMODIFIEDDATETIME,
        cast(DATASTEWARDEMAIL as VARCHAR(16777216)) as DATASTEWARDEMAIL,
        cast(EXECUTIVEEMAIL as VARCHAR(16777216)) as EXECUTIVEEMAIL,
        cast(MANAGEREMAIL as VARCHAR(16777216)) as MANAGEREMAIL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data