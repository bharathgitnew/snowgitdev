{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ACTIVEDIRECTORY_USERLIST',
    unique_key = ['UserId']
) }}


with source_data as
(
    SELECT
        _Filename as _Filename,
        _Filedate as _Filedate,
        JSonField:id::STRING AS UserId,
        JSonField:userPrincipalName::STRING AS UserPrincipalName,
        'User' AS ObjectType,
        JSonField:usageLocation::STRING AS UsageLocation,
        JSonField:givenName::STRING AS GivenName,
        JSonField:surname::STRING AS Surname,
        JSonField:accountEnabled::STRING AS AccountEnabled,
        JSonField:mailNickname::STRING AS MailNickname,
        JSonField:mail::STRING AS Mail,
        JSonField:displayName::STRING AS DisplayName,
        JSonField:userType::STRING AS UserType,
    {%- if is_tel_incremental() %}
    FROM {{ source("ACTIVEDIRECTORY", "USERLIST") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("ACTIVEDIRECTORY", "USERLIST") }})
    {%- else %}
    FROM {{ source("ACTIVEDIRECTORY", "USERLIST") }}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY UserId ORDER BY _Filedate DESC) )= 1
    {%- endif %}
)
,transform_data as
(
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        UserId AS UserId,
        UserPrincipalName AS UserPrincipalName,
        ObjectType AS ObjectType,
        UsageLocation AS UsageLocation,
        GivenName AS GivenName,
        Surname AS SurName,
        AccountEnabled AS AccountEnabled,
        MailNickname AS MailNickname,
        Mail AS Mail,
        DisplayName AS DisplayName,
        UserType AS UserType,
    FROM source_data
)
,type_data AS
(
    SELECT
        CAST(_Filename AS VARCHAR(16777216) ) AS _Filename,
        CAST(_Filedate AS TIMESTAMP_NTZ(9) ) AS _Filedate,
        CAST(_Audit_Log_Id AS VARCHAR(128) ) AS _Audit_Log_Id,
        CAST(_Row_Hash AS VARCHAR(128) ) as _Row_Hash,
        CAST(UserId AS VARCHAR(16777216) ) AS UserId,
        CAST(UserPrincipalName AS VARCHAR(16777216) )  AS UserPrincipalName,
        CAST(ObjectType AS VARCHAR(16777216) )  AS ObjectType,
        CAST(UsageLocation AS VARCHAR(16777216) )  AS UsageLocation,
        CAST(GivenName AS VARCHAR(16777216) )  AS GivenName,
        CAST(Surname AS VARCHAR(16777216) )  AS SurName,
        CAST(AccountEnabled AS VARCHAR(16777216) )  AS AccountEnabled,
        CAST(MailNickname AS VARCHAR(16777216) )  AS MailNickname,
        CAST(Mail AS VARCHAR(16777216) )  AS Mail,
        CAST(DisplayName AS VARCHAR(16777216) )  AS DisplayName,
        CAST(UserType AS VARCHAR(16777216) )  AS UserType,
    FROM transform_data
)
select * from type_data

