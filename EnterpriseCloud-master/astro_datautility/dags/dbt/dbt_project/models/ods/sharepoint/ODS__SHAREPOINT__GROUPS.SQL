/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Repository\EnterpriseCloud\Snowflake\LZ_2_ODS-Sharepoint\GroupList.SQL 
-newFile C:\Repository\EnterpriseCloud\dbt\lz_to_ods\models\sharepoint\Groups.SQL 
-materialized incremental
-alias Groups 
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
    alias='Groups',
    unique_key = ['GroupUniqueId',
    'GroupId']
) }}


with source_data as 
(
SELECT
        SourceData._Filename as _Filename
        ,SourceData._Filedate as _Filedate
      --  ,JsonField:List::STRING AS ListName
      --  ,DataItems.Value::VARIANT AS DataOfList
        ,DataItems.Value:UniqueId::STRING AS GroupUniqueId
        ,DataItems.Value:ID::STRING AS GroupId
        ,DataItems.Value:Name::STRING AS GroupName
        ,DataItems.Value:Description::STRING AS Description
        ,DataItems.Value:Approver_1:Email::STRING AS ApproverEmail1
        ,DataItems.Value:Approver_2:Email::STRING AS ApproverEmail2
        ,DataItems.Value:Author:Email::STRING AS AuthorEmail
        ,DataItems.Value:Editor:Email::STRING AS EditorEmail
        ,DataItems.Value:Created_x0020_Date::TIMESTAMP_NTZ AS CreatedDatetime  
        ,DataItems.Value:Last_x0020_Modified::TIMESTAMP_NTZ AS LastModifiedDatetime
    FROM {{ source("SHAREPOINT", "LISTS") }} SourceData 
        ,LATERAL FLATTEN (input => JsonField:Data) DataItems 
        WHERE SourceData._Filedate = (SELECT MAX(_FileDate) FROM {{ source("SHAREPOINT", "LISTS") }} where JsonField:List::STRING = 'BI Access Groups Requests Lookup') 
        AND JsonField:List::STRING = 'BI Access Groups Requests Lookup' 
        )
,transform_data as
(
    SELECT 
        source_data.GROUPUNIQUEID AS GroupUniqueId, 
        source_data.GROUPID AS GroupId, 
        source_data.GROUPNAME AS GroupName, 
        source_data.DESCRIPTION AS Description, 
        source_data.APPROVEREMAIL1 AS ApproverEMail1, 
        source_data.APPROVEREMAIL2 AS ApproverEmail2, 
        source_data.AUTHOREMAIL AS AuthorEmail, 
        source_data.EDITOREMAIL AS EditorEmail, 
        source_data.CREATEDDATETIME AS CreatedDatetime, 
        source_data.LASTMODIFIEDDATETIME AS LastModifiedDatetime, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(GROUPUNIQUEID as VARCHAR(16777216)) as GROUPUNIQUEID,
        cast(GROUPID as VARCHAR(16777216)) as GROUPID,
        cast(GROUPNAME as VARCHAR(16777216)) as GROUPNAME,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(APPROVEREMAIL1 as VARCHAR(16777216)) as APPROVEREMAIL1,
        cast(APPROVEREMAIL2 as VARCHAR(16777216)) as APPROVEREMAIL2,
        cast(AUTHOREMAIL as VARCHAR(16777216)) as AUTHOREMAIL,
        cast(EDITOREMAIL as VARCHAR(16777216)) as EDITOREMAIL,
        cast(CREATEDDATETIME as TIMESTAMP_NTZ(9)) as CREATEDDATETIME,
        cast(LASTMODIFIEDDATETIME as TIMESTAMP_NTZ(9)) as LASTMODIFIEDDATETIME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data