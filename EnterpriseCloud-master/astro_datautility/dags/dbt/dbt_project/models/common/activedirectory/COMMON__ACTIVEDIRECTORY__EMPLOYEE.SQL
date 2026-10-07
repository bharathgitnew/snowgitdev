{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='employee',
    unique_key = ['UserId']
) }}


with source_data as
(
    SELECT * FROM {{ ref('ODS__ACTIVEDIRECTORY__USERLIST') }}
)
,transform_data as
(
	SELECT
		 UserID
		,UserPrincipalName
		,GivenName
		,SurName
		,MailNickName
		,Mail
		,DisplayName
		,AccountEnabled
		,'{{ invocation_id }}' AS Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash -- Adds column to table on full refresh.
	FROM source_data
	WHERE LEN(MailNickName) = 6
	QUALIFY ROW_NUMBER() OVER (PARTITION BY MailNickname ORDER BY MailNickname,CASE WHEN AccountEnabled = 'true' THEN 1 ELSE 2 END ) = 1
)
,type_data AS
(
	select
		 CAST(UserID AS VARCHAR(16777216)) AS UserId
		,CAST(UserPrincipalName AS VARCHAR(16777216)) AS UserPrincipalName
		,CAST(GivenName AS VARCHAR(16777216)) AS GivenName
		,CAST(SurName AS VARCHAR(16777216)) AS SurName
		,CAST(MailNickName AS VARCHAR(16777216)) AS MailNickName
		,CAST(Mail AS VARCHAR(16777216)) AS Mail
		,CAST(DisplayName AS VARCHAR(16777216)) AS DisplayName
		,CAST(AccountEnabled AS VARCHAR(16777216)) AS AccountEnabled
		,CAST(Audit_Log_Id AS VARCHAR(128)) AS Audit_Log_Id
        ,CAST(_Row_Hash AS VARCHAR(128)) AS _Row_Hash
	from transform_data
)
SELECT
	 UserID
	,UserPrincipalName
	,GivenName
	,SurName
	,MailNickName
	,Mail
	,DisplayName
	,AccountEnabled
	,Audit_Log_Id
	,_Row_Hash
FROM type_data