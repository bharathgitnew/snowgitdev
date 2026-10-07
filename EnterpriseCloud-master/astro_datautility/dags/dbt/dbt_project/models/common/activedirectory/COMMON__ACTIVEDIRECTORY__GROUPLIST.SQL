{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='GroupList',
    unique_key = ['GroupId']
) }}

with source_data as
(
    SELECT * FROM {{ ref('ODS__ACTIVEDIRECTORY__GROUPLIST') }}
)
,transform_data as
(
	SELECT
		 GroupId AS GroupId
		,DisplayName AS DisplayName
		,CASE WHEN SecurityEnabled = 'true' THEN 'Yes' ELSE 'No' END AS IsSecurityEnabled
		,MailNickname AS EMailAddress
		,Description AS Description
		,Type AS Type
		,'{{ invocation_id }}' AS Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash -- Adds column to table on full refresh.
	FROM source_data
)
,type_data AS
(
	select
		 CAST(GroupId AS VARCHAR(16777216)) AS GroupId
		,CAST(DisplayName AS VARCHAR(16777216)) AS DisplayName
		,CAST(IsSecurityEnabled AS VARCHAR(16777216)) AS IsSecurityEnabled
		,CAST(EMailAddress AS VARCHAR(16777216)) AS EMailAddress
		,CAST(Description AS VARCHAR(16777216)) AS Description
		,CAST(Type AS VARCHAR(16777216)) AS Type
		,CAST(Audit_Log_Id AS VARCHAR(128)) AS Audit_Log_Id
		,CAST(_Row_Hash AS VARCHAR(128)) AS _Row_Hash
	from transform_data
)
SELECT
	 GroupId
	,DisplayName
	,IsSecurityEnabled
	,EMailAddress
	,Description
	,Type
	,Audit_Log_Id
	,_Row_Hash
FROM type_data