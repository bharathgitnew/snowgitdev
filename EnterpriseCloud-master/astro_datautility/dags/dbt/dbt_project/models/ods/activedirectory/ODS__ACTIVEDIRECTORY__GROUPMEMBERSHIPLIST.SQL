/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-activedirectory\GroupMembershipList__ActiveDirectory_GroupMembership.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\activedirectory\Group_Membership_List.SQL
-materialized incremental
-alias Group_Membership_List
-incremental_strategy insert_overwrite
-envVariable <<LZ>>
-sourceSchema activedirectory
-sourceDatabase LZ_DEV
-useDistinct $false
model file generated on: 1/14/2022 8:44:43 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='GroupMembershipList'
) }}


with source_data as
(
    SELECT
        _Filename
        ,_Filedate
        ,JsonField:groups_id::String as GroupObjectId
        ,JsonField:id::String as MemberId
        ,JsonField:displayName::String as MemberName
    FROM {{ source("ACTIVEDIRECTORY", "GROUPMEMBERSHIP") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("ACTIVEDIRECTORY", "GROUPMEMBERSHIP") }})
     AND JsonField:"@odata.type"::String = '#microsoft.graph.user'
)
,transform_data as
(
    SELECT
        _Filename
        ,_Filedate
        ,'{{ invocation_id }}' AS _Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash
        ,GroupObjectId AS GroupId
        ,MemberId
        ,MemberName
    FROM source_data
    WHERE GroupObjectId IS NOT NULL
      AND MemberId IS NOT NULL
)
,type_data AS
(
    SELECT
        CAST(_Filename AS VARCHAR(16777216) ) AS _Filename,
        CAST(_Filedate AS TIMESTAMP_NTZ(9) ) AS _Filedate,
        CAST(_Audit_Log_Id AS VARCHAR(128) ) AS _Audit_Log_Id,
        CAST(_Row_Hash AS VARCHAR(128) ) as _Row_Hash,
        CAST(GroupId AS VARCHAR(16777216))  AS GroupId,
        CAST(MemberId AS VARCHAR(16777216))  AS MemberId,
        CAST(MemberName AS VARCHAR(16777216))  AS MemberName,
        
    FROM transform_data
)
select
     *
from type_data