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
   FROM {{ source('ACTIVEDIRECTORY', 'USERLIST') }}
        {% if is_tel_incremental() %}WHERE  _Filedate > IFNULL((SELECT MAX(_Filedate) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY UserId  ORDER BY _Filedate DESC)) = 1
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
        CAST(_Filedate AS TIMESTAMP_NTZ(9) ) AS _Filedate,
        _Filename AS _Filename,
        _Audit_Log_Id AS _Audit_Log_Id,
        _Row_Hash as _Row_Hash,
        UserId AS UserId,
        UserPrincipalName  AS UserPrincipalName,
        ObjectType  AS ObjectType,
        UsageLocation  AS UsageLocation,
        GivenName  AS GivenName,
        Surname  AS SurName,
        AccountEnabled  AS AccountEnabled,
        MailNickname  AS MailNickname,
        Mail  AS Mail,
        DisplayName  AS DisplayName,
        UserType  AS UserType,
    FROM transform_data
)
select * from type_data