{{ config(
    materialized = 'tel_incremental',
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
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _Filename AS _Filename,
        _Filedate AS _Filedate,
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
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _Filename,
        CAST(_Filedate AS TIMESTAMP_NTZ(9) ) AS _Filedate,
        UserId,
        UserPrincipalName,
        ObjectType,
        UsageLocation,
        GivenName,
        SurName,
        AccountEnabled,
        MailNickname,
        Mail,
        DisplayName,
        UserType
    FROM transform_data
)
select * from type_data