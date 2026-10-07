/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-Sharepoint\GROUPS.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\sharepoint\GROUPS.SQL
-materialized incremental
-alias GROUPS
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
    alias='GROUPS',
    unique_key = ['GroupUniqueId',
    'GroupId']
) }}

with
    source_data
    as
    (
        SELECT
ODSGroups.GroupUniqueId AS GroupUniqueId,
ODSGroups.GroupId AS GroupId,
ODSGroups.GroupName AS GroupName,
ODSGroups.Description AS Description,
ODSGroups.ApproverEMail1 AS ApproverEMail1,
ODSGroups.ApproverEmail2 AS ApproverEmail2,
ODSGroups.AuthorEmail AS AuthorEmail,
ODSGroups.EditorEmail AS EditorEmail,
ODSGroups.CreatedDatetime AS CreatedDatetime,
ODSGroups.LastModifiedDatetime AS LastModifiedDatetime
        FROM
            {{ ref('ODS__SHAREPOINT__GROUPS') }} AS ODSGroups
    )

,
transform_data as
(
SELECT
    GroupUniqueId,
    GroupId,
    GroupName,
    Description,
    ApproverEMail1,
    ApproverEmail2,
    AuthorEmail,
    EditorEmail,
    CreatedDatetime,
    LastModifiedDatetime,
    '{{ invocation_id }}' AS AUDIT_LOG_ID
        , SHA2('hash_me') as _ROW_HASH
-- Adds column to table on full refresh.
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