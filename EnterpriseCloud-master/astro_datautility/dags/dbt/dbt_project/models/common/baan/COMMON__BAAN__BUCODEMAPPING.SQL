{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BUCodeMapping',
    unique_key = ['BUCodeByConfiguration',
    'BUCodeTEA',
    'BUCodeTEL']
) }}


with source_data as
(
    SELECT
		 BUCodeByConfiguration
		,BUCodeTEA
		,BUCodeTEL
		,BUCodeOld_TEA
	FROM {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_BUCODEMAPPING') }}
	WHERE BUCodeByConfiguration IS NOT NULL
)
,default_row as
(
	SELECT
		 BUCodeByConfiguration
		,BUCodeTEL
		,ROW_NUMBER() OVER (PARTITION BY BUCodeByConfiguration ORDER BY BUCodeTEL) RowNumber
	FROM source_data
)
,transform_data as
(
    SELECT
		 source_data.BUCodeByConfiguration
		,source_data.BUCodeTEA
		,source_data.BUCodeTEL
		,source_data.BUCodeOld_TEA
		,CASE
			WHEN default_row.RowNumber = 1 THEN 'Yes'
			ELSE 'No'
		 END AS isDefault
		,'{{ invocation_id }}' AS Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash -- Adds column to table on full refresh.
	FROM source_data
	JOIN default_row
	 ON default_row.BUCodeByConfiguration = source_data.BUCodeByConfiguration
	 AND default_row.BUCodeTEL = source_data.BUCodeTEL
)
,type_data as
(
    select
        cast(BUCODEBYCONFIGURATION as VARCHAR(16777216)) as BUCODEBYCONFIGURATION,
        cast(BUCODETEA as VARCHAR(16777216)) as BUCODETEA,
        cast(BUCODETEL as VARCHAR(16777216)) as BUCODETEL,
        cast(BUCODEOLD_TEA as VARCHAR(16777216)) as BUCODEOLD_TEA,
        cast(ISDEFAULT as VARCHAR(16777216)) as ISDEFAULT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_Row_Hash as varchar(128)) as _Row_Hash
    from transform_data
    )
select * from type_data