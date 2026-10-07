{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='GroupList',
    unique_key = ['GroupId']
) }}


with source_data as
(
    SELECT
         _Filename as _Filename
        ,_Filedate as _Filedate
        ,JSonField:id::STRING AS GroupId
        ,JSonField:description::STRING AS Description
        ,'Group' AS ObjectType
        ,JSonField:securityEnabled::STRING AS SecurityEnabled
        ,JSonField:mailNickname::STRING AS MailNickname
        ,JSonField:displayName::STRING AS DisplayName
        ,JSonField:Type::STRING AS GroupType
    {%- if is_incremental() %}
        FROM {{ source("ACTIVEDIRECTORY", "GROUPLIST") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("ACTIVEDIRECTORY", "GROUPLIST") }})
    {%- else %}
        FROM {{ source("ACTIVEDIRECTORY", "GROUPLIST") }}
        QUALIFY (ROW_NUMBER() OVER ( PARTITION BY GroupId ORDER BY _Filedate DESC )) = 1
    {%- endif %}
)
,transform_data as
(
    SELECT
         GroupId AS GroupId
        ,DisplayName AS DisplayName
        ,SecurityEnabled AS SecurityEnabled
        ,MailNickname AS MailNickname
        ,ObjectType AS ObjectType
        ,Description AS Description
        ,GroupType AS Type
        ,'{{ invocation_id }}' AS Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash
    FROM source_data
)
, type_data AS
(
    SELECT
         CAST(GroupId AS VARCHAR(16777216))  AS GroupId
        ,CAST(DisplayName AS VARCHAR(16777216))  AS DisplayName
        ,CAST(SecurityEnabled AS VARCHAR(16777216))  AS SecurityEnabled
        ,CAST(MailNickname AS VARCHAR(16777216))  AS MailNickname
        ,CAST(ObjectType AS VARCHAR(16777216))  AS ObjectType
        ,CAST(Description AS VARCHAR(16777216))  AS Description
        ,CAST(Type AS VARCHAR(16777216))  AS Type
        ,CAST(Audit_Log_Id AS VARCHAR(128))  AS Audit_Log_Id
        ,CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash
    FROM transform_data
)
select
     GroupId
    ,DisplayName
    ,SecurityEnabled
    ,MailNickname
    ,ObjectType
    ,Description
    ,Type
    ,Audit_Log_Id
    ,_Row_Hash
from type_data