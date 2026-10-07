/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-Sharepoint\UserRequests.SQL 
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\sharepoint\UserRequests.SQL 
-materialized incremental
-alias UserRequests 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema SHAREPOINT
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/11/2022 8:35:02 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='UserRequests',
    unique_key = ['RequestUniqueId',
    'RequestId']
) }}


with source_data as 
(
SELECT
          SourceData._Filename as _Filename
          ,SourceData._Filedate as _Filedate
        -- ,JsonField:List::STRING AS ListName
        -- ,DataItems.Value::VARIANT AS DataOfList
          ,DataItems.Value:UniqueId::STRING AS RequestUniqueId
          ,DataItems.Value:ID::STRING AS RequestId
          ,DataItems.Value:Action::STRING AS RequestAction
          ,DataItems.Value:BI_Access_Group_Name:LookupId::Integer AS GroupId
          ,DataItems.Value:Employee_of_Interest:Email::STRING AS EmployeeEmail
          ,DataItems.Value:Approval_Status::STRING AS RequestStatus
          ,DataItems.Value:Approver_1_Date::STRING AS ApproverDate1
          ,DataItems.Value:Approver_2_Date::STRING AS ApproverDate2
          ,DataItems.Value:Approver_3_Date::STRING AS ApproverDate3
          ,DataItems.Value:Completed_Date::STRING AS CompletedDate
          ,DataItems.Value:Created_x0020_Date::TIMESTAMP_NTZ AS CreatedDatetime  
          ,DataItems.Value:Last_x0020_Modified::TIMESTAMP_NTZ AS LastModifiedDatetime
          ,DataItems.Value:Data_Steward:Email::STRING AS DataStewardEmail
          ,DataItems.Value:Executive:Email::STRING AS ExecutiveEmail
          ,DataItems.Value:Manager:Email::STRING AS ManagerEmail
        FROM {{ source("SHAREPOINT", "LISTS") }} SourceData 
        ,LATERAL FLATTEN (input => JsonField:Data) DataItems 
        WHERE SourceData._Filedate = (SELECT MAX(_FileDate) FROM {{ source("SHAREPOINT", "LISTS") }} WHERE JsonField:List::STRING = 'BI Access Groups Requests' ) 
        AND JsonField:List::STRING = 'BI Access Groups Requests' 
        )
,transform_data as
(
SELECT
        source_data.REQUESTUNIQUEID AS RequestUniqueId,
        source_data.REQUESTID AS RequestId,
        source_data.REQUESTACTION AS RequestAction,
        source_data.GROUPID AS GroupId,
        source_data.EMPLOYEEEMAIL AS EmployeeEmail,
        source_data.REQUESTSTATUS AS RequestStatus,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.APPROVERDATE1 , '/Date(' , '' ) , ')/' , '' ) ) ) AS ApproverDate1,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.APPROVERDATE2 , '/Date(' , '' ) , ')/' , '' ) ) ) AS ApproverDate2,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.APPROVERDATE3 , '/Date(' , '' ) , ')/' , '' ) ) ) AS ApproverDate3,
        source_data.CREATEDDATETIME AS CreatedDatetime,
        TO_DATE ( TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.COMPLETEDDATE , '/Date(' , '' ) , ')/' , '' ) ) ) AS CompletedDatetime,
        source_data.LASTMODIFIEDDATETIME AS LastModifiedDatetime,
        source_data.DATASTEWARDEMAIL AS DataStewardEmail,
        source_data.EXECUTIVEEMAIL AS ExecutiveEmail,
        source_data.MANAGEREMAIL AS ManagerEmail,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
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