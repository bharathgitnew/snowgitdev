{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='GroupMembershipList',
    unique_key =['GroupObjectId',
    'MemberId']
) }}


with source_data as
(
    SELECT * FROM {{ ref('ODS__ACTIVEDIRECTORY__GROUPMEMBERSHIPLIST') }}
)
,transform_data as
(
    SELECT
         GroupId
        ,MemberId
        ,'{{ invocation_id }}' AS Audit_Log_Id
    FROM source_data
)
,type_data as
(
    SELECT
         CAST(GroupId AS VARCHAR(16777216)) AS GroupId
        ,CAST(MemberId AS VARCHAR(16777216)) AS MemberId
        ,CAST(Audit_Log_Id AS VARCHAR(128)) AS Audit_Log_Id
    FROM transform_data
)
select
     GroupId
    ,MemberId
    ,Audit_Log_Id
from type_data